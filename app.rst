================================================================
engアプリを作ってみる。
================================================================


テーブルを作る
==================

User Sentence, Score各種を作って、db:migrateする。::

  rails generate scaffold User name:string passwd_hash:string
  rails generate Score Sentence en:string jp:string voice_data:string
  rails generate scaffold Score passed:boolean sentence_id:integer user_id:integer
  rails generate scaffold ScoreEngWritten --parent Score 
  rails generate scaffold ScoreEngNotWritten --parent Score 
  
  rails db:migrate
  rails db:migrate RAILS_ENV=development
  






