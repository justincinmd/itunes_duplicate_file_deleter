#!/usr/bin/ruby1.8 -w

def usage
	puts "Usage: detector.rb"
end

def index_directory
  puts Dir.pwd
  Dir.foreach(Dir.pwd){|x|
    if FileTest.directory?(x)
      Dir.chdir(x) do
        index_directory
      end
    elsif FileTest.ARGF

    end
  }
end

index_directory