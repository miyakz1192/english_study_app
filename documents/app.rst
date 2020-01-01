================================================================
engアプリを作ってみる。
================================================================


テーブルを作る
==================

User Sentence, Score各種を作って、db:migrateする。::

  rails generate scaffold User name:string passwd_hash:string
  rails generate scaffold Sentence no:integer en:string jp:string voice_data:string
  rails generate scaffold Score passed:boolean sentence_id:integer user_id:integer
  rails generate scaffold ScoreEngWritten --parent Score 
  rails generate scaffold ScoreEngNotWritten --parent Score 

  #create all db that defined in database.yaml
  rails db:create:all

  rails db:migrate RAILS_ENV=development

モデルの関係図
====================

以下が関係図。::

  User --has_many-> Score <-has_many-- Sentence
       --dep:dest->       <-dep:dest-- 

  ※  dependency:destroy Aが消えたらBも消える。

Sentenceを読み込む(初期データの投入)
==========================================

seed.rbに処理を記載。

当該ユーザの総獲得ポイントを表示
=======================================

ポイント::

  u.scores.map{|s| s.val}.inject(:+)

どの文章の覚えが良いのか、topXを検索して表示
===================================================

以下は全部のランキングを出力。::

  irb(main):094:0> Hash[u.scores.group(:sentence_id).sum(:val).sort_by{|_,v| -v}]
     (2.8ms)  SELECT SUM(`scores`.`val`) AS sum_val, `scores`.`sentence_id` AS scores_sentence_id FROM `scores` WHERE `scores`.`user_id` = 10 GROUP BY `scores`.`sentence_id`
     => {4=>4, 2=>2, 6=>-1, 3=>-2, 5=>-4}
  irb(main):095:0> 


上記の[0..2]でTOP3を出力。得た配列の各要素に対してsentenceを呼び出してく。以下のようにmapを使うと早い。::


  irb(main):099:0> Hash[u.scores.group(:sentence_id).sum(:val).sort_by{|_,v| -v}].keys[0..2]
     (2.9ms)  SELECT SUM(`scores`.`val`) AS sum_val, `scores`.`sentence_id` AS scores_sentence_id FROM `scores` WHERE `scores`.`user_id` = 10 GROUP BY `scores`.`sentence_id`
     => [4, 2, 6]
  irb(main):100:0> 

ワーストは逆にsort_byで-vをしていせず、vをしていすれば良い。::

参考：hashのソート
https://qiita.com/mnishiguchi/items/9095ac989ed7d51fe395

参考：groupの使い方（図解わかりやすい)
https://pikawaka.com/rails/group

ページング
===========

いかのURLで簡単にできる。
https://qiita.com/residenti/items/1ae1e5ceb59c0729c0b9

Sentenceコントローラとindexのviewに加えた。

ユーザのログイン/ログアウト機能
==================================

deviseというgemを使うと高度な認証機能がさくっと作れるらしい。
以下のページがよくわかりやすい

https://web-camp.io/magazine/archives/16811

カードモードの開発系譜
========================

1) sentencesのindexページからdeleteやeditを消す
  10cb9c47e3c78d2a9b18560bdb29d087c28a8166
2) showのページにnextとback、listを追加
  10cb9c47e3c78d2a9b18560bdb29d087c28a8166
3) showのページに英語文章を表示したり隠したりするボタンを追加。
  34ade0c7ed4fe974ad45d34f0608d21397a3ef8f 
  参考：https://www.pazru.net/js/DOM/7.html
4) ユーザのログイン/ログアウトを作る
5) ajaxを使って、書かずに正解/書かずに不正解のボタンを画面遷移しなくてもできるようにする。




参考：パスの表示
=======================

