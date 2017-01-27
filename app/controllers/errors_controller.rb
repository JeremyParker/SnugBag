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
        # CREATE TEAM
        {:exp => /api\/NewPapersController#index/, :team_id => 2},
        {:exp => /api\/EnvelopesController#index/, :team_id => 2},
        {:exp => /DesignController#new /, :team_id => 2},
        {:exp => /api\/EnvelopeLinersController#index/, :team_id => 2},
        {:exp => /api\/CardBackgroundsController#index/, :team_id => 2},
        {:exp => /api\/FontsController#show/, :team_id => 2},
        {:exp => /api\/EnvelopeLinersController#categories/, :team_id => 2},
        {:exp => /api\/PhotosController#index/, :team_id => 2},
        {:exp => /api\/FontsController#index/, :team_id => 2},
        {:exp => /api\/EnvelopeStampsController#index/, :team_id => 2},
        {:exp => /api\/MotifsController#index/, :team_id => 2},
        {:exp => /api\/MotifsController#categories/, :team_id => 2},
        {:exp => /api\/EnvelopesController#categories/, :team_id => 2},
        {:exp => /api\/LogosController#index/, :team_id => 2},
        {:exp => /api\/EnvelopeStampsController#categories/, :team_id => 2},
        {:exp => /EventCloneJob/, :team_id => 2},
        {:exp => /api\/EnvelopePostmarksController#index/, :team_id => 2},
        {:exp => /R2RenderJob/, :team_id => 2},
        {:exp => /api\/RecipientAddressingFormatsController#index/, :team_id => 2},

        # EVENTS TEAM
        {:exp => /api\/EventsController#show/, :team_id => 3},
        {:exp => /api\/EventsController#update/, :team_id => 3},
        {:exp => /RepliesController#public/, :team_id => 3},
        {:exp => /api\/GuestsController#list/, :team_id => 3},
        {:exp => /api\/Accounts\/CartsController#show/, :team_id => 3},
        {:exp => /api\/InternationalController#show/, :team_id => 3},
        {:exp => /api\/GuestsController#show/, :team_id => 3},
        {:exp => /api\/NotificationsController#index/, :team_id => 3},
        {:exp => /api\/MetricsController#create/, :team_id => 3},
        {:exp => /api\/PublicGuestListsController#index/, :team_id => 3},
        {:exp => /api\/PublicMessagesController#index/, :team_id => 3},
        {:exp => /api\/MetricsController#create/, :team_id => 3},
        {:exp => /api\/GuestsController#update/, :team_id => 3},
        {:exp => /api\/EventsController#show/, :team_id => 3},
        {:exp => /api\/GuestsController#update/, :team_id => 3},
        {:exp => /api\/EventsController#show/, :team_id => 3},
        {:exp => /Events\/DeliveryController#show/, :team_id => 3},
        {:exp => /GuestsController#update/, :team_id => 3},
        {:exp => /api\/GuestsController#list/, :team_id => 3},
        {:exp => /api\/ContactsController#index/, :team_id => 3},
        {:exp => /GuestsController#create/, :team_id => 3},
        {:exp => /Events\/TrackingController#filter_numbers/, :team_id => 3},
        {:exp => /Events\/DetailsController#update/, :team_id => 3},
        {:exp => /Events\/EmailCardsController#update/, :team_id => 3},
        {:exp => /api\/AccountsController#show/, :team_id => 3},
        {:exp => /SendGuestJob/, :team_id => 3},
        {:exp => /SendEventJob/, :team_id => 3},
        {:exp => /RedeliveryJob/, :team_id => 3},
        {:exp => /DispatchStatusJob/, :team_id => 3},
        {:exp => /Events\/TrackingController#show/, :team_id => 3},
        {:exp => /api\/Accounts\/CartsController#show/, :team_id => 3},
        {:exp => /api\/InternationalController#show/, :team_id => 3},
        {:exp => /api\/GuestsController#list/, :team_id => 3},
        {:exp => /api\/NotificationsController#index/, :team_id => 3},
        {:exp => /api\/MetricsController#create/, :team_id => 3},
        {:exp => /Events\/EventPageController#show/, :team_id => 3},
        {:exp => /api\/Accounts\/CartsController#show/, :team_id => 3},
        {:exp => /api\/InternationalController#show/, :team_id => 3},
        {:exp => /api\/NotificationsController#index/, :team_id => 3},
        {:exp => /api\/MetricsController#create/, :team_id => 3},

        # DISCOVERY (EVERYTHING)
        {:exp => /./, :team_id => 1},

        # INTERNATIONAL
        {:exp => /EventToPrintOrderConverter/, :team_id => 4},
        {:exp => /EventAddToCartJob/, :team_id => 4},
        {:exp => /CreditCardAddJob/, :team_id => 4},
        {:exp => /CartSubmitJob/, :team_id => 4},
        {:exp => /OrderCloneJob/, :team_id => 4},
        {:exp => /Pricegun/, :team_id => 4},
        {:exp => /CreditCardsController/, :team_id => 4},
        {:exp => /CartsController/, :team_id => 4},
        {:exp => /api\/carts\/ShippingAddressesController/, :team_id => 4}
      ]
    end
end
