class SummarizeJob < ApplicationJob
  queue_as :default

  MODEL = "claude-sonnet-4-5-20250929"

  def perform(workspace_id:, channel_id:, period_start: 24.hours.ago, period_end: Time.current)
    workspace = Workspace.find(workspace_id)
    events = workspace.events
      .for_channel(channel_id)
      .in_window(period_start, period_end)
      .order(:created_at)

    return if events.empty?

    grouped = group_by_thread(events)
    prompt = build_prompt(grouped)

    client = Anthropic::Client.new(api_key: ENV["ANTHROPIC_API_KEY"])
    response = client.messages.create(
      model: MODEL,
      max_tokens: 2048,
      messages: [ { role: "user", content: prompt } ]
    )

    result_text = response.content.first.text
    parsed = JSON.parse(result_text)

    summary = Summary.create!(
      workspace: workspace,
      channel_id: channel_id,
      period_start: period_start,
      period_end: period_end,
      summary_text: parsed["summary"],
      model_used: MODEL
    )

    (parsed["action_items"] || []).each do |item|
      summary.action_items.create!(
        workspace: workspace,
        channel_id: channel_id,
        description: item["description"],
        assignee_user_id: item["assignee"],
        source_ts: item["source_ts"],
        status: "open"
      )
    end
  end

  private

  def group_by_thread(events)
    threads = {}
    top_level = []

    events.each do |event|
      if event.thread_ts.present? && event.thread_ts != event.ts
        threads[event.thread_ts] ||= []
        threads[event.thread_ts] << event
      else
        top_level << event
      end
    end

    { top_level: top_level, threads: threads }
  end

  def build_prompt(grouped)
    lines = [ "Summarize the following Slack channel activity and extract action items." ]
    lines << ""
    lines << "Return valid JSON with this structure:"
    lines << '{ "summary": "...", "action_items": [{ "description": "...", "assignee": "user_id or null", "source_ts": "..." }] }'
    lines << ""
    lines << "## Messages"
    lines << ""

    grouped[:top_level].each do |event|
      text = event.payload.is_a?(Hash) ? event.payload["text"] : ""
      lines << "[#{event.ts}] #{event.user_id}: #{text}"

      thread_replies = grouped[:threads][event.ts]
      if thread_replies
        thread_replies.each do |reply|
          reply_text = reply.payload.is_a?(Hash) ? reply.payload["text"] : ""
          lines << "  [#{reply.ts}] #{reply.user_id}: #{reply_text}"
        end
      end
    end

    lines.join("\n")
  end
end
