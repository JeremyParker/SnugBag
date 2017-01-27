class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :update, :destroy]

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # GET /teams
  def index
    cors_set_access_control_headers
    @teams = [
        {
          :id => 1,
          :display_name => "discovery"
        },
        {
          :id => 2,
          :display_name => "create"
        },
        {
          :id => 3,
          :display_name => "events"
        },
        {
          :id => 4,
          :display_name => "international/payments"
        },
    ]

    render json: @teams
  end

  # GET /teams/1
  def show
    render json: @team
  end

  # POST /teams
  def create
    @team = Team.new(team_params)

    if @team.save
      render json: @team, status: :created, location: @team
    else
      render json: @team.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /teams/1
  def update
    if @team.update(team_params)
      render json: @team
    else
      render json: @team.errors, status: :unprocessable_entity
    end
  end

  # DELETE /teams/1
  def destroy
    @team.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def team_params
      params.fetch(:team, {})
    end
end
