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
      message = "他の学生は#{event.name}を提出済みです．取り組みましょう．"
      submit = users.joins(:events).where(events: {name: event.name})
      not_submit = users.joins(:events).where.not(events: {name: event.name}).or(users.joins(:events).where(events: {name: nil}))
      all_submit = submit.count
      all_not_submit = all_student - all_submit
      puts "・#{event.name}"
      if divnum <= all_submit && Flag.exists?(send: false)
        puts "メッセージが送信されました"
        puts "提出:#{all_submit}人"
        puts "未提出:#{all_not_submit}人"
        puts "未提出者"
        not_submit.each_with_index do |user|
          Rake::Task["extract:send_message"].invoke("#{user.student_id}", message, focus_course.name)
          Rake::Task["extract:send_message"].reenable
          puts "#{user.name}"
          # sleep 2
        end
      else
        puts "提出:#{all_submit}人"
        puts "未提出:#{all_not_submit}人"
      end
    end
  end
  
  task :send_message, [:student_id, :message, :focus_course] => :environment do |task, args|
    require 'net/http'
    require 'uri'
    require 'json'
    uri = URI.parse("http://3.89.178.10:8080/users/#{args.student_id}/messages")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json;charaset=utf-8"
    request.body = JSON.dump({
      "message" => {
        "title" => "#{args.focus_course}の通知",
        "body" => "【#{args.focus_course}】#{args.message}",
        "icon" => "/icon.png"
      }
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
