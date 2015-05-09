class MessageMailer < ActionMailer::Base
  def secure_message(message)
    @message = message
    mail to: message.recipient, from: message.sender, subject: "Secure Message from #{message.sender}"
  end
end
