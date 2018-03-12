require "yaml"
require "../index"

# This *namespace* defines the **initializr** schema.
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

    def initialize(@name : String)
    end
  end

  # Describes an **installable** package.
  #
  # This object contains the *package*, and which `PackageManager` should handle it.
  struct Installable
    getter name, manager

    def initialize(
      @name : String,
      @manager : String? = nil
    )
    end
  end

  # Describes a *instruction set* for a single **package**.
  struct Package
    include YAMLHelper
    getter name, description, dependencies, install, configure, update, categories

    @categories = [] of String
    @dependencies = [] of String
    @install = [] of Installable
    @configure = [] of String

    def initialize(
      @name : String,
      @description : String? = nil,
      @update : Bool = false
    )
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
                @install.push(Installable.new pkg.as(String), mgr.as(String))
              end
            end
          when Array(YAML::Type)
            value.each do |pkg|
              @install.push(Installable.new pkg.as(String))
            end
          end
        when "categories"
          to_array @categories, value.as(YAMLArray)
        when "configure"
          to_array @configure, value.as(YAMLArray)
        when "dependencies"
          to_array @dependencies, value.as(YAMLArray)
        when "update"
          @update = value.as(Bool)
        end
      end
    end
  end

  # Describes the complete *instruction set* of a **installer file**.
  struct Script
    include YAMLHelper
    getter author, system, dependencies, packages, categories, packageManager

    @dependencies = [] of String
    @categories = [] of Category
    @packages = [] of Package

    def initialize(
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
            pkg = Package.new name.as(String)
            pkg.read content
            pkg.categories.each do |c|
              res = get_category c
              res.packages.push pkg.name
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

    # Builds an instance of `Script` from *YAML* input.
    #
    # ```
    # name = "file.yml"
    # Script.read(File.open(name)) # => Script instance
    # Script.read(File.read(name)) # => Script instance
    # ```
    def self.read(input : String | IO)
      out = Script.new
      out.read(input)
      out
    end
  end
end
