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

sudo apt install git -y
sudo apt update 
sudo apt install make -y
sudo apt install gcc -y
sudo apt install ruby -y
sudo apt install configure -y
sudo xcode-select --install
sudo apt install ruby-dev -y
sudo gem install rails
sudo apt install zlib -y
sudo apt install zlib1g-dev -y
sudo apt install g++ -y
sudo gem install rails

# thease package are needed due to installing mysql db
sudo apt install libmariadb-dev -y
sudo apt install libmysqlclient-dev -y
sudo apt install libssl-dev -y

# thease gem package is needed in Gemfile
gem 'mysql2'
gem 'dotenv-rails'

# thease install is needed for rails6 server execution. detail is shown laster
sudo apt install gnupg -y
sudo apt install curl -y
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn -y
rails webpacker:install


mysqlのインストール
-----------------------

インストール先のシステムは以下。::

  miyakz@eng:~$ cat /etc/issue
  Ubuntu 19.04 \n \l
  
  miyakz@eng:~$ 


以下のコマンドでインストール::

  sudo apt update
  sudo apt install mysql-server -y
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

VMと同じパスワードにしておいた。::
  
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

  $ sudo mysql -u root -p

  ※　パスワードは先程入力したもの(a) 
  
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

実はこれだと足りない。以下が必要。::

  mysql> GRANT ALL ON *.* TO eng;
  Query OK, 0 rows affected (0.03 sec)
  
  mysql> 
  
ちょっとやり過ぎかもなぁ。まぁ、良いか。

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

rails6のserver実行に合わせたライブラリ(webpacker)のインストール
=====================================================================

rails serverをrails6で実行する前提の作業について以下に記す。

以下が必要。::

  sudo apt-get install yarn
  rails webpacker:install

参考にしたURL

  https://qiita.com/NaokiIshimura/items/8203f74f8dfd5f6b87a0

最新yarnのインストール
------------------------

実はapt-getしたyarnだとrails webpacker:install時に以下のエラーになる。::

  miyakz@eng:~/environment/hello_app$ rails webpacker:install
  rails aborted!
  ArgumentError: Malformed version number string 0.32+git
  /var/lib/gems/2.5.0/gems/webpacker-4.2.2/lib/tasks/webpacker/check_yarn.rake:12:in `block (2 levels) in <top (required)>'
  /var/lib/gems/2.5.0/gems/railties-6.0.2.1/lib/rails/commands/rake/rake_command.rb:23:in `block in perform'
  /var/lib/gems/2.5.0/gems/railties-6.0.2.1/lib/rails/commands/rake/rake_command.rb:20:in `perform'
  /var/lib/gems/2.5.0/gems/railties-6.0.2.1/lib/rails/command.rb:48:in `invoke'
  /var/lib/gems/2.5.0/gems/railties-6.0.2.1/lib/rails/commands.rb:18:in `<top (required)>'
  /var/lib/gems/2.5.0/gems/bootsnap-1.4.5/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:22:in `require'
  /var/lib/gems/2.5.0/gems/bootsnap-1.4.5/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:22:in `block in require_with_bootsnap_lfi'
  /var/lib/gems/2.5.0/gems/bootsnap-1.4.5/lib/bootsnap/load_path_cache/loaded_features_index.rb:92:in `register'
  /var/lib/gems/2.5.0/gems/bootsnap-1.4.5/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:21:in `require_with_bootsnap_lfi'
  /var/lib/gems/2.5.0/gems/bootsnap-1.4.5/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:30:in `require'
  /var/lib/gems/2.5.0/gems/activesupport-6.0.2.1/lib/active_support/dependencies.rb:325:in `block in require'
  /var/lib/gems/2.5.0/gems/activesupport-6.0.2.1/lib/active_support/dependencies.rb:291:in `load_dependency'
  /var/lib/gems/2.5.0/gems/activesupport-6.0.2.1/lib/active_support/dependencies.rb:325:in `require'
  bin/rails:4:in `<main>'
  Tasks: TOP => webpacker:install => webpacker:check_yarn
  (See full trace by running task with --trace)
  miyakz@eng:~/environment/hello_app$ 

どうも、yarn --verionが返すバージョンストリングが気に食わないのだと。::

  miyakz@eng:~/environment/hello_app$ yarn --version
  0.32+git
  miyakz@eng:~/environment/hello_app$ 

以下の参考URLのインストラクションにしたがって、以下でインストールしてみる。::

  sudo apt-install curl
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt update && sudo apt install yarn

これで以下のバージョンのyarnがインストールされた::

  miyakz@eng:~/environment/hello_app$ yarn --version
  1.21.1
  miyakz@eng:~/environment/hello_app$ 

webpackerのinstall
-------------------------

上記が完了した状態で以下を実行。::

  miyakz@eng:~/environment/hello_app$ rails webpacker:install
        create  config/webpacker.yml
  Copying webpack core config
        create  config/webpack
        create  config/webpack/development.js
        create  config/webpack/environment.js
        create  config/webpack/production.js
        create  config/webpack/test.js
  Copying postcss.config.js to app root directory
        create  postcss.config.js
  Copying babel.config.js to app root directory
        create  babel.config.js
  Copying .browserslistrc to app root directory
        create  .browserslistrc
  The JavaScript app source directory already exists
         apply  /var/lib/gems/2.5.0/gems/webpacker-4.2.2/lib/install/binstubs.rb
    Copying binstubs
         exist    bin
        create    bin/webpack
        create    bin/webpack-dev-server
        append  .gitignore
  Installing all JavaScript dependencies [4.2.2]
           run  yarn add @rails/webpacker@4.2.2 from "."
  yarn add v1.21.1
  info No lockfile found.
  [1/4] Resolving packages...
  error An unexpected error occurred: "https://registry.yarnpkg.com/@rails%2fujs: The value \"4294967295\" is invalid for option \"family\" registry.yarnpkg.com:443".
  info If you think this is a bug, please open a bug report with the information provided in "/home/miyakz/environment/hello_app/yarn-error.log".
  info Visit https://yarnpkg.com/en/docs/cli/add for documentation about this command.
  Installing dev server for live reloading
           run  yarn add --dev webpack-dev-server from "."
  yarn add v1.21.1
  info No lockfile found.
  [1/4] Resolving packages...
  error An unexpected error occurred: "https://registry.yarnpkg.com/@rails%2fujs: The value \"4294967295\" is invalid for option \"family\" registry.yarnpkg.com:443".
  info If you think this is a bug, please open a bug report with the information provided in "/home/miyakz/environment/hello_app/yarn-error.log".
  info Visit https://yarnpkg.com/en/docs/cli/add for documentation about this command.
  Webpacker successfully installed 🎉 🍰
  miyakz@eng:~/environment/hello_app$ 

こんな感じで上手く言った。


railsの起動方法
===================

たいてい、リモートからアクセスするので、以下のような感じで実行。::

  miyakz@eng:~/environment/hello_app$ rails s -b 192.168.122.6
  => Booting Puma
  => Rails 6.0.2.1 application starting in development 
  => Run `rails server --help` for more startup options
  Puma starting in single mode...
  * Version 4.3.1 (ruby 2.5.5-p157), codename: Mysterious Traveller
  * Min threads: 5, max threads: 5
  * Environment: development
  * Listening on tcp://192.168.122.6:3000
  Use Ctrl-C to stop

