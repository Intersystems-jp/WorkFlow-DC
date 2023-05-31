from flask import Flask, render_template, request
import requests
from requests.auth import HTTPBasicAuth
import goiris
import json


#app = Flask(__name__)
#スタティックページをstatic_folderと設定できる
app = Flask(__name__, static_folder='images')

# 日本語を使えるように
app.config['JSON_AS_ASCII'] = False

#ワークフロー一覧を見る時
@app.route('/',methods=['GET'])
def index():
    url="http://localhost:52773/wf/tasks"
    #apihead={"Content-Type":"application/json;charset=utf-8"}
    #ret = requests.get(url,headers=apihead)
    auth=HTTPBasicAuth("ManagerA","SYS")
    ret=requests.get(url,auth=auth)
    jsontodic=json.loads(ret.text)
    return render_template("index.html",wfinfo=jsontodic,taskinfo=[],pinfo=[])


#１個タスクを選択したとき
@app.route('/task/<tid>',methods=['GET'])
def taskinfo(tid):
    #tid=request.args.get('ref')
    print(tid)
    url="http://localhost:52773/wf/task/"+tid
    auth=HTTPBasicAuth("ManagerA","SYS")
    ret=requests.get(url,auth=auth)
    taskinfodic=json.loads(ret.text)

    #Productテーブルの中身を取得
    #dictionaryで戻る
    pid=taskinfodic["formFields"]["PID"]
    popid=taskinfodic["formFields"]["POPID"]

    pinfodic=goiris.getProductAndPOPInfo(pid,popid)
    returndic={}
    returndic["taskinfo"]=taskinfodic
    returndic["pinfo"]=pinfodic
    #returndic　-> dic
    #dic -> strに変換して戻す
    #return returndic
    print(returndic)
    return json.dumps(returndic,ensure_ascii=False)
    #return render_template("index.html",taskinfo=taskinfodic,pinfo=pinfodic)


#タスクを処理する（承認／却下の指定）
# Bodyに入れるデータ例（TaskRequestにあるものはすべてTaskResponseに含まれる）
# { "action":"却下","formFields":{"RejectedReason":"testtest"}} 
@app.route('/task/<tid>',methods=['POST'])
def taskpost(tid):
    print(tid)
    print(request.form)
    dictdata=request.form.to_dict(flat=True)

    data={}
    data["action"]=dictdata["action"]
    if data["action"]=="却下" :
        reason={"RejectedReason":dictdata["formFields[RejectedReason]"]}
        data["formFields"]=reason
    else :
        data["formFields"]={}

    print(data)
    print(type(data))
    print(json.dumps(data,ensure_ascii=False))
    data=json.dumps(data,ensure_ascii=False)
    headers={'Content-Type':"application/json;charset=utf-8"}
    url="http://localhost:52773/wf/task/"+tid
    auth=HTTPBasicAuth("ManagerA","SYS")
    res=requests.post(url,auth=auth,headers=headers,data=data.encode("utf-8"))

    print(res.status_code)
    returndic={}
    returndic["status"]=res.status_code
    return returndic

@app.route('/product/<pid>',methods=['GET'])
def productinfo(pid):
    infojson=goiris.getProductInfo(pid)
    infodic=json.loads(infojson)
    return render_template("summary.html",pinfo=infodic)


if __name__=="__main__":
    #app.run(debug=True,host='0,0,0,0',port="8081")
    app.run(host='0.0.0.0',port="5000")
    #app.run(debug=True,host='0.0.0.0',port="5000")