require File.expand_path '../spec_helper.rb', __FILE__

RSpec.describe "Alma Webhook app", type: :request do
  let(:webhook_post_body_json) do
    '{
      "id": "3564133053359942874",
      "action": "USER",
      "institution": {
        "value": "EXLDEV1_INST",
        "desc": "Main Campus"
      },
      "time": "2017-11-29T10:50:10.569Z",
      "event": null,
      "webhook_user": {
        "method": "UPDATE",
        "cause": "UI",
        "user": {}
      }
    }'
  end
  context 'GET' do
    it "respond at /" do
      get '/'
      expect(last_response).to be_ok
    end
    it 'echos a challenge param' do
      get '/', challenge: 'test'
      expect(last_response.body).to include 'test'
    end
  end
  context 'POST' do
    it 'returns 200 if signature header is valid' do
      header 'X-Exl-Signature', 'M1klMCQOeneKQclzYimb9Gor2jS5pK83/TqFAEL4w48='
      header 'CONTENT_TYPE', 'application/json'
      post '/', webhook_post_body_json
      expect(last_response.status).to eq 200
    end
  end
end