# frozen_string_literal: true

module Popro
  module Indicator
    module Rails
      class ServerSentEvent
        DEFAULT_HEADERS ||= {
          'Last-Modified': 0,
          'ETag': '',
          'Cache-Control': 'no-cache, must-revalidate',
          'X-Accel-Buffering': 'no',
          'Content-Type': 'text/event-stream'
        }.freeze

        def initialize(response, **options)
          response.status = 200
          response.headers.merge!(options.delete(:headers) || DEFAULT_HEADERS)
          formatter = options.delete(:formatter) || self.class.method(:default_formatter)

          @stream = ::ActionController::Live::SSE.new(response.stream, **options)
          @formatter = formatter
          @response = response
        end

        def call(*args)
          @stream.write(@formatter.call(*args))
        rescue ::ActionController::Live::ClientDisconnected
          # ignore disconnections
        end

        def finish
          @stream.close
        rescue ::ActionController::Live::ClientDisconnected
          # ignore disconnections
        end

        def self.default_formatter(info, yielded)
          info.to_h.merge(yielded: yielded)
        end
      end
    end
  end
end
