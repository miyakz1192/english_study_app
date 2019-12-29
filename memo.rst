==========================================================
どんなアプリ？
==========================================================

DUO 3.0の学習速度アップのために以下の機能を持つweb appを作って
自分だけ利用できるようにする。

もし、DUO 3.0のデータをこのアプリ指定のフォーマットで作って
配置すれば、他の人でもアプリを利用できるようにする。

狭い電車の車内でも学習しやすく、長く学習できそうなゆるい感じを目指す。

機能
====

以下の機能を備える。

0) ログイン・ログアウト機能
　登録したユーザだけ、できるようにする。
　ユーザ登録はローカルのCLIで行えるようにする（基本的には個人ユースの設計)

1) 点数管理機能
  どの英文がＮＧだったかを出力する。点数がつく。
  「英文を書かずに学習」でOKなものは1点加点。
  「英文を書かずに学習」でNGなものは1点減点。
  「英文を書いて学習」でOKなものは2点加点。
  「英文を書いて学習」でNGなものは2点減点。

  ２回め以上の点数について
  「英文を書かずに学習」加点と減点にそれぞれ、係数が加算される(1.01*トライ回数) 
  「英文を書いて学習」加点と減点にそれぞれ、係数が加算される(1.02*トライ回数) 

  要するに、OKなものは学習優先度を低く、間違ったものは学習優先度が高くする。
  とくに書いて学習したもので、ＯＫなものは繰り返しやらなくても良いようにして、
  何回も間違えるものについては、優先度高く学習するような感じにする。

2) ダッシュボード機能
　どの文章の覚えが良いのか、top5を表示
　どの文章の覚えが悪いのか、ワースト5を表示
  達成率を表示
  　点数が１点以上の文章/全文章数のパーセンテージ
  　文章を書いて学習が１回以上があり、点数が2点以上の文章/全文章数のパーセンテージ
  　文章を書かずに学習が１回以上があり、点数が1点以上の文章/全文章数のパーセンテージ


3) リスト機能
　すべての英文の日本語が出力される(点数関係なく、文章番号で出る)。
　選択したものから、以下、カード機能がスタートする。

4) チャレンジリスト機能
　すべての英文の日本語が出力される(点数が低い順に出る)。
　選択したものから、以下、カード機能がスタートする。

5) カード機能
　１本１本、単語帳のように画面に出力。まずは日本語が出る。
　その下に、「英文を書かずに学習」ボタンと「英文を書いて学習」ボタンがある。
　
  「英文を書かずに学習」ボタンを押すと、日本語の下の英文がでる。
  スピーカーボタンを押すと、英文読み上げ。
  その下にOK,NGボタンがでて、どれかを押すと、次の文章に進む


  「英文を書いて学習」ボタンを押すと
  エディットボックスが出現する。そこに英文を入力して、チャレンジボタンを押すと
  英文が出力され、正解したかどうか、間違っていたらどこが間違っていたかを出力する。
  スピーカーボタンを押すと、英文読み上げ。
  OKボタンを押せば、次に進む。

画面デザイン
=============

最初にダッシュボードが出力されて、リスト、チャレンジリストボタンがあって、
それを押すと学習がスタートする。

多分、ダッシュボードの画面が改善が入りやすいので、それとそれ以外を
サービスに分けるのが良さそうな感じ。

データ構造(モデル)
===================

ユーザ(ユーザ名、パスワード) 。なお、パスワードはsha256のハッシュ値

センテンス（英語、日本語、音声データ)

成績データ(base)
         (学習日、正解かどうか、センテンスへのリンク、ユーザへのリンク)

成績データ（英語を書かずに学習) extends 成績データ(base)
成績データ（英語を書いて学習) extends 成績データ(base)

構成
======

まずは、ゼーンブモノリシックで行きます。

ruby と railsのインストール
-------------------------------

事前にいろいろとインストールが必要.
この辺のコマンドだったっけかな。

   32  sudo gem install rails
   33  sudo apt install make -y
   34  sudo apt install gcc -y
   35  sudo gem install rails
   36  sudo apt install configure -y
   37  sudo xcode-select --install
   38  sudo apt install ruby-dev -y
   39  sudo gem install rails
   40  sudo apt install zlib -y
   41  sudo apt install zlib1g-dev -y
   42  sudo gem install rails

mysqlのインストール
-----------------------

インストール先のシステムは以下。::

  miyakz@eng:~$ cat /etc/issue
  Ubuntu 19.04 \n \l
  
  miyakz@eng:~$ 


以下のコマンドでインストール::

  sudo apt update
  sudo apt install mysql-server
  sudo mysql_secure_installation

セキュリティ設定を行う::
  
  miyakz@eng:~$ sudo mysql_secure_installation
  
  Securing the MySQL server deployment.
  
  Connecting to MySQL using a blank password.
  
  VALIDATE PASSWORD PLUGIN can be used to test passwords
  and improve security. It checks the strength of password
  and allows the users to set only those passwords which are
  secure enough. Would you like to setup VALIDATE PASSWORD plugin?
  
  Press y|Y for Yes, any other key for No: no
  Please set the password for root here.
  
  New password: 
  
  Re-enter new password: 
  By default, a MySQL installation has an anonymous user,
  allowing anyone to log into MySQL without having to have
  a user account created for them. This is intended only for
  testing, and to make the installation go a bit smoother.
  You should remove them before moving into a production
  environment.

※　匿名ユーザはoffにした。::
  
  Remove anonymous users? (Press y|Y for Yes, any other key for No) : yes
  Success.

