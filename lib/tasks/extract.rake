namespace :extract do
  desc "５分おきに積極的でない学生を取得"
  task student_extract: :environment do
    # ログインしている教師のコースのレコードを取得
    # courses = current_user.courses.all
    # 上記のレコードでfocus: trueのレコードを取得
    # focus_course = current_user.courses.find_by(focus: true)
    focus_course = Course.find_by(focus: true)
    # focus: trueであるコースに属している学生を取得
    users = focus_course.users.where(role: "Student")
    # 上記の学生で課題を提出している学生レコードを取得
    submitted_student = users.joins(:events).where.not(events: {submitted_time: nil})
    # 課題を提出していない学生レコードを取得
    not_submitted_student = users.joins(:events).where(events: {submitted_time: nil})
    # 課題を提出していない学生の人数を代入
    all_not_submitted_student = not_submitted_student.count
    # 課題を提出している学生の人数を代入
    all_submitted_student = submitted_student.count
    # モニタリングする学生すべての人数
    all_student = submitted_student.count + not_submitted_student.count
    # すべての学生人数を３で割った時の商を取得
    # 例：４÷３＝1.333....の１を@divnum に代入
    divnum = all_student.div(3) * 2
    # 1/3の学生が提出しているかどうかの処理
    if divnum <= all_submitted_student
      puts "提出:#{all_submitted_student}人"
      puts "未提出:#{all_not_submitted_student}人"
      puts "未提出者"
      not_submitted_student.each_with_index do |user|
        puts "#{user.name}"
      end
      if Flag.exists?(send: false)
        puts "メッセージが送信されました"
        Rake::Task["extract:send_message"].invoke
      end
    elsif divnum > all_submitted_student
      puts "提出:#{all_submitted_student}人"
      puts "未提出:#{all_not_submitted_student}人"
    #   flash[:notice] = "メッセージは送信されませんでした"
    end
  end
  task send_message: :environment do
    require 'net/http'
    require 'uri'
    require 'json'
    # チャネルアクセストークン発行
    body = "grant_type=" + URI.encode("client_credentials") + "&" + "client_id=1655422613" + "&" + "client_secret=2e0fb243bbcf66ccde62506615f280c2"
    uri = URI.parse("https://api.line.me/v2/oauth/accessToken")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded"
    request.body = body
      req_options = {
        use_ssl: uri.scheme == "https",
      }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    result = JSON.parse(response.body)
    #render :json => result
    #プッシュメッセージ送信
    uri = URI.parse("https://api.line.me/v2/bot/message/push")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer " + result["access_token"]
    request.body = JSON.dump({
      "to" => "U570cf8973ed4c6ae2a4292bf8b997e54",
        "messages" => [
          {
            "type" => "text",
            "text" => "テスト"
          }
        ]
    })
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
    end
    flag = Flag.find(1)
    flag.update(send: true)
  end
  task reset_flag: :environment do
    flag = Flag.find(1)
    flag.update(send: false)
  end
end
