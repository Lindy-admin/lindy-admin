class ApiController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  before_action :disable_cors
  before_action :set_default_response_format

  def courses
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)
      today = Date.today
      @courses = Course.where("registration_start <= ? AND registration_end >= ?", today, today).order(:id)

      if params.has_key?(:style)
        @courses = @courses.tagged_with(params[:style], on: :styles, all: true)
      end
      if params.has_key?(:location)
        @courses = @courses.tagged_with(params[:location], on: :locations, all: true)
      end

      render
    ensure
      Apartment::Tenant.reset
    end
  end

  def course
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)
      @course = Course.find(params[:id])
      render
    ensure
      Apartment::Tenant.reset
    end
  end

  def styles
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)
      @styles = get_tags_for_context("styles")
      render
    ensure
      Apartment::Tenant.reset
    end
  end

  def locations
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)
      @locations =  get_tags_for_context("locations")
      render
    ensure
      Apartment::Tenant.reset
    end
  end

  def register

    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)

      @member = Member.find_or_initialize_by(email: params[:email])
      @course = Course.find(params[:course].to_i)
      @ticket = @course.tickets.find(params[:ticket].to_i)
      role = params[:role]
      additional_params = params[:additional]

      if Registration.exists?(member_id: @member.id, course_id: @course.id)
        @registration = Registration.where(member_id: @member.id, course_id: @course.id).first
        render :register, status: :conflict
        return
      end

      begin
        @registration = @course.register(@member, member_params, role, @ticket, additional_params)
        payment = @registration.payment
        render :register, status: :created
      rescue Exception => e
        logger.error(e.message)
        render json: { error: 0, message: e.message}, status: :unprocessable_entity
      end

    ensure
      Apartment::Tenant.reset
    end

  end

  def payment_webhook

    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)

      payment = Payment.find(params[:id].to_i)
      if payment == nil
        raise ActiveRecord::RecordNotFound
      end

      mollie = Mollie::API::Client.new(Config.first.mollie_api_key)
      mollie_payment = mollie.payments.get payment.remote_id

      begin
        payment.status = mollie_payment.status
      rescue ArgumentError => e
        payment.status = :unknown
      ensure
        payment.save!
      end

    rescue Mollie::API::Exception => e
      render text: "Failed", status: 500
    ensure
      Apartment::Tenant.reset
    end

  end

  def payment_status
    begin
      tenant = Tenant.where(token: params[:tenant]).first
      Apartment::Tenant.switch!(tenant.token)

      @payment = Payment.find(params[:id])
    ensure
      Apartment::Tenant.reset
    end
  end

  private
  def get_tags_for_context(context)
    ActsAsTaggableOn::Tagging.includes(:tag).where(taggable_type: "Course", context: context).distinct.pluck(:name)
  end

  def set_default_response_format
    request.format = :json
  end

  def registration_params
    params.require(:registration).permit(:status)
  end

  def member_params
    params.require([:firstname, :lastname, :email])
    return {
      firstname: params[:firstname],
      lastname: params[:lastname],
      email: params[:email]
    }
  end

  def course_params
    params.require(:course_id)
  end

  def disable_cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  # def cors_set_access_control_headers
  #   headers['Access-Control-Allow-Origin'] = '*'
  #   headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
  #   headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
  # end
  #
  # def cors_preflight_check
  #   if request.method == 'OPTIONS'
  #     headers['Access-Control-Allow-Origin'] = '*'
  #     headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
  #     headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
  #
  #     render :text => '', :content_type => 'text/plain'
  #   end
  # end

end
