class SettingsController < ApplicationController

  before_action :get_setting, only: [:edit, :update]

  def index
    @settings = Setting.get_all

    if !Setting.mailjet_public_api_key.blank? && !Setting.mailjet_private_api_key.blank?
      auth = {username: Setting.mailjet_public_api_key, password: Setting.mailjet_private_api_key}
      response = HTTParty.get("https://api.mailjet.com/v3/REST/template?OwnerType=user", :basic_auth => auth)
      @mailjet_templates = response["Data"].map{ |template|
        {
          name: template["Name"],
          id: template["ID"]
        }
      }
    end
  end

  def edit
  end

  def update
    clean_params(params)
    Setting.get_all.each_key do |key|
      if params.has_key?(key)
        Setting[key] = params[key]
      end
    end
    Setting.save
    redirect_to settings_path, notice: 'Settings have been updated.'
  end

  def clean_params(params)
    if params.has_key?(:mollie_redirect_url) && !params[:mollie_redirect_url].empty?
      # strip the url params, if any
      begin
        uri = URI(params[:mollie_redirect_url])
        params[:mollie_redirect_url] = "#{uri.scheme}://#{uri.host}#{uri.path}"
      rescue URI::InvalidURIError
        params[:mollie_redirect_url] = Setting[:mollie_redirect_url]
      end
    end
  end

  def get_setting
    @setting = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id])
  end

end
