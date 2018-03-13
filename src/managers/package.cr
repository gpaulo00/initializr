require "./index"

module Initializr::Managers
  # This is the default implementation of `IManagersList`.
  # It gets the availables `IPackageManager` from `IPackageManager.availables`
  class ManagersList < IManagersList
    def initialize
      @availables = IPackageManager.availables
    end
  end

  # Handles the **apt** package manager.
  #
  # This is commonly used in **Debian**-based Linux distributions,
  # such as *Ubuntu*, and *Linux Mint*.
  class APT < IPackageManager
    id "apt"
    name "Debian APT"

    def to_install(pkg : Array(String))
      puts "apt-get install -y #{pkg.join " "}"
    end

    def to_update
      puts "apt-get update"
    end
  end

  # Handles the **Ruby Gem** package manager.
  #
  # This is used to install packages for **Ruby**.
  class RubyGem < IPackageManager
    id "gem"
    name "Ruby Gem"

    def to_install(pkg : Array(String))
      puts "gem install #{pkg.join " "}"
    end
  end

  # Handles the **Yarn** package manager.
  #
  # This is used to install **Node.js** packages through *yarn*.
  class YarnPkg < IPackageManager
    id "yarn"
    name "Yarn"

    def to_install(pkg : Array(String))
      puts "yarn global add #{pkg.join " "}"
    end
  end
end
