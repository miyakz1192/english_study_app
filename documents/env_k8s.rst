===============================================================================
k8s環境下でのeng app
===============================================================================

クラウドネイティブなeng_appを追い求め、k8s上での動作を目指す。やってやるぜgit ops。
このドキュメントは、eng_appのdocker imagesとk8sマニフェストの解説の２部構成。

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


マニフェストファイル(k8s/istio)
================================

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
  eng_app_secret.yaml           : eng-appとMySQLに関連する設定ファイル(パスワードとか含むためsecretあつかい)。
                                  こちらはgitにupしない。
  eng_app_secret_sample.yaml    : 上記のサンプルファイル(gitにupしている)   

  【ネット(istio)関連のリソース】
  eng_app_gateway.yaml : eng-app-app用のistio gatewayの定義。門番みたいなもの。      
  eng_app_virtual_service.yaml: eng-app-app-service用のistio VirtualService(eng-app-virtual-service) 。
                                k8sのServiceの機能豊富版。
  eng_app_destination_rules.yaml: eng-app-virtual-service用の各podへのルーティングルール
  
コンテナポートの設定。::

  eng-app本体：3000
  mysql:3306
  外部からのアクセス方法： NodePortAddress:PortNum →　http://192.168.100.2:31380
                           istio-gatewayによって、31380が80(eng-app-gateway/eng-app-virtual-service)にマッピングされる。
                           get service でistio-gatewayをdescribeすると、80番ポートにマッピングされているのが、31380だとわかる。
                           Port:                     http2  80/TCP
                           TargetPort:               80/TCP
                           NodePort:                 http2  31380/TCP

  
PVも必要で以下。::

  eng_app.yaml:  eng-app-mysql用のPV定義
  eng_app_pvc.yaml: eng-app-mysql用のPVC定義
  eng_app_data.yaml: eng-app用のsentence_data.txtやvoiceデータが配置されているPV
  eng_app_data_pvc.yaml:上記ストレージのPVC

以下、おまけで運用用のコマンド。詳細には解説しない。::

  eng_app_db_init_job.yaml: 構築時一発目に流すjob。DB初期化、テーブル作成、seedデータの投入を実施。
                            (繰り返し初期構築する場合はpvserverの/opt/nfs/eng_app配下を全部削除すること) 
  create_k8s_related_resource.sh: eng_app関連のk8s関連のリソースを一発作成する。
  create_istio_related_resources.sh: eng_app関連のistio関連のリソースを一発作成する。
  delete_k8s_related_resource.sh: eng_app関連のk8s関連のリソースを一括削除する。
  delete_istio_related_resources.sh: eng_app関連のistio関連のリソースを一括削除する。
  log_eng_app.sh: eng-app-appのログを見るスクリプト。
  log_eng_app_db_init_job.sh : eng-app-db-init-jobのログを見るスクリプト。
  log_eng_app_mysql.sh : eng-app-mysqlのログを見るスクリプト。
  login_eng_app.sh:eng-app-appにログインするスクリプト。
  login_eng_app_mysql.sh:eng-app-mysqlにログインするスクリプト。
  
k8s:deployment-eng-app-app.yaml
--------------------------------

eng_appを駆動するマニフェストファイル。DeploymentとServiceが入っている。::

  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ cat deployment-eng-app-app.yaml 
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    # Deploymentの名前。Namespace内ではユニークである必要があります
    name: eng-app-app
    namespace: eng-app 
    labels:
      app: eng-app-app
      version: v1
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
          version: v1
      spec:
        containers:
        - name: eng-app-app
          image: docker.io/miyakz1192/eng_app:1
          ports:
          - containerPort: 3000
          command: ["/bin/sh", "-c", "cd /english_study_app/eng_app/public/; rm -r voice ; ln -s /mnt/voice/ voice; cd /english_study_app/eng_app/ ; rails s -b=0.0.0.0"]
          #command: ["/usr/local/bin/rails server"]
          #for debugging
          #command: ["/bin/sh", "-c", "while true; do sleep 3600; done"]
          envFrom:
          - secretRef:
              name: eng-app-secret
          volumeMounts:
          - mountPath: "/mnt"
            name: eng-app-data
        volumes:
          - name: eng-app-data
            # マウント対象となる Persistent Volume に対応する
            # Persistent Volume Claimを指定
            persistentVolumeClaim:
              claimName: eng-app-data-pvc
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: eng-app-app-service
    labels:
      app: eng-app-app
    namespace: eng-app
  spec:
    ports:
    - port: 3000
      name: http
    selector:
      app: eng-app-app
  
  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ 
  

