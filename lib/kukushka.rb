# frozen_string_literal: true
require_relative "kukushka/version"
require 'fileutils'
require 'rainbow'
require 'yaml'

module Kukushka
  CONFIG_FILE = File.dirname(__FILE__) + '/../tmp/config/kuku.yaml'
  CONFIG_DIR = File.dirname(CONFIG_FILE)
  INIT_CTA = "TODO: kuku init source_file"
  PROVIDE_SOURCE_CTA = "TODO: provide valid source_file path"

  def self.kuku(args)
    Kukushka.kuku(args)
  end

  class Kukushka
    def self.kuku(args)
      new(args).kuku
    end

    def initialize(args)
      @command = args[0]
      @param1 = args[1]
    end

    attr_reader :command, :param1

    def kuku
      init if command == 'init'

      return INIT_CTA unless config_exists?

      return config if command == 'config'
      return cleanup if command == 'cleanup'
      return sample if command == 'sample'
      return punchline if command.nil?
    end

    private
    def init
      source_file = param1

      return INIT_CTA if source_file.nil?

      return PROVIDE_SOURCE_CTA unless File.exist?(source_file)

      dir = File.dirname(CONFIG_FILE)
      FileUtils.mkdir_p(dir) unless File.exists?(dir)
      config = { source: source_file }
      File.open(CONFIG_FILE, 'w') {|f| f.write config.to_yaml }
    end

    def config
      @config ||= YAML::load_file(CONFIG_FILE)
    end

    def cleanup
      FileUtils.rm_rf(CONFIG_DIR) if config_exists?
    end

    def config_exists?
      File.exists?(CONFIG_DIR)
    end

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

    def punchline
      @punchline ||= Rainbow(sample).color(color).bright
    end

    def source
      @source ||= YAML::load_file(CONFIG_FILE)[:source]
    end
    def color
      @color ||= Rainbow::X11ColorNames::NAMES.keys.sample
    end

    def sample
      @sample ||= File.readlines(source, chomp: true).sample
    end
  end
end
