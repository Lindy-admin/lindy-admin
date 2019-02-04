class SettingsController < ApplicationController

  before_action :get_setting

  def index
    if !@config.mailjet_public_api_key.blank? && !@config.mailjet_private_api_key.blank?
      @mailjet_templates = []
      auth = {username: @config.mailjet_public_api_key, password: @config.mailjet_private_api_key}
      response = HTTParty.get("https://api.mailjet.com/v3/REST/template?OwnerType=user", :basic_auth => auth)
      if response != nil && response["Data"] != nil
        @mailjet_templates = response["Data"].map{ |template|
          {
            name: template["Name"],
            id: template["ID"]
          }
        }
      end
    end
  end

  def edit
  end

  def update
    config_params.each_key do |key|
      @config[key] = config_params[key]
    end
    @config.save!
    redirect_to settings_path, notice: 'Settings have been updated.'
  end

  def clean_params(params)
    if params.has_key?(:mollie_redirect_url) && !params[:mollie_redirect_url].empty?
      # strip the url params, if any
      begin
        uri = URI(params[:mollie_redirect_url])
        params[:mollie_redirect_url] = "#{uri.scheme}://#{uri.host}#{uri.path}"
      rescue URI::InvalidURIError
        params[:mollie_redirect_url] = @config.mollie_redirect_url
      end
    end
  end

  private
  def get_setting
    @config = Config.first_or_create
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def config_params
    permitted = params.permit(
      :mollie_api_key,
      :mollie_redirect_url,
      :mailjet_public_api_key,
      :mailjet_private_api_key,
      :mailjet_sender_email_address,
      :mailjet_sender_email_name,
      :mailjet_registered_template_id,
      :mailjet_registered_subject,
      :mailjet_waitinglist_template_id,
      :mailjet_waitinglist_subject,
      :mailjet_accepted_template_id,
      :mailjet_accepted_subject,
      :mailjet_accepted_template_id,
      :mailjet_paid_subject,
      :mailjet_paid_template_id,
      :notification_email_address,
      :mailjet_notification_email_template_id,
    )

    if permitted.has_key?(:mollie_redirect_url) && !permitted[:mollie_redirect_url].empty?
      # strip the url permitted, if any
      begin
        uri = URI(permitted[:mollie_redirect_url])
        permitted[:mollie_redirect_url] = "#{uri.scheme}://#{uri.host}#{uri.path}"
      rescue URI::InvalidURIError
        permitted[:mollie_redirect_url] = @config.mollie_redirect_url
      end
    end

    return permitted
  end

end
