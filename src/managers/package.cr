module Managers
  # This is the base class of the **package managers**.
  #
  # Also, it provides a useful *DSL* to create and register package managers.
  class PackageManager
    @@availables = [] of PackageManager

    # List of packages that will be installed
    #
    # It'll be used as a cache to batch install packages.
    property :ilist
    getter :managerName, :toInstall, :managerID

    # Identifier of this package manager.
    #
    # It should be a **short** and **unique** name, because
    # it'll be used as reference by the scripts.
    @managerID : String? = nil
    @managerName : String? = nil
    @toInstall : (Array(String) -> Bool?)? = nil
    @ilist = [] of String

    # Shows all the available package managers.
    def self.availables
      @@availables
    end

    # Installs the packages using all package managers.
    def self.install
      self.availables.each do |item|
        item.toInstall.call(item.ilist)
      end
    end

    # Little helper to build a `PackageManager` instance.
    def self.build
      PackageManager.new do |item|
        with item yield item
      end
    end

    # Builds a new package manager using a *DSL*.
    def initialize
      @@availables.push self
      with self yield self
      self
    end

    # Defines its name.
    def name(name : String)
      @managerName = name
    end

    # Defines its unique identifier.
    def id(id : String)
      @managerID = id
    end

    # Defines how to install the packages.
    def installsWith(&block : Array(String) -> Bool?)
      @toInstall = block
    end
  end

  # Handles the **apt** package manager.
  #
  # This is commonly used in **Debian**-based Linux distributions,
  # such as *Ubuntu*, and *Linux Mint*.
  PackageManager.build do
    id "apt"
    name "Debian APT"
    installsWith do |pkg|
      puts "apt-get install #{pkg.join " "}"
    end
  end

  # Handles the **Ruby Gem** package manager.
  #
  # This is used to install packages for **Ruby**.
  PackageManager.build do
    id "gem"
    name "Ruby Gem"
    installsWith do |pkg|
      puts "gem install #{pkg.join " "}"
    end
  end

  # Handles the **Yarn** package manager.
  #
  # This is used to install **Node.js** packages through *yarn*.
  PackageManager.build do
    id "yarn"
    name "Yarn"
    installsWith do |pkg|
      puts "yarn global add #{pkg.join " "}"
    end
  end
end
