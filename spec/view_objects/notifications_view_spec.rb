require "rails_helper"

describe NotificationsView do
  subject do
    described_class.new(
      request: request,
      current_user: current_user,
      user_notification_preferences: user_notification_preferences,
    )
  end

  let(:request) { double(referer: referer_url) }
  let(:current_user) do
    {
      "user_id" => user_id,
      "info" => {
        "email" => user_email,
      },
    }
  end
  let(:user_id) { "123" }
  let(:user_email) { "dave@example.com" }
  let(:user_notification_preferences) { double }
  let(:referer_url) { "https://www.example.com#{referer_path}" }
  let(:referer_path) { "/organisations/B20" }

  describe "#user_id" do
    it "returns the current_user['user_id']" do
      expect(subject.user_id).to eq(user_id)
    end
  end

  describe "#user_email" do
    it "returns the current_user['info']['email']" do
      expect(subject.user_email).to eq(user_email)
    end
  end

  describe "#cancel_link_path" do
    context "referer is organisation page" do
      it "returns the referer path" do
        expect(subject.cancel_link_path).to eq(referer_path)
      end
    end

    context "referer is not an organisation page" do
      let(:referer_path) { "/interruption_screen_path" }

      it "returns root_path" do
        expect(subject.cancel_link_path).to eq(Rails.application.routes.url_helpers.root_path)
      end
    end
  end

  describe "#provider_code" do
    context "referer is organisation page" do
      it "returns the referer provider code" do
        expect(subject.provider_code).to eq("B20")
      end
    end

    context "referer is not an organisation page" do
      let(:referer_path) { "/interruption_screen_path" }

      it "returns nil" do
        expect(subject.provider_code).to be_nil
      end
    end
  end

  describe "#user_notification_preferences" do
    it "returns user_notification_preferences" do
      expect(subject.user_notification_preferences).to eq(user_notification_preferences)
    end
  end
end