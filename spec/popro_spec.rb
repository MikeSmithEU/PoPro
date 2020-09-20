# frozen_string_literal: true

require 'spec_helper'
require 'popro'

class IndicatorStub
  def call(info, yielded)
    "[#{info.current}/#{info.total}] #{yielded}"
  end

  def finish
    nil
  end
end

class Stub
  def call; end
end

RSpec.shared_examples 'normal progress indication' do
end

RSpec.describe Popro do
  it 'checks all methods are available' do
    expect(described_class).to respond_to(:new)
    expect(described_class).to respond_to(:each)
    expect(described_class).to respond_to(:each_will)
  end

  let(:iterable) { (0..9) }
  let(:stub) { Stub.new }
  let(:indicator) { IndicatorStub.new }

  it 'supports each' do
    # expect these indications
    iterable.map do |num|
      expect(indicator).to receive(:call)
        .with(be_instance_of(Popro::Info), "FROM RETURN EACH: #{num}").and_call_original
    end

    # expect one finish call to the indicator
    expect(indicator).to receive(:finish)
      .with(no_args).and_call_original

    described_class.each(iterable, indicator: indicator) do |num, progress:|
      expect(progress).to be_instance_of(Popro::Info)

      "FROM RETURN EACH: #{num}" # rubocop:disable Lint/Void
    end
  end

  it 'supports each_will' do
    titler = proc { |num| "Value: #{num}" }

    # expect these indications
    iterable.flat_map do |num|
      expect(indicator).to receive(:call)
        .with(be_instance_of(Popro::Info), "  #{titler.call(num)}").and_call_original

      expect(indicator).to receive(:call)
        .with(be_instance_of(Popro::Info), "✔ #{titler.call(num)}").and_call_original
    end

    # call titler once per iteration
    iterable.each { |num| expect(titler).to receive(:call).with(num).and_call_original }

    # expect one start call to the indicator
    expect(indicator).not_to receive(:start)

    # expect one finish call to the indicator
    expect(indicator).to receive(:finish)
      .with(no_args).and_call_original

    described_class.each_will(iterable, titler, indicator: indicator) do
    end
  end

  it 'can be silenced' do
    expect(described_class.silenced?).to be(false)

    described_class.silenced do
      expect(described_class.silenced?).to be(true)

      # expect these indications not to be called
      expect(indicator).not_to receive(:start)
      expect(indicator).not_to receive(:call)
      expect(indicator).not_to receive(:finish)

      # make sure block is still called
      expect(stub).to receive(:call).exactly(iterable.size).times

      described_class.each(iterable, indicator: indicator) do |num, progress:|
        expect(progress).to be_instance_of(Popro::Info)

        stub.call
        num # rubocop:disable Lint/Void
      end
    end

    expect(described_class.silenced?).to be(false)
  end
end
