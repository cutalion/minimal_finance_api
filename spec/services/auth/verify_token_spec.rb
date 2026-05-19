require "rails_helper"

RSpec.describe Auth::VerifyToken do
  describe ".call" do
    let(:user) { create(:user) }

    it "returns the user for a valid token" do
      token = JsonWebToken.encode(sub: user.id, exp: 1.hour.from_now.to_i)

      result = described_class.call(token: token)

      expect(result).to be_success
      expect(result.payload).to eq(user)
    end

    it "fails with invalid_token when the token is blank" do
      result = described_class.call(token: "")

      expect(result).to be_failure
      expect(result.failure.code).to eq("invalid_token")
    end

    it "fails with invalid_token when the token is nil" do
      result = described_class.call(token: nil)

      expect(result).to be_failure
      expect(result.failure.code).to eq("invalid_token")
    end

    it "fails with invalid_token when the token is malformed" do
      result = described_class.call(token: "not-a-jwt")

      expect(result).to be_failure
      expect(result.failure.code).to eq("invalid_token")
    end

    it "fails with token_expired when the token has expired" do
      token = JsonWebToken.encode(sub: user.id, exp: 1.hour.ago.to_i)

      result = described_class.call(token: token)

      expect(result).to be_failure
      expect(result.failure.code).to eq("token_expired")
    end

    it "fails with invalid_token when the user no longer exists" do
      token = JsonWebToken.encode(sub: user.id, exp: 1.hour.from_now.to_i)
      user.destroy!

      result = described_class.call(token: token)

      expect(result).to be_failure
      expect(result.failure.code).to eq("invalid_token")
    end
  end
end
