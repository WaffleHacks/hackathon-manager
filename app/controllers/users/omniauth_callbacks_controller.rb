class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def mlh
    @user = User.from_mlh_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      session["devise.provider_data"] = request.env["omniauth.auth"]
      set_flash_message(:notice, :success, kind: "MyMLH") if is_navigational_format?
    else
      redirect_to new_user_registration_url
    end
  end

  def discord
    @user = User.from_discord_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      session["devise.provider_data"] = request.env["omniauth.auth"]
      set_flash_message(:notice, :success, kind: "Discord") if is_navigational_format?
    else
      auth_response = request.env["omniauth.auth"]
      info = auth_response["extra"]["raw_info"]
      session["devise.provider_data"] = {
        token: auth_response["credentials"]["token"],
        username: "#{info['username']}##{info['discriminator']}",
        email: info["email"],
        provider: :discord,
        uid: auth_response["uid"]
      }
      redirect_to new_user_registration_url
    end
  end

  def failure
    flash[:alert] = "External authentication failed - try again?"
    redirect_to new_user_session_url
  end
end
