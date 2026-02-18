module SlackSignatureVerification
  extend ActiveSupport::Concern

  private

  def verify_slack_signature
    signing_secret = ENV["SLACK_SIGNING_SECRET"]
    return head :unauthorized if signing_secret.blank?

    timestamp = request.headers["X-Slack-Request-Timestamp"]
    return head :unauthorized if timestamp.blank?

    if (Time.now.to_i - timestamp.to_i).abs > 300
      return head :unauthorized
    end

    body = request_body
    sig_basestring = "v0:#{timestamp}:#{body}"
    computed = "v0=#{OpenSSL::HMAC.hexdigest("SHA256", signing_secret, sig_basestring)}"

    unless ActiveSupport::SecurityUtils.secure_compare(computed, request.headers["X-Slack-Signature"].to_s)
      head :unauthorized
    end
  end

  def request_body
    @_raw_body ||= begin
      request.body.rewind
      body = request.body.read
      request.body.rewind
      body
    end
  end

  def parsed_payload
    @_parsed_payload ||= JSON.parse(request_body)
  end
end
