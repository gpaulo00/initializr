require "./index"

module Initializr
  # The Runners module defines all the code runners for *initializr*.
  module Runners
    # This is the base class of the **runners**.
    #
    # It defines the structure that every runner should have.
    abstract class IRunner
      # Commands to run before the installation
      property preconfigs = [] of String
      # Commands that install the dependencies
      property dependencies = [] of String
      # Commands that install the packages
      property managers = [] of String
      # Commands to run after the installation
      property configs = [] of String

      # Run all configurations
      def execute
        to_run @preconfigs
        to_run @dependencies
        to_run @managers
        to_run @configs
      end

      # Defines how to run the commands
      abstract def to_run(input : Array(String))
    end

    # Uses the **shell** to run configurations.
    # This is the default `BaseRunner` implementation.
    class ShellRunner < IRunner
      def to_run(input : Array(String))
        input.each { |cmd| system cmd }
      end
    end

    # Only prints the commands to `stdout`.
    class DryRunner < IRunner
      def to_run(input : Array(String))
        input.each { |cmd| puts cmd }
      end
    end
  end
end
