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
        @course.update(focus: true)
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
    @role = Enrollment.find_by(user_id: current_user.id, course_id: params[:id])
    if @role.role == "Teacher"
      @course = Course.find(params[:id])
      if @course.focus == true
        @course.update(focus: false)
      elsif @course.focus == false
        @course.update(focus: true)
      end
      redirect_to root_path
    elsif @role.role == "Student"
      redirect_to root_path
    end
  end
  
  # def update
  #   @activity = Event.update(name: name)
  # end
  
  private
    def course_params
        params.require(:course).permit(:course_code, :name)
    end
end
