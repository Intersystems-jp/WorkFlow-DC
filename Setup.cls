Class ZWF.Setup
{

/// %SYS上で実行するアプリ用設定
ClassMethod init()
{
    // 日本語ロケールに変更（コンテナがUbuntu英語版のためデフォルトは英語ロケール）を利用
    Do ##class(Config.NLS.Locales).Install("jpuw")
    // 事前定義ユーザのパスワードを無期限に設定する（デフォルトパスワードはSYS）
    Do ##class(Security.Users).UnExpireUserPasswords("*")

    // コンテナ内Pythonからimport iris するためにコールインサービスを有効に設定
    // 現在の設定を取得
    set st=##class(Security.Services).Get("%Service_CallIn",.pro)
    set pro("Enabled")=1
    // 修正登録
    set st=##class(Security.Services).Modify("%Service_CallIn",.pro)

    /*********************************************************
    【ワークフローユーザポータル使用用ロール／ユーザの作成】
    （ユーザポータルの使用許可のみ持たせる）
    */
    set status=##class(Security.Roles).Create("WorkFlowSystemRole","ワークフローユーザポータル用ロール","%DeepSee_Portal:U")
    if $$$ISERR(status) {
        write $system.Status.GetErrorText(status),!
    }

    //ManagerAの作成
    set status=##class(Security.Users).Create("ManagerA","WorkFlowSystemRole","SYS","ワークフローユーザポータル使用者A",,,,,1,,,,,,1)
    if $$$ISERR(status) {
        write $system.Status.GetErrorText(status),!
    }
    //ManagerBの作成
    set status=##class(Security.Users).Create("ManagerB","WorkFlowSystemRole","SYS","ワークフローユーザポータル使用者B",,,,,1,,,,,,1)
    if $$$ISERR(status) {
        write $system.Status.GetErrorText(status),!
    }
    /*********************************************************/
    
    //REST用パス設定
    set webName = "/wf"
    set webProperties("DispatchClass") = "ISJFoods.WF.REST"
    set webProperties("NameSpace") = "USER"
    set webProperties("Enabled") = 1
    set webProperties("AutheEnabled") = 96
    set webProperties("MatchRoles")=":%All"
    set status = ##class(Security.Applications).Create(webName, .webProperties)
    if $$$ISERR(status) {
        write $system.Status.GetErrorText(status),!
    }

    //USER用パス　Analytics有効化
    set userpath = ##class(Security.Applications).%OpenId("/csp/user")
    set userpath.DeepSeeEnabled=1
    set status=userpath.%Save()
    if $$$ISERR(status) {
        write $system.Status.GetErrorText(status),!
    }
    // JDBCを利用するSQLゲートウェイの設定
    set jdbcgw=##class(%Library.SQLConnection).%New()
    set jdbcgw.Name="Test"
    set jdbcgw.URL="jdbc:IRIS://localhost:1972/USER"
    set jdbcgw.Usr="_SYSTEM"
    set jdbcgw.classpath=".:usr/irissys/dev/java/lib/1.8/intersystems-jdbc-3.7.1.jar"
    set jdbcgw.driver="com.intersystems.jdbc.IRISDriver"
    set jdbcgw.isJDBC=1
    set jdbcgw.pwd="SYS"
    set status=jdbcgw.%Save()
    if $$$ISERR(status) {
        write $system.Status.GetErrorText(status),!
    }
    // SSL構成の追加（teams通知用）
    set status=##class(Security.SSLConfigs).Create("teams")
    if $$$ISERR(status) {
        write $system.Status.GetErrorText(status),!
    }
}

}
