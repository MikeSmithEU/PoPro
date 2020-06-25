# frozen_string_literal: true

module Popro
  # the progress context passed as first argument to blocks (or named argument for `Progress#each` and `Popro.each`)

  WILL_CHECK_MARKS ||= '☐☑'

  class Context
    def initialize(progress:, info:, indicator:, step: 1)
      @progress = progress
      @indicator = indicator
      @info = info
      @step = step
    end

    def each(obj, total = nil, &block)
      total = obj.size if total.nil?
      @info.total += total if total.positive?
      block = proc { |d| d } unless block_given?

      obj.each do |*args|
        did block.call(*args, progress: self)
      end

      self
    end

    def each0(obj, &block)
      each(obj, 0, &block)
    end

    def each_will(obj, titler, total = nil)
      each(obj, total) do |*args, **kwargs|
        kwargs[:progress].will titler.call(*args) do
          yield(*args, **kwargs)
        end
      end
    end

    def start
      raise OutOfSyncError, 'trying to start when already running' if @info.running?

      @info.start
    end

    def done
      raise OutOfSyncError, 'done while not started' unless @info.running?

      @info.finish
      @indicator.finish if @indicator.respond_to? :finish
    end

    def formatter(&block)
      unless @indicator.respond_to?(:formatter=)
        raise ConfigError, "seems formatter is not available for #{@indicator.class}"
      end

      @indicator.formatter = block
      block
    end

    def did(yielded = nil, amount = 1)
      @info.start unless @info.running?
      inc amount, yielded

      self
    end

    def will(title = nil, use_block_result_as_title = nil, step = nil)
      @info.start unless @info.running?
      inc 0, "#{WILL_CHECK_MARKS[0]} #{title}"

      return self unless block_given?

      step = @step if step.nil?
      yielded = yield @context
      yielded = "#{WILL_CHECK_MARKS[1]} #{title}" unless title.nil? || use_block_result_as_title

      # no need to communicate to Indicator if we are not advancing (avoid double calls)
      did yielded, step unless step.zero?
      yielded
    end

    def to_proc
      proc { |yielded| did(yielded) }
    end

    private

    def inc(amount, yielded = nil)
      raise TypeError('expected an integer') unless amount.is_a? Integer

      @info.current += amount unless amount.zero?
      @indicator.call(@info, yielded)
    end
  end
end
