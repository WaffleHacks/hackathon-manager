class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    super do |resource|
      if session["devise.provider_data"].present?
        # Pre-populate the user's info
        info = session["devise.provider_data"]
        resource.email = info["email"]
        resource.password = Devise.friendly_token[0, 20]
        resource.provider = info["provider"]
        resource.uid = info["uid"]

        # Check if the user should be a director
        guilds = HTTParty.get("https://discord.com/api/v8/users/@me/guilds", headers: { "Authorization": "Bearer #{info['token']}" })
        is_director = guilds.any? { |guild| guild["id"] == ENV["DISCORD_GUILD_ID"] and (guild["owner"] or guild["permissions"] & 0x20 == 0x20) }
        if is_director
          resource.role = :director
        end

        resource.save

        # Persist the user's discord id since the devise namespace is cleared
        session["discord_username"] = info["username"]
      end
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    current_user.questionnaire.destroy if current_user.questionnaire.present?
    super
  end

  # Permit adding custom parameters for sign up
  # (Devise gives us email and password by default, but we want some more.)
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end

  # Permit updating custom parameters for sign up
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
