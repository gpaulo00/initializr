require "./index"

module Initializr::Managers
  # This is the base class of the **package managers**.
  #
  # Also, it provides a useful *DSL* to create and register package managers.
  class PackageManager
    @@availables = [] of PackageManager
    property :install_list, :dependency_list, :should_update
    getter :name, :id, :to_install, :to_update

    @to_install = Proc(Array(String), Bool?).new do
      raise "not implemented"
    end
    @to_update = Proc(Bool?).new do
      raise "not implemented"
    end
    # List of packages that will be installed
    @install_list = [] of String
    # List of dependencies that must be installed
    @dependency_list = [] of String
    # Indicates if the package manager should update its database.
    #
    # *i.e.*: With **APT**, it'll run `apt-get update`
    @should_update = false

    # Shows all the available package managers.
    def self.availables
      @@availables
    end

    # Get by identifier
    def self.get(id : String): PackageManager
      @@availables.each do |mgr|
        return mgr if mgr.id == id
      end
      raise "cannot found a handler for '#{id}'"
    end

    # Run all the defined `PackageManager` instances to install the packages
    def self.run
      self.availables.each do |item|
        # install dependencies
        item.to_install.call(item.dependency_list) unless item.dependency_list.empty?
        item.to_update.call() if item.should_update

        # install packages
        item.to_install.call(item.install_list) unless item.install_list.empty?
      end
    end

    # Builds a new package manager using a *DSL*.
    def initialize(@id : String, @name : String)
      @@availables.push self
      with self yield self
    end

    # Defines how to install the packages.
    def installs_with(&block : Array(String) -> Bool?)
      @to_install = block
    end

    # Defines how to update the package manager.
    def updates_with(&block : -> Bool?)
      @to_update = block
    end
  end

  # Handles the **apt** package manager.
  #
  # This is commonly used in **Debian**-based Linux distributions,
  # such as *Ubuntu*, and *Linux Mint*.
  PackageManager.new("apt", "Debian APT") do |i|
    i.installs_with do |pkg|
      puts "apt-get install #{pkg.join " "}"
    end

    i.updates_with do
      puts "apt-get update"
    end
  end

  # Handles the **Ruby Gem** package manager.
  #
  # This is used to install packages for **Ruby**.
  PackageManager.new("gem", "Ruby Gem") do |i|
    i.installs_with do |pkg|
      puts "gem install #{pkg.join " "}"
    end
  end

  # Handles the **Yarn** package manager.
  #
  # This is used to install **Node.js** packages through *yarn*.
  PackageManager.new("yarn", "Yarn") do |i|
    i.installs_with do |pkg|
      puts "yarn global add #{pkg.join " "}"
    end
  end
end
