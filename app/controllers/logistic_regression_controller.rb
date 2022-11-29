class LogisticRegressionController < ApplicationController
  require 'matrix'

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
  
  def index
    # 説明(独立)変数と目的(従属)変数
    # （ e.g.  n 行 3 列 (x1, x2..., y) )
    # data = Matrix[
    #   [30, 21, 0],
    #   [22, 10, 0],
    #   [26, 25, 0],
    #   [14, 20, 0],
    #   [ 6, 10, 1],
    #   [ 2, 15, 1],
    #   [ 6,  5, 1],
    #   [10,  5, 1],
    #   [19, 15, 1]
    # ]

    data = Matrix[
      [0, 0, 0, 0],
      [0, 20, 12, 0],
      [0, 40, 12, 0],
      [13, 30, 100, 0],
      [10, 30, 15, 0],
      [28, 20, 15, 0],
      [27, 30, 16, 0],
      [29, 30, 16, 0],
      [32, 50, 18, 0],
      [41, 20, 22, 0],
      [30, 100, 97, 0],
      [31, 100, 26, 0],
      [55, 40, 27, 0],
      [41, 100, 29, 0],
      [69, 70, 41, 0],
      [33, 100, 22, 1],
      [69, 100, 41, 1],
      [76, 90, 52, 1],
      [74, 100, 25, 1],
      [78, 80, 66, 1],
      [77, 100, 67, 1],
      [79, 100, 70, 1],
      [83, 100, 71, 1],
      [86, 100, 75, 1],
      [88, 100, 82, 1],
      [90, 100, 74, 1]
    ]
    puts "data ="
    data.to_a.each { |row| p row }
    
    # ロジスティック回帰式の定数・係数計算(o0, o1, o2, ...)
    puts "\nNow computing...\n\n"
    reg_logistic = reg_logistic(data)
    # reg_logistic = data.reg_logistic
    puts "omegas = "
    p reg_logistic.to_a
    @view = reg_logistic.to_a
  end
  private :sigmoid, :cross_entropy_loss
end
