================================================================
engアプリを作ってみる。
================================================================


テーブルを作る
==================

User Sentence, Score各種を作って、db:migrateする。::

  rails generate scaffold Sentence no:integer en:string jp:string voice_data:string
  rails generate scaffold Score passed:boolean sentence_id:integer user_id:integer
  rails generate scaffold ScoreEngWritten --parent Score 
  rails generate scaffold ScoreEngNotWritten --parent Score 
  rails g devise User name:string
  rails g devise:views users

  #create all db that defined in database.yaml
  rails db:create:all

  rails db:migrate RAILS_ENV=development

モデルの関係図
====================

以下が関係図。::

  User --has_many-> Score <-has_many-- Sentence
       --dep:dest->       <-dep:dest-- 

  ※  dependency:destroy Aが消えたらBも消える。
  ※　ScoreEngWrittenとScoreEngNotWrittenも同様にUserとSentenceの関係を持つ。

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

以下もさくっとまとまっている。

https://kitsune.blog/rails-devise

environment.rbとroute.rbに設定を追加して、モデルを作成。::

  miyakz@eng2:~/english_study_app/eng_app$ rails g devise User name:string
        invoke  active_record
        create    db/migrate/20200101050938_devise_create_users.rb
        create    app/models/user.rb
        invoke    test_unit
        create      test/models/user_test.rb
        create      test/fixtures/users.yml
        insert    app/models/user.rb
         route  devise_for :users
  miyakz@eng2:~/english_study_app/eng_app$ 

devise環境でUserをconsoleから作るメモ
-------------------------------------------

以下で簡単に作成できる。

irb(main):001:0> User.create!(name: 'hoge', email: 'admin@example.com', password: 'password')

devise環境でnew userのregistrationを消すメモ
------------------------------------------------

以下の参考にあるとおりの手順を実行する。

参考：https://kitsune.blog/rails-devise
参考：https://github.com/plataformatec/devise#configuring-views

config/initializers/devise.rbに以下のコードを追記し、カスタマイズを有効にする。::

  config.scoped_views = true

次に以下を実行して、カスタマイズ用のViewテンプレートを作成::

  rails g devise:views users

この自動生成されたファイルを好きなように編集する。::

  miyakz@eng2:~/english_study_app/eng_app$ rails g devise:views users
        invoke  Devise::Generators::SharedViewsGenerator
        create    app/views/users/shared
        create    app/views/users/shared/_error_messages.html.erb
        create    app/views/users/shared/_links.html.erb
        invoke  form_for
        create    app/views/users/confirmations
        create    app/views/users/confirmations/new.html.erb
        create    app/views/users/passwords
        create    app/views/users/passwords/edit.html.erb
        create    app/views/users/passwords/new.html.erb
        create    app/views/users/registrations
        create    app/views/users/registrations/edit.html.erb
        create    app/views/users/registrations/new.html.erb
        create    app/views/users/sessions
        create    app/views/users/sessions/new.html.erb
        create    app/views/users/unlocks
        create    app/views/users/unlocks/new.html.erb
        invoke  erb
        create    app/views/users/mailer
        create    app/views/users/mailer/confirmation_instructions.html.erb
        create    app/views/users/mailer/email_changed.html.erb
        create    app/views/users/mailer/password_change.html.erb
        create    app/views/users/mailer/reset_password_instructions.html.erb
        create    app/views/users/mailer/unlock_instructions.html.erb
  miyakz@eng2:~/english_study_app/eng_app$ 


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
  a2a781e6789fd7d17ef4a1c9090d4e0a49d496a7
  85a58bf89c4d9ecc7fc166493aa28c5f5c22da8b
  3314b908bd486ccfa41a5dd69540d72e3fc135bd
  1dc3c2498a7a09174f4be1e15f5791517c62d11c
　a5207192187772104512a62e1529b4dc20815fce
5) ajaxを使って、書かずに正解/書かずに不正解のボタンを画面遷移しなくてもできるようにする。
  結局ajaxを使わなくても良い方法で実装。
  d4d7eec2bee5b65d6f5cd9f023d67260aafa5c59
6) 「書かずに正解」とか「書いて正解」を押した場合に、前ページに戻る
  0b4ff8b0da652c9e4f8a689083003bdbcde65bdd
  参考：https://qiita.com/azusanakano/items/8af1266f53a656ef787d
7) 「書いて正解」「書いて不正解」機能を実装
  883e875d32c4cc1aaf2389ff4de97084b3fd2d87