そうすると、usersにアクセスしたあたりで以下のエラーに遭遇する。::

  Started GET "/users" for 192.168.122.1 at 2019-12-30 02:36:02 +0900
  Cannot render console from 192.168.122.1! Allowed networks: 127.0.0.0/127.255.255.255, ::1
  Processing by UsersController#index as HTML
    Rendering users/index.html.erb within layouts/application
    User Load (3.8ms)  SELECT `users`.* FROM `users`
    ↳ app/views/users/index.html.erb:15
    Rendered users/index.html.erb within layouts/application (Duration: 45.2ms | Allocations: 1373)
  [Webpacker] Compiling...
  [Webpacker] Compilation failed:
  yarn run v1.21.1
  info Visit https://yarnpkg.com/en/docs/cli/run for documentation about this command.
  

  error Command "webpack" not found.
  
  Completed 500 Internal Server Error in 27755ms (ActiveRecord: 11.5ms | Allocations: 13306)
  
  
    
  ActionView::Template::Error (Webpacker can't find application in /home/miyakz/environment/hello_app/public/packs/manifest.json. Possible causes:
  1. You want to set webpacker.yml value of compile to true for your environment
     unless you are using the `webpack -w` or the webpack-dev-server.
  2. webpack has not yet re-run to reflect updates.
  3. You have misconfigured Webpacker's config/webpacker.yml file.
  4. Your webpack configuration is not creating a manifest.
  Your manifest contains:
  {
  }
  ):
       6:     <%= csp_meta_tag %>
       7: 
       8:     <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
       9:     <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
      10:   </head>
      11: 
      12:   <body>
    
  app/views/layouts/application.html.erb:9
  
  
  miyakz@eng:~/environment/hello_app$ bin/webpack
  yarn run v1.21.1
  error Command "webpack" not found.
  info Visit https://yarnpkg.com/en/docs/cli/run for documentation about this command.
  miyakz@eng:~/environment/hello_app$ 

ただ、webpackをyarnで直接インストールしてみても、同じようなエラーに遭遇する。::

  miyakz@eng:~/environment/hello_app$ yarn add webpack webpack-dev-server --dev
  yarn add v1.21.1
  info No lockfile found.
  [1/4] Resolving packages...
  error An unexpected error occurred: "https://registry.yarnpkg.com/@rails%2fujs: The value \"4294967295\" is invalid for option \"family\" registry.yarnpkg.com:443".
  info If you think this is a bug, please open a bug report with the information provided in "/home/miyakz/environment/hello_app/yarn-error.log".
  info Visit https://yarnpkg.com/en/docs/cli/add for documentation about this command.
  miyakz@eng:~/environment/hello_app$ 

どうも、これは、qemuのバグらしい。

https://github.com/nodejs/node/issues/19348
https://git.qemu.org/?p=qemu.git;a=commitdiff_plain;h=1e8a98b53867f61da9ca09f411288e2085d323c4

VMで以下を実行してみる。::

  miyakz@eng:~/environment/hello_app$ node -e "let buffer; buffer |= 0; console.log(buffer);"
  -1
  miyakz@eng:~/environment/hello_app$ 

lily2(VMホスト)のqemuのバージョンは以下。::

  miyakz@lily2:~$ qemu-system-x86_64 --version
  QEMU emulator version 3.1.0 (Debian 1:3.1+dfsg-2ubuntu3.5)
  Copyright (c) 2003-2018 Fabrice Bellard and the QEMU Project developers
  miyakz@lily2:~$ 

qemuのソースを見てみたが、どうも、3系では修正されておらず、4系だと修正されている。::

  void helper_cvtps2dq(CPUX86State *env, ZMMReg *d, ZMMReg *s)
  {
      d->ZMM_L(0) = x86_float32_to_int32(s->ZMM_S(0), &env->sse_status);
      d->ZMM_L(1) = x86_float32_to_int32(s->ZMM_S(1), &env->sse_status);
      d->ZMM_L(2) = x86_float32_to_int32(s->ZMM_S(2), &env->sse_status);
      d->ZMM_L(3) = x86_float32_to_int32(s->ZMM_S(3), &env->sse_status);
  }

うーむ。railsでプログラムを組むためにqemuのアップデートが必要？
そしてどうも、4系になると、VMイメージの作り直しが推奨されているとか。。。

というわけで、以下のURLを参考にして、qemuをupdateしてみる。

http://tabletuser.blogspot.com/2019/05/install-qemu-40-to-ubuntu.html
https://mathiashueber.com/manually-update-qemu-on-ubuntu-18-04/

以下の手順でupdateを実施。::

  sudo apt update && sudo apt upgrade -y; time sudo apt-get install build-essential zlib1g-dev pkg-config libglib2.0-dev binutils-dev libboost-all-dev autoconf libtool libssl-dev libpixman-1-dev libpython-dev python-pip python-capstone virtualenv ssvnc -y
  sudo apt update && sudo apt upgrade -y; sudo apt install make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip -y
  git clone https://git.qemu.org/git/qemu.git
  mkdir source 
  mv qemu/ source/
  cd source/
  cd qemu/
  git checkout -b remotes/origin/stable-4.1
  git submodule init
  git submodule update --recursive
  ./configure 
  make
  sudo make install

4.1へのupを確認。::

  miyakz@lily2:~/source/qemu$ qemu-system-x86_64 --version
  QEMU emulator version 4.1.1 (v4.1.1-dirty)
  Copyright (c) 2003-2019 Fabrice Bellard and the QEMU Project developers
  miyakz@lily2:~/source/qemu$ 

実行結果は変わんない。::

  miyakz@eng:~$ node -e "let buffer; buffer |= 0; console.log(buffer);"
  -1
  miyakz@eng:~$ yarn add webpack webpack-dev-server --dev
  yarn add v1.21.1
  info No lockfile found.
  [1/4] Resolving packages...
  error An unexpected error occurred: "https://registry.yarnpkg.com/webpack: The value \"4294967295\" is invalid for option \"family\" registry.yarnpkg.com:443".
  info If you think this is a bug, please open a bug report with the information provided in "/home/miyakz/yarn-error.log".
  info Visit https://yarnpkg.com/en/docs/cli/add for documentation about this command.
  miyakz@eng:~$ 

使っているqemuが古い？？？::

  libvirt+  9212     1 39 12:54 ?        00:01:10 /usr/bin/qemu-system-x86_64 -name guest=eng,debug-threads=on -S -object secret,id=masterKey0,format=raw,file=/var/lib/libvirt/qemu/domain-1-eng/master-key.aes -machine pc-q35-3.1,accel=tcg,usb=off,dump-guest-core=off -m 8192 -realtime mlock=off -smp 2,sockets=2,cores=1,threads=1 -uuid a50e96b0-0887-4e00-9bb9-0a7bebdcd935 -display none -no-user-config -nodefaults -chardev socket,id=charmonitor,fd=24,server,nowait -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc,driftfix=slew -global kvm-pit.lost_tick_policy=delay -no-hpet -no-shutdown -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 -boot strict=on -device pcie-root-port,port=0x8,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x1 -device pcie-root-port,port=0x9,chassis=2,id=pci.2,bus=pcie.0,addr=0x1.0x1 -device pcie-root-port,port=0xa,chassis=3,id=pci.3,bus=pcie.0,addr=0x1.0x2 -device pcie-root-port,port=0xb,chassis=4,id=pci.4,bus=pcie.0,addr=0x1.0x3 -device pcie-root-port,port=0xc,chassis=5,id=pci.5,bus=pcie.0,addr=0x1.0x4 -device pcie-root-port,port=0xd,chassis=6,id=pci.6,bus=pcie.0,addr=0x1.0x5 -device pcie-root-port,port=0xe,chassis=7,id=pci.7,bus=pcie.0,addr=0x1.0x6 -device ich9-usb-ehci1,id=usb,bus=pcie.0,addr=0x1d.0x7 -device ich9-usb-uhci1,masterbus=usb.0,firstport=0,bus=pcie.0,multifunction=on,addr=0x1d -device ich9-usb-uhci2,masterbus=usb.0,firstport=2,bus=pcie.0,addr=0x1d.0x1 -device ich9-usb-uhci3,masterbus=usb.0,firstport=4,bus=pcie.0,addr=0x1d.0x2 -device virtio-serial-pci,id=virtio-serial0,bus=pci.3,addr=0x0 -drive file=/home/miyakz/vms/eng,format=qcow2,if=none,id=drive-virtio-disk0 -device virtio-blk-pci,scsi=off,bus=pci.4,addr=0x0,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 -drive if=none,id=drive-sata0-0-0,media=cdrom,readonly=on -device ide-cd,bus=ide.0,drive=drive-sata0-0-0,id=sata0-0-0 -netdev tap,fd=26,id=hostnet0 -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:92:ba:15,bus=pci.1,addr=0x0 -netdev tap,fd=27,id=hostnet1 -device virtio-net-pci,netdev=hostnet1,id=net1,mac=52:54:00:61:94:05,bus=pci.2,addr=0x0 -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -chardev socket,id=charchannel0,fd=28,server,nowait -device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=org.qemu.guest_agent.0 -device virtio-balloon-pci,id=balloon0,bus=pci.5,addr=0x0 -object rng-random,id=objrng0,filename=/dev/urandom -device virtio-rng-pci,rng=objrng0,id=rng0,bus=pci.6,addr=0x0 -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny -msg timestamp=on
  miyakz    9289 12096  0 12:54 pts/5    00:00:00 

