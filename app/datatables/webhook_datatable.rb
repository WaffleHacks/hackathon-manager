class WebhookDatatable < ApplicationDatatable
  def_delegators :@view, :display_datetime

  def view_columns
    @view_columns ||= {
      id: { source: "Webhook.id" },
      event: { source: "Webhook.event" },
      url: { source: "Webhook.url" },
      active: { source: "Webhook.active" },
      created_at: { source: "Webhook.created_at", searchable: false },
    }
  end

  private

  def data
    records.map do |record|
      {
        id: record.id,
        event: record.event,
        url: record.url,
        active: record.active,
        created_at: display_datetime(record.created_at),
      }
    end
  end

  def get_raw_records
    Webhook.all
  end
end
