# frozen_string_literal: true

# shortcut methods to Popro::Progress usage
module Popro
  class OutOfSyncError < StandardError; end
  class ConfigError < StandardError; end

  require_relative 'popro/progress'

  def self.new(total, **options, &block)
    raise ConfigError, 'using :total is not supported in new' if options.key?(:total) && (options[:total] != total)

    options[:total] = total
    Progress.new(**options, &block)
  end

  def self.each(obj, _total = nil, **options, &block)
    new(0, **options).each(obj, total, &block).done
  end

  def self.each0(obj, **options, &block)
    raise ConfigError, 'using :step is not supported in each0' if options.key?(:step)

    options[:step] = 0
    each(obj, 0, **options, &block)
  end

  def self.command_line(*_args)
    raise 'TODO: implement a `ps` style progress indicator for command line'
  end
end
