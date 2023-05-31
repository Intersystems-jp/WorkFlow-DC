import sys
import json
import iris

def getProductAndPOPInfo(pid,popid):
    sql=("select JSON_OBJECT('PID':Product->PID,'ProductName':Product->ProductName,"
        "'Price':Product->Price,'Description':Product->Description,'ImageFile':Product->ImageFile,'StartDate':TOCHAR(StartDate,'YYYY-MM-DD'),"
        "'Period':Period) as json from ISJFoods_Tbl.POP WHERE Product->PID=? and POPID=?")
    print(sql)

    print(pid+" - "+ popid)
    stmt=iris.sql.prepare(sql)
    rs=stmt.execute(pid,popid)
    
    #for idx,row in enumerate(rs):
    #    reco=row[0]
    reco=rs.__next__()[0]  #strのタイプで取得できる

    #dictionaryにして返す
    return json.loads(reco)

def getProductInfo(pid):
    id=iris.cls("ISJFoods.Utils").IDfromPID(pid)
    obj=iris.cls("ISJFoods.Tbl.Product")._OpenId(id)
    #jmoji=iris.ref("jmoji")
    jmoji=iris.ref("jmoji")
    obj._JSONExportToString(jmoji)
    return jmoji.value

#失敗したらエラー文字列作って戻す
def callBS(jsontext):
    #メッセージ用意
    msg=iris.cls("Ens.StringRequest")._New(jsontext)

    #参照渡しの変数用意
    #bs=iris.ref('bs')
    response=iris.ref('response')
    #サービスのインスタンス作成
    bs=iris.cls("ProductPlan.BS.CurationAndJudgmentService")._New("新商品審査サービス")

    #サービス呼び出し
    retval=iris.ref("retval")
    #第2引数はインスタンス指定なので参照渡しができない。第3引数が文字列の参照渡しなので使ってみる
    status=bs.ProcessInput(msg,response,retval)
    #エラーの場合エラーステータスを取得しJSON文字にして返送（ErrorMsgプロパティに情報設定）
    if iris.system.Status.IsError(status):
        returnmsg={"ErrorMsg":iris.system.Status.GetErrorText(status)}
        return json.dumps(returnmsg,ensure_ascii=False)

    #JSON文字列を返す
    return retval.value