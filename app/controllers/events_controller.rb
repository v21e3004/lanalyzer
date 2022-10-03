class EventsController < ApplicationController
  protect_from_forgery
  require 'net/http'
  require 'uri'
  require 'json'
  def index
    # ログイン中の教師が持つ授業のうち，focus: trueのものをモニタリング
    @courses = current_user.courses.all
    @find_course = @courses.find_by(focus: true)
    @users = @find_course.users.all
    @students = @users.joins(:enrollments).where(enrollments: {role: "Student"})
    # コース，アクティビティ，イベントの３つのテーブルを結合
    @focus_course = Course.eager_load(activities: :events).where(courses: {id: @find_course.id})
    # @focus_course = Course.eager_load(activities: {events: :users}).where(courses: {id: @find_course.id})
    # 未提出学生：提出がnilな学生のレコード
    @not_submit_students = @students.joins(:events).where(events: {submitted_time: nil})
    @all_not_submits = @not_submit_students.count
    
    # all_not_submits = all_students - all_submits
    # not_submitで前回の授業で提出がなかった学生
    # not_submit_status_true = not_submit.where(status: true)
    # # not_submitで前回の授業の情報がないまたは初めてメッセージ送信がされる学生
    # not_submit_status_false = not_submit.where(status: false)
    
    @all_students = @students.count
    # すべての学生人数を３で割った時の商を取得
    # 例：４÷３＝1.333....の１を@divnum に代入
    @doubled = @all_students * 2
    @divnum = @doubled.div(3)
    
    
    @focus_course.each do |course|
      course.activities.each do |activity|
        message1 = "他の学生は#{activity.name}を提出済みです。取り組みましょう。"
        message2 = "他の学生は#{activity.name}を提出済みです。前回の授業で課題を提出できなかったので今回は提出しましょう。"
        # 提出済み学生：提出がnilでない学生のレコード
        @submit_students = activity.events.where.not(submitted_time: nil)
        @all_submits = @submit_students.count
        if @divnum <= @all_submits
          @not_submit_students.each do |student|
            uri = URI.parse("http://3.89.178.10:8080/users/#{student.student_id}/messages")
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json;charaset=utf-8"
            request.body = JSON.dump({
              "message" => {
                "title" => "#{course.name}の通知",
                "body" => "【#{course.name}の通知】#{student.name}さん、#{message1}",
                "icon" => "/icon.png"
              }
            })
            
            req_options = {
              use_ssl: uri.scheme == "https",
            }
            response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
              http.request(request)
            end
          end
          puts "#{activity.name}"
          puts "提出:#{@all_submits}人"
          puts "未提出:#{@all_not_submits}人"
        else
          puts "提出:#{@all_submits}人"
          puts "未提出:#{@all_not_submits}人"
          # break
        end
        # end
      end
    end
    # redirect_to root_path
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
    @find_course = Course.find_by(course_code: access_course)
    # 学生が登録されているかどうか探す
    @find_student = User.find_by(student_id: stid)
    # @event = @find_student.events.find_by(user_id: @find_student.id)
    # 
    # 学生，イベントを作成：ロールが学生かつ学生が未作成かつコースが作成済みかつ学生がmoodleにアクセスした時
    if strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && @find_student.nil? && !@find_course.nil?
      # 学生を登録
      @find_course.users.create(email: stemail, name: stname, password: stid, student_id: stid, role: "Student")
      # イベントを登録
      @new_student = User.find_by(student_id: stid)
      @new_student.enrollments.update(role: "Student")
      @save_event = Event.new(user_id: @new_student.id, course_id: @find_course.id, activity_access: access_time)
      @save_event.save
      puts "Student Created"
    end
    
    if strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && caliper_event["data"][0]["action"] == "http://purl.imsglobal.org/vocab/caliper/v1/action#Submitted" && !@find_course.nil?
      @find_student = User.find_by(student_id: stid)
      activity_name = caliper_event["data"][0]["target"]["name"]
      activityid = caliper_event["data"][0]["target"]["@id"]
      act_id = /id=/.match("#{activityid}")
      # ac_id = act_id.post_match
      @activity = @find_course.activities.find_by(activity_id: "#{act_id.post_match}")
      # 指定したコースにアクティビティが存在しない場合，作成
      if @activity.nil?
        @activity = @find_course.activities.new(name: activity_name, activity_id: activityid)
        @activity.save
      end
      # act_id = activity_id.slice((activity_id.length - 2), 2) || activity_id
      # 課題の提出があった際
      @find_student.events.update(submitted_time: access_time, activity_id: @activity.id)
      
      # ----------------------------------------------------------------------------------------------------
      # redirect_to url_for(:controller => :events, :action => :index)
      redirect_to action: :index
      # render :send_message
      # ----------------------------------------------------------------------------------------------------
      
      puts "Update submitted_time"
    elsif strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && caliper_event["data"][0]["action"] != "http://purl.imsglobal.org/vocab/caliper/v1/action#Submitted" && !@find_course.nil?
      @find_student = User.find_by(student_id: stid)
      @find_student.events.update(activity_access: access_time)
      puts "Update activity_access"
    else
      puts "Not student or not access course"
    end
    
  end
  
  def send_message
    # ログイン中の教師が持つ授業のうち，focus: trueのものをモニタリング
    @courses = current_user.courses.all
    @find_course = @courses.find_by(focus: true)
    @users = @find_course.users.all
    @students = @users.joins(:enrollments).where(enrollments: {role: "Student"})
    # コース，アクティビティ，イベントの３つのテーブルを結合
    @focus_course = Course.eager_load(activities: :events).where(courses: {id: @find_course.id})
    # @focus_course = Course.eager_load(activities: {events: :users}).where(courses: {id: @find_course.id})
    # 未提出学生：提出がnilな学生のレコード
    @not_submit_students = @students.joins(:events).where(events: {submitted_time: nil})
    @all_not_submits = @not_submit_students.count
    
    # all_not_submits = all_students - all_submits
    # not_submitで前回の授業で提出がなかった学生
    # not_submit_status_true = not_submit.where(status: true)
    # # not_submitで前回の授業の情報がないまたは初めてメッセージ送信がされる学生
    # not_submit_status_false = not_submit.where(status: false)
    
    @all_students = @students.count
    # すべての学生人数を３で割った時の商を取得
    # 例：４÷３＝1.333....の１を@divnum に代入
    @doubled = @all_students * 2
    @divnum = @doubled.div(3)
    
    
    @focus_course.each do |course|
      course.activities.each do |activity|
        message1 = "他の学生は#{activity.name}を提出済みです。取り組みましょう。"
        message2 = "他の学生は#{activity.name}を提出済みです。前回の授業で課題を提出できなかったので今回は提出しましょう。"
        # 提出済み学生：提出がnilでない学生のレコード
        @submit_students = activity.events.where.not(submitted_time: nil)
        @all_submits = @submit_students.count
        if @divnum <= @all_submits
          @not_submit_students.each do |student|
            uri = URI.parse("http://3.89.178.10:8080/users/#{student.student_id}/messages")
            request = Net::HTTP::Post.new(uri)
            request.content_type = "application/json;charaset=utf-8"
            request.body = JSON.dump({
              "message" => {
                "title" => "#{course.name}の通知",
                "body" => "【#{course.name}の通知】#{student.name}さん、#{message1}",
                "icon" => "/icon.png"
              }
            })
            
            req_options = {
              use_ssl: uri.scheme == "https",
            }
            response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
              http.request(request)
            end
          end
          puts "#{activity.name}"
          puts "提出:#{@all_submits}人"
          puts "未提出:#{@all_not_submits}人"
        else
          puts "提出:#{@all_submits}人"
          puts "未提出:#{@all_not_submits}人"
          # break
        end
        # end
      end
    end
  end
end
# erd --attributes=foreign_keys,primary_keys,content,timestamp