ポイントとしては、以下。::

  コンテナポートとサービスポート：3000
  プロトコル：http(https化したい)
  PV: eng-app-dataをマウントしている。
  commandでrailsを起動。ついでに、public/voiceのシンボリックを/mnt/voiceに貼る。
  eng_appのversion1を使用。
  secret refとして、eng-app-secretを参照。
  バージョン：v1のDeploymentとして起動。


k8s:deployment-eng-app-mysql.yaml 
--------------------------------

DBマニフェストファイル(DeploymentとServiceが入っている)。::

  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ cat deployment-eng-app-mysql.yaml 
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    # Deploymentの名前。Namespace内ではユニークである必要があります
    name: eng-app-mysql
    namespace: eng-app
    labels:
      app: eng-app-mysql
      version: v1
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
          version: v1
      spec:
        containers:
        - name: eng-app-mysql
          image: docker.io/mysql:5.7.29 #version is 5.7.29 fix !! don't move it(for stable behavior)
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
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: eng-app-mysql-service
    labels:
      app: eng-app-mysql
    namespace: eng-app
  spec:
    ports:
    - port: 3306
      name: http
    selector:
      app: eng-app-mysql
  
  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ 

  
ポイントは以下。::
  mysqlのバージョン：5.7.29で固定。8系は非互換大きく、我のようなDB初心者無理
  PV: eng-app-pvをマウント。docker.io/mysqlの仕様により、/var/lib/mysqlを指定。
  コンテナポート、サービスポート：3306
  プロトコル：http(https化したい)
  secret refとして、eng-app-secretを参照。
  バージョン：v1のDeploymentとして起動。

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

istio:eng_app_gateway.yaml
----------------------------------

gatewayのマニフェスト。::

  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ cat eng_app_gateway.yaml 
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: eng-app-gateway
    namespace: eng-app
  spec: #I refered bookinfo sample spec
    selector:
      istio: ingressgateway # use istio default controller
    servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
      - "*"
  
  
  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ 

selectorとhostはおまじないみたいなもの。hostはクライアントのHTTPヘッダのあるフィールドに設定されるドメイン名。eng_appがドメインを取っていれば、hostにそのドメインを設定するべきだが、eng_appはそこまで気合が入っていないので、ドメインを取っていない。したがって、現時点ではhostの値は"*"で正解。
helloworldサンプル同じく、80(http)をまずは指定。
将来はhttpsに改善したいと思う。
(eng_app本体をいじらずにistio側でできたら楽だなぁ。と思う)

istio:eng_app_virtual_service
---------------------------------

eng_appの仮想サービスの定義。k8sのServiceをVirtualServiceでラップするイメージ(eng-app-app-serviceをeng-app-virtual-serviceでラップする)::

  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ cat eng_app_virtual_service.yaml 
  apiVersion: networking.istio.io/v1alpha3
  kind: VirtualService
  metadata:
    name: eng-app-virtual-service
    namespace: eng-app
  spec:
    hosts:
    - "*"
    gateways:
    - eng-app-gateway
    http:
    - route:
      - destination:
          host: eng-app-app-service
          port:
            number: 3000
  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ 

hostsはGatewayと同じ理由で、"*"を設定する。
destinationはパケットの宛先はeng-app-app-serviceになるため、宛先ポートを指定する。これは、helloworldサンプルをモロに参考。

istio:eng_app_destination_rules.yaml
------------------------------------------