パスの表示::

  miyakz@eng2:~/english_study_app/eng_app$ rails routes
                                 Prefix Verb   URI Pattern                                                                              Controller#Action
                 score_eng_not_writtens GET    /score_eng_not_writtens(.:format)                                                        score_eng_not_writtens#index
                                        POST   /score_eng_not_writtens(.:format)                                                        score_eng_not_writtens#create
              new_score_eng_not_written GET    /score_eng_not_writtens/new(.:format)                                                    score_eng_not_writtens#new
             edit_score_eng_not_written GET    /score_eng_not_writtens/:id/edit(.:format)                                               score_eng_not_writtens#edit
                  score_eng_not_written GET    /score_eng_not_writtens/:id(.:format)                                                    score_eng_not_writtens#show
                                        PATCH  /score_eng_not_writtens/:id(.:format)                                                    score_eng_not_writtens#update
                                        PUT    /score_eng_not_writtens/:id(.:format)                                                    score_eng_not_writtens#update
                                        DELETE /score_eng_not_writtens/:id(.:format)                                                    score_eng_not_writtens#destroy
                     score_eng_writtens GET    /score_eng_writtens(.:format)                                                            score_eng_writtens#index
                                        POST   /score_eng_writtens(.:format)                                                            score_eng_writtens#create
                  new_score_eng_written GET    /score_eng_writtens/new(.:format)                                                        score_eng_writtens#new
                 edit_score_eng_written GET    /score_eng_writtens/:id/edit(.:format)                                                   score_eng_writtens#edit
                      score_eng_written GET    /score_eng_writtens/:id(.:format)                                                        score_eng_writtens#show
                                        PATCH  /score_eng_writtens/:id(.:format)                                                        score_eng_writtens#update
                                        PUT    /score_eng_writtens/:id(.:format)                                                        score_eng_writtens#update
                                        DELETE /score_eng_writtens/:id(.:format)                                                        score_eng_writtens#destroy
                                 scores GET    /scores(.:format)                                                                        scores#index
                                        POST   /scores(.:format)                                                                        scores#create
                              new_score GET    /scores/new(.:format)                                                                    scores#new
                             edit_score GET    /scores/:id/edit(.:format)                                                               scores#edit
                                  score GET    /scores/:id(.:format)                                                                    scores#show
                                        PATCH  /scores/:id(.:format)                                                                    scores#update
                                        PUT    /scores/:id(.:format)                                                                    scores#update
                                        DELETE /scores/:id(.:format)                                                                    scores#destroy
                              sentences GET    /sentences(.:format)                                                                     sentences#index
                                        POST   /sentences(.:format)                                                                     sentences#create
                           new_sentence GET    /sentences/new(.:format)                                                                 sentences#new
                          edit_sentence GET    /sentences/:id/edit(.:format)                                                            sentences#edit
                               sentence GET    /sentences/:id(.:format)                                                                 sentences#show
                                        PATCH  /sentences/:id(.:format)                                                                 sentences#update
                                        PUT    /sentences/:id(.:format)                                                                 sentences#update
                                        DELETE /sentences/:id(.:format)                                                                 sentences#destroy
                                  users GET    /users(.:format)                                                                         users#index
                                        POST   /users(.:format)                                                                         users#create
                               new_user GET    /users/new(.:format)                                                                     users#new
                              edit_user GET    /users/:id/edit(.:format)                                                                users#edit
                                   user GET    /users/:id(.:format)                                                                     users#show
                                        PATCH  /users/:id(.:format)                                                                     users#update
                                        PUT    /users/:id(.:format)                                                                     users#update
                                        DELETE /users/:id(.:format)                                                                     users#destroy
          rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#create
          rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                  action_mailbox/ingresses/postmark/inbound_emails#create
             rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                     action_mailbox/ingresses/relay/inbound_emails#create
          rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                  action_mailbox/ingresses/sendgrid/inbound_emails#create
           rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                              action_mailbox/ingresses/mailgun/inbound_emails#create
         rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#index
                                        POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#create
      new_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/new(.:format)                             rails/conductor/action_mailbox/inbound_emails#new
     edit_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id/edit(.:format)                        rails/conductor/action_mailbox/inbound_emails#edit
          rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#show
                                        PATCH  /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
                                        PUT    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
                                        DELETE /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#destroy
  rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                      rails/conductor/action_mailbox/reroutes#create
                     rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
              rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
                     rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
              update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
                   rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
  miyakz@eng2:~/english_study_app/eng_app$ 



