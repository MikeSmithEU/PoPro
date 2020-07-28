# frozen_string_literal: true

require 'spec_helper'
require 'popro/context'

RSpec.describe Popro::Progress do
  let(:described_instance_args) { { progress: nil, info: nil, indicator: nil } }
  let(:described_instance) { described_class.new(**described_instance_args) }

  it 'checks all methods are available' do
    %i[each done formatter current total will done].each do |method|
      expect(described_instance).to respond_to(method)
    end
  end

  it 'checks we can dynamically add to total' do
    progress = described_class.new
    expect(progress.total).to be 0
    expect(progress.current).to be 0

    expect(progress.add(50)).to be progress
    expect(progress.total).to be 50
    expect(progress.current).to be 0
  end

  xit 'TODO: full specs'
end
