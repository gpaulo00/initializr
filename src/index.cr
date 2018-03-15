require "./runners"
require "./managers/index"

# The Initializr module is the root of this library and
# contains all its code.
module Initializr
  # Name of the application
  NAME = "initializr"
  # Version of the application
  VERSION = "0.3.0"

  # The Context class is a *dependency injection container*.
  class Context
    property runner, managers

    # List of categories that will be installed
    property categories = [] of String
    # List of packages that will be installed
    property packages = [] of String

    def initialize(
      @runner : Initializr::Runners::IRunner = Initializr::Runners::ShellRunner.new,
      @managers : Initializr::Managers::IManagersList = Initializr::Managers::ManagersList.new
    )
    end
  end
end
