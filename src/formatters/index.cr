
require "../index"
require "../schema"

# This *namespace* contains all the **formatters** used by *initializr*.
module Initializr::Formatters
  # This is the base class of the **formatters**.
  #
  # It defines the structure that every formatter should have.
  abstract class BaseFormatter
    def initialize(@root : Initializr::Schema::Script)
    end

    # Gets formatted metadata info.
    abstract def metadata
    # Gets a formatted list of packages.
    abstract def packages
    # Gets a formatted list of categories.
    abstract def categories

    # Asks for confirmation
    abstract def confirm(&block : -> Nil): Bool
  end
end

require "./cli"
