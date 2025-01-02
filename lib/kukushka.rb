# frozen_string_literal: true
require_relative "kukushka/version"
require 'fileutils'
require 'rainbow'
require 'yaml'

module Kukushka
  EXAMPLE_SOURCE ||= File.dirname(__FILE__) + '/../spec/fixtures/pl_001.txt'
  DEFULAT_LINES = File.readlines(EXAMPLE_SOURCE, chomp: true)

  def self.kuku(redis)
    Kukushka.kuku(redis)
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
