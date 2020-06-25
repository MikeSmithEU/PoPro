# frozen_string_literal: true

require 'spec_helper'
require 'popro/indicator'

RSpec.describe Popro::Indicator::Aggregate do
  let(:described_instance) { described_class.new }

  it_should_behave_like 'indicator'

  xit 'TODO: full specs'
end

RSpec.describe Popro::Indicator::Stream do
  let(:described_instance) { described_class.new(formatter: proc { |*_args| nil }) }

  it_should_behave_like 'indicator'

  xit 'TODO: full specs'
end