Destinaton ruleの定義。現時点ではこの定義はeng-app-virtual-serviceから参照されていないため、役に立っていない。将来、カナリアリリースをするとか、そういった時に役に立つリソースである。楽しみにとっておく。::
  
  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ cat eng_app_destination_rules.yaml 
  apiVersion: networking.istio.io/v1alpha3
  kind: DestinationRule
  metadata:
    name: eng-app-destination-rules
    namespace: eng-app
  spec:
    host: eng-app-app
    subsets:
    - labels:
        version: v1
      name: v1
    trafficPolicy:
      tls:
        mode: ISTIO_MUTUAL
  
  miyakz@lily:~/github_repos/documents/cloud_native_study/k8s_ope/eng_app$ 

これ、hostが間違っている臭い。eng-app-appではなく、eng-app-app-serviceがただしそう。subsetsでversionをv1に指定しているが、これは、Deploymentで指定したversionを指定する(例:v1,v2など)。この辺の使い方はbookinfoサンプルが参考になる。

現時点のeng_appシステムでは、ISTIO_MUTUALではないため、eng-app-appとeng-app-mysql間は暗号化されていないトラフィックが流れると思う。

ただし、こういったネットワーク関連のセキュリティ設定やカナリアリリースを考慮したトラフィックルーティングも、eng_app本体を一切変更すること無く、istio側の設定変更で制御できる点が良いのだと思う(Devがやるべき作業を浮かして、他のヒトに任せられるようになる)。

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

spinnaker
===============

再び、spinnakerでハマった。
顛末は、以下に記載。

https://github.com/miyakz1192/documents/blob/master/cloud_native_study/spinnaker_eng_app.rst

まず実験。

単にDeployする設定
-----------------------

