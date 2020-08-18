class MessageValidator
  # @param [String] request_body
  # @return [TrueClass, FalseClass]
  def self.valid?(request_body, exl_signature)
    hmac = OpenSSL::HMAC.new ENV['WEBHOOK_SECRET'], OpenSSL::Digest.new('sha256')
    hmac.update request_body
    exl_signature == Base64.strict_encode64(hmac.digest)
  end
end