#!/usr/bin/ruby1.8 -w

@files = {}
@total_files = 0

def usage
	puts "Usage: detector.rb"
end

def index_directory
  puts Dir.pwd
  Dir.foreach(Dir.pwd){|x|
    if FileTest.directory?(x)
      unless x[0,1] == '.'
        Dir.chdir(x) do
          index_directory
        end
      end
    elsif FileTest.file?(x)
      #puts File.expand_path(x)
      @files[File.size(x)] = [] if @files[File.size(x)].nil?
      @files[File.size(x)] << File.expand_path(x)
      @total_files = @total_files + 1
    end
  }
end

def remove_non_dupes
  @files.delete_if{|key,value|
    value.length < 2
  }
end

puts "Scanning Directories"
index_directory

puts "#{@total_files} Total Files Found"

remove_non_dupes
puts "#{@files.keys.length} Duplicate Sizes Found"