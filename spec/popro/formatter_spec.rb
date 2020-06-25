# frozen_string_literal: true

require 'spec_helper'
require 'popro/formatter'
require 'popro/info'

RSpec.describe Popro::Formatter do
  let(:info) { Popro::Info.new current: 9, total: 100 }
  let(:info10) { Popro::Info.new current: 10, total: 100 }
  let(:info50) { Popro::Info.new total: 50 }
  let(:info20) { Popro::Info.new current: 20, total: 100 }

  describe Popro::Formatter::Aggregate do
    let(:described_instance_args) { [proc {}] }

    it_should_behave_like 'formatter'

    it 'allows aggregating procs' do
      me = described_class.new(proc { 'A' }, proc { 'B' })
      expect(me.call(info)).to eq('AB')
    end

    it 'allows aggregating classes' do
      me = described_class.new(
        Popro::Formatter::RewriteLine.new(Popro::Formatter::Sprintf.new('[%<current>d/%<total>d]')),
        proc { 'proc' }
      )
      expect(me.call(info)).to eq("\r[9/100]proc")
      expect(me.call(info10)).to eq("\r[10/100]proc")
      expect(me.call(info)).to eq("\r[9/100] proc")
    end

    it 'allows custom join callback' do
      me = described_class.new(proc { 'A' }, proc { 'B' }) do |results|
        %(["#{results.join('","')}"])
      end
      expect(me.call(info)).to eq('["A","B"]')
    end
  end

  describe Popro::Formatter::RewriteLine do
    let(:described_instance_args) { [proc {}] }

    it_should_behave_like 'formatter'

    it 'pads the string correctly' do
      me = described_class.new(Popro::Formatter::Sprintf.new('[%<current>d/%<total>d]'))

      expect(me.call(info)).to eq("\r[9/100]")
      expect(me.call(info10)).to eq("\r[10/100]")
      expect(me.call(info)).to eq("\r[9/100] ")
    end
  end

  describe Popro::Formatter::Concat do
    let(:described_instance_args) { [proc {}] }

    it_should_behave_like 'formatter'

    it 'concats results' do
      me = described_class.new(proc { 'A' }, proc { 'B' }, proc { 'C' })
      expect(me.call(info)).to eq('ABC')
    end

    it 'allows custom separator' do
      me = described_class.new(proc { 'A' }, proc { 'B' }, separator: ' & ')
      expect(me.call(info)).to eq('A & B')
    end
  end

  describe Popro::Formatter::Sprintf do
    let(:described_instance_args) { [] }

    it_should_behave_like 'formatter'

    [
      ['', '', ''],
      ['[%<current>d/%<total>d]', '[0/50]', '[20/100]'],
      ['%<pct_formatted>s', '0.0', '20.0'],
      ['%<current>{n}s', ' 0', ' 20']
    ].each do |(format_string, expected, expected_next)|
      it "accepts format_string #{format_string.inspect}" do
        me = described_class.new format_string
        expect(me.call(info50)).to eq(expected)
        expect(me.call(info20)).to eq(expected_next)
      end
    end
  end

  describe Popro::Formatter::Looper do
    let(:described_instance_args) { [] }

    it_should_behave_like 'formatter'

    it 'outputs continuous dots' do
      me = described_class.new
      50.times do
        expect(me.call(nil)).to eq('.')
      end
    end

    it 'allows for a custom enumerator' do
      me = described_class.new 0..10
      50.times do
        (0..10).each do |c|
          expect(me.call(nil)).to eq(c)
        end
      end
    end

    it 'allows for a custom enumerator string' do
      me = described_class.new '...LOADING...'
      50.times do
        '...LOADING...'.split('').each do |c|
          expect(me.call(nil)).to eq(c)
        end
      end
    end
  end

  describe Popro::Formatter::Spinner do
    let(:described_instance_args) { [] }
    let(:slashes) { '-\\|/'.split('') }

    it_should_behave_like 'formatter'

    it 'has a "slashes" default spinner' do
      me = described_class.new

      10.times do
        slashes.each do |c|
          expect(me.call(nil)).to eq(c)
        end
      end
    end

    it 'bounces' do
      me = described_class.new(:slashes, bounce: true)

      10.times do
        slashes.each do |c|
          expect(me.call(nil)).to eq(c)
        end
        slashes.reverse.each do |c|
          expect(me.call(nil)).to eq(c)
        end
      end
    end

    it 'reverses' do
      me = described_class.new(:slashes, reverse: true)

      10.times do
        slashes.reverse.each do |c|
          expect(me.call(nil)).to eq(c)
        end
      end
    end

    it 'does predefined styles as intended' do
      described_class::STYLES.each do |style, chars|
        me = described_class.new style
        20.times do
          chars.split('').each do |c|
            expect(me.call(nil)).to eq(c)
          end
        end
      end
    end
  end
end