8) ダッシュボードの統計機能を実装
　b691148ac0fe611398666b145aabc85042b370c6
9) voiceを再生できるようにする。
  a49e839d6050c07547279dbd42551ceb8f35cfe5
  参考：https://allabout.co.jp/gm/gc/385187/
10) sentenceのリストをkaminariで加工する
  5c03fbfea327a8070488740ce56419399a422247
12) 外部への公開
  cd7d84864b2b07ba19bd6e37ce24bb054e1dbe13　
13) スマホ対応
  074591fe4cad3b00efd80c34d7b6cfff8a8e36f2
14) セキュリティの考慮
  xxxx
15) rails s自動起動(サービスとして)
  5aeda7b936b3b24c58decaf259515f706fe00c26
  参考：https://qiita.com/tkato/items/6a227e7c2c2bde19521c
　参考：https://superuser.com/questions/1098167/how-to-run-service-not-as-root


参考：パスの表示
=======================

パスの表示::

  miyakz@eng2:~/english_study_app/eng_app$ rails routes
                                 Prefix Verb   URI Pattern                                                                              Controller#Action
                       new_user_session GET    /users/sign_in(.:format)                                                                 devise/sessions#new
                           user_session POST   /users/sign_in(.:format)                                                                 devise/sessions#create
                   destroy_user_session DELETE /users/sign_out(.:format)                                                                devise/sessions#destroy
                      new_user_password GET    /users/password/new(.:format)                                                            devise/passwords#new
                     edit_user_password GET    /users/password/edit(.:format)                                                           devise/passwords#edit
                          user_password PATCH  /users/password(.:format)                                                                devise/passwords#update
                                        PUT    /users/password(.:format)                                                                devise/passwords#update
                                        POST   /users/password(.:format)                                                                devise/passwords#create
               cancel_user_registration GET    /users/cancel(.:format)                                                                  devise/registrations#cancel
                  new_user_registration GET    /users/sign_up(.:format)                                                                 devise/registrations#new
                 edit_user_registration GET    /users/edit(.:format)                                                                    devise/registrations#edit
                      user_registration PATCH  /users(.:format)                                                                         devise/registrations#update
                                        PUT    /users(.:format)                                                                         devise/registrations#update
                                        DELETE /users(.:format)                                                                         devise/registrations#destroy
                                        POST   /users(.:format)                                                                         devise/registrations#create
                         accesses_hello GET    /accesses/hello(.:format)                                                                accesses#hello
                       accesses_goodbye GET    /accesses/goodbye(.:format)                                                              accesses#goodbye
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
                                   root GET    /                                                                                        accesses#hello
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

サービスの外部公開
========================

lily2の中のVMとしてeng2サーバが立ち上がっており、それを外部からHTTPアクセスできるようにしたい。
NATをlily2に設定する必要があるのだが、NATに関しては以下のページが大変わかり易い。

参考:https://www.turbolinux.co.jp/products/server/11s/user_guide/x9637.html

eng2:192.168.122.6
lily2: 192.168.0.2,192.168.122.1

192.168.0.2がインターネットに接続するためのサブネット。
192.168.122.0/24がvirbr0。

すでに、KVMによってvirbr0はNATされているので、lily2のiptablesにはたくさん
192.168.122.0/24に関するNATルールが設定されている。
したがって、192.168.122.6(eng2)に関するルールは優先的(No1)にしておかないと、
意図どおりに動作しない。

結論からいうと、以下のiptablesが必要。::

  miyakz@lily2:~/documents/linux_tips/iptables$ ./do.sh 
  set -x
  sudo iptables -t nat -I PREROUTING  1 -p tcp -d 192.168.0.2   --dport 3000 -j DNAT --to-destination 192.168.122.6:3000
  sudo iptables -t nat -I POSTROUTING 1 -p tcp -d 192.168.122.6 --dport 3000 -j SNAT --to-source 192.168.122.1
  sudo iptables        -I FORWARD     1 -p tcp -d 192.168.122.6 --dport 3000 -j ACCEPT
  miyakz@lily2:~/documents/linux_tips/iptables$ 

参考URLにあるとおり、PREROUTING,POSTROUTING,FORWARDそれぞれのチェインにデータを入れる必要がある。

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

rails cの便利集
-------------------

https://kzy52.com/entry/2014/11/28/235958

scopeを使うとビジネスロジックを簡潔にmodelに収めることができる
--------------------------------------------------------------------

https://qiita.com/ngron/items/14a39ce62c9d30bf3ac3

viewとControllerにビジネスロジックを書かない
------------------------------------------------

https://qiita.com/lastcat_/items/f002eeb482319ed21163

Viewに関するロジックをmodelから追い出して、ViewModelとPresenterに寄せよう
----------------------------------------------------------------------------

