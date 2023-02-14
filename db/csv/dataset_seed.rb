require "csv"
require 'date'

date = DateTime.new(2015, 1, 1, 9, 0, 0);
default_user = User.create(email: "test@test.com", name: "テストユーザ", password: "test@test.com")

# コース登録
CSV.foreach('db/csv/courses.csv', headers: true) do |row|
    if row["code_module"] == "FFF" && row["code_presentation"] == "2014B"
        @create_course = Course.create(name: row["code_presentation"], focus: true, course_code: row["code_module"])
        @create_course.users << default_user
        default_user.enrollments.update(role: "Teacher")
    end
end

# 学生登録
student_index = 0
CSV.foreach('db/csv/2014B_FFF/studentInfo_2014B_FFF.csv', headers: true) do |row|
    if row["code_module"] == "FFF" && row["code_presentation"] == "2014B"
        @create_student = User.create(name: "Student#{student_index}", email: "student#{student_index}@test.com", password: "student#{student_index}@test.com", student_id: row["id_student"])
        @create_course.users << @create_student
        @create_student.enrollments.update(role: "Student")
        student_index += 1
    end
    if student_index == 50
        break
    end
end

# アクティビティ登録
CSV.foreach('db/csv/2014B_FFF/vle_2014B_FFF.csv', headers: true) do |row|
    act_id = row["id_site"]
    if row["code_module"] == "FFF" && row["code_presentation"] == "2014B" && act_id.to_i > 779070 && act_id.to_i < 779271
        if row["week_from"] != "" && row["week_to"] != ""
            # 〜から
            week_from = row["week_from"]
            # 〜まで
            week_to = row["week_to"]
            @start_time = date + 18 + (week_from.to_i * 7)
            end_time = date + 18 + (week_to.to_i * 7)
            @create_activity = Activity.create(activity_id: row["id_site"], name: row["activity_type"], course_id: @create_course.id, sent_messages: false, date_to_start: @start_time, date_to_submit: end_time)
        end
        @create_activity = Activity.create(activity_id: row["id_site"], name: row["activity_type"], course_id: @create_course.id, sent_messages: false)
    end
end

# # イベント登録
CSV.foreach('db/csv/2014B_FFF/studentVle_2014B_FFF.csv', headers: true) do |row|
    act_id = row["id_site"]
    @find_student = User.find_by(student_id: row["id_student"])
    @find_activity = Activity.find_by(activity_id: row["id_site"])
    
    if !@find_student.nil? && !@find_activity.nil? && act_id.to_i > 779070 && act_id.to_i < 779271
        @find_event = Event.find_by(user_id: @find_student.id, activity_id: @find_activity.id, course_id: @create_course.id)
        if @find_event.nil?
            if @find_activity.date_to_start != nil
                csv_submitted = row["date"]
                submitted = date + 18 + csv_submitted.to_i
                Event.create(user_id: @find_student.id, activity_id: @find_activity.id, course_id: @create_course.id, submitted_time: @start_time, action: "Submitted")
            else
                Event.create(user_id: @find_student.id, activity_id: @find_activity.id, course_id: @create_course.id, action: "Viewed")
            end
        end
    end
end