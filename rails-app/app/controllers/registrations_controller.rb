class RegistrationsController < ApplicationController

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

  private
  def person_params
    params.permit(:firstname, :lastname, :email, :address)
  end

  def course_params
    params.permit(:course_id)
  end
end
