class CoursesController < ApplicationController
  before_action :authenticate_user!
  def new
    @course = Course.new
  end
 
  def create
    @course = Course.new(course_params)
      if @course.save
        endtime = @course.start_time + Rational(1, 24)
        @course.update(end_time: endtime)
        user = current_user
        @course.users << user
        redirect_to root_path
      else
        flash[:notice] = "入力エラーです"
        render :new
      end
  end
  
  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    redirect_to root_path
  end
  
  def edit
    current_user.courses.update_all(focus: false)
    @course = Course.find(params[:id])
    @course.update(focus: true)
    redirect_to root_path
  end
  
  private
    def course_params
        params.require(:course).permit(:course_code, :name, :start_time)
    end
end
