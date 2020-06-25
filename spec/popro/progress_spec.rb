# frozen_string_literal: true

require 'spec_helper'
require 'popro/context'

RSpec.describe Popro::Context do
  let(:described_instance_args) { { progress: nil, info: nil, indicator: nil } }
  let(:described_instance) { described_class.new(**described_instance_args) }

  it 'checks all methods are available' do
    %i[each done formatter].each do |method|
      expect(described_instance).to respond_to(method)
    end
  end

  xit 'TODO: full specs'
end
