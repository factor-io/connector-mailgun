require 'factor/connector/definition'
require 'factor/connector/runtime'
require 'rest-client'

class MailgunConnectorDefinition < Factor::Connector::Definition

  id :mailgun

  resource :message do

    action :send do |params|
    end

    listener :receive do
      start do |params|
      end

      stop do
      end
    end
  end
end