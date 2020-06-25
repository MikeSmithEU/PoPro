# frozen_string_literal: true

require 'spec_helper'

module ActionController
  module Live
    class Stream
    end

    class SSE
      def initialize(*_args); end

      def write(*_args); end

      def close(*_args); end
    end

    class ClientDisconnected < StandardError; end

    class Response
      def status=(*_args); end

      def headers; end

      def stream; end
    end
  end
end

require 'popro/indicator/rails'

RSpec.describe Popro::Indicator::Rails::ServerSentEvent do
  xit 'do proper mocking and tests' do
    let(:sse) { instance_double(ActionController::Live::SSE) }
    let(:sse_class) { class_double(ActionController::Live::SSE) }
    let(:response) { instance_double(ActionController::Live::Response) }
    let(:client_disconnected) { instance_double(ActionController::Live::ClientDisconnected) }
    let(:stream) { instance_double(ActionController::Live::Stream) }

    before do
      allow(response).to receive(:"status=").and_return(nil)
      allow(response).to receive(:headers).and_return({})
      allow(response).to receive(:stream).and_return(nil)
    end

    let(:described_instance) { described_class.new response }

    it_should_behave_like 'indicator'

    it 'calls write on call' do
      expect(sse_class).to receive(:write).with('[0/10]')
      indicator = Popro::Indicator::Rails::ServerSentEvent.new(response)
      indicator.call(nil, '[0/10]')
    end
  end
end
