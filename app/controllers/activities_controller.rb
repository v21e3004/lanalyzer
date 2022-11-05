class ActivitiesController < ApplicationController
  def new
  end
  
  def edit
    @activity = Activity.find(params[:id])
    if @activity.sent_messages == false
      @activity.update(sent_messages: true)
    else
      @activity.update(sent_messages: false)
    end
    redirect_to root_path
  end
end
