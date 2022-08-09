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
        divnum = all_student.div(3)
        # 1/3の学生が提出しているかどうかの処理
        if divnum <= all_not_submitted_student
            not_submitted_student.each_with_index do |user|
                puts "メッセージが送信されました:#{user.name}"
            end
            puts "提出:#{all_submitted_student}人"
            puts "未提出:#{all_not_submitted_student}人"
        elsif divnum > all_not_submitted_student
            puts "メッセージは送信されませんでした"
        #   flash[:notice] = "メッセージは送信されませんでした"
        end
    end
end
