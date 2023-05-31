Class ISJFoods.BO.SendMessageToTeams Extends Ens.BusinessOperation
{

/// The type of adapter used to communicate with external systems
Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Property token As %String(MAXLEN = 200);

Parameter SETTINGS = "token:teams設定,ReplyCodeActions,RetryInterval,AlertRetryGracePeriod:Alerting,FailureTimeout,QueueCountAlert:Alerting,QueueWaitAlert:Alerting,SendSuperSession";

/// 入力情報 {"PID":"P123123","Message":"POPに表示したいメッセージ","Status":"pending"} など
Method POSTString(pRequest As Ens.StringRequest, ByRef pResponse As Ens.StringResponse) As %Status
{
    #dim ex As %Exception.AbstractException
    set status=$$$OK
    try {
        set json={}.%FromJSON(pRequest.StringValue)
        if (json.Status="pending")&(..%ConfigName="審査員へ通知")  {
            set moji="# POP候補届きました"_$$$NL
            set moji=moji_"- PID："_json.PID_$$$NL
            set moji=moji_"- メッセージ："_json.Message_$$$NL
            set moji=moji_"- [確認ページ](http://localhost:9093/csp/user/_DeepSee.UserPortal.Workflow.zen)"_$$$NL
            set moji=moji_"- [詳細データ](http://localhost:5001/product/"_json.PID_")"
        }
        else {
            if json.Status="approved" {
                set moji="# 登録したPOPが**承認**されました！"_$$$NL
            }
            elseif json.Status="rejected" {
                set moji="# 登録したPOPが**却下**されました・・😢"_$$$NL
            }
            elseif json.Status="pending" {
                set moji="# 登録したPOPが**保留**となりました。"_$$$NL
            }
            set moji=moji_"- [詳細データ](http://localhost:5001/product/"_json.PID_")"
        }

        $$$TRACE(moji)

        set originalurl=..Adapter.URL
        if $EXTRACT(originalurl,*)="/" {
            set url=originalurl_..token
        }
        else {
            set url=originalurl_"/"_..token
        }

        set teamsjson={}
        set teamsjson.text=moji

        set stream=##class(%Stream.TmpBinary).%New()
        do teamsjson.%ToJSON(stream)
        //Bodyに作成したJSONを入れる場合は、PostURL()メソッド第4引数にストリームで指定する
        $$$ThrowOnError(..Adapter.PostURL(url,.pHttpResponse,,stream))

        if pHttpResponse.StatusCode'=200 {
            set status=$$$ERROR($$$EnsErrGeneral,$$$StatusDisplayString(status)_":"_pHttpResponse.Data.Read())
        }
        $$$ThrowOnError(status)
    }
    catch ex {
        set status=ex.AsStatus()
    }
    return status
}

XData MessageMap
{
<MapItems>
        <MapItem MessageType="Ens.StringRequest">
            <Method>POSTString</Method>
        </MapItem>
    </MapItems>
}

}
