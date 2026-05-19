module Auth
  class VerifyToken < ApplicationService
    attr_accessor :token

    private

    def perform
      fail!(:invalid_token, message: "Token is missing or invalid") if token.blank?

      payload = begin
        JsonWebToken.decode(token)
      rescue JWT::ExpiredSignature
        fail!(:token_expired, message: "Token has expired")
      rescue JWT::DecodeError
        fail!(:invalid_token, message: "Token is missing or invalid")
      end

      user = User.find_by(id: payload[:sub])
      fail!(:invalid_token, message: "Token is missing or invalid") unless user

      user
    end
  end
end
