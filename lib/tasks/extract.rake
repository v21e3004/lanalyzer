namespace :extract do
  desc "５分おきに積極的でない学生を取得，メッセージを送信"
  task student_extract: :environment do
    focus_course = Course.find_by(focus: true)
    users = focus_course.users.where(role: "Student")
    events = focus_course.events.select(:name).where.not(name: nil).distinct
    all_student = users.count
    # すべての学生人数を３で割った時の商を取得
    # 例：４÷３＝1.333....の１を@divnum に代入
    doubled = all_student * 2
    divnum = doubled.div(3)
    
    events.each_with_index do |event|
      submit = users.joins(:events).where(events: {name: event.name})
      not_submit = users.joins(:events).where.not(events: {name: event.name}).or(users.joins(:events).where(events: {name: nil}))
      all_submit = submit.count
      all_not_submit = all_student - all_submit
      puts "・#{event.name}"
      if divnum <= all_submit
        puts "提出:#{all_submit}人"
        puts "未提出:#{all_not_submit}人"
        puts "未提出者"
        not_submit.each_with_index do |user|
          puts "#{user.name}"
        end
        if Flag.exists?(send: false)
          puts "メッセージが送信されました"
          Rake::Task["extract:send_message"].invoke
        end
      elsif divnum > all_submit
      puts "提出:#{all_submit}人"
      puts "未提出:#{all_not_submit}人"
      end
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
