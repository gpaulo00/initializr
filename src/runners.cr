require "./index"

module Initializr
  # The Runners module defines all the code runners for *initializr*.
  module Runners
    # This is the base class of the **runners**.
    #
    # It defines the structure that every runner should have.
    abstract class IRunner
      property configs, preconfigs
      @configs = [] of String
      @preconfigs = [] of String

      # Run the pre-install configurations
      def preconfigure
        to_run @preconfigs
      end

      # Run the configurations
      def configure
        to_run @configs
      end

      # Defines how to run the commands
      private def to_run(input : Array(String))
        raise "not implemented"
      end
    end

    # Uses the **shell** to run configurations.
    # This is the default `BaseRunner` implementation.
    class ShellRunner < IRunner
      private def to_run(input : Array(String))
        input.each do |i|
          puts i
        end
      end
    end
  end
end
