class RegistrationsController < ApplicationController

  before_action :set_registration, only: [:destroy, :switch_role]
  skip_before_action :verify_authenticity_token, only: [:create]

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
      respond_to do |format|
        format.html { redirect_to @member, notice: 'Member is already registered for this course' }
        format.json { render :show, status: :conflict, location: @member }
      end
      return
    end

    respond_to do |format|
      registration = @course.register(@member, member_params, role, @ticket)
      payment = registration.payment

      if payment
        format.html { redirect_to payment.payment_url }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @registration.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Registration was successfully removed.' }
      format.json { head :no_content }
    end
  end

  def switch_role
    new_role = !@registration.role
    respond_to do |format|
      if @registration.update(role: new_role)
        format.html { redirect_to :back, notice: "Role was switched." }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_registration
    @registration = Registration.find(params[:id])
  end

  def member_params
    params.permit(:firstname, :lastname, :email, :address)
  end

  def course_params
    params.permit(:course_id)
  end
end
