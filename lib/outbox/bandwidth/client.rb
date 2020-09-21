# frozen_string_literal: true

require 'bandwidth'

module Outbox
  module Bandwidth
    # Uses Bandwidth's official Ruby API client (bandwidth) to deliver
    # SMS messages.
    #
    #   Outbox::Messages::SMS.default_client(
    #     :bandwidth,
    #     account_sid: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    #     token: 'yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy',
    #     secret: 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
    #   )
    #   sms = Outbox::Messages::SMS.new(
    #     to: '+15552224444',
    #     from: '+15551115555',
    #     body: 'Hello World'
    #   )
    #   sms.deliver
    class Client < Outbox::Clients::Base
      attr_reader :api_client
      include ::Bandwidth::Messaging

      def initialize(settings = nil)
        super

        options = @settings.dup
        @api_client = ::Bandwidth::Client.new(
          messaging_basic_auth_user_name: options[:token],
          messaging_basic_auth_password: options[:secret]
        )
        @account_id = options[:subaccount_id] || options[:account_id]
      end

      def deliver(sms)
        messaging_client = @api_client.messaging_client.client
        body = ::Bandwidth::MessageRequest.new
        body.application_id = sms[:application_id]
        body.to = sms.to
        body.from = sms.from
        body.text = sms.body
        body.media = [sms[:media_url]] unless sms[:media_url].nil?
        messaging_client.create_message(account_id(sms), body: body)
      end

      protected

      def account_id(sms)
        return sms[:account_id] unless sms[:account_id].nil?
        @account_id
      end
    end
  end
end