DeployするJSON設定。eng-appのマニフェストも含まれてしまっている。
こいつをgitにおいているもので、外付けにできないもんか::

  {
    "account": "default",
    "cloudProvider": "kubernetes",
    "manifestArtifactAccount": "embedded-artifact",
    "manifests": [
      {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
          "labels": {
            "app": "eng-app-app",
            "version": "v1"
          },
          "name": "eng-app-app",
          "namespace": "eng-app"
        },
        "spec": {
          "replicas": 1,
          "selector": {
            "matchLabels": {
              "app": "eng-app-app"
            }
          },
          "template": {
            "metadata": {
              "labels": {
                "app": "eng-app-app",
                "version": "v1"
              }
            },
            "spec": {
              "containers": [
                {
                  "command": [
                    "/bin/sh",
                    "-c",
                    "cd /english_study_app/eng_app/public/; rm -r voice ; ln -s /mnt/voice/ voice; cd /english_study_app/eng_app/ ; rails s -b=0.0.0.0"
                  ],
                  "envFrom": [
                    {
                      "secretRef": {
                        "name": "eng-app-secret"
                      }
                    }
                  ],
                  "image": "docker.io/miyakz1192/eng_app:1",
                  "name": "eng-app-app",
                  "ports": [
                    {
                      "containerPort": 3000
                    }
                  ],
                  "volumeMounts": [
                    {
                      "mountPath": "/mnt",
                      "name": "eng-app-data"
                    }
                  ]
                }
              ],
              "volumes": [
                {
                  "name": "eng-app-data",
                  "persistentVolumeClaim": {
                    "claimName": "eng-app-data-pvc"
                  }
                }
              ]
            }
          }
        }
      },
      {
        "apiVersion": "v1",
        "kind": "Service",
        "metadata": {
          "labels": {
            "app": "eng-app-app"
          },
          "name": "eng-app-app-service",
          "namespace": "eng-app"
        },
        "spec": {
          "ports": [
            {
              "name": "http",
              "port": 3000
            }
          ],
          "selector": {
            "app": "eng-app-app"
          }
        }
      },
      {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
          "labels": {
            "app": "eng-app-mysql",
            "version": "v1"
          },
          "name": "eng-app-mysql",
          "namespace": "eng-app"
        },
        "spec": {
          "replicas": 1,
          "selector": {
            "matchLabels": {
              "app": "eng-app-mysql"
            }
          },
          "template": {
            "metadata": {
              "labels": {
                "app": "eng-app-mysql",
                "version": "v1"
              }
            },
            "spec": {
              "containers": [
                {
                  "envFrom": [
                    {
                      "secretRef": {
                        "name": "eng-app-secret"
                      }
                    }
                  ],
                  "image": "docker.io/mysql:5.7.29",
                  "name": "eng-app-mysql",
                  "ports": [
                    {
                      "containerPort": 3306
                    }
                  ],
                  "volumeMounts": [
                    {
                      "mountPath": "/var/lib/mysql",
                      "name": "eng-app-pv"
                    }
                  ]
                }
              ],
              "volumes": [
                {
                  "name": "eng-app-pv",
                  "persistentVolumeClaim": {
                    "claimName": "eng-app-pvc"
                  }
                }
              ]
            }
          }
        }
      },
      {
        "apiVersion": "v1",
        "kind": "Service",
        "metadata": {
          "labels": {
            "app": "eng-app-mysql"
          },
          "name": "eng-app-mysql-service",
          "namespace": "eng-app"
        },
        "spec": {
          "ports": [
            {
              "name": "http",
              "port": 3306
            }
          ],
          "selector": {
            "app": "eng-app-mysql"
          }
        }
      },
      {
        "apiVersion": "networking.istio.io/v1alpha3",
        "kind": "DestinationRule",
        "metadata": {
          "name": "eng-app-destination-rules",
          "namespace": "eng-app"
        },
        "spec": {
          "host": "eng-app-app",
          "subsets": [
            {
              "labels": {
                "version": "v1"
              },
              "name": "v1"
            }
          ],
          "trafficPolicy": {
            "tls": {
              "mode": "ISTIO_MUTUAL"
            }
          }
        }
      },
      {
        "apiVersion": "networking.istio.io/v1alpha3",
        "kind": "Gateway",
        "metadata": {
          "name": "eng-app-gateway",
          "namespace": "eng-app"
        },
        "spec": {
          "selector": {
            "istio": "ingressgateway"
          },
          "servers": [
            {
              "hosts": [
                "*"
              ],
              "port": {
                "name": "http",
                "number": 80,
                "protocol": "HTTP"
              }
            }
          ]
        }
      },
      {
        "apiVersion": "networking.istio.io/v1alpha3",
        "kind": "VirtualService",
        "metadata": {
          "name": "eng-app-virtual-service",
          "namespace": "eng-app"
        },
        "spec": {
          "gateways": [
            "eng-app-gateway"
          ],
          "hosts": [
            "*"
          ],
          "http": [
            {
              "route": [
                {
                  "destination": {
                    "host": "eng-app-app-service",
                    "port": {
                      "number": 3000
                    }
                  }
                }
              ]
            }
          ]
        }
      }
    ],
    "moniker": {
      "app": "eng"
    },
    "name": "Deploy (Manifest)",
    "relationships": {
      "loadBalancers": [],
      "securityGroups": []
    },
    "source": "text",
    "type": "deployManifest"
  }
  


単にDeleteする設定
--------------------

以下のようなJSON定義。
ラベルのselectorにappを指定し、EXISTSを指定するのがミソ。
これにより、appにeng-appを含むdeploymentが選択される。
すなわち、eng-app-app本体とeng-app-mysqlのDBが同時に削除される。::

  {
    "account": "default",
    "app": "eng",
    "cloudProvider": "kubernetes",
    "kinds": [
      "deployment"
    ],
    "labelSelectors": {
      "selectors": [
        {
          "key": "app",
          "kind": "EXISTS",
          "values": [
            "eng-app"
          ]
        }
      ]
    },
    "location": "eng-app",
    "mode": "label",
    "name": "Delete (Manifest)",
    "options": {
      "cascading": true
    },
    "type": "deleteManifest"
  }

dockerhubのイメージ更新を元にデプロイ
==========================================

