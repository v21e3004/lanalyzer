class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @courses = current_user.courses.all
    @focus_course = current_user.courses.find_by(focus: true)
    @users = @focus_course.users.where(role: "Student")
  end
end
