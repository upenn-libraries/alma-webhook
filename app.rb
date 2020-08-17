require 'dotenv/load'
require 'json'
require 'base64'
require 'sinatra'
require 'slack-notifier'
require './lib/slack_notifier'
require './lib/webhook_bib_response'
require './lib/message_validator'

# echo back challenge to confirm endpoint viability
get '/' do
  challenge = request.params['challenge']
  response.write({ challenge: challenge }.to_json)
  response.close
end

# upon validating EXL sig header, push Webhook notification body to Slack
post '/' do
  unless MessageValidator.valid? request
    response.status = 401
    response.write({ error_message: 'Invalid Signature' }.to_json)
    response.close
    return
  end

  bib_action = WebhookBibResponse.new request.body.read

  unless bib_action.mms_id
    response.status = 400
    response.write({ error_message: 'Failed to extract MMS ID from response' }.to_json)
    response.close
    return
  end

  slack = SlackNotifier.new

  case bib_action.event
  when 'BIB_UPDATED'
    # do noting for now
    # slack.send bib_action.template
  when 'BIB_DELETED'
    # do nothing for now
    # slack.send bib_action.template
  when 'BIB_CREATED'
    slack.ping bib_action.template
  end

  response.status = 204
  response.close
end
