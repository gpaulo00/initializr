require "yaml"

# This module defines functions that helps with YAML (un)marshalling.
module YAMLHelper
  # converts a YAML::Any to Array(String)
  def to_array(out : Array(String), input : YAML::Any)
    input.each do |item|
      out.push item.as_s
    end
  end
end

# Describes a *instruction set* for a single **package**.
struct Package
  include YAMLHelper
  property name, description, dependencies, install, configure, update

  def initialize(
    @name : String,
    @description : String? = nil,
    @dependencies : Array(String) = [] of String,
    @install : Array(String) = [] of String,
    @configure : Array(String) = [] of String,
    @update : Bool = false
  )
  end

  # Reads data from *YAML* input, and puts it into the **Package**.
  def read(input : YAML::Any)
    input.each do |key, value|
      case key
      when "description"
        @description = value.as_s
      when "install"
        to_array @install, value
      when "configure"
        to_array @configure, value
      when "dependencies"
        to_array @dependencies, value
      when "update"
        @update = !!value
      end
    end
  end
end

# Describes the complete *instruction set* of a **installer file**.
struct Script
  include YAMLHelper
  property version, author, system, dependencies, packages

  def initialize(
    @version : String? = nil,
    @author : String? = nil,
    @system : String? = nil,
    @dependencies : Array(String) = [] of String,
    @packages : Array(Package) = [] of Package
  )
  end

  # Reads data from *YAML* input, and puts it into the **Script**.
  def read(input : String | IO)
    parse = YAML.parse(input)
    parse.each do |key, value|
      case key
      when "version"
        @version = value.as_s
      when "author"
        @author = value.as_s
      when "system"
        @system = value.as_s
      when "dependencies"
        to_array @dependencies, value
      when "packages"
        value.each do |name, content|
          pkg = Package.new name.as_s
          pkg.read content
          @packages.push pkg
        end
      end
    end
  end

  # Print info about this script
  def print
    puts "ver.:\t#{@version}" unless @version.nil?
    puts "author:\t#{@author}" unless @author.nil?
    puts "system:\t#{@system}" unless @system.nil?
  end

  # Print the list of packages written in the script
  def print_packages
    total = @packages.size.to_s.size
    @packages.each_with_index do |pkg, i|
      puts "#{(i + 1).to_s.rjust(total, '0')}) #{pkg.name}\t- #{pkg.description}"
    end
  end

  # Builds an instance of **Script** from *YAML* input.
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
