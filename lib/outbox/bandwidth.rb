# frozen_string_literal: true

require 'outbox'

module Outbox
  module Bandwidth
    require 'outbox/bandwidth/version'
    require 'outbox/bandwidth/client'
  end

  Messages::SMS.register_client_alias(:bandwidth, Outbox::Bandwidth::Client)
end
