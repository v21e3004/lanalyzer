namespace :extract do
  desc "５分おきに積極的でない学生を取得，メッセージを送信"
  task student_extract: :environment do
    focus_course = Course.find_by(focus: true)
    students = focus_course.users.where(role: "Student")
    events = focus_course.events.select(:name).where.not(name: nil).distinct
    all_students = students.count
    # すべての学生人数を３で割った時の商を取得
    # 例：４÷３＝1.333....の１を@divnum に代入
    doubled = all_students * 2
    divnum = doubled.div(3)
    
    events.each_with_index do |event|
      message1 = "他の学生は#{event.name}を提出済みです。取り組みましょう。"
      message2 = "他の学生は#{event.name}を提出済みです。前回の授業で課題を提出できなかったので今回は提出しましょう。"
      # 提出学生：イベント毎に提出してる学生レコード
      submits = students.joins(:events).where(events: {name: event.name})
      all_submits = submits.count
      
      # 未提出学生：イベント名がnillまたは対象のイベントの名前がない学生
      not_submit = students.joins(:events).where.not(events: {name: event.name}).or(students.joins(:events).where(events: {name: nil}))
      all_not_submits = all_students - all_submits
      # not_submitで前回の授業で提出がなかった学生
      not_submit_status_true = not_submit.where(status: true)
      # not_submitで前回の授業の情報がないまたは初めてメッセージ送信がされる学生
      not_submit_status_false = not_submit.where(status: false)
      puts "・#{event.name}"
      if divnum <= all_submits && Flag.exists?(send: false)
        # 提出済みで前回提出できなかった学生のstatusをtrueにする
        submits.update_all(status: false)
        puts "メッセージが送信されました"
        puts "提出:#{all_submits}人"
        puts "未提出:#{all_not_submits}人"
        puts "未提出者"
        # 未提出者にメッセージ送信：前回提出したかどうかで場合分け
        # 前回の授業の情報がないまたは初めてメッセージ送信がされる学生
        not_submit_status_false.each_with_index do |user|
          Rake::Task["extract:send_message"].invoke("#{user.student_id}", message1, focus_course.name)
          Rake::Task["extract:send_message"].reenable
          puts "#{user.name}"
        end
        # 前回の授業で課題の提出がなかった学生
        not_submit_status_true.each_with_index do |user|
          Rake::Task["extract:send_message"].invoke("#{user.student_id}", message2, focus_course.name)
          Rake::Task["extract:send_message"].reenable
          puts "#{user.name}"
        end
        not_submit_status_false.update_all(status: true)
      else
        puts "提出:#{all_submits}人"
        puts "未提出:#{all_not_submits}人"
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
        "body" => "【#{args.focus_course}の通知】#{args.message}",
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
  
  task reset: :environment do
    flag = Flag.find(1)
    flag.update(send: false)
  #   focus_course = Course.find_by(focus: true)
  #   students = focus_course.users.where(role: "Student")
  #   submit = events.joins(students).where.not(name: nil)
  #   submit.update_all(name: nil)
  end
  
  task average_time: :environment do
    focus_course = Course.find_by(focus: true)
    students = focus_course.users.where(role: "Student")
    events = focus_course.events.select(:name).where.not(name: nil).distinct
    events.each_with_index do |event|
      array = []
      submits = Event.where(name: event.name)
      # access_time = Event.where(name: event.name)
      submits.each_with_index do |time|
        sub_time = time.submitted_time
        activ_time = time.activity_access
        difference = sub_time - activ_time
        array.push(difference)
      end
      avr = array.sum.fdiv(array.length)
      puts avr
    end
  end
end
