# ワークフローコンポーネントを使ったサンプル

このリポジトリには、IRISのInteroperability（相互運用性）を使用してシステム連携の自動的な流れの中にユーザから指示を統合できる「ワークフローコンポーネント」の動作を確認できるサンプルが含まれています。

![](/assets/demo-image.png)

《サンプルのテーマ》　店舗で販売している商品に付けるPOPメッセージ候補を予めテーブルに登録できる仕組みがあると仮定しています。

IRISのInteroperabilityの仕組みを利用して、POPメッセージ候補が登録されるテーブルに対して一定間隔でSELECT文を実行します。
新たなレコードが存在する場合、ワークフローコンポーネントを利用して、担当者に審査を依頼します。

担当者は、ワークフローユーザポータルを使用して、POPメッセージ候補の承認／却下を指示できるようにしています。

## サンプル確認手順

コンテナを使用しています。以下の手順でコンテナを開始します。
### 1) コンテナのビルド

```
docker-compose build
```

### 2) コンテナの開始

```
docker-compose up -d
```

> コンテナ内ではInterSystems IRIS 2023.1とFlaskのアプリケーションが開始されます。

コンテナ開始後、ワークフローユーザポータルで処理できるデータが4件作成されます。

ワークフローユーザポータルにログイン、またはFlask版ユーザポータルを利用して動作をご確認いただけます。

#### 2-1. [ワークフロー：ユーザポータル](http://127.0.0.1:9093/csp/user/_DeepSee.UserPortal.Home.zen?$NAMESPACE=USER&$NAMESPACE=USER&)

> 管理ポータルでメッセージのトレースを参照される場合は、ワークフローユーザポータルは管理ポータルとは異なるブラウザで開くことをお勧めします。（管理ポータル／ワークフローユーザポータルにアクセスする際、IRIS内ユーザを利用してログインを行うため、ブラウザの種別が同一の場合、毎回ログインしなおす必要があります）

以下のワークフローユーザでログインしてください。

ユーザ名：ManagerA／パスワード：SYS

![](/assets/IRIS-WF-UserPortal.png)

#### 2-2. [Flaskアプリ版ユーザポータル](http://localhost:5001)

ユーザ名：ManagerA でログインするように作成しています。

![](/assets/Flask-WF-UserPortal.png)

#### 2-3. POPメッセージ用テーブルをご覧いただく場合は、管理ポータルのSQLメニューを利用します。

[IRIS管理ポータル SQLメニュー](http://localhost:9093/csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE=USER&$NAMESPACE=USER)

管理ポータルには以下のユーザ名／パスワードでログインします。

ユーザ名：SuperUser／パスワード：SYS

以下のSQLで販売商品に対するPOPメッセージの申請登録を確認できます。
```
SELECT 
Product->PID,Product->ProductName,POPID,Status,Message,TO_CHAR(StartDate,'YYYY-MM-DD') As StartDate, Period,RejectedReason, Done
FROM ISJFoods_Tbl.POP
```

#### 2-4. メッセージの確認方法

IRISの管理ポータル、プロダクション構成画面は以下URLでアクセスできます。

- [IRIS管理ポータル](http://localhost:9093/csp/sys/UtilHome.csp)

- [プロダクション構成画面](http://127.0.0.1:9093/csp/user/EnsPortal.ProductionConfig.zen?$NAMESPACE=USER&$NAMESPACE=USER&)


- メッセージの確認手順

    - (1) [プロダクション構成画面](http://127.0.0.1:9093/csp/user/EnsPortal.ProductionConfig.zen?$NAMESPACE=USER&$NAMESPACE=USER&)にアクセスします。
        サービス：POPメッセージSQL抽出 の文字の付近をクリックし、画面右の「メッセージ」タブを選択します。
        ![](/assets/CheckMessage.png)


    - (2) 処理したいメッセージを選択します。

        コンテナ開始段階で4件のメッセージが参照できるので、ヘッダ列にある番号をクリックし、メッセージのトレース画面を開きます。
        ![](/assets/Message-Trace1.png)

        トレースを開き[2]のメッセージをクリックした後、画面右の「コンテンツ」タブを確認します。
        
        以下タグのデータを確認します。
        > <_Message></_Message> と <_Subject></_Subject>

        この画面はユーザ指示後に確認しますので、開いたままとします。

    - (3) ワークフローユーザポータル、またはFlaskアプリ上で(2)で確認した情報と同じリストを処理します。

        ワークフローユーザポータルの場合は、対象行を選択します。

        Flaskアプリの場合は「審査する」ボタンをクリックします。
    
        承認か却下ボタンをクリックします。

    - (4) ユーザ指示後のトレースを確認します。

        (2)で確認したトレースをリロードします。

        待機していた処理がユーザからの指示により、再開していることがわかります。（[3]のメッセージをクリックすると画面右の「コンテンツ」タブでユーザが指示したときのボタン情報を確認できます）

        ![](/assets/Message-Trace2.png)

**POPメッセージ審査完了通知（Teams）をご利用いただく場合**

コンテナ開始時点では、POPメッセージ審査完了通知（Teams）は無効になっています。Teamsの任意チャネルに対して「[Incoming Webhook](https://learn.microsoft.com/ja-jp/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook?tabs=dotnet)」の設定を行ってください。

設定後、以下設定欄に必要な情報をご記入ください。

![](/assets/TeamsSettings.png)

オペレーション：登録者へ通知 を選択し「設定」タブにある以下設定を作成されたIncoming Webhookに合わせ修正してください。

- HTTPサーバ
- URL
- teams設定にある「token」

続いて、[プロセス：POP審査](http://127.0.0.1:9093/csp/user/EnsPortal.BPLEditor.zen?BP=ISJFoods.BP.JudgmentProcess.bpl) のエディタを開き、一番下にある「登録者への通知」アクティビティをクリックし、画面右にある「無効」のチェックを外し、コンパイルボタンをクリックします。
![](/assets/BPL.png)


#### 2-6. メモ

もう1度、同じデータを利用してワークフローユーザポータル上で審査したい場合は、[IRIS管理ポータル SQLメニュー](http://localhost:9093/csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE=USER&$NAMESPACE=USER)の「クエリ実行」タブで、以下UPDATE文を実行してください。

```
update ISJFoods_Tbl.POP
set Done=0,Status='pending',RejectedReason=null
```
UPDATE文実行後、[メッセージの確認方法](#2-4-メッセージの確認方法)でご確認ください。

### 3) コンテナの停止

> docker-compose stop


### 4) コンテナ破棄

> docker-compose down
