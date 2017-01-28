require 'bugsnag/api'

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

    client = Bugsnag::Api::Client.new(auth_token: ENV["BUGSNAG_TOKEN"])
    query_hash = {
      per_page: 1000,
      "filters[error.status][]": "open",
      "filters[app.release_stage][]": "production",
      "filters[event.since][]": "7d",
      "filters[event.severity][0][value]": "error",
      "filters[event.severity][0][type]": "eq"
    }
    # TODO: error handling
    @response = client.errors("5437fc527765622ef400a8e7", query_hash)

    if team_id = params[:team_id]
      matchers = controllers_for(team_id.to_i)
      @errors = @response.select {|e| matchers.find{ |c| c.match(e.last_context)}}
    else
      @errors = @response.reject {|e| controller_matchers.find{ |c| c[:exp].match(e.last_context)}}
    end

    render json: {:errors => @errors.map {|e| e.to_hash}}
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

    def controllers_for(team_id)
      controller_matchers.select{|c| c[:team_id] == team_id}.map{|c| c[:exp]}
    end

    # TODO: make a controllers table to store these associations
    def controller_matchers
      [
        {:exp => /replies#public/, :team_id => 2},
        {:exp => /PackageVariationCloneJob/, :team_id => 2},
        {:exp => /R2RenderJob/, :team_id => 2},
        {:exp => /RedeliveryJob/, :team_id => 3},
        {:exp => /EventTemplateJob/, :team_id => 3},
        {:exp => /EventAddToCartJob/, :team_id => 4},
        {:exp => /api\/pricing#by_cards/, :team_id => 2},
        {:exp => /MediaFileConversionJob/, :team_id => 2},
        {:exp => /MediaFileUploadJob/, :team_id => 2},
        {:exp => /api\/postboxes/, :team_id => 3},
        {:exp => /api\/contacts/, :team_id => 3},
        {:exp => /RendererCompleteJob/, :team_id => 2},
        {:exp => /ElasticsearchIndexJob/, :team_id => 1},
        {:exp => /api\/contact_groups#add_contacts/, :team_id => 3},
        {:exp => /ImageComparisonJob/, :team_id => 2},
        {:exp => /OrderEmailJob/, :team_id => 4},
        {:exp => /dashboard#index/, :team_id => 3},
        {:exp => /api\/google_api_signatures#create/, :team_id => 2},
        {:exp => /api\/photos#create/, :team_id => 2},
        {:exp => /api\/accounts#show/, :team_id => 3},
        {:exp => /EventAggregatorJob/, :team_id => 3},
        {:exp => /api\/events#update/, :team_id => 2},
        {:exp => /admin\/new_papers/, :team_id => 2},
        {:exp => /guests/, :team_id => 3},
        {:exp => /api\/guests/, :team_id => 3},
        {:exp => /SendEventJob/, :team_id => 3},
        {:exp => /api\/private_messages/, :team_id => 3},
        {:exp => /api\/notifications/, :team_id => 3},
        {:exp => /SubmitPrintOrderJob/, :team_id => 4},
        {:exp => /email_addresses/, :team_id => 3},
        {:exp => /ClassifyEventJob/, :team_id => 2},
        {:exp => /api\/events#create/, :team_id => 2},
        {:exp => /api\/v1\/events\/\d+-\d+/, :team_id => 2},
        {:exp => /SimpleEmailJob/, :team_id => 3},
        {:exp => /partials#cart_modal/, :team_id => 4},
        {:exp => /GuestSchedulerJob/, :team_id => 3},
        {:exp => /papers#index/, :team_id => 2},
        {:exp => /NodeRendererJob/, :team_id => 2},
        {:exp => /SendGuestJob/, :team_id => 3},
        {:exp => /accounts#send_reset_link/, :team_id => 3},
        {:exp => /accounts#create/, :team_id => 3},
        {:exp => /about#show/, :team_id => 1},
        {:exp => /events\/status#show/, :team_id => 3},
        {:exp => /replies#public/, :team_id => 3},
        {:exp => /lib\/paperless\/spam\/event_presenter.rb:103/, :team_id => 2},
        {:exp => /events\/tracking#show/, :team_id => 3},
        {:exp => /EdgeCastPurgeJob/, :team_id => 1},
        {:exp => /hiring#apply/, :team_id => 1},
        {:exp => /EventCloneJob/, :team_id => 2},
        {:exp => /admin\/accounts#unmerge/, :team_id => 1},
        {:exp => /accounts#connect/, :team_id => 1},
        {:exp => /home#show/, :team_id => 1}
      ]
    end
end
