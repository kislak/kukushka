# frozen_string_literal: true
require_relative "kukushka/version"
require 'fileutils'
require 'rainbow'
require 'yaml'

module Kukushka
  INIT_CTA = "TODO: kuku init source_file"
  PROVIDE_SOURCE_CTA = "TODO: provide valid source_file path"
  DEFAULT_CIRCLE = 5

  def self.kuku(args)
    Kukushka.kuku(args)
  end

  def self.on?
    Config.new.on?
  end

  def self.on!
    Config.new.enable
  end

  class Config
    CONFIG_FILE = File.dirname(__FILE__) + '/../tmp/config/kuku.yaml'
    CONFIG_DIR = File.dirname(CONFIG_FILE)

    def on?
      return true unless exists?
      exists? && config[:enabled]
    end

    def exists?
      File.exists?(CONFIG_DIR)
    end

    def init(source_file)
      source_file ||= File.dirname(__FILE__) + '/../spec/fixtures/pl_001.txt'
      return INIT_CTA if source_file.nil?
      return PROVIDE_SOURCE_CTA unless File.exist?(source_file)

      dir = File.dirname(CONFIG_FILE)
      FileUtils.mkdir_p(dir) unless File.exists?(dir)
      config = {
        source: source_file,
        enabled: true,
        counter: 0,
        from: 0,
        circle: DEFAULT_CIRCLE,
      }
      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
    end

    def enable
      config.merge!(enabled: true)
      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
      'enabled'
    end

    def disable
      config.merge!(enabled: false)
      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
      'disabled'
    end

    def cleanup
      FileUtils.rm_rf(CONFIG_DIR) if config_exists?
    end

    def source
      @source ||= config[:source]
    end

    def counter
      @counter ||= config[:counter]
    end

    def from
      @from ||= config[:from]
    end

    def circle
      @circle ||= config[:circle]
    end

    def set_counter(new_counter)
      config.merge!(counter: new_counter)
      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
    end

    def set_circle(new_circle)
      config.merge!(circle: new_circle)
      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
    end

    def set_from(new_from)
      config.merge!(from: new_from)
      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
    end

    def config
      @config ||= YAML::load_file(CONFIG_FILE)
    end
  end

  class Kukushka
    def self.kuku(args)
      new(args).kuku
    end

    def initialize(args)
      @command = args[0]
      @param1 = args[1]
      @config = Config.new
    end

    attr_reader :command, :param1, :config

    def kuku
      config.init(param1) if command == 'init'

      return INIT_CTA unless config.exists?

      return config.enable if command == 'on'
      return config.disable if command == 'off'

      if command == 'counter'
        return config.set_counter(0) if param1.nil?
        return config.set_counter(nil) if param1 == 'no' || param1 == 'off' || param1 == 'nil'
        return config.set_counter(param1.to_i)
      end

      if command == 'from'
        config.set_from(0) if param1.nil?
        config.set_from(param1.to_i)
        config.set_counter(config.from)
      end

      if command == 'circle'
        config.set_circle(DEFAULT_CIRCLE) if param1.nil?
        config.set_circle(param1.to_i)
        config.set_counter(config.from)
      end

      return config.cleanup if command == 'cleanup'
      # return show if command == 'show'
      return sample if command == 'sample'
      return punchline
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
      if config.counter
        config.set_counter(config.counter + 1)
        config.set_counter(0) if config.counter > lines.size

        if config.counter < config.from
          config.set_counter(config.from)
        end

        if config.counter >= config.from + config.circle - 1
          config.set_counter(config.from)
        end

        return "#{config.counter}. #{lines[config.counter]}"
      end

      lines.sample
    end

    def lines
      @lines ||= File.readlines(config.source, chomp: true)
    end

    def punchline
      @punchline ||= Rainbow(sample).color(color).bright
    end

    def color
      @color ||= Rainbow::X11ColorNames::NAMES.keys.sample
    end
  end
end
