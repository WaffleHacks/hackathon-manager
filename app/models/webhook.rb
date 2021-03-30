class Webhook < ApplicationRecord
  audited

  POSSIBLE_EVENTS = {
    "questionnaire.pending" => "Questionnaire Status: Pending Review (new application)",
    "questionnaire.late_waitlist" => "Questionnaire Status: Waitlisted, Late",
    "questionnaire.rsvp_confirmed" => "Questionnaire Status: RSVP Confirmed",
    "questionnaire.rsvp_denied" => "Questionnaire Status: RSVP Denied",
  }.freeze

  POSSIBLE_FORMATS = %w[json slack discord].freeze

  validates_presence_of :active, :url, :event, :format
  validates_inclusion_of :event, in: POSSIBLE_EVENTS
  validates_inclusion_of :format, in: POSSIBLE_FORMATS
  validates_format_of :url, with: %r{http(s|)://([a-z0-9\-]+\.)+[a-z0-9\-]+(/[a-z0-9\-_.]*)*(\?([a-z0-9\-_]+(=[a-z0-9\-_]*|))*(&([a-z0-9\-_]+(=[a-z0-9\-_]*|))|)*)*}i, on: :create

  strip_attributes

  def self.for_event(event)
    return unless POSSIBLE_EVENTS.include?(event)

    Webhook.where(event: event)
  end

  def self.queue_for_event(event, **data)
    for_event(event).map { |webhook| TriggerWebhookJob.perform_later(webhook, event, **data) }
  end
end
