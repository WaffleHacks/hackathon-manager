require 'discordrb/webhooks'
require 'net/http'

module Webhooks
  READABLE_EVENTS = {
    "questionnaire.pending" => "New Application",
    "questionnaire.late_waitlist" => "New Late Application",
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
      # Generate the human readable content for the message
      description, fields = generate_content(type, **data)

      client = Discordrb::Webhooks::Client.new(url: url)
      response = client.execute do |builder|
        builder.add_embed do |embed|
          # Set the constants
          embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: HackathonConfig['name'], icon_url: HackathonConfig['logo_asset'])
          embed.color = '#1c7ed6'
          embed.timestamp = Time.now

          # Set the title and content
          embed.title = READABLE_EVENTS[type]
          embed.description = description

          # Set the fields
          fields.each { |field| embed.add_field(**field, inline: true) }
        end
      end

      [response.code, response.body]
    end

    def slack(url, type, **data)
      # Generate the human readable content for the message
      description, fields = generate_content(type, **data)

      # Parse the URI
      uri = URI.parse(url)

      # Build the request
      req = Net::HTTP::Post.new(uri, { 'Content-Type' => 'application/json' })

      # Setup the request body as an attachment
      body = {
        text: "#{type}: #{data.to_json}",
        blocks: [
          {
            type: "header",
            text: {
              type: "plain_text",
              text: READABLE_EVENTS[type],
              emoji: false,
            }
          },
          {
            type: "section",
            block_id: "description",
            fields: [
              {
                type: "plain_text",
                text: description
              }
            ]
          }
        ]
      }

      # Add fields if necessary
      unless fields.empty?
        body[:blocks] << {
          type: "section",
          block_id: "fields",
          fields: fields.map { |field| { type: "mrkdwn", text: "*#{field[:name]}*: #{field[:value]}" } }
        }
      end

      # Add the body to the request
      req.body = body.to_json

      # Send the request
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(req)
      end

      [response.code.to_i, response.body]
    end

    def generate_content(type, **data)
      case type
      when "questionnaire.pending"
        questionnaire = data[:questionnaire]
        school = questionnaire.school
        user = questionnaire.user
        [
          "_#{user.first_name} #{user.last_name}_ (id: #{user.id}) just applied!",
          [
            {
              name: "School",
              value: school.full_name.present? ? school.full_name : "<not provided>"
            },
            {
              name: "Discord",
              value: questionnaire.discord
            }
          ]
        ]
      when "questionnaire.late_waitlist"
        questionnaire = data[:questionnaire]
        school = questionnaire.school
        user = questionnaire.user
        [
          "_#{user.first_name} #{user.last_name}_ (id: #{user.id}) just applied! They were automatically waitlisted since the deadline passed.",
          [
            {
              name: "School",
              value: school.full_name.present? ? school.full_name : "<not provided>"
            },
            {
              name: "Discord",
              value: questionnaire.discord
            }
          ]
        ]
      when "questionnaire.rsvp_confirmed"
        questionnaire = data[:questionnaire]
        user = questionnaire.user
        ["_#{user.first_name} #{user.last_name}_ (id: #{user.id}) will be attending!", []]
      when "questionnaire.rsvp_denied"
        questionnaire = data[:questionnaire]
        user = questionnaire.user
        ["_#{user.first_name} #{user.last_name}_ (id: #{user.id}) will not be attending.", []]
      when "testing" then ["Just testing that webhooks work.", []]
      else ["Invalid event, something went very wrong", []]
      end
    end
  end
end
