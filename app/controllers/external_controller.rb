class ExternalController < ApplicationController
  skip_before_action :verify_authenticity_token

  def register
    params.require(:email)
    params.require(:token)

    if ENV["REGISTRATION_TOKEN"] != params[:token]
      render json: { "success" => false, "reason" => "invalid registration token" }, status: 401 and return
    end

    user = User.find_by(email: params[:email])
    unless user
      render json: { "success" => false, "reason" => "missing field 'email'" }, status: 400 and return
    end

    user.role = :director
    user.save

    render json: { "success" => true }
  end
end
