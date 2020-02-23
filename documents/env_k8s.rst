===============================================================================
k8s環境下でのeng app
===============================================================================

docker images
=================

以下のような感じで作成。dockerfileレポジトリにdockerfile一式を格納。

https://github.com/miyakz1192/dockerfiles

全体像
-------

railsイメージ：ubuntu 19.10イメージをベースに、rails6.0をインストールしたもの。
eng_app_baseイメージ：railsイメージをベースに、eng_appと関連gemをbundle installしたもの。
eng_appイメージ：eng_app_baseイメージをベースに、最新のeng_appソースをgit pullして動作するベースとなるイメージ。

DBとして、mysqlのDBイメージをk8sから直接利用。これは、k8sマニフェストファイルの所で別途解説。
あと、eng_appを動作させるマニフェストファイルがある。後述する。


railsイメージ
------------------

以下のような内容。::

  FROM docker.io/ubuntu:19.10
  MAINTAINER miyakz1192 <miyakz1192@gmail.com>
  
  #thank you this link
  #https://qiita.com/yagince/items/deba267f789604643bab
  ENV DEBIAN_FRONTEND=noninteractive
  
  RUN apt-get update ;  apt-get --ignore-missing install build-essential git-core curl openssl libssl-dev libcurl4-openssl-dev zlib1g zlib1g-dev libreadline6-dev libyaml-dev libxml2-dev libxslt1-dev libffi-dev software-properties-common libgdm-dev libncurses5-dev automake autoconf bison libpq-dev pgadmin3 libc6-dev ruby-dev libsqlite3-dev libsqlite3-0 nodejs git make gcc ruby ruby-dev g++ libmariadb-dev -y
  
  RUN  gem install bundler ; gem install rails 

ポイントはDEBIAN_FRONTENDの設定で、これをセットしていないと、dockerimage構築時に走るapt installによるパッケージ
インストール過程でキーボード入力を求められた場合にインストールプロセスが止まってしまう。dockerimageの構築は、
サイレントが前提のため、この設定は必須となる。

RUNにて、railsのインストールに必要な各種パッケージを入れる。

eng_app_baseイメージ。
-------------------------

以下のような内容。::

  FROM docker.io/miyakz1192/rails:1
  MAINTAINER miyakz1192 <miyakz1192@gmail.com>
  
  ENV DEBIAN_FRONTEND=noninteractive
  
  # thease install is needed for rails6 server execution. detail is shown laster
  RUN apt install gnupg curl -y
  RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
  RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
  RUN apt update && apt install yarn -y
  RUN cd / ; git clone https://github.com/miyakz1192/english_study_app.git ; cd /english_study_app/eng_app ; bundle install 
  RUN cd /english_study_app/eng_app ; rails webpacker:install

ポイントは最新のyarnをインストールする所と、bundleインストール。特別なことは実施していないのだが、
yarn/bundleの時間が大変かかるため、eng_app_baseの構築は必須となる。


eng_appイメージ。
-----------------------

以下のような内容。::

 FROM docker.io/miyakz1192/eng_app_base:1
 MAINTAINER miyakz1192 <miyakz1192@gmail.com>
 
 ENV DEBIAN_FRONTEND=noninteractive
 
 RUN  cd /english_study_app/eng_app ; git pull origin master

基本的には、eng_appが動作する下準備がすべて完了しているため、
最新のソースをpullして、動作するだけ。


マニフェストファイル。
=============================

以下のレポジトリに配置。

https://github.com/miyakz1192/documents.git

このレポジトリの以下のファイル群。

cloud_native_study/k8s_ope/eng_app

全体像。
-----------

以下のファイルが存在する。

  deployment-eng-app-app.yaml : eng-app本体のマニフェスト
  deployment-eng-app-mysql.yaml : eng-appが使うMySQLのマニフェスト    
  eng_app_secret.yaml           : eng-appとMySQLに関連する設定ファイル(パスワードとか含むためsecretあつかい)。こちらはgitにupしない。
  eng_app_secret_sample.yaml    : 上記のサンプルファイル(gitにupしている)   
  
