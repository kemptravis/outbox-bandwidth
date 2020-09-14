# frozen_string_literal: true

require 'spec_helper'

describe Outbox::Bandwidth do
  it 'has a version number' do
    expect(Outbox::Bandwidth::VERSION).not_to be nil
  end
end
