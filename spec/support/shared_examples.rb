# frozen_string_literal: true

RSpec.shared_examples 'formatter' do
  let(:described_instance) { described_class.new(*described_instance_args) }

  it 'responds to #call()' do
    expect(described_instance).to respond_to(:call)
  end
end

RSpec.shared_examples 'indicator' do
  it 'responds to #call() and #finish()' do
    %i[call finish].each do |method|
      expect(described_instance).to respond_to(method)
    end
  end
end
