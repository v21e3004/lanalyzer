# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# コース登録
@course1 = Course.new(name: "テストコース１", course_code: "AA0001", focus: true)
@course1.save

@course2 = Course.new(name: "テストコース２", course_code: "AA0002", focus: false)
@course2.save

# アクティビティ追加
@activity1 = Activity.create(name: "課題１", activity_id: 11, course_id: @course1.id)
@activity2 = Activity.create(name: "演習課題", activity_id: 17, course_id: @course1.id)
@activity3 = Activity.create(name: "テスト", activity_id: 1, course_id: @course2.id)
# 
# ユーザ登録
@default_user = User.new(email: "test@test.com", name: "テストユーザ", password: "test@test.com")
@default_user.save
@course1.users << @default_user
@course2.users << @default_user
@default_user.enrollments.update(role: "Teacher")

# 課題提出済み
@user1 = User.new(email: "v00e0001@oita-u.ac.jp", name: "v00e0001 student1", password: "v00e0001", student_id: "v00e0001")
@user1.save
@event1 = Event.create(user_id: @user1.id, activity_id: @activity1.id, submitted_time: "2022-07-11 00:32:32", course_id: @course1.id)
@event11 = Event.create(user_id: @user1.id, activity_id: @activity2.id, submitted_time: "2022-07-11 00:32:32", course_id: @course1.id)
@course1.users << @user1
@user1.enrollments.update(role: "Student")

@user2 = User.new(email: "v00e0002@oita-u.ac.jp", name: "v00e0002 student2", password: "v00e0002", student_id: "v00e0002")
@user2.save
@event2 = Event.create(user_id: @user2.id, activity_id: @activity1.id, submitted_time: "2022-07-12 00:59:23", course_id: @course1.id)
@event22 = Event.create(user_id: @user2.id, activity_id: @activity2.id, submitted_time: "2022-07-12 00:32:32", course_id: @course1.id)
@course1.users << @user2
@user2.enrollments.update(role: "Student")

# @user3 = User.new(email: "v00e0003@oita-u.ac.jp", name: "v00e0003 student3", password: "v00e0003", student_id: "v00e0003")
# @user3.save
# @event3 = Event.create(user_id: @user3.id, activity_access: "2022-07-18 00:00:00", activity_id: @activity1.id, submitted_time: "2022-07-18 01:00:00", course_id: @course1.id)
# @event33 = Event.create(user_id: @user3.id, activity_access: "2022-07-18 00:00:00", activity_id: @activity2.id, submitted_time: "2022-07-18 00:32:32", course_id: @course1.id)
# @course1.users << @user3
# @user3.enrollments.update(role: "Student")

@user4 = User.new(email: "v00e0004@oita-u.ac.jp", name: "v00e0004 student4", password: "v00e0004", student_id: "v00e0004")
@user4.save
@event4 = Event.create(user_id: @user4.id, activity_id: @activity1.id, submitted_time: "2022-07-14 01:00:00", course_id: @course1.id)
@event44 = Event.create(user_id: @user4.id, activity_id: @activity2.id, submitted_time: "2022-07-14 00:32:32", course_id: @course1.id)
@course1.users << @user4
@user4.enrollments.update(role: "Student")





# @user5 = User.new(email: "v00e0005@oita-u.ac.jp", name: "v00e0005 student5", password: "v00e0005", student_id: "v00e0005")
# @user5.save
# @event5 = Event.create(user_id: @user5.id, activity_id: @activity3.id, submitted_time: "2022-07-12 00:59:23", course_id: @course2.id)
# @course2.users << @user5
# @user5.enrollments.update(role: "Student")

# @user6 = User.new(email: "v00e0006@oita-u.ac.jp", name: "v00e0006 student6", password: "v00e0006", student_id: "v00e0006")
# @user6.save
# @event6 = Event.create(user_id: @user6.id, activity_id: @activity3.id, submitted_time: "2022-07-12 00:59:23", course_id: @course2.id)
# @course2.users << @user6
# @user6.enrollments.update(role: "Student")

# @user7 = User.new(email: "v00e0007@oita-u.ac.jp", name: "v00e0007 student7", password: "v00e0007", student_id: "v00e0007")
# @user7.save
# @event7 = Event.create(user_id: @user7.id, activity_id: @activity3.id, submitted_time: "2022-07-12 00:59:23", course_id: @course2.id)
# @course2.users << @user7
# @user7.enrollments.update(role: "Student")




# 課題未提出
@user11 = User.new(email: "v00e0011@oita-u.ac.jp", name: "v00e0011 student11", password: "v00e0011", student_id: "v00e0011")
@user11.save
@event11 = Event.create(user_id: @user11.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00",)
Event.create(user_id: @user11.id, activity_id: @activity3.id, submitted_time: "2022-07-18 01:00:00", course_id: @course1.id)
@course1.users << @user11
@user11.enrollments.update(role: "Student")

# @user12 = User.new(email: "v00e0012@oita-u.ac.jp", name: "v00e0012 student12", password: "v00e0012", student_id: "v00e0012")
# @user12.save
# @event12 = Event.create(user_id: @user12.id, course_id: @course1.id)
# @course1.users << @user12
# @user12.enrollments.update(role: "Student")

# @user13 = User.new(email: "v00e0013@oita-u.ac.jp", name: "v00e0013 student13", password: "v00e0013", student_id: "v00e0013")
# @user13.save
# @event13 = Event.create(user_id: @user13.id, course_id: @course2.id)
# @course2.users << @user13
# @user13.enrollments.update(role: "Student")


