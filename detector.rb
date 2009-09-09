#!/usr/bin/ruby1.8 -w

require 'ftools'
require 'rubygems'
require 'highline/import'


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
      if !x.include?('.aa') and !x.include?('.pos')
        @files[File.size(x)] = [] if @files[File.size(x)].nil?
        @files[File.size(x)] << File.expand_path(x)
        @total_files = @total_files + 1
      end
    end
  }
end

def remove_non_dupes
  @files.delete_if{|key,value|
    value.length < 2
  }
end

def test_for_dupes
  @files.each{|size, file_paths|
    match_files = []

    while file_paths.length > 0
      base_file = file_paths[0]
      match_files << base_file

      for path in file_paths
        unless match_files.include?(path)
          match_files << path if File.compare(base_file, path)
        end
      end

      clear_dupe(match_files.dup) if match_files.length > 1

      file_paths = file_paths - match_files
      match_files = []
    end
  }
end

def clear_dupe(matched_files)
  puts ""
  puts ""
  choose do |menu|
    menu.prompt = "Select which file to keep:"
    menu.choice(:skip)
    matched_files.each{|f|
      menu.choice(f) do |file, details|
        matched_files.delete(file)
        matched_files.each{|file_to_delete| File.delete(file_to_delete)}
      end
    }
  end  
end

a = "/raid/music/Compilations/Greatest Hitz/15 Why.mp3"
b = "/raid/music/Soundgarden/Badmotorfinger/08 Room a Thousand Years Wide.mp3"
puts File.compare(a, b)
exit


puts "Scanning Directories"
index_directory

puts "#{@total_files} Total Files Found"

remove_non_dupes
puts "#{@files.keys.length} Duplicate Sizes Found"

puts "Testing for Dupes"
test_for_dupes