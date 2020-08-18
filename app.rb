require 'dotenv/load'
require 'sinatra'
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
  request_body = request.body.read
  unless MessageValidator.valid?(
      request_body,
      request.env['X-Exl-Signature'] || request.env['HTTP_X_EXL_SIGNATURE']
  )
    response.status = 401
    response.write({ error_message: 'Invalid Signature' }.to_json)
    response.close
    return
  end

  bib_action = WebhookBibResponse.new request_body

  # No MMS ID? Nothing we can do with this hook
  unless bib_action.mms_id
    response.status = 400
    response.write({ error_message: 'Failed to extract MMS ID from response' }.to_json)
    response.close
    return
  end

  # Based on the BIB action, do something (for now, post a Slack notification)
  # Use a response status with light semantic value, mostly for spec purposes
  # as Alma/ExL likely doesn't care about response codes.
  response.status = case bib_action.event
                    when 'BIB_UPDATED'
                      # do noting for now
                      # SlackNotifier.send bib_action.template
                      204
                    when 'BIB_DELETED'
                      # do nothing for now
                      # SlackNotifier.send bib_action.template
                      204
                    when 'BIB_CREATED'
                      SlackNotifier.ping bib_action.template
                      200
                    else
                      500
                    end
  response.close
end
