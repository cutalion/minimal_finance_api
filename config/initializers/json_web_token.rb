Rails.application.config.to_prepare do
  JsonWebToken.algorithm = "RS256"
  JsonWebToken.secret =
    if ENV["JWT_PRIVATE_KEY"].present?
      OpenSSL::PKey::RSA.new(ENV["JWT_PRIVATE_KEY"])
    elsif Rails.env.local?
      Rails.logger.warn "[JsonWebToken] JWT_PRIVATE_KEY is not set — generating an insecure ephemeral key"
      OpenSSL::PKey::RSA.generate(2048)
    else
      raise "JWT_PRIVATE_KEY is required in #{Rails.env}"
    end
end
