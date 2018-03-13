
module Initializr
  # The Manages module contains all the managers implemented by *initializr*.
  #
  # Things like the **package managers** are defined here.
  module Managers
    # This is the base class of the **package managers**.
    abstract class IPackageManager
      property install_list, dependency_list, should_update
      # List of packages that will be installed
      @install_list = [] of String
      # List of dependencies that must be installed
      @dependency_list = [] of String
      # Indicates if the package manager should update its database.
      #
      # *i.e.*: With **APT**, it'll run `apt-get update`
      @should_update = false

      # name and id of the IPackageManager
      {% for attr in [:name, :id] %}
        macro {{attr.id}}(content)
          def {{attr.id}}
            "#{ \{{ content }} }"
          end
        end
        abstract def {{attr.id}}: String
      {% end %}

      # Run all the operations of this package manager
      def execute
        # install dependencies
        to_install(@dependency_list) unless @dependency_list.empty?
        to_update if @should_update

        # install packages
        to_install(@install_list) unless @install_list.empty?
      end

      # Returns instances of all subclasses
      def self.availables
        {{ @type.all_subclasses }}.map { |i| i.new }
      end

      # Defines how to install the packages
      abstract def to_install(input : Array(String)): Bool?

      # Defines how to update the package manager
      def to_update: Bool?
        raise "not implemented"
      end
    end

    # This abstract class defines methods to manage list of `IPackageManager`.
    abstract class IManagersList
      property availables
      @availables = [] of IPackageManager

      # Gets an instance of `IPackageManager` by its identifier.
      def get(id : String): IPackageManager
        @availables.each do |mgr|
          return mgr if mgr.id == id
        end
        raise "cannot found a handler for '#{id}'"
      end

      # Run all the defined `PackageManager` instances to install the packages
      def execute
        @availables.each do |item|
          item.execute
        end
      end
    end
  end
end

require "./package"
