require 'spec_helper'

describe 'Mailgun' do
  describe 'Messages' do
    it 'can send a message' do
      service_instance = service_instance('mailgun_messages')

      params = {
        'api_key' => ENV['MAILGUN_API_KEY'],
        'to'      => 'factor-test@mailinator.com',
        'from'    => 'Factor Test <factor-test@mailinator.com>',
        'domain'  => ENV['MAILGUN_DOMAIN'],
        'subject' => "Test on #{Time.now}",
        'message' => 'Test'
      }

      service_instance.test_action('send',params) do
        response = expect_return
        expect(response[:payload]).to be_a(Hash)
        expect(response[:payload]).to include('message')
        expect(response[:payload]['message']).to be_a(String)
        expect(response[:payload]).to include('id')
        expect(response[:payload]['id']).to be_a(String)
        expect(response[:payload]['message']).to be == 'Queued. Thank you.'
      end
    end
  end
end