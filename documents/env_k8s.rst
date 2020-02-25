===============================================================================
k8s環境下でのeng app
===============================================================================

docker images
=================

以下のような感じで作成。dockerfileレポジトリにdockerfile一式を格納。

https://github.com/miyakz1192/dockerfiles

全体像
-------

imageの全体像は以下の通り。::

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

なお、PVとPVCは同一レポジトリの以下のディレクトリで管理。

cloud_native_study/k8s_ope/pv/eng_app

全体像。
-----------

以下のファイルが存在する。::
  
  【k8s関連リソース】
  deployment-eng-app-app.yaml : eng-app本体のマニフェスト(DeploymentとServiceの定義)
  deployment-eng-app-mysql.yaml : eng-appが使うMySQLのマニフェスト(DeploymentとServiceの定義)    
  eng_app_secret.yaml           : eng-appとMySQLに関連する設定ファイル(パスワードとか含むためsecretあつかい)。こちらはgitにupしない。
  eng_app_secret_sample.yaml    : 上記のサンプルファイル(gitにupしている)   

  【ネット(istio)関連のリソース】
  eng_app_gateway.yaml : eng-app-app用のistio gatewayの定義。門番みたいなもの。      
  eng_app_virtual_service.yaml: eng-app-app-service用のistio VirtualService(eng-app-virtual-service) 。k8sのServiceの機能豊富版。
  eng_app_destination_rules.yaml: eng-app-virtual-service用の各podへのルーティングルール
  
コンテナポートの設定。::
  eng-app本体：3000
  mysql:3306
  
PVも必要で以下。::

  eng_app.yaml:  eng-app-mysql用のPV定義
  eng_app_pvc.yaml: eng-app-mysql用のPVC定義
  eng_app_data.yaml: eng-app用のsentence_data.txtやvoiceデータが配置されているPV
  eng_app_data_pvc.yaml:上記ストレージのPVC

以下、おまけで運用用のコマンド。詳細には解説しない。::

  

  
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

DATABASE_*はeng_appの環境変数。

DATABASE_DEV_HOSTはeng_appの接続先のDBのホスト名。

DATABASE_DEV_USERはDBのユーザ名。

DATABASE_DEV_PASSWORDは任意の値が指定できるが、docker.io/mysqlを使用するため、rootで固定。

INIT_USER_MODEはnormal固定で良い。

INIT_USER_EMAILは初期ユーザのemailアドレス。

INIT_USER_PASSWDは初期ユーザのパスワード。適当に指定する。


PV:eng_app.yaml
----------------

eng_appのPVを指定する。::

  root@kubecon1:~/documents/cloud_native_study/k8s_ope/pv/eng_app# cat eng_app.yaml 
  # halyardについてはclaimが無いのだが、一応、以下で作っておく。
  # disk: 10Gi
  # ReadWriteOnce
  # セキュリティコンテキスト
  #  fsGroup:1000
  #  runAsUser: 1000
  # 上記値は過去の経験値から
  # 一応、根拠としてはvalues.yamlから	
  
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: eng-app
    namespace: eng-app
  spec:
    capacity:
      storage: 10Gi
    accessModes:
      - ReadWriteOnce
    # PersistentVolumeClaim を削除した時の動作
    persistentVolumeReclaimPolicy: Recycle
  #  storageClassName: slow
    mountOptions:
      - hard
    ## マウント先のNFS Serverの情報を記載
    nfs:
      path: /opt/nfs/eng_app
      server: pvserver
  root@kubecon1:~/documents/cloud_native_study/k8s_ope/pv/eng_app# 

ディスクの容量は10Gi。モードはReadWriteOnce(同時に1つのコンテナのみマウント可能)。
ポイントは、nfs限定にしており、NFSサーバでのパスとNFSサーバ名を明確に指定している

PVC:eng_app_pvc.yaml
-------------------------

PVCを指定する。::

  root@kubecon1:~/documents/cloud_native_study/k8s_ope/pv/eng_app# cat eng_app_pvc.yaml 
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: eng-app-pvc
    namespace: eng-app
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 10Gi
  root@kubecon1:~/documents/cloud_native_study/k8s_ope/pv/eng_app# 

ポイントは10Gi、ReadWriteOnceのストレージを要求する。
なお、namespace eng-appにて、PVは１つ、PVCは１つなため、自動的に、
PV-PVCがマッチングする。

PV:eng_app_data.yaml
---------------------------

eng-appが必要なsentence_data.txtやvoiceデータが格納済みのストレージのPV。以下の定義。::

  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: eng-app-data
    namespace: eng-app
  spec:
    capacity:
      storage: 10Gi
    accessModes:
      - ReadOnlyMany
    # PersistentVolumeClaim を削除した時の動作
    persistentVolumeReclaimPolicy: Recycle
  #  storageClassName: slow
    mountOptions:
      - hard
    ## マウント先のNFS Serverの情報を記載
    nfs:
      path: /opt/nfs/eng_app_data
      server: pvserver

ポイントは、他のコンテナからも読めるように想定しているため、accessModesがReadOnlyManyであることと、同じくpvserverの/opt/nfs/eng_app_dataというパスを明示している点。

  
PVC:eng_app_data_pvc.yaml
---------------------------

eng_app_data用のPVC。以下の定義。::

  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: eng-app-data-pvc
    namespace: eng-app
  spec:
    accessModes:
      - ReadOnlyMany
    resources:
      requests:
        storage: 10Gi

ポイントはReadOnlyManyを指定してディスクを探す点。
eng_appシステムにおいては、ReadWriteOnceが1つ、ReadOnlyManyが1つなので、混同することが無い。
  



  












