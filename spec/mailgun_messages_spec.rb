require 'spec_helper'

describe MailgunConnectorDefinition do
  describe :messages do
    it 'can :send' do
      params = {
        api_key: @api_key,
        domain:  @domain,
        to:      'factor-test@mailinator.com',
        from:    'Factor Test <factor-test@mailinator.com>',
        subject: "Test on #{Time.now}",
        message: 'Test'
      }

      @runtime.run([:message,:send], params)

      expect(@runtime).to respond
      data = @runtime.logs.last[:data]

      expect(data).to be_a(Hash)
      expect(data).to include(:message)
      expect(data[:message]).to be_a(String)
      expect(data).to include(:id)
      expect(data[:id]).to be_a(String)
      expect(data[:message]).to be == 'Queued. Thank you.'
    end

    it 'can :receive' do
      @runtime.start_listener([:message,:receive], api_key: @api_key)
      expect(@runtime).to message info:"Web hook status: open"
      expect(@runtime).to respond

      send_email

      expect(@runtime).to trigger
      @runtime.logs.clear
      @runtime.stop_listener
      expect(@runtime).to respond
    end
  end
end