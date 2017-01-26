
class ErrorsController < ApplicationController
  before_action :set_error, only: [:show, :update, :destroy]

  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # GET /errors
  def index
    cors_set_access_control_headers
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