CDのspinnakerが一通り出来たため、CI/CD環境を作成する。
pipeline/pipe1.jsonに記載したパイプラインを作ったが、
なぜか、dockerhubにイメージを更新してもデプロイが始まらない。::

  "triggers": [
   {
    "account": "dockerhub",
    "enabled": true,
    "organization": "miyakz1192",
    "registry": "index.docker.io",
    "repository": "miyakz1192/eng_app",
    "tag": "",
    "type": "docker"
   }

以下の記事を参照すると::

  https://github.com/spinnaker/spinnaker/wiki/Docker-Registry-Implementation

以下のように記載がある。::

  Since Clouddriver caches every image digest, we can track when individual tags are created or updated. The Igor microservice was extended to poll for incoming docker changes for every account configured in Clouddriver in igor/pull#64. Once it sees a tag was created, or a tag's digest has changed, it sends an event to the Echo microservice, which acts as an event bus. If the updated repository or tag matches one of the exiting pipeline triggers, Echo will start that pipeline. This was added in echo/pull#76. The Deck microservice had the ability to expose adding Docker triggers to pipelines added in deck/pull#2059.

ということで、igorのログを見ると以下のように、しっかりとtag2を検出しているのだが、pipelineが動かない。
dockerのイメージをpush時に内容を変更しないとdigest値が変わらない。tagを付け替えただけでは全く変更なし。
なので、ちゃんと中身を変更する必要がある。

ただし、コンテナの中のソースの中身を変えたくても、docker buildがキャッシュを使ってしまい、
更新が出来ない。::

  miyakz@dockerbuild:~/dockerfiles/eng_app$ ./repush_as_tag_1.sh 
  ++ sudo docker image rm miyakz1192/eng_app:1
  Error: No such image: miyakz1192/eng_app:1
  ++ sudo docker build -t eng_app .
  Sending build context to Docker daemon  4.096kB
  Step 1/4 : FROM docker.io/miyakz1192/eng_app_base:1
   ---> c3dd0c3f0e1f
  Step 2/4 : MAINTAINER miyakz1192 <miyakz1192@gmail.com>
   ---> Using cache
   ---> 886411d819be
  Step 3/4 : ENV DEBIAN_FRONTEND=noninteractive
   ---> Using cache
   ---> 214ed282b30f
  Step 4/4 : RUN  cd /english_study_app/eng_app ; git pull origin master
   ---> Using cache
   ---> b40a417bd1d6
  Successfully built b40a417bd1d6
  Successfully tagged eng_app:latest
  +++ sudo docker image list
  +++ grep 'eng_app '
  +++ awk '{print $3}'
  ++ sudo docker tag b40a417bd1d6 miyakz1192/eng_app:1
  ++ sudo docker push miyakz1192/eng_app:1
  The push refers to repository [docker.io/miyakz1192/eng_app]
  c4fa52177fcb: Layer already exists 
  3243764a145c: Layer already exists 
  a8a46e54bfa1: Layer already exists 
  1e5bef97fe42: Layer already exists 
  7639bfaf3e1c: Layer already exists 
  abd741d9e448: Layer already exists 
  868d2f92ffe0: Layer already exists 
  7f90146b865f: Layer already exists 
  fcfa834a9aa0: Layer already exists 
  9497c30cbf12: Layer already exists 
  1f705bb004bc: Layer already exists 
  efb37b70f734: Layer already exists 
  4cbbc216bd6a: Layer already exists 
  1: digest: sha256:75c79cf44334c0a8c332a377ffe3f83ab494da0d15221841d023ee53d3effc46 size: 3046

前回のsha256ダイジェスト値は75c~だったが、変わらない。理由は、Step 4/4の所でキャッシュを
使っているため。というわけで、以下の--no-chacheオプションを付けてビルドする必要がある。::

   sudo docker build -t eng_app . --no-cache

これでダイジェスト値を変更することができた。::

  1: digest: sha256:47bb87383b3cb6be8b4c57792764528b915fb85651ceb41cba870303ddc687f3 size: 3046

  





  
  


