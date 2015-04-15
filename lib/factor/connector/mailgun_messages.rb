require 'factor-connector-api'
require 'uri'
require 'rest-client'

Factor::Connector.service 'mailgun_messages' do

  listener 'receive' do
    start do |params|
      api_key = params['api_key']
      filter = params['filter'] || 'catch_all()'

      fail 'API Key (api_key) is required' unless api_key

      hook_url = web_hook do
        start do |listener_start_params, hook_data, _req, _res|
          info 'Recevied a hook call'

          headers = {}
          JSON.parse(hook_data.delete('message_headers'), symbolize_names: true).map do |header|
            headers[header.first] = header.last
          end
          hook_data['headers'] = headers

          start_workflow hook_data
        end
      end

      info "Starting webhook listener at #{hook_url}"

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

      info "Registering webhook with Mailgun"
      begin
        response = JSON.parse(RestClient.post(uri.to_s, content), symbolize_names: true)
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
        response = JSON.parse(RestClient.delete(uri.to_s), symbolize_names: true)
      rescue => ex
        fail "Failed to connect to mailgun server: #{ex.message}"
      end
    end
  end
end