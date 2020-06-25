# frozen_string_literal: true

require 'spec_helper'
require 'popro/info'

RSpec.describe Popro::Info do
  let(:described_instance) { described_class.new(total: 100) }

  it 'checks all methods are available' do
    %i[running? start finish pct pct_formatted total_length to_f next].each do |method|
      expect(described_instance).to respond_to(method)
    end
  end

  it 'maintains status' do
    expect(described_instance.running?).to be(false)
    expect(described_instance.current).to eq(0)
    expect(described_instance.total).to eq(100)
    expect(described_instance.pct).to eq(0)
    expect(described_instance.pct_formatted).to eq('0.0')
    expect(described_instance.total_length).to eq(3)
    expect(described_instance.to_f).to eq(0)

    described_instance.start

    expect(described_instance.running?).to be(true)
    expect(described_instance.current).to eq(0)
    expect(described_instance.total).to eq(100)
    expect(described_instance.pct).to eq(0)
    expect(described_instance.pct_formatted).to eq('0.0')
    expect(described_instance.total_length).to eq(3)
    expect(described_instance.to_f).to eq(0)

    described_instance.finish

    expect(described_instance.running?).to be(false)
    expect(described_instance.current).to eq(0)
    expect(described_instance.total).to eq(100)
    expect(described_instance.pct).to eq(0)
    expect(described_instance.pct_formatted).to eq('0.0')
    expect(described_instance.total_length).to eq(3)
    expect(described_instance.to_f).to eq(0)

    described_instance.start
    described_instance.next(1)
    described_instance.next(4)

    expect(described_instance.running?).to be(true)
    expect(described_instance.current).to eq(5)
    expect(described_instance.total).to eq(100)
    expect(described_instance.pct).to eq(0.05)
    expect(described_instance.pct_formatted).to eq('5.0')
    expect(described_instance.total_length).to eq(3)
    expect(described_instance.to_f).to eq(0.05)
  end

  it 'can only increase by Integer' do
    expect { described_instance.next(1.3) }.to raise_error(TypeError, 'expected an integer')
  end
end
