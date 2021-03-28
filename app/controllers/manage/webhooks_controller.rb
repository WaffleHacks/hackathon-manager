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
    event = params[:event]
    @webhook = Webhook.new(event: event)
    respond_with(:manage, @webhook)
  end

  def create
    @webhook = Webhook.new(webhook_params)
    @webhook.save
    respond_with(:manage, @webhook)
  end

  def update
    @webhook.update_attributes(webhook_params)
    respond_with(:manage, @webhook)
  end

  def destroy
    @webhook.destroy
    respond_with(:manage, @webhook)
  end

  def test
    uri = URI.parse(@webhook.url)

    headers = { 'Content-Type' => 'application/json' }
    if @webhook.secret?
      headers['Authorization'] = @webhook.secret
    end

    req = Net::HTTP::Post.new(uri, headers)
    req.body = {
      type: "testing",
      content: "Hello world!"
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(req)
    end

    @status = {
      code: response.code.to_i,
      body: response.body,
    }

    render "show"
  end

  private

  def webhook_params
    params.require(:webhook).permit(:event, :url, :secret, :active)
  end

  def set_webhook
    @webhook = Webhook.find(params[:id])
  end
end