# frozen_string_literal: true

require 'bandwidth'

module Outbox
  module Bandwidth
    # Uses Bandwidth's official Ruby API client (bandwidth) to deliver
    # SMS messages.
    #
    # https://dev.bandwidth.com/sdks/ruby.html
    #
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
        bandwidth_client_settings = options.slice(
          :messaging_basic_auth_user_name, 
          :messaging_basic_auth_password, 
          :voice_basic_auth_user_name, 
          :voice_basic_auth_password,
          :two_factor_auth_basic_auth_user_name,
          :two_factor_auth_basic_auth_password,
          :environment,
          :base_url
        )
        @account_id = options[:account_id]
        @application_id = options[:application_id]
        @api_client = ::Bandwidth::Client.new(
          bandwidth_client_settings
        )
      end

      def deliver(sms)
        messaging_client = @api_client.messaging_client.client
        body = create_message_body(sms)
        messaging_client.create_message(account_id(sms), body: body)
      end

      protected

      def account_id(sms)
        return sms[:account_id] unless sms[:account_id].nil?
        @account_id
      end

      # rubocop:disable Metrics/AbcSize
      def create_message_body(sms)
        body = ::Bandwidth::MessageRequest.new
        body.application_id = sms[:application_id] || @application_id
        body.to = sms.to.is_a?(Array) ? sms.to : [sms.to]
        body.from = sms.from
        body.text = sms.body
        body.tag = sms[:tag] unless sms[:tag].nil?
        body.media = [sms[:media_url]] unless sms[:media_url].nil?
        body
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
