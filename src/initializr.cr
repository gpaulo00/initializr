require "colorize"
require "admiral"
require "./index"
require "./schema"
require "./managers/package"

# It is the *command-line interface* to **initializr**.
#
# This is built on top of **admiral** DSL, and should be
# managed within a *shell*.
class Initializr::CLI < Admiral::Command
  define_version VERSION
  define_help description: "configure your system with a single command"
  define_argument action : String,
    description: "The action to execute"
  define_flag input : String,
    description: "The YAML configuration file",
    short: i,
    required: true
  define_flag confirm : Bool,
    description: "Skips confirmation messages",
    short: y,
    default: false,
    long: yes
  define_flag dry : Bool,
    description: "Only prints the commands",
    short: n,
    default: false,
    long: "dry-run"

  # Prints an array of data
  def print_array(input : Array(T)) forall T
    total = input.size.to_s.size
    input.each_with_index do |item, i|
      puts "#{(i + 1).to_s.rjust(total, '0')}) #{item}"
    end
  end

  # Asks for confirmation, if needed
  def confirm(skip = false)
    print "Do you want to continue? [y/N] ".colorize(:blue).mode(:bold) unless skip
    if skip || gets.as(String).downcase == "y"
      yield
    else
      puts "aborting process".colorize(:light_magenta)
    end
  end

  # Runs the command-line interface
  def run
    puts "#{NAME} v#{VERSION}".colorize(:cyan).mode(:bold)
    ctx = Initializr::Context.new

    # dry run
    if flags.dry
      ctx.runner = Initializr::Runners::DryRunner.new
    end

    # parse file
    file = flags.input
    unless File.exists? file
      raise "cannot found the script '#{file}'"
    end
    root = Initializr::Schema::Script.new(ctx).read File.open(file)
    puts "script info:".colorize(:green).mode(:bold)
    puts "#{"author".colorize(:yellow)}:\t#{root.author}"
    puts "#{"system".colorize(:yellow)}:\t#{root.system}"
    puts

    # execute commands
    case arguments.action
    when "packages", .nil?
      puts "packages:".colorize(:green).mode(:bold)
      print_array(
        root.packages.map do |i|
          "#{i.name.colorize(:blue)}\t- #{i.description}"
        end
      )
    when "categories"
      puts "categories:".colorize(:green).mode(:bold)
      print_array(
        root.categories.map do |i|
          "#{i.name.colorize(:blue)}\t [#{i.packages.join ", "}]"
        end
      )
    when "install"
      packages = ARGV[ARGV.index("install").as(Int32) + 1..-1]
      if packages.empty?
        # install defaults
        root.install ["default"]
      else
        root.install packages
      end

      # confirm & execute
      confirm flags.confirm do
        root.run
      end
    else
    end
  end
end

# run the command line interface
Initializr::CLI.run
