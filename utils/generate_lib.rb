require 'rubygems'
require 'id3'
require 'json'
require 'iconv'

CONFIRM = true

FOLDER_PATH = '../player/lib'
OUT_FILE_PATH = '../player/list.js'

filenames = Dir.entries(FOLDER_PATH).select { |file_name| File.file?("#{FOLDER_PATH}/#{file_name}") }

out = []

class String
	def to_my_utf8
		::Iconv.conv('UTF-8//IGNORE', 'UTF-8', self + ' ')[0..-2]
	end
end

filenames.each do |file_name|
	puts "#{file_name}"

	file_path = File.join(FOLDER_PATH, file_name)
	mp3 = ID3::AudioFile.new(file_path)

	begin
		# formatted = "#{mp3.tagID3v2['ARTIST']['text']} — #{mp3.tagID3v2['TITLE']['text']}"
		formatted = "#{mp3.tagID3v2['TITLE']['text']}"	
	rescue StandardError => e
		puts "   ERR: #{e}"
		formatted = "Unknown"
	end

	if CONFIRM
		print "   #{formatted} || "; STDOUT.flush
		override = gets

		formatted = override if override.length > 1
	end

	object = {
		'title' => formatted.to_my_utf8,
		'file' => file_name,
		'howl' => false
	}
	out << object
	
	puts " > #{formatted}"
end

File.open(OUT_FILE_PATH, 'w') do |f|
	f.write("LIST = #{JSON::generate(out)}")
end