Decoratorとpresenterの基本解説

https://tech.kitchhike.com/entry/2018/02/28/221159

以下のURLもわかりやすい。

https://qiita.com/KentFujii/items/02fa3e4933a7c54e7016

以下、引用。::

  Rubyでhtmlを生成するというプロセスなので、テンプレートエンジンよりRubyの良さを活かしやすい(例えば継承してコードを使いまわすとか)ですが、presenter最大のメリットはhtmlの塊に名前をつけて管理できるところだと思います。それだけでこのviewはどういう意図があるのか？がより理解しやすくなるので。

なお、presenterは単なるデザインパターンであり、それを実現するためのgemとかは無いらしい。
ちなみに、app/modelsと同じ階層にpresentersディレクトリを作るのが主流？

https://tech.unifa-e.com/entry/2017/08/03/192008

Deviseのroutingのコンフィグ
-------------------------------

http://katahirado.hatenablog.com/entry/2014/08/16/180718

https://qiita.com/chamao/items/de00920c343a3e237d20

https://www.tmp1024.com/articles/devise-scope-and-path

Deviseの本家ページ
---------------------

https://github.com/plataformatec/devise

rubyのcaseは表現力が強力
----------------------------

https://melborne.github.io/2013/02/25/i-wanna-say-something-about-rubys-case/

セキュリティの実装
========================

検討する実装。仕様はmemo.rstを参照。
DeviseのFailureAppを使おうと思う。
これを使ってログイン失敗時をフックして、失敗したIPアドレスをDBに記録するため。

心配なのは、FailureAppを使うことで、Deviseデフォルトの挙動を上書きしないかということ。
今回はログ出力程度の話なので、デフォルト挙動は変更したくない。

以下が、DeviseのoriginalのFailureAppだと思う。

 /var/lib/gems/2.5.0/gems/devise-4.7.1/lib/devise/failure_app.rb

FailureAppを参照している箇所は以下。::
  
  miyakz@eng2:~$ grep -rn FailureApp /var/lib/gems/2.5.0/gems/devise-4.7.1/*
  /var/lib/gems/2.5.0/gems/devise-4.7.1/CHANGELOG.md:64:  *  Allow people to extend devise failure app, through invoking `ActiveSupport.run_load_hooks` once `Devise::FailureApp` is loaded (by @wnm)
  /var/lib/gems/2.5.0/gems/devise-4.7.1/lib/devise.rb:14:  autoload :FailureApp,         'devise/failure_app'
  /var/lib/gems/2.5.0/gems/devise-4.7.1/lib/devise/mapping.rb:124:      @failure_app = options[:failure_app] || Devise::FailureApp
  /var/lib/gems/2.5.0/gems/devise-4.7.1/lib/devise/delegator.rb:15:      app || Devise::FailureApp
  /var/lib/gems/2.5.0/gems/devise-4.7.1/lib/devise/failure_app.rb:10:  class FailureApp < ActionController::Metal
  miyakz@eng2:~$ 
  
以下、defaultのFalureAppを決定するところ。
/var/lib/gems/2.5.0/gems/devise-4.7.1/lib/devise/mapping.rb:::

    def default_failure_app(options)
      @failure_app = options[:failure_app] || Devise::FailureApp
      if @failure_app.is_a?(String)
        ref = Devise.ref(@failure_app)
        @failure_app = lambda { |env| ref.get.call(env) }
      end
    end

上書きしてしまう動作のようなので、Devise::FailureAppを継承したFailureAppを定義して
それを使ったほうが良さそう。定義の場所は以下。::

  /var/lib/gems/2.5.0/gems/devise-4.7.1/lib/devise/failure_app.rb:10:  class FailureApp < ActionController::Metal

それは以下に記載(本家)。::

  https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated

以下のページにもズバリで記載している。::

  https://stackoverflow.com/questions/12873957/devise-log-after-auth-failure/33230548

  class LogAuthenticationFailure < Devise::FailureApp
    def respond
      if request.env.dig('warden.options', :action) == 'unauthenticated'
        Rails.logger.info('...')
      end
      super
    end
  end

rails6バージョンではもっと簡単にアクセスできるようだ。::

  request.env["warden"].authenticate?
  参考：　/var/lib/gems/2.5.0/gems/devise-4.7.1/lib/devise/rails/routes.rb

本家のページにも記載されている手順で実装すれば、なんとかなりそう。


参考：
==================================

button_to
https://web-camp.io/magazine/archives/19147
https://pikawaka.com/rails/button_to

railsコントローラのパラメータ関連
https://railsguides.jp/action_controller_overview.html





