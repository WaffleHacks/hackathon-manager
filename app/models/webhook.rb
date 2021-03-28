class Webhook < ApplicationRecord
  audited

  POSSIBLE_TRIGGERS = {
    "questionnaire.pending" => "Questionnaire Status: Pending Review (new application)",
    "questionnaire.waitlist" => "Questionnaire Status: Waitlisted, Late",
    "questionnaire.rsvp_confirmed" => "Questionnaire Status: RSVP Confirmed",
    "questionnaire.rsvp_denied" => "Questionnaire Status: RSVP Denied",
  }.freeze

  validates_presence_of :active, :url, :event
  validates_inclusion_of :event, in: POSSIBLE_TRIGGERS
  validates_format_of :url, with: %r{http(s|)://([a-z0-9\-]+\.)+[a-z0-9\-]+(/[a-z0-9\-_.]*)*(\?([a-z0-9\-_]+(=[a-z0-9\-_]*|))*(&([a-z0-9\-_]+(=[a-z0-9\-_]*|))|)*)*}i, on: :create

  strip_attributes

  def self.for_event(event)
    raise ArgumentError, "Unknown event: #{event}" unless POSSIBLE_TRIGGERS.include?(event)

    Webhook.where(event: event)
  end
end