確認してみると古かった。::

  miyakz@lily2:~$ /usr/bin/qemu-system-x86_64 --version
  QEMU emulator version 3.1.0 (Debian 1:3.1+dfsg-2ubuntu3.7)
  Copyright (c) 2003-2018 Fabrice Bellard and the QEMU Project developers
  miyakz@lily2:~$ 

新しいのはこちら。::

  miyakz@lily2:~/source/qemu$ which qemu-system-x86_64
  /usr/local/bin/qemu-system-x86_64
  miyakz@lily2:~/source/qemu$ 

libvirtの使うqemuを切り替える必要がある？
適当にgrepしてみると、各VMイメージの設定ファイルで設定されているらしい。::

  miyakz@lily2:/etc$ sudo grep -rn /usr/bin/qemu-system-x86_64 *
  [sudo] miyakz のパスワード: 
  apparmor.d/abstractions/libvirt-qemu:132:  /usr/bin/qemu-system-x86_64 rmix,
  libvirt/qemu/u1904_temp2.xml:40:    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  libvirt/qemu/ubuntu1904_template.xml:40:    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  libvirt/qemu/exp.xml:40:    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  libvirt/qemu/kubenode11.xml:40:    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  libvirt/qemu/pvserver.xml:40:    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  libvirt/qemu/kubecon1.xml:40:    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  libvirt/qemu/eng.xml:40:    <emulator>/usr/bin/qemu-system-x86_64</emulator>
  miyakz@lily2:/etc$ 

設定を変えてみると怒られる。::

   miyakz@lily2:~$ sudo virsh edit  eng
   [sudo] miyakz のパスワード: 
   error: internal error: Failed to probe QEMU binary with QMP: libvirt:  error : cannot execute binary /usr/local/bin/qemu-system-x86_64: 許可がありません
   
   Failed. Try again? [y,n,i,f,?]: 
   
apparmorは生きている。::

  miyakz@lily2:~/source/qemu$ sudo /etc/init.d/apparmor status
  ● apparmor.service - Load AppArmor profiles
     Lin PID: 582 (code=exited, status=0/SUCCESS)
      Tasks: 0 (limit: 4915)
     Memory: 0B
     CGroup: /system.slice/apparmor.service
  
  
  
  12月 29 17:33:49 lily2 apparmor.systemd[582]: Restarting AppArmor
  12月 29 17:33:49 lily2 apparmor.systemd[582]: Reloading AppArmor profiles
  12月 29 17:33:49 lily2 apparmor.systemd[582]: Skipping profile in /etc/apparmor.d/disable: usr.sbin.rsyslogd
  12月 29 17:33:46 lily2 systemd[1]: Starting Load AppArmor profiles...
  12月 29 17:33:48 lily2 systemd[1]: Started Load AppArmor profiles.
  miyakz@lily2:~/source/qemu$ oaded: loaded (bled; vendor preset: enabled)
     Active: active (exited) since Sun 2019-12-29 17:33:48 JST; 19h ago
       Docs: 
  ://gitlab.com/apparmor/apparmor/wikis/home/https://gitlab.com/apparmor/apparmor/wikis/home/


apparmorを消す::

  miyakz@lily2:~/source/qemu$ sudo /etc/init.d/apparmor stop
  [sudo] miyakz のパスワード: 
  [ ok ] Stopping apparmor (via systemctl): apparmor.service.
  miyakz@lily2:~/source/qemu$ sudo /etc/init.d/apparmor teardown
  Usage: /etc/init.d/apparmor {start|stop|restart|reload|force-reload|status}
  miyakz@lily2:~/source/qemu$ sudo apt-get remove apparmor
  パッケージリストを読み込んでいます... 完了
  依存関係ツリーを作成しています                
  状態情報を読み取っています... 完了
  以下のパッケージは「削除」されます:
    apparmor
    アップグレード: 0 個、新規インストール: 0 個、削除: 1 個、保留: 0 個。
    この操作後に 1,973 kB のディスク容量が解放されます。
    続行しますか? [Y/n] y
    (データベースを読み込んでいます ... 現在 160069 個のファイルとディレクトリがインストールされています。)
    apparmor (2.13.2-9ubuntu6.1) を削除しています ...
    man-db (2.8.5-2) のトリガを処理しています ...
    miyakz@lily2:~/source/qemu$ 

なぜか、普通に起動しなくなり・・・::
  
  miyakz@lily2:~/source/qemu$ virsh start eng
  error: Failed to start domain eng
  error: internal error: process exited while connecting to monitor: 2019-12-30T04:27:43.506591Z qemu-system-x86_64: -object secret,id=masterKey0,format=raw,file=/var/lib/libvirt/qemu/domain-4-eng/master-key.aes: Unable to read /var/lib/libvirt/qemu/domain-4-eng/master-key.aes: Failed to open file “/var/lib/libvirt/qemu/domain-4-eng/master-key.aes”: Permission denied
  
  miyakz@lily2:~/source/qemu$ 

lily2を再起動した後は正常にきどうするようになった。::

  miyakz@lily2:~$ virsh start eng
  Domain eng started
  
  miyakz@lily2:~$ 

また、普通に4系のqemuに切り替えられるようになった。::

  miyakz@lily2:~$ virsh edit eng
  /Domain eng XML configuration edited.
  
  miyakz@lily2:~$ 

確認。::

  miyakz@lily2:~$ ps -ef | grep eng
  libvirt+  1607     1 99 13:36 ?        00:00:36 /usr/local/bin/qemu-system-x86_64 -name guest=eng,debug-threads=on -S -object secret,id=masterKey0,format=raw,file=/var/lib/libvirt/qemu/domain-2-eng/master-key.aes -machine pc-q35-3.1,accel=tcg,usb=off,dump-guest-core=off -m 8192 -realtime mlock=off -smp 2,sockets=2,cores=1,threads=1 -uuid a50e96b0-0887-4e00-9bb9-0a7bebdcd935 -display none -no-user-config -nodefaults -chardev socket,id=charmonitor,fd=24,server,nowait -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc,driftfix=slew -global kvm-pit.lost_tick_policy=delay -no-hpet -no-shutdown -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 -boot strict=on -device pcie-root-port,port=0x8,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x1 -device pcie-root-port,port=0x9,chassis=2,id=pci.2,bus=pcie.0,addr=0x1.0x1 -device pcie-root-port,port=0xa,chassis=3,id=pci.3,bus=pcie.0,addr=0x1.0x2 -device pcie-root-port,port=0xb,chassis=4,id=pci.4,bus=pcie.0,addr=0x1.0x3 -device pcie-root-port,port=0xc,chassis=5,id=pci.5,bus=pcie.0,addr=0x1.0x4 -device pcie-root-port,port=0xd,chassis=6,id=pci.6,bus=pcie.0,addr=0x1.0x5 -device pcie-root-port,port=0xe,chassis=7,id=pci.7,bus=pcie.0,addr=0x1.0x6 -device ich9-usb-ehci1,id=usb,bus=pcie.0,addr=0x1d.0x7 -device ich9-usb-uhci1,masterbus=usb.0,firstport=0,bus=pcie.0,multifunction=on,addr=0x1d -device ich9-usb-uhci2,masterbus=usb.0,firstport=2,bus=pcie.0,addr=0x1d.0x1 -device ich9-usb-uhci3,masterbus=usb.0,firstport=4,bus=pcie.0,addr=0x1d.0x2 -device virtio-serial-pci,id=virtio-serial0,bus=pci.3,addr=0x0 -drive file=/home/miyakz/vms/eng,format=qcow2,if=none,id=drive-virtio-disk0 -device virtio-blk-pci,scsi=off,bus=pci.4,addr=0x0,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1 -drive if=none,id=drive-sata0-0-0,media=cdrom,readonly=on -device ide-cd,bus=ide.0,drive=drive-sata0-0-0,id=sata0-0-0 -netdev tap,fd=26,id=hostnet0 -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:92:ba:15,bus=pci.1,addr=0x0 -netdev tap,fd=27,id=hostnet1 -device virtio-net-pci,netdev=hostnet1,id=net1,mac=52:54:00:61:94:05,bus=pci.2,addr=0x0 -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -chardev socket,id=charchannel0,fd=28,server,nowait -device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=org.qemu.guest_agent.0 -device virtio-balloon-pci,id=balloon0,bus=pci.5,addr=0x0 -object rng-random,id=objrng0,filename=/dev/urandom -device virtio-rng-pci,rng=objrng0,id=rng0,bus=pci.6,addr=0x0 -msg timestamp=on
  miyakz    1636  1421  0 13:37 pts/0    00:00:00 ssh eng
  miyakz    1666  1569  0 13:37 pts/1    00:00:00 grep --color=auto eng
  miyakz@lily2:~$ /usr/local/bin/qemu-system-x86_64 --version
  QEMU emulator version 4.1.1 (v4.1.1-dirty)
  Copyright (c) 2003-2019 Fabrice Bellard and the QEMU Project developers
  miyakz@lily2:~$ 

