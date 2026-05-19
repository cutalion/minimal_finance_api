Rails.application.config.to_prepare do
  JsonWebToken.algorithm = "HS256"
  JsonWebToken.secret =
    if ENV["JWT_SECRET"].present?
      ENV["JWT_SECRET"]
    elsif Rails.env.local?
      Rails.logger.warn "[JsonWebToken] JWT_SECRET is not set — falling back to an insecure default"
      "change-me"
    else
      raise "JWT_SECRET is required in #{Rails.env}"
    end
end
