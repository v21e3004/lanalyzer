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

@user1 = User.new(email: "v00e0001@oita-u.ac.jp", name: "v00e0001 student1", password: "v00e0001", role: "Student", student_id: "v00e0001")
@user1.save
Event.create(name: "テキスト課題２", user_id: @user1.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
@course1.users << @user1

@user2 = User.new(email: "v00e0002@oita-u.ac.jp", name: "v00e0002 student2", password: "v00e0002", role: "Student", student_id: "v00e0002")
@user2.save
Event.create(name: "テキスト課題２", user_id: @user2.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00")
# , submitted_time: "2022-07-18 01:00:00"
@course1.users << @user2

@user3 = User.new(email: "v00e0003@oita-u.ac.jp", name: "v00e0003 student3", password: "v00e0003", role: "Student", student_id: "v00e0003")
@user3.save
Event.create(user_id: @user3.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
@course1.users << @user3





@user4 = User.new(email: "v00e0004@oita-u.ac.jp", name: "v00e0004 student4", password: "v00e0004", role: "Student", student_id: "v00e0004")
@user4.save
Event.create(name: "テキスト課題２", user_id: @user4.id, course_id: @course1.id, activity_access: "2022-07-18 00:00:00")
# , submitted_time: "2022-07-18 01:00:00"
@course1.users << @user4

@user5 = User.new(email: "v00e0005@oita-u.ac.jp", name: "v00e0005 student5", password: "v00e0005", role: "Student", student_id: "v00e0005")
@user5.save
Event.create(name: "テキスト課題１", user_id: @user5.id, course_id: @course2.id, activity_access: "2022-07-18 00:00:00", submitted_time: "2022-07-18 01:00:00")
@course2.users << @user5

@user6 = User.new(email: "v00e0006@oita-u.ac.jp", name: "v00e0006 student6", password: "v00e0006", role: "Student", student_id: "v00e0006")
@user6.save
Event.create(name: "テキスト課題２", user_id: @user6.id, course_id: @course2.id, activity_access: "2022-07-18 00:00:00")
@course2.users << @user6

Flag.create(send: false)