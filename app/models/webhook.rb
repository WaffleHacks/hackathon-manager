class Webhook < ApplicationRecord
  include FlagShihTzu
  audited

  POSSIBLE_EVENTS = {
    questionnaire_pending: "Questionnaire Status: Pending Review (new application)",
    questionnaire_late_waitlist: "Questionnaire Status: Waitlisted, Late",
    questionnaire_rsvp_confirmed: "Questionnaire Status: RSVP Confirmed",
    questionnaire_rsvp_denied: "Questionnaire Status: RSVP Denied",
  }.freeze

  POSSIBLE_FORMATS = %w[json slack discord].freeze

  # The possible events that can be listened to
  has_flags 1 => :questionnaire_pending,
            2 => :questionnaire_late_waitlist,
            3 => :questionnaire_rsvp_confirmed,
            4 => :questionnaire_rsvp_denied,
            :column => 'events'

  has_many :webhook_histories

  validates_presence_of :active, :url, :format
  validates_inclusion_of :format, in: POSSIBLE_FORMATS
  validates_format_of :url, with: %r{http(s|)://([a-z0-9\-]+\.)+[a-z0-9\-]+(/[a-z0-9\-_.]*)*(\?([a-z0-9\-_]+(=[a-z0-9\-_]*|))*(&([a-z0-9\-_]+(=[a-z0-9\-_]*|))|)*)*}i, on: :create

  strip_attributes

  def self.for_event(event)
    event_sym = event.to_sym
    return [] unless POSSIBLE_EVENTS.include?(event_sym)

    Webhook.public_send(event_sym)
  end

  def self.queue_for_event(event, **data)
    for_event(event).map { |webhook| TriggerWebhookJob.perform_later(webhook, event, **data) }
  end
end
