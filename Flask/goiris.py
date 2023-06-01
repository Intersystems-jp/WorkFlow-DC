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
