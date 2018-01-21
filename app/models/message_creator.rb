require 'twilio-ruby'

class MessageCreator
  
  attr_accessor :message, :sms_record

  def initialize(params)
    # Creates new message with allowed parameters
    @message = Message.new(allowed_params(params))
    account_sid = ENV["TWILIO_TEST_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_TEST_AUTH_TOKEN"]
    @client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def ok?
    save_message && send_notification
  end

  def is_it_email?  # Checks to see if it is an email or a text
    if @message.sender_message.include? "@"
      if @message.recipient_message.include? "@" # Checks both sender and recipient fields
        @message.sender_email = @message.sender_message
        @message.save
        @message.recipient_email = @message.recipient_message
        @message.save
        return "email"
      end
    end
  end

  def clean_number(num) # Cleans the number into Twilio API format and returns it
    number = num.scan(/\d+/).join
    number[0] == "1" ? number[0] = '' : number
    number unless number.length != 10
  end

  private

  def send_notification
    # If email send email notification
    if is_it_email? == "email"
      MessageMailer.secure_message(@message).deliver_now
    else  # If text send text notification
      @message.sender_phone = @message.sender_message
      @message.save
      @message.recipient_phone = @message.recipient_message
      @message.save
      # Ensures the number is in correct format
      from_texter = "+1" + clean_number(@message.sender)
      to_texter = "+1" + clean_number(@message.recipient)
      begin # Error handling, in case the text won't work
        @sms_record = @client.account.messages.create(
          :from => from_texter,
          :to => to_texter,
          :body => @message.secure_id
        )
      rescue Twilio::REST::RequestError => e
        puts e.message
      end
    end
  end

  def save_message  # Saves the message with an encrypted message
    @message.secure_id = SecureRandom.urlsafe_base64(25)
    @message.save
  end

  def allowed_params(params)
    { # Params that a message can have
      sender_message: params[:message][:sender], 
      recipient_message: params[:message][:recipient], 
      body: params[:message][:body]
    }
  end
end #end class