※　リモートでのrootユーザはoffにした。::
  
  
  Normally, root should only be allowed to connect from
  'localhost'. This ensures that someone cannot guess at
  the root password from the network.
  
  Disallow root login remotely? (Press y|Y for Yes, any other key for No) : yes
  Success.
  
  By default, MySQL comes with a database named 'test' that
  anyone can access. This is also intended only for testing,
  and should be removed before moving into a production
  environment.
  
  
  Remove test database and access to it? (Press y|Y for Yes, any other key for No) : yes
   - Dropping test database...
  Success.
  
   - Removing privileges on test database...
  Success.
  
  Reloading the privilege tables will ensure that all changes
  made so far will take effect immediately.
  
  Reload privilege tables now? (Press y|Y for Yes, any other key for No) : yes
  Success.
  
  All done! 
  miyakz@eng:~$ 

次にrootユーザをパスワード指定で入れるようにする。::
  
  mysql> SELECT user,authentication_string,plugin,host FROM mysql.user;
  +------------------+-------------------------------------------+-----------------------+-----------+
  | user             | authentication_string                     | plugin                | host      |
  +------------------+-------------------------------------------+-----------------------+-----------+
  | root             |                                           | auth_socket           | localhost |
  | mysql.session    | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | mysql_native_password | localhost |
  | mysql.sys        | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | mysql_native_password | localhost |
  | debian-sys-maint | *A9A76E0A4CB45C215C9E8440BD0FA5CD9B9328B0 | mysql_native_password | localhost |
  +------------------+-------------------------------------------+-----------------------+-----------+
  4 rows in set (0.01 sec)
  
  mysql>  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '*';
  Query OK, 0 rows affected (0.00 sec)
  
  mysql> 
  
  このパスワードはVMのパスワードと同じにした。

設定を反映。::

  
  mysql>  FLUSH PRIVILEGES;
  Query OK, 0 rows affected (0.00 sec)
  
  mysql> SELECT user,authentication_string,plugin,host FROM mysql.user;
  +------------------+-------------------------------------------+-----------------------+-----------+
  | user             | authentication_string                     | plugin                | host      |
  +------------------+-------------------------------------------+-----------------------+-----------+
  | root             | *667F407DE7C6AD07358FA38DAED7828A72014B4E | mysql_native_password | localhost |
  | mysql.session    | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | mysql_native_password | localhost |
  | mysql.sys        | *THISISNOTAVALIDPASSWORDTHATCANBEUSEDHERE | mysql_native_password | localhost |
  | debian-sys-maint | *A9A76E0A4CB45C215C9E8440BD0FA5CD9B9328B0 | mysql_native_password | localhost |
  +------------------+-------------------------------------------+-----------------------+-----------+
  4 rows in set (0.01 sec)
  
  mysql> 
  
以上で完了です。なお、今後はMySQLにrootユーザでログインしたい場合は、以下のコマンドになります。::
  
  $ mysql -u root -p

engアプリ向けにengユーザを作る。これはパスワードなし。::

  mysql> CREATE USER eng
      -> ;
  Query OK, 0 rows affected (0.01 sec)
  
  mysql> 

また、DBのcreate権限を与える::

  mysql> show grants for eng
      -> ;
  +---------------------------------+
  | Grants for eng@%                |
  +---------------------------------+
  | GRANT USAGE ON *.* TO 'eng'@'%' |
  +---------------------------------+
  1 row in set (0.01 sec)
  
  mysql> grant create on *.* to  eng;
  Query OK, 0 rows affected (0.04 sec)
  
  mysql> show grants for eng;
  +----------------------------------+
  | Grants for eng@%                 |
  +----------------------------------+
  | GRANT CREATE ON *.* TO 'eng'@'%' |
  +----------------------------------+
  1 row in set (0.00 sec)
  
  mysql> 
  
  

以下のURLを参考にした。

https://www.virment.com/how-to-install-mysql-ubuntu/


mysqlドライバをrailsで使う
-----------------------------

普通にrails new appnameすると、sqlite3が設定されるので、後から変更する必要がある。
そこで、Gemfileに以下を設定しておく。::

  miyakz@eng:~/environment/hello_app$ cat Gemfile  | grep sql
  # Use sqlite3 as the database for Active Record
  #gem 'sqlite3', '~> 1.4'
  gem 'mysql2'
  miyakz@eng:~/environment/hello_app$ 
  
上記のように、sqlite3の設定をコメントアウトして、mysql2を入れる。
budle installする前に以下を実行しておく。理由はそうしておかないとbundle installで怒られるため::

  mysql client is missing. You may need to 'sudo apt-get install libmariadb-dev', 'sudo apt-get install libmysqlclient-dev' or 'sudo yum install
  mysql-devel', and try again.

実行しておくべきコマンドは以下。::

  sudo apt-get install libmariadb-dev
  sudo apt-get install libmysqlclient-dev

以下もついでに必要になる。::

  apt install libssl-dev

んで、bundle installすると、mysqlのドライバがインストールされる。

DBのパスワードを環境変数で渡すようにする。
---------------------------------------------

config/database.yamlにパスワードを記載しなくても良いようにする.
以下のGemをインストールする。::

   gem dotenv-rails

アプリケーションのrootに.envを以下のように作成する。::

 DATABASE_DEV_PASSWORD = '設定したパスワードを記入'
 DATABASE_DEV_USER = '作成したMySQLユーザー名を記入'
 DATABASE_DEV_HOST = 'localhostとか'

https://qiita.com/fuku_tech/items/a380ebb1fd156c14c25b

参考にしたURL

https://qiita.com/fuku_tech/items/a380ebb1fd156c14c25b



railsのDB定義を行う。
-----------------------

bundle installができたら、以下のように、設定を行う。::


  






以下のURLを参考。

https://qiita.com/pchatsu/items/a7f53da2e57ae4aca065












