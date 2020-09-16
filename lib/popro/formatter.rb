# frozen_string_literal: true

module Popro
  module Formatter
    class Aggregate
      def initialize(*formatters, &block)
        @formatters = formatters
        @join = if block_given?
                  block
                else
                  proc(&:join)
                end
      end

      def call(info, *args)
        @join.call(
          @formatters.collect do |formatter|
            formatter.call(info, *args)
          end
        )
      end
    end

    class RewriteLine
      def initialize(formatter)
        @formatter = formatter
        @longest = 0
      end

      def call(info, *args)
        result = @formatter.call(info, *args)
        @longest = [@longest, result.size].max
        "\r#{result.ljust(@longest, ' ')}"
      end
    end

    module Concat
      # Factory for calling Aggregate with a join block
      def self.new(*formatters, separator: '')
        Aggregate.new(*formatters) do |results|
          results.join separator
        end
      end
    end

    class Estimate
      # TODO: cleaner implementation/formatstring
      attr_reader :info

      def initialize
        @start_time = current_time
        @info = nil
      end

      def call(info, *_args)
        @info = info

        [
          "elapsed: #{format_duration(elapsed)}",
          "[#{format_duration(estimated_left)}/#{format_duration(estimated_total)}]"
        ].join(', ')
      end

      private

      def elapsed
        current_time - @start_time
      end

      def estimated_total
        return nil if info.current.zero? || info.total.zero?

        elapsed + (info.total / info.current) * elapsed
      end

      def estimated_left
        return nil if info.current.zero? || info.total.zero?

        (info.total / info.current) * elapsed
      end

      def format_duration(secs)
        return '??d??h??m??s' if secs.nil?

        format('%02dd%02dh%02dm%02ds', secs / 86_400, secs / 3600 % 24, secs / 60 % 60, secs % 60)
      end

      def current_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    class Sprintf
      def initialize(format_string = nil)
        @format_string = format_string
      end

      def call(info, *_args)
        string_params = Hash.new { |_, k| info.public_send(k) }
        format_string.gsub('{n}', info.total_length.to_s) % string_params
      end

      def format_string
        @format_string ||= '[%<current>{n}s/%<total>-{n}s] %<pct_formatted>4s%%'
      end
    end

    class Looper
      def initialize(enumerable = nil)
        enumerable = '.' if enumerable.nil?
        enumerable = enumerable.split '' if enumerable.is_a? String

        @enumerator = Enumerator.new do |e|
          loop do
            enumerable.each do |item|
              e.yield item
            end
          end
        end
      end

      def call(...)
        @enumerator.next
      end
    end

    class Spinner < Looper
      STYLES ||= {
        slashes: '-\\|/',
        hbar: '▁▂▃▄▅▆▇█',
        vbar: '▉▊▋▌▍▎',
        heartbeat: '♥♡',
        dots: '⣀⣄⣤⣦⣶⣷⣿',
        block: '░▒▓█',
        circle: '◜◝◞◟'
      }.freeze

      def initialize(style_type = nil, bounce: false, reverse: false)
        style = STYLES[style_type] || STYLES[:slashes]
        style = style.reverse if reverse
        style += style.reverse if bounce
        super style
      end
    end
  end
end
