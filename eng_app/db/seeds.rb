# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

sentence_file_path="/home/miyakz/sentence_data.txt"

unless sentence_file_path
  puts "ERROR: sentence_file_path is required"
  exit 
end

Sentence.destroy_all

File.open(sentence_file_path) do |f|
  f.each_line do |line|
    s = line.split("::")
    no = s[0].to_i
    jp = s[1]
    en = s[2]
    Sentence.create([{no: no, jp: jp, en: en}])
  end
end



