class SettingsController < ApplicationController

  before_action :get_setting, only: [:edit, :update]

  def index
    @settings = Setting.get_all
  end

  def edit
  end

  def update
    Setting.get_all.each_key do |key|
      if params.has_key?(key)
        Setting[key] = params[key]
      end
    end
    Setting.save
    redirect_to settings_path, notice: 'Settings have been updated.'
  end

  def get_setting
    @setting = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id])
  end

end
