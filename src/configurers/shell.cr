
require "../index"

# This *namespace* contains all the **configurers** used by *initializr*.
module Initializr::Configurers
  # This is the base class of the **configurers**.
  #
  # It defines the structure that every configurer should have.
  abstract class BaseConfigurer
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

    private def self.to_run(input : Array(String))
      raise "not implemented"
    end
  end

  # Uses the **shell** to run configurations.
  # This is the default `BaseConfigurer` implementation.
  class Shell < BaseConfigurer
    private def self.to_run(input : Array(String))
      input.each do |i|
        puts i
      end
    end
  end
end
