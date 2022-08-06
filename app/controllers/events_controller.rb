class EventsController < ApplicationController
  protect_from_forgery
  def index
    # ログインしている教師のコースのレコードを取得
    @courses = current_user.courses.all
    # 上記のレコードでfocus: trueのレコードを取得
    @focus_course = current_user.courses.find_by(focus: true)
    # focus: trueであるコースに属している学生を取得
    @users = @focus_course.users.where(role: "Student")
    # 上記の学生で課題を提出している学生レコードを取得
    @submitted_student = @users.joins(:events).where.not(events: {submitted_time: nil})
    # 課題を提出していない学生レコードを取得
    @not_submitted_student = @users.joins(:events).where(events: {submitted_time: nil})
    # 課題を提出していない学生の人数を代入
    @all_not_submitted_student = @not_submitted_student.count
    # 課題を提出している学生の人数を代入
    @all_submitted_student = @submitted_student.count
    # モニタリングする学生すべての人数
    @all_student = @submitted_student.count + @not_submitted_student.count
    # すべての学生人数を３で割った時の商を取得
    # 例：４÷３＝1.333....の１を@divnum に代入
    @divnum = @all_student.div(3)
    
    # 1/3の学生が提出しているかどうかの処理
    if @divnum <= @all_not_submitted_student
      flash[:notice] = "メッセージが送信されました"
      # redirect_to root_path
    elsif @divnum > @all_not_submitted_student
      flash[:notice] = "メッセージは送信されませんでした"
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
    # 学生，イベントを作成：ロールが学生かつ学生が未作成かつコースが作成済みかつ学生がコースにアクセスした時
    if strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && find_student.nil? && !find_course.nil? && !access_course.nil?
      # 学生を登録
      find_course.users.create(email: stemail, name: stname, password: stid, student_id: stid, role: "Student")
      # イベントを登録
      u_id = User.find_by(student_id: stid)
      Event.create(user_id: u_id.id, course_id: find_course.id, activity_access: access_time)
      puts "Student Created"
    # eventsの更新：ロールが学生かつ学生が作成済みかつコースが作成済みかつ学生がコースにアクセスした時
    elsif strole == "http://purl.imsglobal.org/vocab/lis/v2/membership#Learner" && !find_student.nil? && !find_course.nil? && !access_course.nil?
      # 提出時刻の更新：action#Submittedの時
      if caliper_event["data"][0]["action"] == "http://purl.imsglobal.org/vocab/caliper/v1/action#Submitted"
        activity_name = caliper_event["data"][0]["target"]["name"]
        find_student.events.update(submitted_time: access_time, name: activity_name)
        puts "Update submitted_time"
      # アクセス時刻の更新：action#Submitted以外の時
      elsif caliper_event["data"][0]["action"] != "http://purl.imsglobal.org/vocab/caliper/v1/action#Submitted"
        find_student.events.update(activity_access: access_time)
        puts "Update activity_access"
      end
    else
      puts "Not student or not access course"
    end
  end
end
# erd --attributes=foreign_keys,primary_keys,content,timestamp