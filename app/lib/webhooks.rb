require 'discordrb/webhooks'
require 'net/http'

module Webhooks
  READABLE_TRIGGERS = {
    "questionnaire.pending" => "New Application",
    "questionnaire.waitlist" => "New Late Application",
    "questionnaire.rsvp_confirmed" => "RSVP Confirmed",
    "questionnaire.rsvp_denied" => "RSVP Denied",
    "testing" => "Webhooks work!",
  }.freeze

  def self.emit(format, url, secret, type, **data)
    return unless Webhook::POSSIBLE_FORMATS.include? format

    case format
    when "json" then standard(url, secret, type, **data)
    when "discord" then discord(url, type, **data)
    when "slack" then slack(url, type, **data)
    end
  end

  class << self
    private

    def standard(url, secret, type, **data)
      # Parse the URI
      uri = URI.parse(url)

      # Add headers
      headers = { 'Content-Type' => 'application/json' }
      if secret != ""
        headers['Authorization'] = secret
      end

      # Build the request
      req = Net::HTTP::Post.new(uri, headers)
      req.body = { type: type }.deep_merge(data).to_json

      # Send the request
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(req)
      end

      [response.code.to_i, response.body]
    end

    def discord(url, type, **data)
      client = Discordrb::Webhooks::Client.new(url: url)
      response = client.execute do |builder|
        builder.add_embed do |embed|
          # Set the constants
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: HackathonConfig['name'], icon_url: HackathonConfig['logo_asset'])
          embed.color = '#1c7ed6' # TODO: add hackathon specific color if exists
          embed.timestamp = Time.now

          # TODO: figure out how to format data based on event type

          # Set the title and content
          embed.title = READABLE_TRIGGERS[type]
          embed.description = "<PLACEHOLDER>"
        end
      end

      [response.code, response.body]
    end

    def slack(url, type, **data)
      # Parse the URI
      uri = URI.parse(url)

      # Build the request
      req = Net::HTTP::Post.new(uri, { 'Content-Type' => 'application/json' })

      # TODO: figure out how to format data based on event type

      # Setup the request body as an attachment
      req.body = {
        text: "#{type}: #{data.to_json}",
        blocks: [
          {
            type: "header",
            text: {
              type: "plain_text",
              text: READABLE_TRIGGERS[type],
              emoji: false,
            }
          },
          {
            type: "section",
            block_id: "description",
            fields: [
              {
                type: "plain_text",
                text: "Testing"
              }
            ]
          }
        ]
      }.to_json

      # Send the request
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(req)
      end

      [response.code.to_i, response.body]
    end
  end
end
