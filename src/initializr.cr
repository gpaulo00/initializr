require "admiral"
require "./index"
require "./schema"
require "./managers/index"

module Initializr
  class CLI < Admiral::Command
    define_version Version
    define_help description: "configure your system with a single command"
    define_argument action : String,
      description: "The action to execute"
    define_flag input : String,
      description: "The YAML configuration file",
      short: i,
      required: true

    def run
      puts "#{Name} v#{Version}"

      # parse file
      file = flags.input
      unless File.exists? file
        raise "cannot found the script '#{file}'"
      end
      root = Initializr::Schema::Script.read(File.open(file))
      puts "\nscript metadata:"
      root.print

      # execute commands
      case arguments.action
      when "packages", .nil?
        # print package list
        puts "packages:"
        root.print_packages
      when "categories"
        # print category list
        puts "categories:"
        root.print_categories
      end
    end
  end
end

# run the command line interface
Initializr::CLI.run
