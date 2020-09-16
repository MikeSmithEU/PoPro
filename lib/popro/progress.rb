# frozen_string_literal: true

module Popro
  class Progress
    require_relative 'context'
    require_relative 'info'
    require_relative 'indicator'

    DEFAULT_OPTIONS ||= {
      total: 0,
      current: 0,
      indicator: Indicator.default
    }.freeze

    attr_reader :context

    def initialize(**options)
      @started = false

      options = DEFAULT_OPTIONS
                .merge(step: block_given? ? 0 : 1)
                .merge(options)

      @info = Info.new(total: options.delete(:total), current: options.delete(:current))

      options.merge!(progress: self, info: @info)
      @context = Context.new(**options)

      register_aliases
      return unless block_given?

      yield self
      done
    end

    # increase the total
    def add(amount)
      @info.total += amount
      self
    end

    private

    def register_aliases
      class << self
        %i[each each_will each_gonna to_proc gonna will did formatter start done].each do |method_name|
          define_method method_name do |*args, &block|
            @context.public_send(method_name, *args, &block)
          end
        end

        %i[current total].each do |method_name|
          define_method method_name do
            @info.public_send(method_name)
          end
        end
      end
    end
  end
end
