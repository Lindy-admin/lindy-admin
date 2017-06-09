class RegistrationsController < ApplicationController
  before_action :set_registration, only: [:destroy]

  # GET /registrations/new
  def new
    @courses = Course.all #TODO filter courses that cannot be registered to
  end

  # POST /registrations
  # POST /registrations.json
  def create
    @person = Person.find_or_initialize_by(email: params[:email])
    @course = Course.find(params[:course])
    role = params[:role]

    if Registration.exists?(person_id: @person.id, course_id: @course.id)
      respond_to do |format|
        format.html { redirect_to @person, notice: 'Person is already registered for this course' }
        format.json { render :show, status: :conflict, location: @person }
      end
      return
    end

    respond_to do |format|
      if @course.register(@person, person_params, role)
        format.html { redirect_to @person, notice: 'Person was successfully registered.' }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_registration
    @registration = Registration.find(params[:id])
  end

  def person_params
    params.permit(:firstname, :lastname, :email, :address)
  end

  def course_params
    params.permit(:course_id)
  end
end
