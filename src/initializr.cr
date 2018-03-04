require "./schema.cr"

module Initializr
  puts "initializr - bootstrap configs in your system"

  # Prints the help message
  def self.help
    puts <<-EOF
it uses your own script (a YAML file) and lets to quickly configure your system.

Use: #{PROGRAM_NAME} [script.yml]
EOF
    exit 0
  end

  # Prints an error and exit
  def self.error(msg : String)
    puts " [ERROR] #{msg}"
    exit 1
  end

  # main code
  if ARGV.size < 1
    help
  else
    # check if file exists
    file = ARGV[0]
    unless File.exists? file
      error "cannot found the script '#{file}'"
    end

    # parse file
    root = Script.read(File.open(file))
    puts
    root.print
    puts "\nscript packages:"
    root.print_packages
  end
end
