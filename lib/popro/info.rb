# frozen_string_literal: true

module Popro
  class Info
    attr_accessor :total, :current

    def initialize(total: nil, current: nil)
      @total = total
      @current = current || 0
      @started = false
    end

    def running?
      @started
    end

    def start
      @started = true
      self
    end

    def finish
      @started = false
      self
    end

    def pct
      return 0 if @total.nil? || @total.zero?

      @current.to_f / @total
    end

    def pct_formatted
      percentage = pct
      return nil if percentage.nil?

      format('%<percent>.1f', percent: pct * 100)
    end

    def total_length
      num = [@total, @current].max
      return 1 if num.zero?

      Math.log10(num + 1).ceil
    end

    def to_f
      pct
    end

    def next(num = 1)
      raise TypeError, 'expected an integer' unless num.is_a? Integer

      @current += num
      self
    end

    def to_h
      {
        started: @started,
        pct: pct,
        pct_formatted: pct_formatted,
        current: @current,
        total: @total
      }
    end
  end
end
