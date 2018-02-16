require 'sinatra'
require 'json'
require 'base64'

get '/' do
  challenge = request.params['challenge']
  response.write({ challenge: challenge }.to_json)
  response.close
end

post '/' do
  body = request.body.read

  unless validateSignature(body, ENV['WEBHOOK_SECRET'], request.env['X-Exl-Signature'] || request.env['HTTP_X_EXL_SIGNATURE'])
    response.status = 401
    response.write({errorMessage: 'Invalid Signature'}.to_json)
    response.close
  else
    body = JSON.parse(body)
    logger.info body
  end
end

def validateSignature(body, secret, signature)
  digest = OpenSSL::Digest.new("sha256")
  hmac = OpenSSL::HMAC.new(secret, digest)
  hmac.update(body)
  hash = Base64.strict_encode64(hmac.digest)

  return hash == signature
end
