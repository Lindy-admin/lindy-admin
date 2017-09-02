class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]
  before_action :set_course, only: [:course]
  helper_method :sort_column, :sort_direction

  # GET /members
  # GET /members.json
  def index
    @members = Member.all.order(sort_column + " " + sort_direction).page(params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data Member.to_csv(@members), filename: "Members.csv" }
      format.xls { send_data Member.to_csv(@members, col_sep: "\t"), filename: "Members.xls" }
    end
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: 'Member was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def course
    members = @course.participants.order(sort_column + " " + sort_direction).page(params[:page])

    respond_to do |format|
      format.html
      format.csv { send_data Member.to_csv(members), filename: "#{@course.title}_participants.csv" }
      format.xls { send_data Member.to_csv(members, col_sep: "\t"), filename: "#{@course.title}_participants.xls" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:firstname, :lastname, :email, :address)
    end

    def sort_column
      Member.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end
end
