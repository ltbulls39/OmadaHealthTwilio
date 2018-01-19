require 'twilio-ruby'

class MessageCreator
  
  attr_accessor :message, :sms_record

  def initialize(params)
    @message = Message.new(allowed_params(params))
  end

  def ok?
    save_message && send_notification
  end

  def check_digits(strings)
    if strings[0] == "+"
      seq = strings.reverse.chop.reverse
      seq.scan(/\D/).empty?
    elsif strings.include?("+") ? false : true
      strings.scan(/\D/).empty?
    else 
      return false
    end 
  end

  def is_it_email?
    if @message.sender_message.include? "@"
      return "email"
    else 
      return "not email"
    end
  end

  def is_it_text?
    if check_digits(@message.sender_message) && check_digits(@message.recipient_message)
      return "sms"
    end
    return "not sms"
  end

  def clean_number(num)
    if num.length == 12 && num[0] == "+" && check_digits(num)
      return num
    end

    if num.length == 11 && check_digits(num)
      num = "+" + num
      return num
    end

    if num.length == 10 && check_digits(num)
      num = "+1" + num
      return num      
    end
  end

  def clean_number2(num)
    number = num.scan(/\d+/).join
    number[0] == "1" ? number[0] = '' : number
    number unless number.length != 10
  end

  private

  def send_notification
    if is_it_email? == "email"
      MessageMailer.secure_message(@message).deliver_now
    elsif is_it_text? == "sms"
      #from_texter = @message.sender_message
      #to_texter = @message.recipient_message

      from_texter = "+1" + clean_number2(@message.sender_message)
      to_texter = "+1" + clean_number2(@message.recipient_message)
      begin
        #account_sid = ENV["TWILIO_ACCOUNT_SID"]
        #auth_token = ENV["TWILIO_AUTH_TOKEN"]
        account_sid = ENV["TWILIO_ACCOUNT_SID"]
        auth_token = ENV["TWILIO_AUTH_TOKEN"]
        @client = Twilio::REST::Client.new(account_sid, auth_token)
        @sms_record = @client.messages.create(
          :from => from_texter,
          :to => to_texter,
          :body => @message.body
        )
      rescue StandardError => e
        p "we got an error"
        puts e.message
      end
    end
  end

  def save_message
    @message.secure_id = SecureRandom.urlsafe_base64(25)
    @message.save
  end

  def allowed_params(params)
    {
      sender_message: params[:message][:sender], 
      recipient_message: params[:message][:recipient], 
      body: params[:message][:body]
    }
  end
end #end class
