class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
    @courses = current_user.courses.all
    @courses_activities_events = @courses.eager_load(activities: :events).where(courses: {focus: true})
    @find_course = @courses.where(focus: true)
  end
end
