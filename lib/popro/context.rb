# frozen_string_literal: true

module Popro
  # the progress context passed as first argument to blocks (or named argument for `Progress#each` and `Popro.each`)

  WILL_CHECK_MARKS ||= ' ✔'

  class Context
    def initialize(progress:, info:, indicator:, step: 1)
      @progress = progress
      @indicator = indicator
      @info = info
      @step = step
    end

    def each(obj, total = nil, &block)
      _each(obj, total) do |*args|
        did block.call(*args, progress: @info)
      end
    end

    def each_will(obj, titler, total = nil, &block)
      _each(obj, total) do |*args|
        title = titler.call(*args)
        will(title) do
          block.call(*args, progress: @info)
          nil
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

    def did(yielded = nil, amount = nil)
      @info.start unless @info.running?
      amount = @step if amount.nil?
      raise TypeError, "amount: expected an integer, got #{amount.class}" unless amount.is_a? Integer

      @info.current += amount unless amount.zero?
      @indicator.call(@info, yielded)

      self
    end

    def gonna(title)
      @indicator.call(@info, title)
      self
    end

    def each_gonna(obj, titler, total = nil, &block)
      _each(obj, total) do |*args|
        gonna(titler.call(*args))
        block.call(*args, progress: @info) if block_given?
      end
    end

    def will(title = nil, step = nil, &block)
      gonna "#{WILL_CHECK_MARKS[0]} #{title}"

      return self unless block_given?

      block.call
      yielded = "#{WILL_CHECK_MARKS[1]} #{title}"
      did(yielded, step || @step)
      yielded
    end

    def to_proc
      proc { |yielded| did(yielded) }
    end

    private

    def _each(obj, total = nil, &block)
      total = obj.size if total.nil?
      raise TypeError, "total: expected an integer got #{total.class}" unless total.is_a?(Integer) || total.nil?

      @info.total += total if total.positive?
      # block = proc { |d| d } unless block_given?

      obj.each do |*args, **kwargs|
        block.call(*args, **kwargs)
      end

      self
    end
  end
end