ただ、結果は変わらず。??::

  miyakz@eng:~$ node -e "let buffer; buffer |= 0; console.log(buffer);"
  -1
  miyakz@eng:~$ 
  
  miyakz@eng:~$ yarn add webpack webpack-dev-server --dev 
  yarn add v1.21.1
  info No lockfile found.
  [1/4] Resolving packages...
  error An unexpected error occurred: "https://registry.yarnpkg.com/webpack: The value \"4294967295\" is invalid for option \"family\" registry.yarnpkg.com:443".
  info If you think this is a bug, please open a bug report with the information provided in "/home/miyakz/yarn-error.log".
  info Visit https://yarnpkg.com/en/docs/cli/add for documentation about this command.
  miyakz@eng:~$ 

もう一回だけ、環境を再構築してみたが結果は変わらず。なお、以下の結果となる。::

  【lily2】
  
  miyakz@lily2:~$ node
  > a = undefined
  undefined
  > a >>> 0
  0
  > 

  miyakz@lily2:~$ node -e "let buffer; buffer |= 0; console.log(buffer);"
  0
  miyakz@lily2:~$ 

  
  【VM（4.1.1で動作）】
  miyakz@eng2:~/environment/eng$ node
  a = undefined
  > a = undefined
  undefined
  > a >>> 0
  4294967295
  > quit
  ReferenceError: quit is not defined
  > miyakz@eng2:~/environment/eng$ 


  miyakz@eng2:~/environment/eng$ node -e "let buffer; buffer |= 0; console.log(buffer);"
  -1
  miyakz@eng2:~/environment/eng$ 

なんと・・・当該修正があたっているのは、qemu4.2からであった（確認不足・・・）。
もう一回、4.2にしてみる。

qemuのソースをgitでダウンロードしてbranchを見てみると、4.1が最新に見えたのだが、じつはこのバージョンには該当修正はない。参照URLに示すとおり、masterに対してコンパイルするべきであった。このバージョンであれば、
修正が入っている。::

  miyakz@lily2:~/source$ cat do.sh 
  git clone https://git.qemu.org/git/qemu.git
  cd qemu/
  git submodule init
  git submodule update --recursive
  ./configure 
  make
  #sudo make install
  
  miyakz@lily2:~/source$ 

修正がバッチリ入っている。::

  miyakz@lily2:~/source/qemu$ grep x86 target/i386/ops_sse.h  | head
   * x86 mandates that we return the indefinite integer value for the result
      static inline RETTYPE x86_##FN(FLOATTYPE a, float_status *s)        \
      d->ZMM_L(0) = x86_float32_to_int32(s->ZMM_S(0), &env->sse_status);
      d->ZMM_L(1) = x86_float32_to_int32(s->ZMM_S(1), &env->sse_status);
      d->ZMM_L(2) = x86_float32_to_int32(s->ZMM_S(2), &env->sse_status);
      d->ZMM_L(3) = x86_float32_to_int32(s->ZMM_S(3), &env->sse_status);
      d->ZMM_L(0) = x86_float64_to_int32(s->ZMM_D(0), &env->sse_status);
      d->ZMM_L(1) = x86_float64_to_int32(s->ZMM_D(1), &env->sse_status);
      d->MMX_L(0) = x86_float32_to_int32(s->ZMM_S(0), &env->sse_status);
      d->MMX_L(1) = x86_float32_to_int32(s->ZMM_S(1), &env->sse_status);
  miyakz@lily2:~/source/qemu$ 
  
もう一回、qemuをビルドして、eng2で以下を実行してみた。驚くべきことに
問題は修正されているようだ。::

  miyakz@eng2:~$  node -e "let buffer; buffer |= 0; console.log(buffer);"
  0
  miyakz@eng2:~$ 

