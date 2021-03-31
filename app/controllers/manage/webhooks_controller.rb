require 'net/http'

class Manage::WebhooksController < Manage::ApplicationController
  before_action :require_director
  before_action :set_webhook, only: [:show, :edit, :update, :destroy, :test]

  respond_to :html, :json

  def index
    respond_with(:manage, Webhook.all)
  end

  def datatable
    render json: WebhookDatatable.new(params, view_context: view_context)
  end

  def show
    respond_with(:manage, @webhook)
  end

  def edit
  end

  def new
    events = params[:events]
    @webhook = Webhook.new(events: events)
    respond_with(:manage, @webhook)
  end

  def create
    @webhook = Webhook.new(webhook_params)
    @webhook.save
    respond_with(:manage, @webhook)
  end

  def update
    puts webhook_params
    @webhook.update_attributes(webhook_params)
    respond_with(:manage, @webhook)
  end

  def destroy
    @webhook.destroy
    respond_with(:manage, @webhook)
  end

  def test
    # Send out a testing webhook
    code, body = Webhooks.emit(@webhook.format, @webhook.url, @webhook.secret, :testing, status: "It works!")
    @status = {
      code: code,
      body: body,
    }

    render "show"
  end

  private

  def webhook_params
    params.require(:webhook).permit(
      :url, :secret, :active, :format,
      :questionnaire_pending, :questionnaire_late_waitlist, :questionnaire_rsvp_confirmed, :questionnaire_rsvp_denied
    )
  end

  def set_webhook
    @webhook = Webhook.find(params[:id])
  end
end
