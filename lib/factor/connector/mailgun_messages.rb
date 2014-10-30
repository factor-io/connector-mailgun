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

  listener 'receive'
    start do |params|
      api_key = params['api_key']
      filter = params['filter'] || 'catch_all()'

      fail 'API Key (api_key) is required' unless api_key

      hook_url = web_hook do
        start do |listener_start_params, hook_data, _req, _res|
          info 'Recevied a hook call'

          headers = {}
          JSON.parse(hook_data.delete('message_headers')).map do |header|
            headers[header.first] = header.last
          end
          hook_data['headers'] = headers

          start_workflow hook_data
        end
      end

      content = {
        priority: 0,
        description: 'Factor.io Mailgun Connector listener',
        expression: filter,
        action: [ "forward(#{hook_url})" ]
      }

      base_url     = "https://api.mailgun.net/v2/routes"
      uri          = URI(base_url)
      uri.user     = 'api'
      uri.password = api_key

      begin
        response = JSON.parse(RestClient.post(uri.to_s, content))
      rescue => ex
        fail "Failed to connect to mailgun server: #{ex.message}"
      end

      @id = response['route']['id']
    end

    stop do |params|
      api_key = params['api_key']

      fail 'API Key (api_key) is required' unless api_key

      base_url     = "https://api.mailgun.net/v2/routes/#{@id}"
      uri          = URI(base_url)
      uri.user     = 'api'
      uri.password = api_key

      begin
        response = JSON.parse(RestClient.delete(uri.to_s))
      rescue => ex
        fail "Failed to connect to mailgun server: #{ex.message}"
      end
    end
  end
end