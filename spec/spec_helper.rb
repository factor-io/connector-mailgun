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
end