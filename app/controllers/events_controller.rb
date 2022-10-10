class EventsController < ApplicationController
  protect_from_forgery
  require 'net/http'
  require 'uri'
  require 'json'
  def index
    # redirect_to root_path
  end
  
  def send_message(send_activity_name, send_course_code)
    # ログイン中の教師が持つ授業のうち，focus: trueのものをモニタリング
    # コース，アクティビティ，イベントの３つのテーブルを結合
    courses_activities_events = Course.eager_load(activities: :events).where(courses: {focus: true})
    courses_activities_events.each do |course|
      if course.course_code == send_course_code
        course.activities.each do |activity|
          # message1 = "他の学生は#{activity.name}を提出済みです。取り組みましょう。"
          # message2 = "他の学生は#{activity.name}を提出済みです。前回の授業で課題を提出できなかったので今回は提出しましょう。"
          # 提出済み学生のイベント：提出がnilでない学生のレコード
          submitted_user = User.joins(:events).where.not(events: {submitted_time: nil}).where(events: {activity_id: activity.id}).where(events: {course_id: course.id})
          submitted_students = submitted_user.joins(:enrollments).where(enrollments: {role: "Student"})
          submitted_students_num = submitted_students.count
          # 未提出学生のイベント：提出がnilな学生のレコード
          not_submitted_user = course.users.all
          not_submitted_students = not_submitted_user.joins(:enrollments).where(enrollments: {role: "Student"})
          send_message_students = not_submitted_students - submitted_students
          not_submitted_students_all_num = not_submitted_students.count
          not_submitted_students_num = not_submitted_students_all_num - submitted_students_num
          all_students_num = submitted_students_num + not_submitted_students_num
          # 2/3の学生数を取得：すべての学生人数を３で割った時の商を取得
          # 例：４÷３＝1.333....の１をdivnum に代入
          doubled = all_students_num * 2
          divnum = doubled.div(3)
          if divnum <= submitted_students_num && send_activity_name == activity.name
            send_message_students.each do |student|
              # 過去に未提出の課題があるかどうかチェック
              submitted_activities = student.events.distinct.pluck(:activity_id)
              all_activities = Activity.distinct.pluck(:id)
              check_activity = all_activities - submitted_activities
              send_message_activity = []
              check_activity.each do |set_id|
                set = Activity.find_by(id: set_id)
                send_message_activity.push(set.name)
              end
              if check_activity.nil? || send_activity_name == send_message_activity[0]
                message = "他の学生は#{activity.name}を提出済みです。取り組みましょう。"
              else
                message = "他の学生は#{activity.name}を提出済みです。過去に提出できなかった課題があるので今回は提出しましょう。\n\n過去の課題：#{send_message_activity}"
              end
              uri = URI.parse("http://3.89.178.10:8080/users/#{student.student_id}/messages")
              request = Net::HTTP::Post.new(uri)
              request.content_type = "application/json;charaset=utf-8"
              request.body = JSON.dump({
                "message" => {
                  "title" => "#{course.name}の通知",
                  "body" => "【#{course.name}の通知】#{message}",
                  "icon" => "/icon.png"
                }
              })
              
              req_options = {
                use_ssl: uri.scheme == "https",
              }
              response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
                http.request(request)
              end
              puts "メッセージ送信 => #{student.name}"
            end
            puts "提出"
          else
            puts "未提出"
          end
        end
      end
    end
  end

  def create
    # POSTされたCaliper Eventをパース
    caliper_event = JSON.parse(request.body.read)
    # 変数に代入
    # 学生氏名
    stname = caliper_event["data"][0]["actor"]["name"]
    # 統合認証ID取得
    stid = caliper_event["data"][0]["actor"]["name"].slice(0,8)
    # 学生email
    stemail = stid + "@oita-u.ac.jp"
    # ロール＝学生を取得
    strole = caliper_event["data"][0]["membership"]["roles"][0]
    
    access_time = caliper_event["data"][0]["eventTime"]
    # DBからユーザがアクセスしたコースレコードを取得
    access_course = caliper_event["data"][0]["group"]["courseNumber"]
    find_course = Course.find_by(course_code: access_course)
    # 学生が登録されているかどうか探す
    find_student = User.find_by(student_id: stid)
    # 学生，イベントを作成：ロールが学生かつ学生が未作成かつコースが作成済みかつ学生がmoodleにアクセスした時
    if strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && find_student.nil? && !find_course.nil?
      # 学生を登録
      user = User.create(email: stemail, name: stname, password: stid, student_id: stid)
      find_course.users << user
      # イベントを登録
      new_student = User.find_by(student_id: stid)
      new_student.enrollments.update(role: "Student")
      save_event = Event.new(user_id: new_student.id, course_id: find_course.id)
      save_event.save!
      puts "Student Created"
    end
    if strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && caliper_event["data"][0]["action"] == "http://purl.imsglobal.org/vocab/caliper/v1/action#Submitted" && !find_course.nil?
      activity_name = caliper_event["data"][0]["target"]["name"]
      activityid = caliper_event["data"][0]["target"]["@id"]
      act_id = /id=/.match("#{activityid}")
      activity = find_course.activities.find_by(activity_id: "#{act_id.post_match}")
      # 指定したコースにアクティビティが存在しない場合，作成
      if activity.nil?
        activity = find_course.activities.new(name: activity_name, activity_id: "#{act_id.post_match}")
        activity.save!
        Event.create(user_id: find_student.id, submitted_time: access_time, activity_id: activity.id, course_id: find_course.id)
        puts "課題のレコード，提出イベント作成"
      end
      if !activity.nil?
        event_all = find_student.events.all
        event = event_all.find_by(activity_id: activity.id)
        if event.nil?
          Event.create(user_id: find_student.id, submitted_time: access_time, activity_id: activity.id, course_id: find_course.id)
          puts "提出イベント作成"
        else
          event.update(submitted_time: access_time)
          puts "提出イベントアップデート"
        end
      end
      # メッセージを送信するメソッドの呼び出し
      send_message(activity_name, access_course)
      puts "Update submitted time"
    elsif strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && caliper_event["data"][0]["action"] != "http://purl.imsglobal.org/vocab/caliper/v1/action#Submitted" && !find_course.nil?
      find_student = User.find_by(student_id: stid)
      find_student.events.update(activity_access: access_time)
      puts "Update activity access"
    else
      puts "Not student or not access course"
    end
    render status: 200
  end
end
# erd --attributes=foreign_keys,primary_keys,content,timestamp