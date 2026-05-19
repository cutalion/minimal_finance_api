class ApplicationController < ActionController::API
  before_action :authenticate_user!

  attr_reader :current_user

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.delete_prefix("Bearer ")
    result = Auth::VerifyToken.call(token: token)

    if result.success?
      @current_user = result.payload
    else
      render_service_failure(result, status: :unauthorized)
    end
  end

  def render_service_failure(result, status: :unprocessable_content)
    f = result.failure
    render_error(status, f.code, f.message, f.details)
  end

  def render_error(status, code, message, details = nil)
    body = { error: { code: code, message: message } }
    body[:error][:details] = details if details

    render json: body, status: status
  end
end
