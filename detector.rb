#!/usr/bin/ruby1.8 -w

def usage
	puts "Usage: detector.rb"
end

def index_directory
  Dir.foreach(Dir.pwd){|x|
    if FileTest.directory?(x)
      Dir.chdir(x) do
        index_directory(x)
      end
    elsif FileTest.ARGF

    end
  }
end

puts Dir.pwd