require 'twilio-ruby'

class MessageCreator
  
  attr_accessor :message, :sms_record

  def initialize(params)
    @message = Message.new(allowed_params(params))
    account_sid = ENV["TWILIO_TEST_ACCOUNT_SID"]
    auth_token = ENV["TWILIO_TEST_AUTH_TOKEN"]
    @client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def ok?
    save_message && send_notification
  end
=begin
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
=end
  def is_it_email?
    if @message.sender_message.include? "@"
      if @message.recipient_message.include? "@"
        @message.sender_email = @message.sender_message
        @message.save
        @message.recipient_email = @message.recipient_message
        @message.save
        return "email"
      end
    end
  end

=begin
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
=end
  def clean_number2(num)
    number = num.scan(/\d+/).join
    number[0] == "1" ? number[0] = '' : number
    number unless number.length != 10
  end

  private

  def send_notification
    if is_it_email? == "email"
      MessageMailer.secure_message(@message).deliver_now
    else
      #from_texter = @message.sender_message
      #to_texter = @message.recipient_message
      @message.sender_phone = @message.sender_message
      @message.save
      @message.recipient_phone = @message.recipient_message
      @message.save

      from_texter = "+1" + clean_number2(@message.sender)
      to_texter = "+1" + clean_number2(@message.recipient)
      begin
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
