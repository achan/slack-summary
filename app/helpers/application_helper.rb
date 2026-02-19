module ApplicationHelper
  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      no_images: true,
      link_attributes: { target: "_blank", rel: "noopener" }
    )
    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      fenced_code_blocks: true,
      strikethrough: true,
      no_intra_emphasis: true,
      tables: true
    )
    sanitize(markdown.render(emojify(text)))
  end

  def render_blocks(blocks)
    sanitize(blocks.map { |block| render_block(block) }.join)
  end

  def render_event_body(event)
    payload = event.payload
    return unless payload.is_a?(Hash)

    blocks = payload["blocks"]
    if blocks.is_a?(Array) && blocks.any?
      render_blocks(blocks)
    elsif payload["text"].present?
      render_markdown(payload["text"])
    end
  end

  def short_time_ago(time)
    seconds = (Time.current - time).to_i
    return "now" if seconds < 60

    minutes = seconds / 60
    return "#{minutes}m" if minutes < 60

    hours = minutes / 60
    return "#{hours}h" if hours < 24

    days = hours / 24
    return "#{days}d" if days < 7

    weeks = days / 7
    return "#{weeks}w" if days < 30

    months = days / 30
    "#{months}mo"
  end

  private

  def emojify(text)
    text.gsub(/:([a-z0-9_+-]+):/) do |match|
      emoji = Emoji.find_by_alias($1)
      emoji ? emoji.raw : match
    end
  end

  def render_block(block)
    case block["type"]
    when "rich_text"
      (block["elements"] || []).map { |el| render_block_element(el) }.join
    when "section"
      text = block.dig("text", "text") || ""
      type = block.dig("text", "type")
      content = type == "mrkdwn" ? render_markdown(text) : h(text)
      "<p>#{content}</p>"
    when "header"
      "<strong>#{h(block.dig("text", "text"))}</strong>"
    when "divider"
      "<hr>"
    when "context"
      items = (block["elements"] || []).map do |el|
        el["type"] == "image" ? "" : h(el["text"] || "")
      end.join(" ")
      "<p class=\"text-xs text-muted\">#{items}</p>"
    else
      ""
    end
  end

  def render_block_element(element)
    case element["type"]
    when "rich_text_section"
      "<p>#{render_inline_elements(element["elements"] || [])}</p>"
    when "rich_text_preformatted"
      "<pre><code>#{render_inline_elements(element["elements"] || [])}</code></pre>"
    when "rich_text_quote"
      "<blockquote>#{render_inline_elements(element["elements"] || [])}</blockquote>"
    when "rich_text_list"
      tag = element["style"] == "ordered" ? "ol" : "ul"
      items = (element["elements"] || []).map do |item|
        "<li>#{render_inline_elements(item["elements"] || [])}</li>"
      end.join
      "<#{tag}>#{items}</#{tag}>"
    else
      ""
    end
  end

  def render_inline_elements(elements)
    elements.map { |el| render_inline_element(el) }.join
  end

  def render_inline_element(el)
    case el["type"]
    when "text"
      text = h(el["text"])
      style = el["style"] || {}
      text = "<strong>#{text}</strong>" if style["bold"]
      text = "<em>#{text}</em>" if style["italic"]
      text = "<del>#{text}</del>" if style["strike"]
      text = "<code>#{text}</code>" if style["code"]
      text
    when "link"
      text = h(el["text"].presence || el["url"])
      "<a href=\"#{h(el["url"])}\" target=\"_blank\" rel=\"noopener\">#{text}</a>"
    when "emoji"
      if el["unicode"]
        el["unicode"].split("-").map { |cp| cp.to_i(16) }.pack("U*")
      else
        emoji = Emoji.find_by_alias(el["name"])
        emoji ? emoji.raw : ":#{el["name"]}:"
      end
    when "user"
      "<strong>@#{h(el["user_id"])}</strong>"
    when "channel"
      "<strong>##{h(el["channel_id"])}</strong>"
    else
      ""
    end
  end
end
