  rails generate scaffold User name:string passwd_hash:string
  rails generate scaffold Sentence no:integer en:string jp:string voice_data:string
  rails generate scaffold Score passed:boolean sentence_id:integer user_id:integer
  rails generate scaffold ScoreEngWritten --parent Score 
  rails generate scaffold ScoreEngNotWritten --parent Score 

  #create all db that defined in database.yaml
  rails db:create:all

  rails db:migrate
  rails db:migrate RAILS_ENV=development

