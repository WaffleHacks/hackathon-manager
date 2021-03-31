class WebhookDatatable < ApplicationDatatable
  def_delegators :@view, :link_to, :manage_webhook_path, :display_datetime

  def view_columns
    @view_columns ||= {
      id: { source: "Webhook.id", searchable: false },
      url: { source: "Webhook.url" },
      active: { source: "Webhook.active" },
      format: { source: "Webhook.format" },
      created_at: { source: "Webhook.created_at", searchable: false },
    }
  end

  private

  def data
    records.map do |record|
      puts record
      {
        id: record.id,
        link: link_to('<i class="fa fa-search"></i>'.html_safe, manage_webhook_path(record)),
        url: record.url,
        active: yes_no_display(record.active),
        format: record.format,
        created_at: display_datetime(record.created_at),
      }
    end
  end

  def get_raw_records
    Webhook.all
  end
end
