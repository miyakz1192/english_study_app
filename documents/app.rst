================================================================
engアプリを作ってみる。
================================================================


テーブルを作る
==================

User Sentence, Score各種を作って、db:migrateする。::

  rails generate scaffold User name:string passwd_hash:string
  rails generate scaffold Sentence en:string jp:string voice_data:string
  rails generate scaffold Score passed:boolean sentence_id:integer user_id:integer
  rails generate scaffold ScoreEngWritten --parent Score 
  rails generate scaffold ScoreEngNotWritten --parent Score 

  #create all db that defined in database.yaml
  rails db:create:all

  rails db:migrate
  rails db:migrate RAILS_ENV=development

Sentenceを読み込む(初期データの投入)
==========================================

どの文章の覚えが良いのか、topXを検索して表示
===================================================
  
  






