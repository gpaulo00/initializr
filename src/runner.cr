
require "./index"

module Initializr
  # This is the base class of the **runners**.
  #
  # It defines the structure that every runner should have.
  abstract class BaseRunner
    @@configs = [] of String
    @@preconfigs = [] of String

    # Gets the configuration list
    def self.configs
      @@configs
    end

    # Sets the configuration lists
    def self.configs=(input)
      @@configs = input
    end

    # Gets the pre-install configuration list
    def self.preconfigs
      @@preconfigs
    end

    # Sets the pre-install configuration lists
    def self.preconfigs=(input)
      @@preconfigs = input
    end

    # Run the pre-install configurations
    def self.preconfigure
      to_run @@preconfigs
    end

    # Run the configurations
    def self.configure
      to_run @@configs
    end

    # Defines how to run the commands
    private def self.to_run(input : Array(String))
      raise "not implemented"
    end
  end

  # Uses the **shell** to run configurations.
  # This is the default `BaseRunner` implementation.
  class ShellRunner < BaseRunner
    private def self.to_run(input : Array(String))
      input.each do |i|
        puts i
      end
    end
  end
end
