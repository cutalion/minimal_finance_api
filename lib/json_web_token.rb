require "jwt"

module JsonWebToken
  class NotConfiguredError < StandardError; end

  class << self
    attr_accessor :secret
    attr_accessor :algorithm

    def encode(payload)
      assert_configured!
      JWT.encode(payload, secret, algorithm)
    end

    def decode(token)
      assert_configured!
      JWT.decode(token, secret, true, algorithm: algorithm).first.symbolize_keys
    end

    private

    def assert_configured!
      unless secret.present?
        raise NotConfiguredError,
              'JsonWebToken.secret is not set. Set it with: JsonWebToken.secret = "some-secret"'
      end

      unless algorithm.present?
        raise NotConfiguredError,
              'JsonWebToken.algorithm is not set. Set it with: JsonWebToken.algorithm = "HS256" ' \
              '(or "HS384", "HS512", "RS256", etc.)'
      end

      expected = algorithm.start_with?("HS") ? String : OpenSSL::PKey::PKey
      unless secret.is_a?(expected)
        raise NotConfiguredError,
              "JsonWebToken.secret must be a #{expected} for #{algorithm} (got #{secret.class})"
      end
    end
  end
end
