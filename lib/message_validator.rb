class MessageValidator
  # @param [Sinatra::Request] request
  # @return [TrueClass, FalseClass]
  def self.valid?(request)
    exlibris_signature = request.env['X-Exl-Signature'] || request.env['HTTP_X_EXL_SIGNATURE']
    hmac = OpenSSL::HMAC.new ENV['WEBHOOK_SECRET'], OpenSSL::Digest.new('sha256')
    hmac.update request.body.read
    exlibris_signature == Base64.strict_encode64(hmac.digest)
  end
end