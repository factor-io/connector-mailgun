require "codeclimate-test-reporter"
require 'rspec'
require 'factor/connector/test'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

require 'factor-connector-mailgun'

RSpec.configure do |c|
  c.include Factor::Connector::Test

  c.before :each do
    @api_key = ENV['MAILGUN_API_KEY']
    @domain  = ENV['MAILGUN_DOMAIN']
    @runtime = Factor::Connector::Runtime.new(MailgunConnectorDefinition)
  end

  def send_email(options={})
    to      = options[:to] || "test@#{@domain}"
    from    = options[:from] || "test@#{@domain}"
    subject = options[:subject] || "test"
    text    = options[:text] || options[:message] || "test messgae"
    client  = Mailgun::Client.new @api_key
    content = { from: from, to: to, subject: subject, text: message }

    client.send_message(@domain, content)
  end
end