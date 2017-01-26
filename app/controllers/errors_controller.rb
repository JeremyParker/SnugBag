
class ErrorsController < ApplicationController
  before_action :set_error, only: [:show, :update, :destroy]

  # GET /errors
  def index
    @errors = File.read("#{Rails.root}/public/sample_resonse.json")

    render json: @errors
  end

  # GET /errors/1
  def show
    render json: @error
  end

  # POST /errors
  def create
    @error = Error.new(error_params)

    if @error.save
      render json: @error, status: :created, location: @error
    else
      render json: @error.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /errors/1
  def update
    if @error.update(error_params)
      render json: @error
    else
      render json: @error.errors, status: :unprocessable_entity
    end
  end

  # DELETE /errors/1
  def destroy
    @error.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_error
      @error = Error.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def error_params
      params.fetch(:error, {})
    end
end