PVも必要で以下。


コンテナポートの設定。::
  eng-app本体：3000
  mysql:3306
  


deployment-eng-app-app.yaml
--------------------------------

eng_appを駆動するマニフェストファイル。::

  root@kubecon1:~/documents/cloud_native_study/k8s_ope/eng_app# cat deployment-eng-app-app.yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    # Deploymentの名前。Namespace内ではユニークである必要があります
    name: eng-app-app
    namespace: eng-app 
  spec:
    # レプリカ数の指定
    replicas: 1
    selector:
      matchLabels:
        app: eng-app-app
    # Podのテンプレート(PodTemplate)
    template:
      metadata:
        labels:
          # ラベル指定は必須
          app: eng-app-app
      spec:
        containers:
        - name: eng-app-app
          image: docker.io/miyakz1192/eng_app:1
          ports:
          - containerPort: 3000
          command: ["/bin/sh", "-c", "cd /english_study_app/eng_app/ ; rails s -b=0.0.0.0"]
          #command: ["/usr/local/bin/rails server"]
          #for debugging
          #command: ["/bin/sh", "-c", "while true; do sleep 3600; done"]
          envFrom:
          - secretRef:
              name: eng-app-secret
  root@kubecon1:~/documents/cloud_native_study/k8s_ope/eng_app# 

ポイントとしては、以下。::

  コンテナポート：3000
  commandでrailsを起動。
  eng_appのversion1を使用。
  secret refとして、eng-app-secretを参照。


deployment-eng-app-mysql.yaml 
--------------------------------

DBマニフェストファイル。::

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    # Deploymentの名前。Namespace内ではユニークである必要があります
    name: eng-app-mysql
    namespace: eng-app
  spec:
    # レプリカ数の指定
    replicas: 1
    selector:
      matchLabels:
        app: eng-app-mysql
    # Podのテンプレート(PodTemplate)
    template:
      metadata:
        labels:
          # ラベル指定は必須
          app: eng-app-mysql
      spec:
        containers:
        - name: eng-app-mysql
          image: docker.io/mysql:latest
          ports:
          - containerPort: 3306
          envFrom:
          - secretRef:
              name: eng-app-secret
          volumeMounts:
          - mountPath: "/var/lib/mysql"
            name: eng-app-pv
        volumes:
          - name: eng-app-pv
            # マウント対象となる Persistent Volume に対応する
            # Persistent Volume Claimを指定
            persistentVolumeClaim:
              claimName: eng-app-pvc
  
ポイントは以下。::
  docker.io/mysql:latestを使用。
  eng-app-pvcをPersistent Volumeとして利用。
  コンテナポート：3306

eng_app_secret.yaml  
------------------------

secretファイル。::
  
  root@kubecon1:~/documents/cloud_native_study/k8s_ope/eng_app# cat eng_app_secret_sample.yaml 
  #specify the values without " and '
  MYSQL_ROOT_PASSWORD=mysqlpasswd
  DATABASE_DEV_PASSWORD=mysqlpasswd(equivalent value of MYSQL_ROOT_PASSWORD)
  DATABASE_DEV_USER=root
  DATABASE_DEV_HOST=hostooripaddressofmysql 
  INIT_USER_EMAIL=email_address_of_firstuser_of_eng_app
  INIT_USER_MODE=normal
  INIT_USER_PASSWD=passwd_of_INIT_USER
  SENTENCE_FILE_PATH=/write/down/path/like/this/to/sentence_data.txt
  root@kubecon1:~/documents/cloud_native_study/k8s_ope/eng_app# 
  
 
MYSQL_*はeng-app-mysqlのための環境変数。docker.io/mysqlの仕様により、
MYSQLを動作させるrootユーザのパスワードを指定する。

DATABASE_*はeng_appの環境変数。DATABASE_DEV_PASSWORDは任意の値が
指定できるが、docker.io/mysqlを使用するため、rootで固定。










