require "colorize"
require "./index"
require "../schema"

module Initializr::Formatters
  # It is the default formatter, and is designed to have output to *cli*.
  class CLI < BaseFormatter
    def metadata
      puts "script info:".colorize(:green).mode(:bold)
      puts "#{"author".colorize(:yellow)}:\t#{@root.author}"
      puts "#{"system".colorize(:yellow)}:\t#{@root.system}"
    end

    def packages
      puts "\npackages:".colorize(:green).mode(:bold)
      res = @root.packages.map do |i|
        "#{i.name.colorize(:blue)}\t- #{i.description}"
      end
      print_array res
    end

    def categories
      puts "\ncategories:".colorize(:green).mode(:bold)
      res = @root.categories.map do |i|
         "#{i.name.colorize(:blue)}\t [#{i.packages.join ", "}]"
      end
      print_array res
    end

    def print_array(input : Array(T)) forall T
      total = input.size.to_s.size
      input.each_with_index do |item, i|
        puts "#{(i + 1).to_s.rjust(total, '0')}) #{item}"
      end
    end
  end
end