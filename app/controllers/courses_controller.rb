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
        @course.update(focus: true)
        # redirect_to new_timetable_path(@course.id)
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
    @course = Course.find(params[:id])
    if @course.focus == true
      @course.update(focus: false)
    elsif @course.focus == false
      @course.update(focus: true)
    end
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
