# frozen_string_literal: true

require 'popro'

module Popro
  module Indicator
    require_relative 'formatter'

    class Null
      def self.new
        self
      end

      def self.initialize
        self
      end

      def self.call(*_args); end

      def self.finish; end
    end

    class Aggregate
      def initialize(*indicators)
        @indicators = indicators
      end

      def call(*args)
        @indicators.each do |indicator|
          indicator.call(*args)
        end
      end

      def finish
        @indicators.each(&:finish)
      end
    end

    class Stream
      attr_accessor :formatter

      def initialize(stream: nil, formatter: nil)
        formatter = self.class.default_formatter(formatter) if formatter.nil? || formatter.is_a?(String)

        @formatter = formatter
        @stream = stream || $stdout
      end

      def call(*args)
        @stream << @formatter.call(*args)
        @stream.flush
      end

      def finish
        @stream << "\n"
        @stream.flush
      end

      def self.default_formatter(format_string = nil)
        ::Popro::Formatter::Sprintf.new(format_string)
      end
    end

    class Callback
      def initialize(finish = nil, &block)
        @finish = finish
        @callback = block
      end

      def call(*args)
        @callback.call(*args)
      end

      def finish
        @finish&.call
      end
    end

    def self.default_formatter(*extra_formatters)
      ::Popro::Formatter::RewriteLine.new(
        ::Popro::Formatter::Concat.new(
          ::Popro::Formatter::Spinner.new(:dots, bounce: true),
          ::Popro::Formatter::Sprintf.new,
          *extra_formatters,
          (proc do |_, yielded = nil|
            yielded if yielded.is_a?(String) || yielded.is_a?(Numeric)
          end),
          separator: ' '
        )
      )
    end

    def self.default(*extra_formatters)
      Stream.new(formatter: default_formatter(*extra_formatters))
    end
  end
end
