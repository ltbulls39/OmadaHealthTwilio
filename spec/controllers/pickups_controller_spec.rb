require 'rails_helper'

describe PickupsController do
  let(:message) { FactoryGirl.create :message, :with_secure_id }
  describe "GET #show" do
    subject { get :show, id: message.secure_id }
    it { should render_template('pickups/show')}
    it "pulls the message" do
      subject
      expect(assigns[:message]).to eq(message)
    end
    it "sets up a reply" do
      subject
      expect(assigns[:reply]).to be_a(Message)
      expect(assigns[:reply].sender_message).to eq(message.recipient)
      expect(assigns[:reply].recipient_message).to eq(message.sender)
    end
  end
end
