require "yaml"
require "../index"

# The Schema module defines the schema that the scripts should have.
#
# It's used to build a workable copy in memory of the scripts.
module Initializr::Schema
  alias YAMLHash = Hash(YAML::Type, YAML::Type)
  alias YAMLArray = Array(YAML::Type)

  private module YAMLHelper
    # converts a YAML::Any to Array(T)
    def to_array(out : Array(T), input : YAMLArray) forall T
      input.each do |item|
        out.push item.as(T)
      end
    end
  end

  # Describes a **category** of packages.
  struct Category
    getter name, packages
    @packages = [] of String

    # Marks it to install.
    def mark_install(ctx : Script)
      @packages.each do |i|
        ctx.packages.each do |pkg|
          if pkg.name == i
            pkg.mark_install ctx
            break
          end
        end
      end
    end

    def initialize(@name : String)
    end
  end

  # Describes an **installable** package.
  #
  # This object contains the *package*, and which `IPackageManager` should handle it.
  struct Installable
    getter app, name, manager

    # Marks it to install.
    #
    # This is the most basic unit that can be installed, since it declares a
    # single packages.
    def mark_install(ctx : Script)
      name = (manager.nil? ? ctx.packageManager : @manager).as(String)
      mgr = @app.managers.get name
      mgr.install_list.push @name
    end

    def initialize(
      @app : Initializr::Context,
      @name : String,
      @manager : String? = nil
    )
    end
  end

  # Describes a *instruction set* for a single **package**.
  struct Package
    include YAMLHelper
    getter app, name, description, dependencies, install, configure, update, categories

    @categories = [] of String
    @dependencies = [] of String
    @install = [] of Installable
    @configure = [] of String
    @preinstall = [] of String

    def initialize(
      @app : Initializr::Context,
      @name : String,
      @description : String? = nil,
      @update : Bool = false
    )
    end

    # Marks it to install.
    #
    # This will mark to install the **packages** and the **dependencies**
    def mark_install(ctx : Script)
      # add packages
      @install.each do |i|
        i.mark_install ctx
      end

      # add dependencies (and update)
      mgr = @app.managers.get ctx.packageManager
      mgr.dependency_list += @dependencies
      mgr.should_update = true if @update

      # add configurations
      @app.runner.preconfigs += @preinstall
      @app.runner.configs += @configure
    end

    # Reads data from *YAML* input, and puts it into the `Package`.
    def read(input : YAML::Type)
      input.as(YAMLHash).each do |key, value|
        case key.as(String)
        when "description"
          @description = value.as(String)
        when "install"
          case value
          when Hash(YAML::Type, YAML::Type)
            value.each do |mgr, pkgs|
              pkgs.as(YAMLArray).each do |pkg|
                @install.push(Installable.new @app, pkg.as(String), mgr.as(String))
              end
            end
          when Array(YAML::Type)
            value.each do |pkg|
              @install.push(Installable.new @app, pkg.as(String))
            end
          end
        when "categories"
          to_array @categories, value.as(YAMLArray)
        when "configure"
          to_array @configure, value.as(YAMLArray)
        when "preinstall"
          to_array @preinstall, value.as(YAMLArray)
        when "dependencies"
          to_array @dependencies, value.as(YAMLArray)
        when "update"
          @update = value.as(Bool)
        end
      end
    end
  end

  # Describes the complete *instruction set* of a script.
  struct Script
    include YAMLHelper
    getter app, author, system, dependencies, packages, categories, packageManager

    @dependencies = [] of String
    @categories = [] of Category
    @packages = [] of Package

    def initialize(
      @app : Initializr::Context,
      @author : String? = nil,
      @system : String? = nil,
      @packageManager : String = "apt"
    )
    end

    # Reads data from *YAML* input, and puts it into the `Script`.
    def read(input : String | IO)
      parse = YAML.parse(input).raw
      parse.as(YAMLHash).each do |key, value|
        case key.as(String)
        when "author"
          @author = value.as(String)
        when "system"
          @system = value.as(String)
        when "packageManager"
          @packageManager = value.as(String)
        when "dependencies"
          to_array @dependencies, value.as(YAMLArray)
        when "packages"
          # package list
          value.as(YAMLHash).each do |name, content|
            pkg = Package.new @app, name.as(String)
            pkg.read content
            pkg.categories.each do |category|
              get_category(category).packages << pkg.name
            end
            @packages.push pkg
          end
        end
      end
    end

    # Gets a `Category` by its name, or creates a new one.
    def get_category(name : String)
      # get category
      @categories.each do |item|
        return item if item.name == name
      end

      # insert if not exists
      res = Category.new name
      @categories.push res
      res
    end


    # Marks some `Package` or `Category` objects to be installed.
    #
    # You should reference them with its name. Example:
    # ```
    # # mark "mypackage" and "default" to install
    # root.install([
    #   "mypackage",
    #   "default",
    # ])
    # ```
    #
    # NOTE: if the name is in both arrays, *categories* takes
    # precedence over the *packages*.
    def install(input : Array(String))
      selections = (@categories + @packages)
      input.each do |item|
        # check the package with the selection list
        selections.each do |pkg|
          if pkg.name == item
            pkg.mark_install self
            break
          end
        end
      end
    end

    # Run all the operations.
    #
    # This should run the `PackageManager` to install the packages,
    # and run the every configuration for the packages.
    def run
      # add dependencies
      mgr = @app.managers.get @packageManager
      mgr.dependency_list += @dependencies

      # preconfiguration, install & configuration
      @app.runner.preconfigure
      @app.managers.execute
      @app.runner.configure
    end

    # Builds an instance of `Script` from *YAML* input.
    #
    # ```
    # name = "file.yml"
    # Script.read(app, File.open(name)) # w/ IO input
    # Script.read(app, File.read(name)) # w/ string
    # ```
    def self.read(app : Initializr::Context, input : String | IO)
      out = Script.new app
      out.read(input)
      out
    end
  end
end
