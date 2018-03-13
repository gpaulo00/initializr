require "colorize"
require "admiral"
require "./index"
require "./schema"
require "./managers/package"
require "./formatters/cli"

# It is the *command-line interface* to **initializr**.
#
# This is built on top of **admiral** DSL, and should be
# managed within a *shell*.
class Initializr::CLI < Admiral::Command
  define_version Version
  define_help description: "configure your system with a single command"
  define_argument action : String,
    description: "The action to execute"
  define_flag input : String,
    description: "The YAML configuration file",
    short: i,
    required: true

  def run
    puts "#{Name} v#{Version}".colorize(:cyan).mode(:bold)
    ctx = Initializr::Context.new

    # parse file
    file = flags.input
    unless File.exists? file
      raise "cannot found the script '#{file}'"
    end
    root = Initializr::Schema::Script.read(ctx, File.open(file))
    formatter = Initializr::Formatters::CLI.new root
    formatter.metadata

    # execute commands
    case arguments.action
    when "packages", .nil?
      formatter.packages
    when "categories"
      formatter.categories
    when "install"
      packages = ARGV[ARGV.index("install").as(Int32) + 1..-1]
      if packages.empty?
        # install defaults
        root.install ["default"]
      else
        root.install packages
      end

      # confirm & execute
      formatter.confirm do
        root.run
      end
    end
  end
end

# run the command line interface
Initializr::CLI.run
