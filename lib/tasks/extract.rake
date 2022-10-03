namespace :extract do
  desc "５分おきに積極的でない学生を取得，メッセージを送信"
  task student_extract: :environment do
    # ログイン中の教師が持つ授業のうち，focus: trueのものをモニタリング
    @courses = current_user.courses.all
    @find_course = @courses.find_by(focus: true)
    @users = @find_course.users.all
    @students = @users.joins(:enrollments).where(enrollments: {role: "Student"})
    # コース，アクティビティ，イベントの３つのテーブルを結合
    @focus_course = Course.eager_load(activities: :events).where(courses: {id: @find_course.id})
    # @focus_course = Course.eager_load(activities: {events: :users}).where(courses: {id: @find_course.id})
    
    # 提出済み学生：提出がnilでない学生のレコード
    @submit_students = @students.joins(:events).where.not(events: {submitted_time: nil})
    @all_submits = @submit_students.count
    # 未提出学生：提出がnilでない学生のレコード
    @not_submit_students = @students.joins(:events).where(events: {submitted_time: nil})
    @all_not_submits = @not_submit_students.count
    
    # all_not_submits = all_students - all_submits
    # not_submitで前回の授業で提出がなかった学生
    # not_submit_status_true = not_submit.where(status: true)
    # # not_submitで前回の授業の情報がないまたは初めてメッセージ送信がされる学生
    # not_submit_status_false = not_submit.where(status: false)
    
    @all_students = @users.count
    # すべての学生人数を３で割った時の商を取得
    # 例：４÷３＝1.333....の１を@divnum に代入
    @doubled = @all_students * 2
    @divnum = @doubled.div(3)
    
    
    
    @focus_course.each do |course|
      course.activities.each do |activity|
        # events.each_with_index do |event|
        # end
        message1 = "他の学生は#{activity.name}を提出済みです。取り組みましょう。"
        message2 = "他の学生は#{activity.name}を提出済みです。前回の授業で課題を提出できなかったので今回は提出しましょう。"
        
        activity.events.zip(@not_submit_students) do |event, student|
          if @divnum <= @all_submits
          
            uri = URI.parse("http://3.89.178.10:8080/users/#{student.student_id}/messages")
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json;charaset=utf-8"
            request.body = JSON.dump({
              "message" => {
                "title" => "#{corse.name}の通知",
                "body" => "【#{corse.name}の通知】#{message1}",
                "icon" => "/icon.png"
              }
            })
            
            req_options = {
              use_ssl: uri.scheme == "https",
            }
            response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
              http.request(request)
            end
            puts "提出:#{@all_submits}人"
            puts "未提出:#{@all_not_submits}人"
          else
            puts "提出:#{@all_submits}人"
            puts "未提出:#{@all_not_submits}人"
          end
        end
      end
    end
  end
  
  task :send_message, [:student_id, :message, :focus_course] => :environment do |task, args|
    require 'net/http'
    require 'uri'
    require 'json'
    
    focus_course = Course.find_by(focus: true)
    
    focus_course.update(send_message: true)
  end
  
  task reset: :environment do
    focus_course = Course.find_by(focus: true)
    focus_course.update(send_message: false)
    spawn("bundle exec whenever --clear-crontab")
  #   focus_course = Course.find_by(focus: true)
  #   students = focus_course.users.where(role: "Student")
  #   submit = events.joins(students).where.not(name: nil)
  #   submit.update_all(name: nil)
  end
  
  task average_time: :environment do
    focus_course = Course.find_by(focus: true)
    events = focus_course.events.select(:name).where.not(name: nil).distinct
    events.each_with_index do |event|
      array = []
      # submits = Event.where(name: event.name)
      submits = focus_course.events.where(name: event.name)
      # access_time = Event.where(name: event.name)
      submits.each_with_index do |time|
        sub_time = time.submitted_time
        activ_time = time.activity_access
        difference = sub_time - activ_time
        array.push(difference)
        # puts difference
      end
      avr = array.sum.fdiv(array.length)
      puts avr
    end
  end
end
