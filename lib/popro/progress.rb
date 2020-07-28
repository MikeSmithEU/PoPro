# frozen_string_literal: true

module Popro
  class Progress
    require_relative 'context'
    require_relative 'info'
    require_relative 'indicator'

    DEFAULT_OPTIONS ||= {
      total: 0,
      current: 0,
    }.freeze

    attr_reader :context

    def initialize(**options)
      options.merge!(DEFAULT_OPTIONS)

      @started = false

      @info = Info.new(total: options.delete(:total), current: options.delete(:current))

      options[:step] ||= (block_given? ? 0 : 1)

      options[:indicator] = Indicator.default unless options.key? :indicator

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
        %i[each each_will to_proc did will formatter start done].each do |method_name|
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
