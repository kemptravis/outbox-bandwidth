# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'

describe Outbox::Bandwidth::Client do
  describe '.new' do
    context 'with a messaging_basic_auth' do
      it 'configures the Bandwidth API client' do
        api_client = double(:api_client)
        expect(::Bandwidth::Client).to receive(:new).with(
          messaging_basic_auth_user_name: 'AC1',
          messaging_basic_auth_password: 'abcdef'
        ).and_return(api_client)
        client = Outbox::Bandwidth::Client.new(
          messaging_basic_auth_user_name: 'AC1',
          messaging_basic_auth_password: 'abcdef'
        )
        expect(client.api_client).to be(api_client)
      end
    end
    context 'with a custom environment and base url' do
      it 'configures the Bandwidth API client' do
        api_client = double(:api_client)
        expect(::Bandwidth::Client).to receive(:new).with(
          messaging_basic_auth_user_name: 'AC1',
          messaging_basic_auth_password: 'abcdef',
          environment: 'custom_env',
          base_url: 'custom.test.com'
        ).and_return(api_client)
        client = Outbox::Bandwidth::Client.new(
          messaging_basic_auth_user_name: 'AC1',
          messaging_basic_auth_password: 'abcdef',
          environment: 'custom_env',
          base_url: 'custom.test.com'
        )
        expect(client.api_client).to be(api_client)
      end
    end
  end

  describe '#deliver' do
    before do
      @messaging_client = double(:messaging_client)
      @api_client = double(:api_client)
      @body = double(:body)
      allow(::Bandwidth::MessageRequest).to receive(:new).and_return(@body)
      allow(::Bandwidth::Client).to receive(:new).with(
        messaging_basic_auth_user_name: 'AC1',
        messaging_basic_auth_password: 'abcdef'
      ).and_return(@api_client)
      @client = Outbox::Bandwidth::Client.new(
        messaging_basic_auth_user_name: 'AC1',
        messaging_basic_auth_password: 'abcdef',
        account_id: 'account_1'
      )
      @sms = Outbox::Messages::SMS.new do
        to '+14155551212'
        from 'Company Name'
        body 'Hello world.'
      end
    end

    it 'delivers the SMS' do
      expect(@body).to receive(:application_id=)
      expect(@body).to receive(:to=)
      expect(@body).to receive(:from=)
      expect(@body).to receive(:text=)
      expect(@api_client).to receive_message_chain(:messaging_client, :client) { @messaging_client }
      expect(@messaging_client).to receive(:create_message).with(
        'account_1',
        body: @body
      )
      @client.deliver(@sms)
    end

    context 'with a subaccount' do
      it 'delivers the SMS from the subaccount' do
        @sms[:account_id] = 'subaccount_id_1'
        expect(@body).to receive(:application_id=)
        expect(@body).to receive(:to=)
        expect(@body).to receive(:from=)
        expect(@body).to receive(:text=)
        expect(@api_client).to receive_message_chain(:messaging_client, :client) { @messaging_client }
        expect(@messaging_client).to receive(:create_message).with(
          'subaccount_id_1',
          body: @body
        )
        @client.deliver(@sms)
      end
    end
  end
end
