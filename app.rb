require 'dotenv/load'
require 'json'
require 'base64'
require 'sinatra'
require 'slack-notifier'

# echo back challenge to confirm endpoint viability
get '/' do
  challenge = request.params['challenge']
  response.write({ challenge: challenge }.to_json)
  response.close
end

# upon validating EXL sig header, push Webhook notification body to Slack
post '/' do
  body = request.body.read
  exlibris_signature = request.env['X-Exl-Signature'] || request.env['HTTP_X_EXL_SIGNATURE']
  unless valid_signature?(body, exlibris_signature)
    response.status = 401
    response.write({ error_message: 'Invalid Signature' }.to_json)
    response.close
    return
  end

  webhook_response = JSON.parse(body)
  slack = Slack::Notifier.new ENV['WEBHOOK_SLACK_WEBHOOK']
  slack.ping "```#{webhook_response}```" unless ENV['RACK_ENV'] == 'test'
  response.status = 200
  response.close
end

# validate signature
def valid_signature?(body, signature)
  digest = OpenSSL::Digest.new 'sha256'
  hmac = OpenSSL::HMAC.new ENV['WEBHOOK_SECRET'], digest
  hmac.update body
  hash = Base64.strict_encode64 hmac.digest
  hash == signature
end