webpackerのinstallも今度こそちゃんと成功した。::

  miyakz@eng2:~/environment/eng$ rails webpacker:install
     identical  config/webpacker.yml
  Copying webpack core config
         exist  config/webpack
     identical  config/webpack/development.js
     identical  config/webpack/environment.js
     identical  config/webpack/production.js
     identical  config/webpack/test.js
  Copying postcss.config.js to app root directory
     identical  postcss.config.js
  Copying babel.config.js to app root directory
     identical  babel.config.js
  Copying .browserslistrc to app root directory
     identical  .browserslistrc
  The JavaScript app source directory already exists
         apply  /var/lib/gems/2.5.0/gems/webpacker-4.2.2/lib/install/binstubs.rb
    Copying binstubs
         exist    bin
     identical    bin/webpack
     identical    bin/webpack-dev-server
  File unchanged! The supplied flag value not found!  .gitignore
  Installing all JavaScript dependencies [4.2.2]
           run  yarn add @rails/webpacker@4.2.2 from "."
  yarn add v1.21.1
  info No lockfile found.
  [1/4] Resolving packages...
  [2/4] Fetching packages...
  warning sha.js@2.4.11: Invalid bin entry for "sha.js" (in "sha.js").
  info fsevents@1.2.11: The platform "linux" is incompatible with this module.
  info "fsevents@1.2.11" is an optional dependency and failed compatibility check. Excluding it from installation.
  [3/4] Linking dependencies...
  [4/4] Building fresh packages...
  success Saved lockfile.
  success Saved 592 new dependencies.
  info Direct dependencies
  ├─ @rails/actioncable@6.0.2
  ├─ @rails/activestorage@6.0.2
  ├─ @rails/ujs@6.0.2
  ├─ @rails/webpacker@4.2.2
  └─ turbolinks@5.2.0
  info All dependencies
  ├─ @babel/core@7.7.7
  ├─ @babel/generator@7.7.7
  ├─ @babel/helper-builder-binary-assignment-operator-visitor@7.7.4
  ├─ @babel/helper-call-delegate@7.7.4
  ├─ @babel/helper-create-class-features-plugin@7.7.4
  ├─ @babel/helper-define-map@7.7.4
  ├─ @babel/helper-explode-assignable-expression@7.7.4
  ├─ @babel/helper-module-transforms@7.7.5
  ├─ @babel/helper-regex@7.5.5
  ├─ @babel/helper-wrap-function@7.7.4
  ├─ @babel/helpers@7.7.4
  ├─ @babel/highlight@7.5.0
  ├─ @babel/plugin-proposal-async-generator-functions@7.7.4
  ├─ @babel/plugin-proposal-class-properties@7.7.4
  ├─ @babel/plugin-proposal-dynamic-import@7.7.4
  ├─ @babel/plugin-proposal-json-strings@7.7.4
  ├─ @babel/plugin-proposal-object-rest-spread@7.7.7
  ├─ @babel/plugin-proposal-optional-catch-binding@7.7.4
  ├─ @babel/plugin-proposal-unicode-property-regex@7.7.7
  ├─ @babel/plugin-syntax-top-level-await@7.7.4
  ├─ @babel/plugin-transform-arrow-functions@7.7.4
  ├─ @babel/plugin-transform-async-to-generator@7.7.4
  ├─ @babel/plugin-transform-block-scoped-functions@7.7.4
  ├─ @babel/plugin-transform-block-scoping@7.7.4
  ├─ @babel/plugin-transform-classes@7.7.4
  ├─ @babel/plugin-transform-computed-properties@7.7.4
  ├─ @babel/plugin-transform-destructuring@7.7.4
  ├─ @babel/plugin-transform-dotall-regex@7.7.7
  ├─ @babel/plugin-transform-duplicate-keys@7.7.4
  ├─ @babel/plugin-transform-exponentiation-operator@7.7.4
  ├─ @babel/plugin-transform-for-of@7.7.4
  ├─ @babel/plugin-transform-function-name@7.7.4
  ├─ @babel/plugin-transform-literals@7.7.4
  ├─ @babel/plugin-transform-member-expression-literals@7.7.4
  ├─ @babel/plugin-transform-modules-amd@7.7.5
  ├─ @babel/plugin-transform-modules-commonjs@7.7.5
  ├─ @babel/plugin-transform-modules-systemjs@7.7.4
  ├─ @babel/plugin-transform-modules-umd@7.7.4
  ├─ @babel/plugin-transform-named-capturing-groups-regex@7.7.4
  ├─ @babel/plugin-transform-new-target@7.7.4
  ├─ @babel/plugin-transform-object-super@7.7.4
  ├─ @babel/plugin-transform-parameters@7.7.7
  ├─ @babel/plugin-transform-property-literals@7.7.4
  ├─ @babel/plugin-transform-regenerator@7.7.5
  ├─ @babel/plugin-transform-reserved-words@7.7.4
  ├─ @babel/plugin-transform-runtime@7.7.6
  ├─ @babel/plugin-transform-shorthand-properties@7.7.4
  ├─ @babel/plugin-transform-spread@7.7.4
  ├─ @babel/plugin-transform-sticky-regex@7.7.4
  ├─ @babel/plugin-transform-template-literals@7.7.4
  ├─ @babel/plugin-transform-typeof-symbol@7.7.4
  ├─ @babel/plugin-transform-unicode-regex@7.7.4
  ├─ @babel/preset-env@7.7.7
  ├─ @babel/runtime@7.7.7
  ├─ @rails/actioncable@6.0.2
  ├─ @rails/activestorage@6.0.2
  ├─ @rails/ujs@6.0.2
  ├─ @rails/webpacker@4.2.2
  ├─ @types/parse-json@4.0.0
  ├─ @types/q@1.5.2
  ├─ @webassemblyjs/floating-point-hex-parser@1.8.5
  ├─ @webassemblyjs/helper-code-frame@1.8.5
  ├─ @webassemblyjs/helper-fsm@1.8.5
  ├─ @webassemblyjs/helper-wasm-section@1.8.5
  ├─ @webassemblyjs/wasm-edit@1.8.5
  ├─ @webassemblyjs/wasm-opt@1.8.5
  ├─ @xtuc/ieee754@1.2.0
  ├─ abbrev@1.1.1
  ├─ acorn@6.4.0
  ├─ aggregate-error@3.0.1
  ├─ ajv-errors@1.0.1
  ├─ ajv-keywords@3.4.1
  ├─ ajv@6.10.2
  ├─ amdefine@1.0.1
  ├─ ansi-styles@3.2.1
  ├─ anymatch@2.0.0
  ├─ are-we-there-yet@1.1.5
  ├─ argparse@1.0.10
  ├─ arr-flatten@1.1.0
  ├─ array-find-index@1.0.2
  ├─ asn1.js@4.10.1
  ├─ asn1@0.2.4
  ├─ assert@1.5.0
  ├─ assign-symbols@1.0.0
  ├─ async-each@1.0.3
  ├─ async-foreach@0.1.3
  ├─ asynckit@0.4.0
  ├─ atob@2.1.2
  ├─ autoprefixer@9.7.3
  ├─ aws-sign2@0.7.0
  ├─ aws4@1.9.0
  ├─ babel-loader@8.0.6
  ├─ babel-plugin-macros@2.8.0
  ├─ base@0.11.2
  ├─ base64-js@1.3.1
  ├─ bcrypt-pbkdf@1.0.2
  ├─ big.js@5.2.2
  ├─ binary-extensions@1.13.1
  ├─ block-stream@0.0.9
  ├─ bluebird@3.7.2
  ├─ boolbase@1.0.0
  ├─ brace-expansion@1.1.11
  ├─ braces@2.3.2
  ├─ browserify-aes@1.2.0
  ├─ browserify-cipher@1.0.1
  ├─ browserify-des@1.0.2
  ├─ browserify-sign@4.0.4
  ├─ browserify-zlib@0.2.0
  ├─ buffer-xor@1.0.3
  ├─ buffer@4.9.2
  ├─ builtin-status-codes@3.0.0
  ├─ cache-base@1.0.1
  ├─ caller-callsite@2.0.0
  ├─ caller-path@2.0.0
  ├─ callsites@2.0.0
  ├─ camelcase-keys@2.1.0
  ├─ caniuse-lite@1.0.30001017
  ├─ case-sensitive-paths-webpack-plugin@2.2.0
  ├─ caseless@0.12.0
  ├─ chokidar@2.1.8
  ├─ chownr@1.1.3
  ├─ chrome-trace-event@1.0.2
  ├─ class-utils@0.3.6
  ├─ clean-stack@2.2.0
  ├─ cliui@5.0.0
  ├─ clone-deep@4.0.1
  ├─ coa@2.0.2
  ├─ code-point-at@1.1.0
  ├─ collection-visit@1.0.0
  ├─ color-convert@1.9.3
  ├─ color-name@1.1.3
  ├─ color-string@1.5.3
  ├─ color@3.1.2
  ├─ combined-stream@1.0.8
  ├─ commander@2.20.3
  ├─ compression-webpack-plugin@3.0.1
  ├─ concat-map@0.0.1
  ├─ concat-stream@1.6.2
  ├─ console-browserify@1.2.0
  ├─ console-control-strings@1.1.0
  ├─ constants-browserify@1.0.0
  ├─ convert-source-map@1.7.0
  ├─ copy-concurrently@1.0.5
  ├─ copy-descriptor@0.1.1
  ├─ core-js-compat@3.6.1
  ├─ core-js@3.6.1
  ├─ core-util-is@1.0.2
  ├─ create-ecdh@4.0.3
  ├─ create-hmac@1.1.7
  ├─ cross-spawn@6.0.5
  ├─ crypto-browserify@3.12.0
  ├─ css-blank-pseudo@0.1.4
  ├─ css-color-names@0.0.4
  ├─ css-declaration-sorter@4.0.1
  ├─ css-has-pseudo@0.10.0
  ├─ css-loader@3.4.0
  ├─ css-prefers-color-scheme@3.1.1
  ├─ css-select-base-adapter@0.1.1
  ├─ css-select@2.1.0
  ├─ css-unit-converter@1.1.1
  ├─ css-what@3.2.1
  ├─ cssdb@4.4.0
  ├─ cssnano-preset-default@4.0.7
  ├─ cssnano-util-raw-cache@4.0.1
  ├─ cssnano-util-same-parent@4.0.1
  ├─ cssnano@4.1.10
  ├─ csso@4.0.2
  ├─ currently-unhandled@0.4.1
  ├─ cyclist@1.0.1
  ├─ dashdash@1.14.1
  ├─ debug@2.6.9
  ├─ decamelize@1.2.0
  ├─ decode-uri-component@0.2.0
  ├─ delayed-stream@1.0.0
  ├─ delegates@1.0.0
  ├─ des.js@1.0.1
  ├─ detect-file@1.0.0
  ├─ diffie-hellman@5.0.3
  ├─ dom-serializer@0.2.2
  ├─ domain-browser@1.2.0
  ├─ domelementtype@1.3.1
  ├─ domutils@1.7.0
  ├─ dot-prop@4.2.0
  ├─ duplexify@3.7.1
  ├─ ecc-jsbn@0.1.2
  ├─ electron-to-chromium@1.3.322
  ├─ emoji-regex@7.0.3
  ├─ emojis-list@2.1.0
  ├─ enhanced-resolve@4.1.0
  ├─ entities@2.0.0
  ├─ errno@0.1.7
  ├─ error-ex@1.3.2
  ├─ es-to-primitive@1.2.1
  ├─ escape-string-regexp@1.0.5
  ├─ eslint-scope@4.0.3
  ├─ esprima@4.0.1
  ├─ esrecurse@4.2.1
  ├─ estraverse@4.3.0
  ├─ events@3.0.0
  ├─ execa@1.0.0
  ├─ expand-brackets@2.1.4
  ├─ expand-tilde@2.0.2
  ├─ extend@3.0.2
  ├─ extglob@2.0.4
  ├─ extsprintf@1.3.0
  ├─ fast-deep-equal@2.0.1
  ├─ fast-json-stable-stringify@2.1.0
  ├─ file-loader@4.3.0
  ├─ fill-range@4.0.0
  ├─ find-cache-dir@2.1.0
  ├─ findup-sync@3.0.0
  ├─ flatted@2.0.1
  ├─ flatten@1.0.3
  ├─ flush-write-stream@1.1.1
  ├─ for-in@1.0.2
  ├─ forever-agent@0.6.1
  ├─ form-data@2.3.3
  ├─ from2@2.3.0
  ├─ fs-minipass@2.0.0
  ├─ fs.realpath@1.0.0
  ├─ fstream@1.0.12
  ├─ gauge@2.7.4
  ├─ gaze@1.1.3
  ├─ get-caller-file@2.0.5
  ├─ get-stream@4.1.0
  ├─ getpass@0.1.7
  ├─ glob-parent@3.1.0
  ├─ glob@7.1.6
  ├─ global-modules@2.0.0
  ├─ global-prefix@3.0.0
  ├─ globule@1.3.0
  ├─ har-schema@2.0.0
  ├─ har-validator@5.1.3
  ├─ has-ansi@2.0.0
  ├─ has-unicode@2.0.1
  ├─ has-value@1.0.0
  ├─ hash.js@1.1.7
  ├─ hex-color-regex@1.1.0
  ├─ hmac-drbg@1.0.1
  ├─ hosted-git-info@2.8.5
  ├─ hsl-regex@1.0.0
  ├─ hsla-regex@1.0.0
  ├─ html-comment-regex@1.1.2
  ├─ http-signature@1.2.0
  ├─ https-browserify@1.0.0
  ├─ ieee754@1.1.13
  ├─ import-cwd@2.1.0
  ├─ import-fresh@2.0.0
  ├─ import-from@2.1.0
  ├─ import-local@2.0.0
  ├─ in-publish@2.0.0
  ├─ indent-string@4.0.0
  ├─ infer-owner@1.0.4
  ├─ inflight@1.0.6
  ├─ ini@1.3.5
  ├─ interpret@1.2.0
  ├─ invariant@2.2.4
  ├─ invert-kv@2.0.0
  ├─ is-absolute-url@2.1.0
  ├─ is-accessor-descriptor@1.0.0
  ├─ is-arrayish@0.2.1
  ├─ is-binary-path@1.0.1
  ├─ is-callable@1.1.5
  ├─ is-color-stop@1.1.0
  ├─ is-data-descriptor@1.0.0
  ├─ is-date-object@1.0.2
  ├─ is-descriptor@1.0.2
  ├─ is-directory@0.3.1
  ├─ is-extglob@2.1.1
  ├─ is-finite@1.0.2
  ├─ is-obj@1.0.1
  ├─ is-plain-obj@1.1.0
  ├─ is-plain-object@2.0.4
  ├─ is-regex@1.0.5
  ├─ is-resolvable@1.1.0
  ├─ is-stream@1.1.0
  ├─ is-svg@3.0.0
  ├─ is-symbol@1.0.3
  ├─ is-typedarray@1.0.0
  ├─ is-utf8@0.2.1
  ├─ is-windows@1.0.2
  ├─ is-wsl@1.1.0
  ├─ isarray@1.0.0
  ├─ isexe@2.0.0
  ├─ isstream@0.1.2
  ├─ jest-worker@24.9.0
  ├─ js-base64@2.5.1
  ├─ js-levenshtein@1.1.6
  ├─ js-tokens@4.0.0
  ├─ jsesc@2.5.2
  ├─ json-schema-traverse@0.4.1
  ├─ json-schema@0.2.3
  ├─ json-stringify-safe@5.0.1
  ├─ json5@2.1.1
  ├─ jsprim@1.4.1
  ├─ last-call-webpack-plugin@3.0.0
  ├─ lcid@2.0.0
  ├─ lines-and-columns@1.1.6
  ├─ load-json-file@1.1.0
  ├─ loader-runner@2.4.0
  ├─ locate-path@3.0.0
  ├─ lodash.get@4.4.2
  ├─ lodash.has@4.5.2
  ├─ lodash.memoize@4.1.2
  ├─ lodash.template@4.5.0
  ├─ lodash.templatesettings@4.2.0
  ├─ lodash.uniq@4.5.0
  ├─ lodash@4.17.15
  ├─ loose-envify@1.4.0
  ├─ loud-rejection@1.6.0
  ├─ make-dir@2.1.0
  ├─ mamacro@0.0.3
  ├─ map-age-cleaner@0.1.3
  ├─ map-obj@1.0.1
  ├─ map-visit@1.0.0
  ├─ mdn-data@2.0.4
  ├─ mem@4.3.0
  ├─ memory-fs@0.4.1
  ├─ meow@3.7.0
  ├─ merge-stream@2.0.0
  ├─ miller-rabin@4.0.1
  ├─ mime-db@1.42.0
  ├─ mime-types@2.1.25
  ├─ mimic-fn@2.1.0
  ├─ mini-css-extract-plugin@0.8.2
  ├─ minimalistic-crypto-utils@1.0.1
  ├─ minimatch@3.0.4
  ├─ minimist@1.2.0
  ├─ minipass-collect@1.0.2
  ├─ minipass-flush@1.0.5
  ├─ minipass-pipeline@1.2.2
  ├─ minipass@3.1.1
  ├─ mississippi@3.0.0
  ├─ mixin-deep@1.3.2
  ├─ mkdirp@0.5.1
  ├─ ms@2.1.2
  ├─ nan@2.14.0
  ├─ nanomatch@1.2.13
  ├─ nice-try@1.0.5
  ├─ node-gyp@3.8.0
  ├─ node-libs-browser@2.2.1
  ├─ node-releases@1.1.44
  ├─ node-sass@4.13.0
  ├─ nopt@3.0.6
  ├─ normalize-package-data@2.5.0
  ├─ normalize-range@0.1.2
  ├─ normalize-url@1.9.1
  ├─ npm-run-path@2.0.2
  ├─ npmlog@4.1.2
  ├─ nth-check@1.0.2
  ├─ num2fraction@1.2.2
  ├─ oauth-sign@0.9.0
  ├─ object-assign@4.1.1
  ├─ object-copy@0.1.0
  ├─ object-inspect@1.7.0
  ├─ object-keys@1.1.1
  ├─ object.getownpropertydescriptors@2.1.0
  ├─ object.values@1.1.1
  ├─ optimize-css-assets-webpack-plugin@5.0.3
  ├─ os-browserify@0.3.0
  ├─ os-homedir@1.0.2
  ├─ os-locale@3.1.0
  ├─ os-tmpdir@1.0.2
  ├─ osenv@0.1.5
  ├─ p-defer@1.0.0
  ├─ p-finally@1.0.0
  ├─ p-is-promise@2.1.0
  ├─ p-limit@2.2.1
  ├─ p-locate@3.0.0
  ├─ p-map@3.0.0
  ├─ p-try@2.2.0
  ├─ pako@1.0.10
  ├─ parallel-transform@1.2.0
  ├─ parent-module@1.0.1
  ├─ parse-json@4.0.0
  ├─ parse-passwd@1.0.0
  ├─ pascalcase@0.1.1
  ├─ path-browserify@0.0.1
  ├─ path-complete-extname@1.0.0
  ├─ path-dirname@1.0.2
  ├─ path-exists@3.0.0
  ├─ path-key@2.0.1
  ├─ path-parse@1.0.6
  ├─ path-type@4.0.0
  ├─ performance-now@2.1.0
  ├─ pinkie@2.0.4
  ├─ pnp-webpack-plugin@1.5.0
  ├─ posix-character-classes@0.1.1
  ├─ postcss-attribute-case-insensitive@4.0.1
  ├─ postcss-calc@7.0.1
  ├─ postcss-color-functional-notation@2.0.1
  ├─ postcss-color-gray@5.0.0
  ├─ postcss-color-hex-alpha@5.0.3
  ├─ postcss-color-mod-function@3.0.3
  ├─ postcss-color-rebeccapurple@4.0.1
  ├─ postcss-colormin@4.0.3
  ├─ postcss-convert-values@4.0.1
  ├─ postcss-custom-media@7.0.8
  ├─ postcss-custom-properties@8.0.11
  ├─ postcss-custom-selectors@5.1.2
  ├─ postcss-dir-pseudo-class@5.0.0
  ├─ postcss-discard-comments@4.0.2
  ├─ postcss-discard-duplicates@4.0.2
  ├─ postcss-discard-empty@4.0.1
  ├─ postcss-discard-overridden@4.0.1
  ├─ postcss-double-position-gradients@1.0.0
  ├─ postcss-env-function@2.0.2
  ├─ postcss-flexbugs-fixes@4.1.0
  ├─ postcss-focus-visible@4.0.0
  ├─ postcss-focus-within@3.0.0
  ├─ postcss-font-variant@4.0.0
  ├─ postcss-gap-properties@2.0.0
  ├─ postcss-image-set-function@3.0.1
  ├─ postcss-import@12.0.1
  ├─ postcss-initial@3.0.2
  ├─ postcss-lab-function@2.0.1
  ├─ postcss-load-config@2.1.0
  ├─ postcss-loader@3.0.0
  ├─ postcss-logical@3.0.0
  ├─ postcss-media-minmax@4.0.0
  ├─ postcss-merge-longhand@4.0.11
  ├─ postcss-merge-rules@4.0.3
  ├─ postcss-minify-font-values@4.0.2
  ├─ postcss-minify-gradients@4.0.2
  ├─ postcss-minify-params@4.0.2
  ├─ postcss-minify-selectors@4.0.2
  ├─ postcss-modules-extract-imports@2.0.0
  ├─ postcss-modules-local-by-default@3.0.2
  ├─ postcss-modules-scope@2.1.1
  ├─ postcss-modules-values@3.0.0
  ├─ postcss-nesting@7.0.1
  ├─ postcss-normalize-charset@4.0.1
  ├─ postcss-normalize-display-values@4.0.2
  ├─ postcss-normalize-positions@4.0.2
  ├─ postcss-normalize-repeat-style@4.0.2
  ├─ postcss-normalize-string@4.0.2
  ├─ postcss-normalize-timing-functions@4.0.2
  ├─ postcss-normalize-unicode@4.0.1
  ├─ postcss-normalize-url@4.0.1
  ├─ postcss-normalize-whitespace@4.0.2
  ├─ postcss-ordered-values@4.1.2
  ├─ postcss-overflow-shorthand@2.0.0
  ├─ postcss-page-break@2.0.0
  ├─ postcss-place@4.0.1
  ├─ postcss-preset-env@6.7.0
  ├─ postcss-pseudo-class-any-link@6.0.0
  ├─ postcss-reduce-initial@4.0.3
  ├─ postcss-reduce-transforms@4.0.2
  ├─ postcss-replace-overflow-wrap@3.0.0
  ├─ postcss-safe-parser@4.0.1
  ├─ postcss-selector-matches@4.0.0
  ├─ postcss-selector-not@4.0.0
  ├─ postcss-svgo@4.0.2
  ├─ postcss-unique-selectors@4.0.1
  ├─ prepend-http@1.0.4
  ├─ private@0.1.8
  ├─ process-nextick-args@2.0.1
  ├─ process@0.11.10
  ├─ prr@1.0.1
  ├─ pseudomap@1.0.2
  ├─ psl@1.7.0
  ├─ public-encrypt@4.0.3
  ├─ pumpify@1.5.1
  ├─ punycode@1.4.1
  ├─ q@1.5.1
  ├─ qs@6.5.2
  ├─ query-string@4.3.4
  ├─ querystring-es3@0.2.1
  ├─ querystring@0.2.0
  ├─ randomfill@1.0.4
  ├─ read-cache@1.0.0
  ├─ read-pkg@1.1.0
  ├─ readdirp@2.2.1
  ├─ redent@1.0.0
  ├─ regenerate-unicode-properties@8.1.0
  ├─ regenerator-runtime@0.13.3
  ├─ regenerator-transform@0.14.1
  ├─ regexpu-core@4.6.0
  ├─ regjsgen@0.5.1
  ├─ regjsparser@0.6.2
  ├─ remove-trailing-separator@1.1.0
  ├─ repeat-element@1.1.3
  ├─ repeating@2.0.1
  ├─ request@2.88.0
  ├─ require-main-filename@2.0.0
  ├─ resolve-cwd@2.0.0
  ├─ resolve-dir@1.0.1
  ├─ resolve-url@0.2.1
  ├─ resolve@1.14.1
  ├─ ret@0.1.15
  ├─ rgb-regex@1.0.1
  ├─ rgba-regex@1.0.0
  ├─ rimraf@2.7.1
  ├─ run-queue@1.0.3
  ├─ safer-buffer@2.1.2
  ├─ sass-graph@2.2.4
  ├─ sass-loader@7.3.1
  ├─ sax@1.2.4
  ├─ scss-tokenizer@0.2.3
  ├─ semver@5.7.1
  ├─ set-value@2.0.1
  ├─ setimmediate@1.0.5
  ├─ shallow-clone@3.0.1
  ├─ shebang-command@1.2.0
  ├─ shebang-regex@1.0.0
  ├─ simple-swizzle@0.2.2
  ├─ snapdragon-node@2.1.1
  ├─ snapdragon-util@3.0.1
  ├─ sort-keys@1.1.2
  ├─ source-list-map@2.0.1
  ├─ source-map-resolve@0.5.3
  ├─ source-map-support@0.5.16
  ├─ source-map-url@0.4.0
  ├─ spark-md5@3.0.0
  ├─ spdx-correct@3.1.0
  ├─ spdx-exceptions@2.2.0
  ├─ split-string@3.1.0
  ├─ sprintf-js@1.0.3
  ├─ sshpk@1.16.1
  ├─ ssri@7.1.0
  ├─ stable@0.1.8
  ├─ static-extend@0.1.2
  ├─ stdout-stream@1.4.1
  ├─ stream-browserify@2.0.2
  ├─ stream-each@1.2.3
  ├─ stream-http@2.8.3
  ├─ strict-uri-encode@1.1.0
  ├─ string_decoder@1.1.1
  ├─ string.prototype.trimleft@2.1.1
  ├─ string.prototype.trimright@2.1.1
  ├─ strip-bom@2.0.0
  ├─ strip-eof@1.0.0
  ├─ strip-indent@1.0.1
  ├─ style-loader@1.1.2
  ├─ stylehacks@4.0.3
  ├─ svgo@1.3.2
  ├─ tar@2.2.2
  ├─ terser-webpack-plugin@2.3.1
  ├─ terser@4.4.3
  ├─ through2@2.0.5
  ├─ timers-browserify@2.0.11
  ├─ timsort@0.3.0
  ├─ to-arraybuffer@1.0.1
  ├─ to-fast-properties@2.0.0
  ├─ to-object-path@0.3.0
  ├─ to-regex-range@2.1.1
  ├─ tough-cookie@2.4.3
  ├─ trim-newlines@1.0.0
  ├─ true-case-path@1.0.3
  ├─ ts-pnp@1.1.5
  ├─ tslib@1.10.0
  ├─ tty-browserify@0.0.0
  ├─ tunnel-agent@0.6.0
  ├─ turbolinks@5.2.0
  ├─ tweetnacl@0.14.5
  ├─ typedarray@0.0.6
  ├─ unicode-canonical-property-names-ecmascript@1.0.4
  ├─ unicode-match-property-ecmascript@1.0.4
  ├─ unicode-match-property-value-ecmascript@1.1.0
  ├─ unicode-property-aliases-ecmascript@1.0.5
  ├─ union-value@1.0.1
  ├─ unique-slug@2.0.2
  ├─ unquote@1.1.1
  ├─ unset-value@1.0.0
  ├─ upath@1.2.0
  ├─ uri-js@4.2.2
  ├─ urix@0.1.0
  ├─ url@0.11.0
  ├─ use@3.1.1
  ├─ util-deprecate@1.0.2
  ├─ util.promisify@1.0.0
  ├─ util@0.11.1
  ├─ uuid@3.3.3
  ├─ v8-compile-cache@2.0.3
  ├─ validate-npm-package-license@3.0.4
  ├─ vendors@1.0.3
  ├─ verror@1.10.0
  ├─ vm-browserify@1.1.2
  ├─ watchpack@1.6.0
  ├─ webpack-assets-manifest@3.1.1
  ├─ webpack-cli@3.3.10
  ├─ webpack@4.41.5
  ├─ which-module@2.0.0
  ├─ which@1.3.1
  ├─ wide-align@1.1.3
  ├─ worker-farm@1.7.0
  ├─ wrap-ansi@5.1.0
  ├─ xtend@4.0.2
  ├─ yallist@3.1.1
  ├─ yaml@1.7.2
  ├─ yargs-parser@13.1.1
  └─ yargs@13.2.4
  Done in 102.76s.
  Installing dev server for live reloading
           run  yarn add --dev webpack-dev-server from "."
  yarn add v1.21.1
  [1/4] Resolving packages...
  [2/4] Fetching packages...
  info fsevents@1.2.11: The platform "linux" is incompatible with this module.
  info "fsevents@1.2.11" is an optional dependency and failed compatibility check. Excluding it from installation.
  [3/4] Linking dependencies...
  warning "webpack-dev-server > webpack-dev-middleware@3.7.2" has unmet peer dependency "webpack@^4.0.0".
  warning " > webpack-dev-server@3.10.1" has unmet peer dependency "webpack@^4.0.0 || ^5.0.0".
  [4/4] Building fresh packages...
  success Saved lockfile.
  success Saved 100 new dependencies.
  info Direct dependencies
  └─ webpack-dev-server@3.10.1
  info All dependencies
  ├─ @types/events@3.0.0
  ├─ @types/glob@7.1.1
  ├─ @types/minimatch@3.0.3
  ├─ @types/node@13.1.1
  ├─ accepts@1.3.7
  ├─ ansi-colors@3.2.4
  ├─ ansi-html@0.0.7
  ├─ array-flatten@1.1.1
  ├─ array-union@1.0.2
  ├─ array-uniq@1.0.3
  ├─ async-limiter@1.0.1
  ├─ async@2.6.3
  ├─ batch@0.6.1
  ├─ body-parser@1.19.0
  ├─ bonjour@3.5.0
  ├─ buffer-indexof@1.1.1
  ├─ cliui@4.1.0
  ├─ compressible@2.0.17
  ├─ compression@1.7.4
  ├─ connect-history-api-fallback@1.6.0
  ├─ content-disposition@0.5.3
  ├─ cookie-signature@1.0.6
  ├─ cookie@0.4.0
  ├─ deep-equal@1.1.1
  ├─ default-gateway@4.2.0
  ├─ del@4.1.1
  ├─ destroy@1.0.4
  ├─ detect-node@2.0.4
  ├─ dns-equal@1.0.0
  ├─ dns-packet@1.3.1
  ├─ dns-txt@2.0.2
  ├─ ee-first@1.1.1
  ├─ eventemitter3@4.0.0
  ├─ eventsource@1.0.7
  ├─ express@4.17.1
  ├─ faye-websocket@0.10.0
  ├─ finalhandler@1.1.2
  ├─ follow-redirects@1.9.0
  ├─ forwarded@0.1.2
  ├─ globby@6.1.0
  ├─ handle-thing@2.0.0
  ├─ hpack.js@2.1.6
  ├─ html-entities@1.2.1
  ├─ http-deceiver@1.2.7
  ├─ http-parser-js@0.4.10
  ├─ http-proxy-middleware@0.19.1
  ├─ http-proxy@1.18.0
  ├─ internal-ip@4.3.0
  ├─ ip-regex@2.1.0
  ├─ ip@1.1.5
  ├─ ipaddr.js@1.9.1
  ├─ is-absolute-url@3.0.3
  ├─ is-arguments@1.0.4
  ├─ is-path-cwd@2.2.0
  ├─ is-path-in-cwd@2.1.0
  ├─ is-path-inside@2.1.0
  ├─ json3@3.3.3
  ├─ killable@1.0.1
  ├─ loglevel@1.6.6
  ├─ media-typer@0.3.0
  ├─ merge-descriptors@1.0.1
  ├─ methods@1.1.2
  ├─ mime@2.4.4
  ├─ multicast-dns-service-types@1.1.0
  ├─ multicast-dns@6.2.3
  ├─ negotiator@0.6.2
  ├─ node-forge@0.9.0
  ├─ object-is@1.0.2
  ├─ obuf@1.1.2
  ├─ on-headers@1.0.2
  ├─ opn@5.5.0
  ├─ original@1.0.2
  ├─ p-retry@3.0.1
  ├─ path-is-inside@1.0.2
  ├─ path-to-regexp@0.1.7
  ├─ portfinder@1.0.25
  ├─ proxy-addr@2.0.5
  ├─ querystringify@2.1.1
  ├─ raw-body@2.4.0
  ├─ regexp.prototype.flags@1.3.0
  ├─ retry@0.12.0
  ├─ select-hose@2.0.0
  ├─ selfsigned@1.10.7
  ├─ serve-index@1.9.1
  ├─ serve-static@1.14.1
  ├─ sockjs-client@1.4.0
  ├─ sockjs@0.3.19
  ├─ spdy-transport@3.0.0
  ├─ spdy@4.0.1
  ├─ thunky@1.1.0
  ├─ type-is@1.6.18
  ├─ unpipe@1.0.0
  ├─ utils-merge@1.0.1
  ├─ wbuf@1.7.3
  ├─ webpack-dev-middleware@3.7.2
  ├─ webpack-dev-server@3.10.1
  ├─ websocket-extensions@0.1.3
  ├─ ws@6.2.1
  ├─ yargs-parser@11.1.1
  └─ yargs@12.0.5
  Done in 34.18s.
  Webpacker successfully installed 🎉 🍰
  miyakz@eng2:~/environment/eng$ 

参考
====

参考にしたURL

https://stackoverflow.com/questions/57640492/webpacker-error-on-creating-new-rails-app-in-rails-6

https://qiita.com/pchatsu/items/a7f53da2e57ae4aca065

