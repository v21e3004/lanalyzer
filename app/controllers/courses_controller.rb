class CoursesController < ApplicationController
  before_action :authenticate_user!
  def new
    @course = Course.new
  end
 
  def create
    @course = Course.new(course_params)
      if @course.save
        user = current_user
        @course.users << user
        @course.update(send_message: false)
        # redirect_to new_timetable_path
        
        @courses = current_user.courses.all
        @courses.update_all(focus: false)
        @course.update(focus: true)
        redirect_to new_timetable_path(@course.id)
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
    @courses = current_user.courses.all
    # current_user.courses.update_all(focus: false)
    @courses.update_all(focus: false, send_message: false)
    @course = Course.find(params[:id])
    @course.update(focus: true)
    redirect_to root_path
  end
  
  # def update
  #   @activity = Event.update(name: name)
  # end
  
  private
    def course_params
        params.require(:course).permit(:course_code, :name)
    end
end
