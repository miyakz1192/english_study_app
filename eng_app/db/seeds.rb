# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
#

############## CONFIGRATION #######################
sentence_file_path = ENV["SENTENCE_FILE_PATH"]
###################################################

puts "INFO: start initial data"

unless sentence_file_path
  puts "ERROR: sentence_file_path is required"
  exit 
end

puts "INFO:  initialize sentence data"
Sentence.destroy_all
File.open(sentence_file_path) do |f|
  f.each_line do |line|
    s = line.split("::")
    no = s[0].to_i
    jp = s[1]
    en = s[2]
    voice_data_path = sprintf("/voice/%03d.mp3",no)
    Sentence.create([{no: no, jp: jp, en: en, voice_data: voice_data_path}])
    puts "INFO:   no #{no} is done"
  end
end

puts "INFO:  initialize user data"
User.destroy_all
u = User.create!(mode: ENV["INIT_USER_MODE"], email: ENV["INIT_USER_EMAIL"], password: ENV["INIT_USER_PASSWD"])

puts "INFO:  initialize score data"
Score.destroy_all
Sentence.all.each do |s|
  Score.create!(passed: false, val: 0, sentence_id: s.id, user_id: u.id)
  puts "INFO:   no #{s.no} is done"
end
