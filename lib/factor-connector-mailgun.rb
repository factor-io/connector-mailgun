require 'factor/connector/definition'
require 'factor/connector/runtime'

require 'mailgun'
require 'uri'
require 'websockethook'

class MailgunConnectorDefinition < Factor::Connector::Definition
  id :mailgun

  def validate(params, key, options={})
    value = params[key]
    name  = options[:name] || key.to_s.capitalize
    if options[:default]
      value ||= options[:default]
    end
    if options[:required]
      fail "#{name} (:#{key}) is required" unless value
    end

    value
  end
  def to_response(client_response)
    client_response.to_h.inject({}){|m,(k,v)| m[k.to_sym] = v; m}
  end

  resource :message do

    action :send do |params|
      domain  = validate(params,:domain, required:true)
      api_key = validate(params,:api_key, required:true, name:'API Key')
      to      = validate(params,:to, required:true)
      from    = validate(params,:from, required:true)
      subject = validate(params,:subject, required:true)
      message = validate(params,:message, required:true)
      content = { from: from, to: to, subject: subject, text: message }
      client  = Mailgun::Client.new api_key

      begin
        respond to_response(client.send_message(domain, content))
      rescue => ex
        fail "Failed to connect to mailgun server: #{ex.message}"
      end
    end

    listener :receive do
      api_key       = ''
      route_id      = ''
      hook_url      = ''
      hook          = WebSocketHook.new
      listen_thread = nil
      client        = nil

      start do |params|
        api_key = validate(params,:api_key,name:'API Key', required:true)
        filter  = validate(params,:filter, required:true, default:'catch_all()')
        client  = Mailgun::Client.new api_key

        listen_thread = Thread.new do
          hook.listen do |post|
            case post[:type]
            when 'hook'
              info "Received hook"
              trigger post[:data]
            when 'registered'
              hook_url = post[:data][:url]
              content = {
                priority: 0,
                description: 'Factor.io Mailgun Connector listener',
                expression: filter,
                action: [ "forward('#{hook_url}')" ]
              }
              info "Registering webhook '#{hook_url}' with Mailgun"
              
              begin
                response = to_response(client.post('routes',content))
              rescue => ex
                fail "Failed to connect to mailgun server: #{ex.message}"
              end
              route_id = response[:route]['id']
              info "Registered Mailgun route: #{route_id}"
              respond to_response(response)
            when 'open'
              info "Web hook status: #{post[:type]}"
            when 'restart'
              warn "Web hook restarting"
            else
              error "Web hook status: #{post[:type]}"
            end
          end
        end
      end

      stop do
        info "Stopping web hook listener on '#{hook_url}'"
        hook.stop
        info "Deleting Mailgun route '#{route_id}'"
        begin
          respond to_response(client.delete("routes/#{route_id}"))
        rescue => ex
          fail "Failed to connect to mailgun server: #{ex.message}"
        end
      end
    end
  end
end