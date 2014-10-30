require 'factor-connector-api'
require 'uri'
require 'rest-client'

Factor::Connector.service 'mailgun_messages' do

  action 'send' do |params|
    domain  = params['domain']
    api_key = params['api_key']
    to      = params['to']
    from    = params['from']
    subject = params['subject']
    message = params['message']


    fail 'Domain (domain) is required' unless domain
    fail 'API Key (api_key) is required' unless api_key
    fail 'To (to) is required' unless to
    fail 'Subject (subject) is required' unless subject
    fail 'Message (message) is required' unless message

    base_url     = "https://api.mailgun.net/v2/#{domain}"
    uri          = URI(base_url)
    uri.path     = uri.path + "/messages"
    uri.user     = 'api'
    uri.password = api_key

    content = { from: from, to: to, subject: subject, text: message }

    begin
      response = JSON.parse(RestClient.post(uri.to_s, content))
    rescue => ex
      fail "Failed to connect to mailgun server: #{ex.message}"
    end

    action_callback response
  end
end