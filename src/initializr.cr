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
    print " Do you want to continue? [y/N] ".colorize(:blue).mode(:bold) unless skip
    yield if skip || gets.as(String).downcase == "y"
  end

  # Colorizes and joins a `Array(String)`
  def join_array(input : Array(String))
    input.map { |i| i.colorize(:blue) }.join(", ")
  end

  # Colorizes a title
  def title(str : String)
    str.colorize(:green).mode(:bold)
  end

  # Colorizes a subtitle
  def subtitle(str : String)
    " - #{str.colorize(:yellow)}"
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
    puts title("script info:")
    puts "#{subtitle("author")}: #{root.author}"
    puts "#{subtitle("system")}: #{root.system}"
    puts

    # execute commands
    case arguments.action
    when "packages", .nil?
      puts title("packages:")
      print_array(
        root.packages.map do |i|
          "#{i.name.colorize(:blue)}\t- #{i.description}"
        end
      )
    when "categories"
      puts title("categories:")
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
      puts title("the following will be installed:")
      puts "#{subtitle("categories")}: #{join_array(ctx.categories)}" unless ctx.categories.empty?
      puts "#{subtitle("packages")}: #{join_array(ctx.packages)}" unless ctx.packages.empty?
      puts
      confirm flags.confirm do
        root.run
      end
    else
    end
  end
end

# run the command line interface
Initializr::CLI.run
