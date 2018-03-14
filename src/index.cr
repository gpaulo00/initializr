require "./runners"
require "./managers/index"

# The Initializr module is the root of this library and
# contains all its code.
module Initializr
  Name    = "initializr"
  Version = "0.2.0"

  # The Context class is a *dependency injection container*.
  class Context
    getter runner, managers

    def initialize(
      @runner : Initializr::Runners::IRunner = Initializr::Runners::ShellRunner.new,
      @managers : Initializr::Managers::IManagersList = Initializr::Managers::ManagersList.new
    )
    end
  end
end
