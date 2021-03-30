class TriggerWebhookJob < ApplicationJob
  queue_as :default

  def perform(webhook, event, **data)
    # Fire current the webhook
    code, body = Webhooks.emit(webhook.format, webhook.url, webhook.secret, event, **data)

    # Add the event to the webhook's history
    webhook.webhook_histories.create(status_code: code, body: body)
  end
end
