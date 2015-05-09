require 'rails_helper'

describe MessageMailer do
  let(:message) { FactoryGirl.create :message, :with_secure_id }

  describe "#secure_message" do
    subject { MessageMailer.secure_message(message).deliver_now}
    let(:email) { subject;ActionMailer::Base.deliveries.last }

    it "goes to the right people" do
      expect(email.to).to eq([message.recipient])
      expect(email.from).to eq([message.sender])
    end

    it "doesn't contain the message text" do
      expect(email.body).to_not match(/body text for the message/)
    end
  end
end
