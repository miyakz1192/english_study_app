================================================================
engアプリを作ってみる。
================================================================


  109  rails generate scaffold User name:string passwd_hash:string
  110* rails generate Score Sentence en:string jp:string voice_data:string
  111  rails generate scaffold Score passed:boolean sentence_id:integer user_id:integer
  112  rails generate scaffold ScoreEngWritten --parent Score 
  113  rails generate scaffold ScoreEngNotWritten --parent Score 







