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
# ユーザ登録
@default_user = User.new(email: "test@gmail.com", name: "テストユーザ", password: "test@gmail.com", role: "Teacher")
@default_user.save
@course1.users << @default_user
@course2.users << @default_user

Flag.create(send: false)

# 課題提出済み
@user1 = User.new(email: "v00e0001@oita-u.ac.jp", name: "v00e0001 student1", password: "v00e0001", role: "Student", student_id: "v00e0001")
@user1.save
Event.create(name: "テキスト課題", user_id: @user1.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
@course1.users << @user1

@user2 = User.new(email: "v00e0002@oita-u.ac.jp", name: "v00e0002 student2", password: "v00e0002", role: "Student", student_id: "v00e0002")
@user2.save
Event.create(name: "テキスト課題", user_id: @user2.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
@course1.users << @user2

# @user3 = User.new(email: "v00e0003@oita-u.ac.jp", name: "v00e0003 student3", password: "v00e0003", role: "Student", student_id: "v00e0003")
# @user3.save
# Event.create(name: "テキスト課題1", user_id: @user3.id, course_id: @course2.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
# @course2.users << @user3

# @user4 = User.new(email: "v00e0004@oita-u.ac.jp", name: "v00e0004 student4", password: "v00e0004", role: "Student", student_id: "v00e0004")
# @user4.save
# Event.create(name: "テキスト課題1", user_id: @user4.id, course_id: @course2.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
# # , submitted_time: "2022-07-18 01:00:00"
# @course2.users << @user4

# @user5 = User.new(email: "v00e0005@oita-u.ac.jp", name: "v00e0005 student5", password: "v00e0005", role: "Student", student_id: "v00e0005")
# @user5.save
# Event.create(name: "テキスト課題1", user_id: @user5.id, course_id: @course2.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
# @course2.users << @user5

# @user6 = User.new(email: "v00e0006@oita-u.ac.jp", name: "v00e0006 student6", password: "v00e0006", role: "Student", student_id: "v00e0006")
# @user6.save
# Event.create(name: "テキスト課題1", user_id: @user6.id, course_id: @course2.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
# @course2.users << @user6

# @user7 = User.new(email: "v00e0007@oita-u.ac.jp", name: "v00e0007 student7", password: "v00e0007", role: "Student", student_id: "v00e0007")
# @user7.save
# Event.create(name: "テキスト課題1", user_id: @user7.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
# # , submitted_time: "2022-07-18 01:00:00"
# @course1.users << @user7


# 課題未提出
@user11 = User.new(email: "v00e0011@oita-u.ac.jp", name: "v00e0011 student11", password: "v00e0011", role: "Student", student_id: "v00e0011")
@user11.save
Event.create(user_id: @user11.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00")
@course1.users << @user11

@user12 = User.new(email: "v00e0012@oita-u.ac.jp", name: "v00e0012 student12", password: "v00e0012", role: "Student", student_id: "v00e0012")
@user12.save
Event.create(user_id: @user12.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00")
@course1.users << @user12

@user13 = User.new(email: "v00e0013@oita-u.ac.jp", name: "v00e0013 student13", password: "v00e0013", role: "Student", student_id: "v00e0013")
@user13.save
Event.create(user_id: @user13.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00")
@course1.users << @user13

