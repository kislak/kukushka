# frozen_string_literal: true
require_relative "kukushka/version"
require 'fileutils'
require 'rainbow'
require 'yaml'

module Kukushka
  INIT_CTA = "TODO: kuku init source_file"
  PROVIDE_SOURCE_CTA = "TODO: provide valid source_file path"

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
        enabled: true
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
      @source ||= YAML::load_file(CONFIG_FILE)[:source]
    end

    private
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

      return config.cleanup if command == 'cleanup'
      # return show if command == 'show'
      return sample if command == 'sample'
      return punchline if command.nil?
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
      @sample ||= File.readlines(config.source, chomp: true).sample
    end

    def punchline
      @punchline ||= Rainbow(sample).color(color).bright
    end

    def color
      @color ||= Rainbow::X11ColorNames::NAMES.keys.sample
    end
  end
end
