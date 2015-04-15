require 'spec_helper'

describe MailgunConnectorDefinition do
  describe :messages do
    it 'can send a message' do

      

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
  end
end