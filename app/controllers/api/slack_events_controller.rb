module Api
  class SlackEventsController < ApplicationController
    include SlackSignatureVerification

    skip_before_action :verify_authenticity_token
    before_action :verify_slack_signature, unless: :url_verification?

    def create
      payload = parsed_payload

      if url_verification?
        return render json: { challenge: payload["challenge"] }
      end

      event = payload["event"]
      return head :ok unless event

      channel_id = event["channel"] || event.dig("item", "channel")
      return head :ok unless channel_id

      slack_channel = SlackChannel.find_by(channel_id: channel_id, active: true)
      slack_channel ||= auto_track_direct_conversation(channel_id, event["channel_type"])
      return head :ok unless slack_channel

      event_id = payload["event_id"]
      return head :ok unless event_id

      SlackEvent.create_or_find_by(event_id: event_id) do |e|
        e.slack_channel = slack_channel
        e.event_type = event["type"]
        e.user_id = event["user"]
        e.ts = event["ts"]
        e.thread_ts = event["thread_ts"]
        e.payload = event
      end

      head :ok
    end

    private

    def url_verification?
      parsed_payload["type"] == "url_verification"
    end

    def auto_track_direct_conversation(channel_id, channel_type)
      return unless %w[im mpim].include?(channel_type)

      workspace = Workspace.find_by(signing_secret: ENV["SLACK_SIGNING_SECRET"])
      return unless workspace

      case channel_type
      when "im"
        return unless workspace.include_dms
      when "mpim"
        return unless workspace.include_mpims
      end

      workspace.slack_channels.find_or_create_by(channel_id: channel_id) do |c|
        c.channel_name = channel_id
      end
    end
  end
end
