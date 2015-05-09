require 'rails_helper'

feature "Sending a message" do
  scenario "successful sending" do
    send_simple_message("Here is the message for you")
    expect(page).to have_content("Message sent")
    verify_message_pickup("Here is the message for you")
  end

  def send_simple_message(message_text)
    visit new_message_path
    fill_in "Sender", with: "sender@example.com"
    fill_in "Recipient", with: "recipient@example.com"
    fill_in "Body", with: message_text
    click_button "Send"
  end

  def verify_message_pickup(message_text)
    last_email = ActionMailer::Base.deliveries.last
    message_pickup_path = last_email.body.to_s.slice /\/pickups\/(\S+)/, 0
    visit message_pickup_path
    expect(page).to have_content(message_text)
  end
end
