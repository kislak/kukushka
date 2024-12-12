# frozen_string_literal: true

require_relative "kukushka/version"

module Kukushka
  class Error < StandardError; end

  def self.kuku
    "Hello from Kukushka!"
  end
end
