class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @login_user = current_user.enrollments.select(:role).distinct
    @courses = current_user.courses.all
    @student_course = @courses.joins(:enrollments).where(enrollments: {role: "Student"}).distinct
    @teacher_course = @courses.joins(:enrollments).where(enrollments: {role: "Teacher"}).distinct
    @courses_activities_events = @teacher_course.eager_load(activities: :events).where(courses: {focus: true})
    @find_course = @courses.where(focus: true)
    @submitted_student = current_user.events.all
  end
end
