# Taken from http://snippets.dzone.com/posts/show/3349

require 'digest/md5'
require 'digest/sha1'

$BUFLEN = 1024

class Hasher
	# Constructor
	# method = "SHA1" or "MD5"
	# filepath = Full filepath
	def initialize(method, filepath)
		if (method.upcase == "SHA1")
			@hashfunc = Digest::SHA1.new
			@hashname = "SHA1"
		else
			@hashfunc = Digest::MD5.new
			@hashname = "MD5"
		end
		@fullfilename = filepath
	end

	def hashname
		@hashname
	end

	# Compute hash code
	def hashsum
		open(@fullfilename, "r") do |io|
			puts "Reading "+@fullfilename
			counter = 0
			while (!io.eof)
				readBuf = io.readpartial($BUFLEN)
				putc '.' if ((counter+=1) % 3 == 0)
				@hashfunc.update(readBuf)
			end
		end
		return "#{@hashfunc.hexdigest}"
	end
end
