class TriggerWebhookJob < ApplicationJob
  queue_as :default

  def perform(webhook, event, **data)
    puts data

    # Fire current the webhook
    _code, _body = Webhooks.emit(webhook.format, webhook.url, webhook.secret, event, **data)

    # Add the event to the webhook's history
    # TODO: implement webhook history
  end
end
