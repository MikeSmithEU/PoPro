# frozen_string_literal: true

module Popro
  module Indicator
    require_relative 'formatter'

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
        @stream = stream || STDOUT
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

    def self.default_formatter
      ::Popro::Formatter::RewriteLine.new(
        ::Popro::Formatter::Concat.new(
          ::Popro::Formatter::Spinner.new(:dots, bounce: true),
          ::Popro::Formatter::Sprintf.new,
          (proc do |_, yielded = nil|
            yielded if yielded.is_a?(String) || yielded.is_a?(Numeric)
          end),
          separator: ' '
        )
      )
    end

    def self.default
      Stream.new(formatter: default_formatter)
    end
  end
end
