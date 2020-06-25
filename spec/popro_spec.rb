# frozen_string_literal: true

require 'spec_helper'
require 'popro'

RSpec.describe Popro do
  it 'checks all methods are available' do
    expect(described_class).to respond_to(:new)
    expect(described_class).to respond_to(:each)
    expect(described_class).to respond_to(:each0)
  end

  # TODO: full specs
end
