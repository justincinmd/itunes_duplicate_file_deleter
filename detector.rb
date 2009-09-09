#!/usr/bin/ruby1.8 -w

def usage
	puts "Usage: detector.rb"
end

def index_directory
  puts Dir.pwd
  Dir.foreach(Dir.pwd){|x|
    if FileTest.directory?(x)
      puts x
      unless x[0] == '.'
        Dir.chdir(x) do
          index_directory
        end
      end
    else

    end
  }
end

index_directory