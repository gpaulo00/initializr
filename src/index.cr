require "./runner"

# Main module of **initializr**.
#
# Contains all the definitions used by this project.
module Initializr
  Name    = "initializr"
  Version = "0.2.0"

  class Context
    getter :runner
    @runner : Initializr::BaseRunner = Initializr::ShellRunner.new

    def initialize
    end
  end
end
