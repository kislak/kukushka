# frozen_string_literal: true
require_relative "kukushka/version"
require 'fileutils'
require 'rainbow'
require 'yaml'

module Kukushka
  EXAMPLE_SOURCE ||= File.dirname(__FILE__) + '/../fixtures/pl_001.txt'
  DEFULAT_LINES = File.readlines(EXAMPLE_SOURCE, chomp: true)
  CONFIG_ENTRIES = %i(source enabled annoying format counter from circle)

  def self.kuku(redis)
    Kukushka.kuku(redis)
  end

  def self.store(config_entry)
    Config.store(config_entry)
  end

  def self.restore(redis)
    Config.restore(redis)
  end

  def self.reset(redis)
    Config.reset(redis)
  end

  class Config
    CONFIG_FILE = File.dirname(__FILE__) + '/../tmp/config/kuku.yaml'
    SOURCE = File.dirname(__FILE__) + '/../spec/fixtures/pl_001.txt'

    CONFIG_DIR = File.dirname(CONFIG_FILE)
    dir = File.dirname(CONFIG_FILE)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)

    def self.store(config_entry)
      new.store(config_entry)
    end

    def self.restore(redis)
      new.restore(redis)
    end

    def self.reset(redis)
      config = new
      config.reset
      config.restore(redis)
    end

    def reset
      config = {
        source: SOURCE,
        enabled: true,
        counter: 0,
        from: 0,
        circle: 0,
        annoying: 0,
        format: nil,
      }

      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
    end

    def store(config_entry)
      raise 'unknown config' if (config_entry.keys - CONFIG_ENTRIES).any?

      config = YAML::load_file(CONFIG_FILE)
      config.merge!(config_entry)
      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
    end

    def restore(redis)
      config.each do |key, value|
        redis.set(key, value)
      end

      if @source = redis.get(:source)
        value = File.readlines(@source, chomp: true)
        redis.set(:lines, value)
      end
    end

    private

    def config
      @config ||= YAML::load_file(CONFIG_FILE)
    end
  end

  class Kukushka
    def self.kuku(redis)
      new(redis).kuku
    end

    def initialize(redis)
      @redis = redis
    end

    attr_reader :redis

    def kuku
      Rainbow(sample).color(color).bright
    end

    private

    # if ARGV[0] == 'config'
    #   # source
    #   # range_number
    #   # range_size
    #   # annoying_factor
    #   # with feedback_loop
    #   # statistics
    # end
    #
    # if ARGV[0] == 'statistics'
    # end

    def sample
      if counter
        set_counter(counter + 1)
        set_counter(0) if counter > lines.size

        if counter < from
          set_counter(from)
        end

        if counter > to
          set_counter(from)
        end


        return lines[counter] if redis.get(:format) == 'simple'
        return "#{lines[counter]} #{counter} [#{from}-#{to}/#{lines.size - 1}]"
      end

      lines.sample
    end

    def counter
      @counter ||= redis.get(:counter).to_i
    end

    def to
      @to ||= from + circle - 1
    end

    def set_counter(new_counter)
      redis.set(:counter, new_counter)
      @counter = new_counter
    end

    def lines
      # binding.pry
      redis_lines = redis.get(:lines)
      if redis_lines
        @lines = JSON.parse(redis.get(:lines))
      end
      @lines ||= DEFULAT_LINES
    end

    def from
      @from ||= redis.get(:from).to_i
    end

    def circle
      @circle ||= redis.get(:circle).to_i
      @circle = lines.size if @circle == 0
      @circle
    end

    def color
      @color ||= Rainbow::X11ColorNames::NAMES.keys.sample
    end
  end
end
