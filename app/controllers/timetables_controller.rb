class TimetablesController < ApplicationController
  before_action :authenticate_user!
  def new
    @@course = Course.find_by(id: params[:format])
    # @timetable = @course.timetables.build
    @timetable = Timetable.new
    
  end
 
  def create
    @timetable = @@course.timetables.build(timetable_params)
      if @timetable.save
        redirect_to root_path
      else
        flash[:notice] = "入力エラーです"
        render :new
      end
  end
  
  private
    def timetable_params
        params.require(:timetable).permit(:lesson1, :lesson2, :lesson3, :lesson4, :lesson5, :lesson6, :lesson7, :lesson8, :lesson9, :lesson10, :lesson11, :lesson12, :lesson13, :lesson14, :lesson15,)
    end
end