テストデータ
=================

s = []
u = User.create(name: "test", passwd_hash: "nohash")
s[0] = Sentence.all[0]
s[1] = Sentence.all[1]
s[2] = Sentence.all[2]
s[3] = Sentence.all[3]
s[4] = Sentence.all[4]
s[5] = Sentence.all[5]


#s[0] is 0 points

#s[1] is 2 points
ScoreEngNotWritten.create(passed: true, sentence: s[1], user: u)
ScoreEngNotWritten.create(passed: true, sentence: s[1], user: u)

#s[2] is -2 points
ScoreEngNotWritten.create(passed: false, sentence: s[2], user: u)
ScoreEngNotWritten.create(passed: false, sentence: s[2], user: u)

#s[3] is 4 points
ScoreEngWritten.create(passed: true, sentence: s[3], user: u)
ScoreEngWritten.create(passed: true, sentence: s[3], user: u)

#s[4] is -4 points
ScoreEngWritten.create(passed: false, sentence: s[4], user: u)
ScoreEngWritten.create(passed: false, sentence: s[4], user: u)

#s[5] is -1 points
ScoreEngNotWritten.create(passed: true, sentence: s[5], user: u)
ScoreEngWritten.create(passed: false, sentence: s[5], user: u)

小ネタ
===========================================

DB migrateのリセット
-------------------------

以下のコマンドで実施。::

  rails db:migrate VERSION=0

generateで作ったものの取り消し
-----------------------------------

railsコマンドで

  https://shinodogg.com/2011/02/15/rails%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%81%A7generate%E3%81%97%E3%81%9F%E3%81%AE%E3%82%92%E5%8F%96%E3%82%8A%E6%B6%88%E3%81%97%E3%81%9F%E3%81%84%E5%A0%B4%E5%90%88%E3%83%A1%E3%83%A2/

scaffoldで作ったものは以下で削除。

https://tamamemo.hatenablog.com/entry/20120113/1326435969

実行例::

  miyakz@eng2:~/english_study_app/eng_app$ rails destroy scaffold user
        invoke  active_record
        remove    db/migrate/20191231014921_create_users.rb
        remove    app/models/user.rb
        invoke    test_unit
        remove      test/models/user_test.rb
        remove      test/fixtures/users.yml
        invoke  resource_route
         route    resources :users
        invoke  scaffold_controller
        remove    app/controllers/users_controller.rb
        invoke    erb
        remove      app/views/users
        remove      app/views/users/index.html.erb
        remove      app/views/users/edit.html.erb
        remove      app/views/users/show.html.erb
        remove      app/views/users/new.html.erb
        remove      app/views/users/_form.html.erb
        invoke    test_unit
        remove      test/controllers/users_controller_test.rb
        remove      test/system/users_test.rb
        invoke    helper
        remove      app/helpers/users_helper.rb
        invoke      test_unit
        invoke    jbuilder
        remove      app/views/users
        remove      app/views/users/index.json.jbuilder
        remove      app/views/users/show.json.jbuilder
        remove      app/views/users/_user.json.jbuilder
        invoke  assets
        invoke    scss
        remove      app/assets/stylesheets/users.scss
        invoke  scss
  miyakz@eng2:~/english_study_app/eng_app$ 
  


参考：
==================================

button_to
https://web-camp.io/magazine/archives/19147
https://pikawaka.com/rails/button_to

railsコントローラのパラメータ関連
https://railsguides.jp/action_controller_overview.html





