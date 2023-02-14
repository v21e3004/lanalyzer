class LogisticRegressionController < ApplicationController
  require 'matrix'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'openssl'

  ALPHA = 0.01      # 学習率
  EPS   = 1.0e-12   # 閾値
  LOOP  = 10000000  # 最大ループ回数
  OMEGA  = 5.0       # 初期値: ω
  CEL   = 0.0       # 初期値: 交差エントロピー誤差
  
  def reg_logistic(calc_matrix)
    # 元の数, サンプル数
    e = calc_matrix.column_size - 1
    n = calc_matrix.row_size
    # 自身 Matrix が空の場合は例外スロー
    raise "Self array is nil!" if calc_matrix.empty?
    # β初期値 (1 行 e + 1 列)
    bs = Matrix.build(1, e + 1) { |_| OMEGA }
    # X の行列 (n 行 e 列)
    # (第1列(x_0)は定数項なので 1 固定)
    xs = Matrix.hstack(Matrix.build(n, 1) { 1 }, calc_matrix.minor(0, n, 0, e))
    # t の行列 (n 行 1 列)
    ts = calc_matrix.minor(0, n, e, 1)
    # 交差エントロピー誤差初期値
    loss = CEL
    LOOP.times do |i|
      #puts "i=#{i}"
      # シグモイド関数適用（予測値計算）
      ys = sigmoid(xs * bs.transpose)
      # dE 計算
      des = (ys - ts).transpose * xs / n
      # β 更新
      bs -= ALPHA * des
      # 前回算出交差エントロピー誤差退避
      loss_pre = loss
      # 交差エントロピー誤差計算
      loss = cross_entropy_loss(ts, ys)
      # 今回と前回の交差エントロピー誤差の差が閾値以下になったら終了
      break if (loss - loss_pre).abs < EPS
    end
    return bs
  end

  # シグモイド関数
  def sigmoid(x)
    return x.map { |a| 1.0 / (1.0 + Math.exp(-a)) }
  rescue => e
    raise
  end

  # 交差エントロピー誤差関数
  def cross_entropy_loss(ts, ys)
    return ts.zip(ys).map { |t, y|
      t * Math.log(y) + (1.0 - t) * Math.log(1.0 - y)
    }.sum
  rescue => e
    raise
  end
  
  # x学習ログの正規化(submitのみ)
  def normalization_x(receive_course)
    users_array = []
    course = Course.find_by(id: receive_course.id)
    users = course.users.all
    students = users.joins(:enrollments).where(enrollments: {role: "Student"})
    all_activities = course.activities.where.not(date_to_submit: nil).where.not(date_to_start: nil)
    # 分母
    denominator = all_activities.count
    students.each do |student|
      student_activities = student.events.where(action: "Submitted")
      numerator = student_activities.count
      result = ((numerator.to_f / denominator.to_f) * 100.0).to_f
      users_array.push(result.to_i)
    end
    return users_array
  end
  
  # y学習ログの正規化(viewのみ)
  def normalization_y(receive_course)
    users_array = []
    course = Course.find_by(id: receive_course.id)
    users = course.users.all
    students = users.joins(:enrollments).where(enrollments: {role: "Student"})
    all_activities = course.activities.where(date_to_submit: nil).where(date_to_start: nil)
    # 分母
    denominator = all_activities.count
    students.each do |student|
      student_activities = student.events.where(action: "Viewed")
      numerator = student_activities.count
      result = ((numerator.to_f / denominator.to_f) * 100.0).to_f
      users_array.push(result.to_i)
    end
    return users_array
  end
  
  # p(probability)学習ログの正規化
  def normalization_p(receive_course)
    users_array = []
    course = Course.find_by(id: receive_course.id)
    users = course.users.all
    students = users.joins(:enrollments).where(enrollments: {role: "Student"})
    all_activities = course.activities.where.not(date_to_submit: nil).where.not(date_to_start: nil)
    # latest_activities = all_activities[-2]
    latest_activities = course.activities.find_by(activity_id: 779270)
    students.each do |student|
      student_activities = student.events.find_by(activity_id: latest_activities.id)
      if student_activities.nil?
        users_array.push(0)
      else
        users_array.push(1)
      end
    end
    return users_array
  end
  
  def create_matrix(receive_course)
    @data = Matrix[]
    x_array = normalization_x(receive_course)
    y_array = normalization_y(receive_course)
    p_array = normalization_p(receive_course)
    @data = Matrix.rows([x_array, y_array, p_array]).transpose
    return @data
  end
  
  def request_to_potify(student_id, sendername, message)
    uri = URI.parse("http://3.89.178.10:8080/users/#{student_id}/messages")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json;charaset=utf-8"
    request.body = JSON.dump({
      "message" => {
        "title" => "#{sendername}の通知",
        "body" => "【#{sendername}の通知】\n#{message}\n\nMessage Created by LAnalyzer",
        "icon" => "/icon.png"
      }
    })
    
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    puts "メッセージ送信 => #{student_id}"
  end
  
  #Submitアクティビティが新しく登録された際に実行
  def calc
    # 説明(独立)変数と目的(従属)変数
    # （ e.g.  n 行 3 列 (x, y..., p) )
    # 引数c:計算を行うコース，引数a:新しく追加された期限あり課題
    course = Course.find(params[:id])
    users = course.users.all
    students = users.joins(:enrollments).where(enrollments: {role: "Student"})
    message = "#{course.name}に期限ありの課題が追加されました。提出時刻を確認し、取り組みましょう。"
    x_array = normalization_x(course)
    y_array = normalization_y(course)
    create_matrix(course)
    puts "data ="
    @data.to_a.each { |row| p row }
    # ロジスティック回帰式の定数・係数計算(o0, o1, o2, ...)
    puts "\nNow computing...\n\n"
    reg_logistic = reg_logistic(@data)
    omegas = reg_logistic.to_a
    omegas = omegas.flatten
    puts "omegas = "
    p omegas
    students.each_with_index do |student, i|
      percent = 1.0 / (1.0 + Math.exp(-1 * (omegas[0] + (omegas[1] * x_array[i]) + (omegas[2] * y_array[i]))))
      if percent >= 0.5 && percent < 1
        puts "メッセージ送信"
        p student.name
        p percent.to_i
        request_to_potify(student.student_id, course.name, message)
      elsif percent < 0.5 && percent > 0 && percent >= 1
        puts "未送信"
      else
      end
    end
  end
  private :sigmoid, :cross_entropy_loss
end
