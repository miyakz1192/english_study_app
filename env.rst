=======================================================
engアプリの環境構築に関するメモ
=======================================================

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

bundle installができたら、以下のように、設定を行う。
dotenvのgemを使って上手く、環境変数で情報を渡す。::
  
  miyakz@eng:~/environment/hello_app$ cat config/database.yml 
  # SQLite. Versions 3.8.0 and up are supported.
  #   gem install sqlite3
  #
  #   Ensure the SQLite 3 gem is defined in your Gemfile
  #   gem 'sqlite3'
  #
  default: &default
    adapter: mysql2
    encoding: utf8
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    timeout: 5000
    username: <%= ENV['DATABASE_DEV_USER'] %>
    password: <%= ENV['DATABASE_DEV_PASSWORD'] %>
    host:  <%= ENV['DATABASE_DEV_HOST'] %>
  
  development:
    <<: *default
    database: db/development_eng
  
  # Warning: The database defined as "test" will be erased and
  # re-generated from your development database when you run "rake".
  # Do not set this db to the same as development or production.
  test:
    <<: *default
    database: db/test_eng
  
  production:
    <<: *default
    database: db/production_eng
  miyakz@eng:~/environment/hello_app$ 

rails db:createを実行して上手く言った。

rails6のserver実行に合わせたライブラリのインストール
--------------------------------------------------------

以下が必要。::

  sudo apt-get install yarn
  rails webpacker:install

参考にしたURL

  https://qiita.com/NaokiIshimura/items/8203f74f8dfd5f6b87a0
  




  






以下のURLを参考。

https://qiita.com/pchatsu/items/a7f53da2e57ae4aca065





















