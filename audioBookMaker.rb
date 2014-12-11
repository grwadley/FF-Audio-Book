#!/usr/bin/env ruby

#globals
$audio_file_count = 0
$current_speaker = ""

##
# Written By Austin Kidd, Gregory Wadley
# This program reads a transcript (line 14) of a skype conversation and creates
# an audio log.
#
# Required for use: ffmpeg, OSX.
#
# voices for users should be specified in the say() function (line 57)
##

#main function
#read all the lines, send them to the say function to create audio files
#these files are combined into chapters by combine()
def speakBook()
	startTime = 
	build()
	outputFile = File.open("outputList.txt", 'w')

	lines_array = IO.readlines("transcript")
	start = false
	speaker = ''
	text = ''
	lineCount=0
	combineCount = 0
	chapter = 0

	lines_array.each do |line|
		if line =~ /(\[.*\]\s)(.*):\s(.*)/i
			if start
				say(speaker,text,outputFile)
				lineCount+=1
				combineCount+=1
			end
			speaker = $2.to_s
			text = $3.to_s
			start = true
		else
			text += line
		end

		puts lineCount.to_s+"/32138"

		#cleanup the file and combine into a chapter at certain benchmarks.
		if combineCount == 1000 || line=~/^EOF$/
			combineCount = 0
			outputFile.close
			cleanupOutput()
			combine("outputListFinal.txt",chapter.to_s)
			chapter+=1
			resetLists()
			outputFile = File.open("outputList.txt", 'w')
			puts "chapter complete"
		end
	end

	outputFile.close
end

#say function
# uses OSX's say. Takes a speaker, the text to say, and the current list of audio files
# if block selects the voice based on username
def say(speaker,text,outputList)
	if speaker =~ /(.*) : On \d+\/\d+\/\d+, at \d+:\d+ \w*, (.*) wrote/
		speaker = $1.to_s
		quotedSpeaker = $2.to_s
		message = quoteAppend(speaker,quotedSpeaker)
	else
		message = speechAppend(speaker)
	end
	voice = 'Bruce'
	#change these to the people in your chat. Won't work with many more people because of the limited number of voices.
	if speaker =~ /cody/i
		voice = 'Ralph'
	elsif speaker =~ /kidd/i
		voice = 'Bruce'
	elsif speaker =~ /hamstra/i
		voice = 'Kathy'
	elsif speaker =~ /munsch/i
		voice = 'Princess'
	elsif speaker =~ /schott/i
		voice = 'Junior'
	elsif speaker =~ /hennings/i
		voice = 'Agnes'
	elsif speaker =~ /aguiniga/i
		voice = 'Zarvox'
	elsif speaker =~ /brandon/i
		voice = 'Whisper'
	elsif speaker =~ /shah/i
		voice = 'Vicki'
	elsif speaker =~ /mcdonald/i
		voice = 'Victoria'
	elsif speaker =~ /williams/i
		voice = 'Alex'
	elsif speaker =~ /wadley/i
		voice = 'Cellos'
	end

	#speak the text to .aiff files, track the files to later be combined
	if $current_speaker != speaker
		`say -v Fred "#{message}" -o recordings/"#{$audio_file_count}".aiff`
		outputList.write("file 'recordings/"+$audio_file_count.to_s+".aiff'\n")
		$audio_file_count+=1
		$current_speaker = speaker
	end
	`say -v #{voice} "#{text}" -o recordings/"#{$audio_file_count}".aiff`
	outputList.write("file 'recordings/"+$audio_file_count.to_s+".aiff'\n")
	$audio_file_count+=1
end

#Narrates changes in speaker. These are chosen randomly. Feel free to add more.
def speechAppend(speaker)
	prng = Random.new
	num = prng.rand(5)
	if num ==0
		message = "then "+speaker+" said "
	elsif num == 1
		message = "and "+speaker+" was like"
	elsif num == 2
		message = "so "+speaker+" replied "
	elsif num == 3
		message = " and "+speaker+" whispered "
	else
		message = ". "+speaker+" pondered this, and said "
	end
	return message
end

#ideally, this fixes the quote issue. It works sometimes.
def quoteAppend(speaker,quotedSpeaker)
	message = "then "+speaker+" quoted "+quotedSpeaker+" saying: "
	return message
end

#runs at the beginning of each call. Cleans the recordings,chapters,and lists.
def build()
	`rm -rf recordings/`
	`mkdir recordings`
	`rm -rf chapters/`
	`mkdir chapters`
	`rm -rf outputList.txt`
	`touch outputList.txt`
end

#lists of files to be combined must be reset after each chapter. this funtion does that.
def resetLists()
	`rm -rf outputList.txt`
	`rm -rf outputListFinal.txt`
	`touch outputList.txt`
	`touch outputListFinal.txt`
end

#uses ffmpeg to combine files into chapters.
def combine(file,chapter)
	`ffmpeg -f concat -i "#{file}" -c copy chapters/Chapter"#{chapter}".aiff`
end

#somtimes lines fail. This function ensures that we only try to combine things that actually exist.
def cleanupOutput()
	lines_array = IO.readlines("outputList.txt")

	outputFile = File.open("outputListFinal.txt", 'w')
	lines_array.each do |line|
		if line =~ /file '(.*)'/
			filename = $1.to_s
			if(File.exist?(filename))
				outputFile.write("file '"+filename+"'\n")
			end
		end
	end

	outputFile.close
end

#start the program!
speakBook()