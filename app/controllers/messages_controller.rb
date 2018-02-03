class MessagesController < ApplicationController
  def new
    @message = Message.new
  end

  def create
    action = MessageCreator.new(params) 
    if action.ok?
      flash[:message] = "Message sent"
      redirect_to new_message_path
    else
      my_var = @message
      @message = action.message
      flash[:message] = "Message not sent"      
      render :new
    end
  end
end
