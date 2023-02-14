class EventsController < ApplicationController
  protect_from_forgery
  require 'net/http'
  require 'uri'
  require 'json'
  require 'openssl'
  
  def index
    send_summary_at_teacher()
  end
  
  def response_success
    render status: 200, json: { status: 200, message: "Success" }
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
  
  # LogStoreのエンドポイント，必要なログをDBに保存
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
  
    # 学生がモニタリング拒否しているかどうか
    if !find_student.nil? && !find_course.nil?
      monitoring_course = Enrollment.find_by(user_id: find_student.id, course_id: find_course.id)
    end
    # 学生がモニタリング拒否しているかどうか
    if !monitoring_course.nil? && monitoring_course.monitoring == false
      puts "Monitaring deney"
      response_success()
    else
        # 学生，イベントを作成：ロールが学生かつ学生が未作成かつコースが作成済みかつ学生がmoodleにアクセスした時
      if strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && find_student.nil? && !find_course.nil?
        # 学生を登録
        user = User.create(email: stemail, name: stname, password: stid, student_id: stid)
        find_course.users << user
        # イベントを登録
        new_student = User.find_by(student_id: stid)
        new_student.enrollments.update(role: "Student")
        save_event = Event.new(user_id: new_student.id, course_id: find_course.id, action: "Access")
        save_event.save!
        puts "Student Created"
      end
      # action#Submittedの場合
      if strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && caliper_event["data"][0]["action"] == "http://purl.imsglobal.org/vocab/caliper/v1/action#Submitted" && !find_course.nil?
        activity_name = caliper_event["data"][0]["target"]["name"]
        activityid = caliper_event["data"][0]["target"]["@id"]
        act_id = /id=/.match("#{activityid}")
        activity = find_course.activities.find_by(activity_id: "#{act_id.post_match}")
        # 指定したコースにアクティビティが存在しない場合，作成
        if activity.nil?
          activity = find_course.activities.new(name: activity_name, activity_id: "#{act_id.post_match}", sent_messages: false)
          activity.save!
          Event.create(user_id: find_student.id, submitted_time: access_time, activity_id: activity.id, course_id: find_course.id)
          puts "課題のレコード，提出イベント作成"
        end
        if !activity.nil?
          event_all = find_student.events.all
          event = event_all.find_by(activity_id: activity.id)
          if event.nil?
            Event.create(user_id: find_student.id, submitted_time: access_time, activity_id: activity.id, course_id: find_course.id, action: "Submitted")
            puts "提出イベント作成"
            # 新しい期限付き課題作成と同時にロジスティック回帰モデルでωを計算
            submitted_activities = find_course.activities.where.not(date_to_submit: nil).where.not(date_to_start: nil)
            submitted_activities_num = submitted_activities.count
            if submitted_activities_num > 1
              redirect_to "logistic_regression/#{find_course.id}", method: :get
            end
          else
            event.update(submitted_time: access_time, action: "Submitted")
            puts "提出イベントアップデート"
          end
        end
        puts "Update submitted time"
        # action#Viewedの場合
      elsif strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && caliper_event["data"][0]["action"] == "http://purl.imsglobal.org/vocab/caliper/v1/action#Viewed" && !find_course.nil?
        activity_name = caliper_event["data"][0]["object"]["name"]
        activity = find_course.activities.find_by(name: activity_name)
        # 指定したコースにアクティビティが存在しない場合，作成
        if activity.nil?
          activity = find_course.activities.new(name: activity_name, sent_messages: false)
          activity.save!
          Event.create(user_id: find_student.id, submitted_time: access_time, activity_id: activity.id, course_id: find_course.id, action: "Viewed")
          puts "アクティビティ作成，viewedイベント作成"
        end
        if !activity.nil?
          event_all = find_student.events.all
          event = event_all.find_by(activity_id: activity.id)
          if event.nil?
            Event.create(user_id: find_student.id, submitted_time: access_time, activity_id: activity.id, course_id: find_course.id, action: "Viewed")
            puts "Viewedイベント作成"
          else
            event.update(submitted_time: access_time)
            puts "Viewedイベントアップデート"
          end
        end
        puts "Update view time"
      elsif strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && caliper_event["data"][0]["action"] != "http://purl.imsglobal.org/vocab/caliper/v1/action#Submitted" && caliper_event["data"][0]["action"] != "http://purl.imsglobal.org/vocab/caliper/v1/action#Viewed" && !find_course.nil?
        find_student = User.find_by(student_id: stid)
        find_student.events.update(submitted_time: access_time, action: "Access")
        puts "Update activity access"
      else
        puts "Not student or not access course"
      end
      response_success()
    end
  end
end
# erd --attributes=foreign_keys,primary_keys,content,timestamp