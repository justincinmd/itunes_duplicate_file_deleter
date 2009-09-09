#!/usr/bin/ruby1.8 -w

require 'ftools'
require 'rubygems'
require 'highline/import'
require 'mp3info'
require 'yaml'

@files = {}
@mp3_files = {}
@old_mp3_files = {}
@total_files = 0
@total_mp3_files = 0
@base = Dir.pwd

def usage
	puts "Usage: detector.rb"
end

def index_directory
  File.delete("files.yaml") if File.exist?("files.yaml")
  File.delete("mp3_files.yaml") if File.exist?("mp3_files.yaml") and Dir.pwd != @base

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

      if x.downcase.include?('.mp3')
        if !@old_mp3_files[File.expand_path(x)].nil?
          size = @old_mp3_files[File.expand_path(x)]
          @mp3_files[size] = [] if @mp3_files[size].nil?
          @mp3_files[size] << File.expand_path(x)
        else
          begin
            size = Mp3Info.open(File.expand_path(x)).audio_content[1]
            @mp3_files[size] = [] if @mp3_files[size].nil?
            @mp3_files[size] << File.expand_path(x)
            @total_mp3_files = @total_mp3_files + 1

            @old_mp3_files[File.expand_path(x)] = size
          rescue
          end
        end
      end
    end
  }
end

def remove_non_dupes
  @files.delete_if{|key,value|
    value.length < 2
  }
  @mp3_files.delete_if{|key,value|
    value.length < 2
  }
end

def test_for_dupes
  checked = 0
  @mp3_files.each{|size, file_paths|
    checked = checked + 1
    puts "Checking MP3 #{checked} of #{@mp3_files.length}"
    match_files = []

    while file_paths.length > 0
      base_file = file_paths[0]
      match_files << base_file
      
      audio_content = Mp3Info.open(base_file).audio_content
      base_content = IO.read(base_file, audio_content[1], audio_content[0])

      for path in file_paths
        unless match_files.include?(path)
          audio_content = Mp3Info.open(path).audio_content
          match_content = IO.read(path, audio_content[1], audio_content[0])
          
          match_files << path if base_content == match_content
        end
      end

      clear_dupe(match_files.dup) if match_files.length > 1

      file_paths = file_paths - match_files
      match_files = []
    end
  }

  checked = 0
  @files.each{|size, file_paths|
    checked = checked + 1
    puts "Checking item #{checked} of #{@files.length}"
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
  test = matched_files.collect{|f| File.basename(f, File.extname(f)).sub(/\s*\d+\z/, '') }.uniq.length == 1
  if test
    puts ""
    puts ""
#    choose do |menu|
#      matched_files.each{|f| puts f}
#      menu.prompt = "Delete all but #{matched_files[0]}:"
#      menu.choice(:no)
#      menu.choice(:yes) do
#        matched_files.delete(matched_files[0])
#        matched_files.each{|file_to_delete| File.delete(file_to_delete)}
#      end
#    end
#  this logic is good enough to run on auto
    matched_files.delete(matched_files[0])
    matched_files.each{|file_to_delete| File.delete(file_to_delete)}

    puts "Auto-deleted all but #{matched_files[0]}"
  else
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
end

puts "Scanning Directories"
if File.exists?('mp3_files.yaml')
  puts 'Loading from YAML'
  @old_mp3_files = YAML::load(File.open('mp3_files.yaml'))
end
index_directory
File.open('mp3_files.yaml', 'w') { |f| f.puts @old_mp3_files.to_yaml }

puts "#{@total_files} Total Files Found"
puts "#{@total_mp3_files} Total MP3 Files to Test"

remove_non_dupes
puts "#{@files.keys.length} Duplicate Sizes Found"
puts "#{@mp3_files.keys.length} Duplicate MP3 Content Lengths Found"

sleep 10

puts "Testing for Dupes"
test_for_dupes