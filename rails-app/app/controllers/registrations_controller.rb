class RegistrationsController < ApplicationController

  before_action :set_registration, only: [:show, :edit, :update, :destroy, :switch_role, :set_status]
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate_user!, :only => [:create]

  # GET /registrations/new
  def new
    @courses = Course.all #TODO filter courses that cannot be registered to
  end

  # POST /registrations
  # POST /registrations.json
  def create
    @member = Member.find_or_initialize_by(email: params[:email])
    @course = Course.find(params[:course])
    @ticket = @course.tickets.find(params[:ticket])
    role = params[:role]

    if Registration.exists?(member_id: @member.id, course_id: @course.id)
      @registration = Registration.where(member_id: @member.id, course_id: @course.id).first
      render :show, status: :conflict
      return
    end

    @registration = @course.register(@member, member_params, role, @ticket)
    payment = @registration.payment

    if payment
      render :show, status: :created, location: @registration
    else
      render json: @registration.errors, status: :unprocessable_entity
    end

  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @registration.update(registration_params)
        format.html { redirect_to @registration, notice: 'Registration was successfully updated.' }
        format.json { render :show, status: :ok, location: @registration }
      else
        format.html { render :edit }
        format.json { render json: @registration.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @registration.destroy
    respond_to do |format|
      format.html { redirect_to @registration.course, notice: 'Registration was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def switch_role
    new_role = !@registration.role
    respond_to do |format|
      if @registration.update(role: new_role)
        format.html { redirect_to :back, notice: "Role was switched." }
        format.json { render :show, status: :ok, location: @registration }
      else
        format.html { render :edit }
        format.json { render json: @registration.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_status
    new_status = params[:status]
    respond_to do |format|
      if @registration.update(status: new_status)
        format.html { redirect_back fallback_location: root_path, notice: "Status was updated to #{new_status}" }
        format.json { render :show, status: :ok, location: @registration }
      else
        format.html { render :edit }
        format.json { render json: @registration.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_registration
      @registration = Registration.find(params[:id])
    end

    def registration_params
      params.require(:registration).permit(:status)
    end

    def member_params
      params.require(:member).permit(:member, :course, :role, :ticket, :status)
    end

    def member_params
      params.permit(:firstname, :lastname, :email, :address)
    end

    def course_params
      params.permit(:course_id)
    end
end
