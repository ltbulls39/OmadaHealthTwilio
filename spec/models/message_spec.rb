require 'rails_helper'

describe Message do
  let(:message) { FactoryGirl.create :message, :with_secure_id }
  describe "#to_param" do
    subject { message.to_param }
    it "should return the secure id value" do
      expect(subject).to eq(message.secure_id)
    end
  end
end
