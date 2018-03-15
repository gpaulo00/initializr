require "../runners"

module Initializr
  # The Manages module contains all the managers implemented by *initializr*.
  #
  # Things like the **package managers** are defined here.
  module Managers
    # This is the base class of the **package managers**.
    abstract class IPackageManager
      # List of packages that will be installed
      property install_list = [] of String
      # List of dependencies that must be installed
      property dependency_list = [] of String
      # Indicates if the package manager should update its database.
      #
      # *i.e.*: With **APT**, it'll run `apt-get update`
      property should_update = false

      # name and id of the IPackageManager
      {% for attr in [:name, :id] %}
        macro {{attr.id}}(content)
          def {{attr.id}}
            "#{ \{{ content }} }"
          end
        end
        abstract def {{attr.id}}: String
      {% end %}

      # Configure the `Runner` to run the operations of this package manager
      def configure(runner : Initializr::Runners::IRunner)
        # add dependencies to runner
        runner.dependencies << to_install(@dependency_list) unless @dependency_list.empty?
        runner.managers << to_update if @should_update

        # add packages to runner
        runner.managers << to_install(@install_list) unless @install_list.empty?
      end

      # Returns instances of all subclasses
      def self.availables
        {{ @type.all_subclasses }}.map { |i| i.new }
      end

      # Defines how to install the packages
      abstract def to_install(input : Array(String)) : String

      # Defines how to update the package manager
      def to_update : String
        raise "not implemented"
      end
    end

    # This abstract class defines methods to manage list of `IPackageManager`.
    abstract class IManagersList
      property availables = [] of IPackageManager

      # Gets an instance of `IPackageManager` by its identifier.
      def get(id : String) : IPackageManager
        @availables.each do |mgr|
          return mgr if mgr.id == id
        end
        raise "cannot found a handler for '#{id}'"
      end

      # Configure the `Runner` to install the packages
      def configure(runner : Initializr::Runners::IRunner)
        @availables.each { |mgr| mgr.configure runner }
      end
    end
  end
end

require "./package"
