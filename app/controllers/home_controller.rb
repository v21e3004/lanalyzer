class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @courses = current_user.courses.all
    @find_course = @courses.find_by(focus: true)
    if !@find_course.nil?
      @users = @find_course.users.all
      @students = @users.joins(:enrollments).where(enrollments: {role: "Student"})
      # コース，アクティビティ，イベントの３つのテーブルを結合
      @focus_course = Course.eager_load(activities: :events).where(courses: {id: @find_course.id})
      # @focus_course = Course.eager_load(activities: {events: :users}).where(courses: {id: @find_course.id})
      # @submit_students = @students.joins(:events).where.not(events: {submitted_time: nil})
    else
    end
    
  end
end
