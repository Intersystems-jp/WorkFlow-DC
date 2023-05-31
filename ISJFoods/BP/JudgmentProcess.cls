/// 
Class ISJFoods.BP.JudgmentProcess Extends Ens.BusinessProcessBPL
{

Storage Default
{
<Type>%Storage.Persistent</Type>
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.StreamContainer' response='Ens.StreamContainer' height='2000' width='2000' >
<context>
<property name='WorkFlowMsg' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='1000' />
</parameters>
</property>
<property name='WorkFlowResponse' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='UpdateStatusData' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='1000' />
</parameters>
</property>
<property name='NotifyMsg' type='Ens.StringRequest' instantiate='0' />
<property name='PID' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='POPID' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
<property name='RejectedReason' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='2500' />
</parameters>
</property>
</context>
<sequence xend='200' yend='1450' >
<code name='表示メッセージ作成' xpos='200' ypos='250' >
<annotation><![CDATA[＜入力メッセージ例＞
{"StartDate":"2023-04-29","Period":"7","Message":"とてもおいしい卵です","Product":1,"POPID":"POP001"}
]]></annotation>
<![CDATA[ //Ens.StreamContainerのStreamプロパティにJSON文字列格納される
 //Ens.StringRequestはStringValueプロパティにJSON文字格納される
 
 if $classname(request)="Ens.StreamContainer" {
  set json={}.%FromJSON(request.Stream)
 }
 if $classname(request)="Ens.StringRequest" {
  set json={}.%FromJSON(request.StringValue) 
 }

 set msg="POPメッセージ候補："_json.Message_$C(13,10)
 set msg=msg_"開始日："_json.StartDate_$C(13,10)
 set msg=msg_"期間"_json.Period_$C(13,10)
 set msg=msg_"参考URL：http://localhost:5000/product/"_json.PID
 //set context.WorkFlowMsg=msg
 set context.WorkFlowMsg=json.Message
 set context.PID=json.PID
 set context.POPID=json.POPID]]>
</code>
<call name='判断ワークフロー呼び出し' target='POP審査ワークフロー' async='1' xpos='200' ypos='350' >
<annotation><![CDATA[%UserNameを指定しない場合、ワークフローロールに含まれるユーザが自ら引き受けるかどうか決められる]]></annotation>
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;承認,却下,保留&quot;" action="set" />
<assign property="callrequest.%Subject" value="&quot;商品ID：&quot;_context.PID_&quot; 新着POPメッセージ&quot;" action="set" />
<assign property="callrequest.%UserName" value="&quot;ManagerA&quot;" action="set" />
<assign property="callrequest.%Message" value="context.WorkFlowMsg" action="set" />
<assign property="callrequest.%FormFields" value="&quot;PID,POPID,URL,RejectedReason&quot;" action="set" />
<assign property="callrequest.%FormValues" value="context.PID" action="set" key="&quot;PID&quot;" />
<assign property="callrequest.%FormValues" value="context.POPID" action="set" key="&quot;POPID&quot;" />
<assign property="callrequest.%FormValues" value="&quot;http://localhost:5001/product/&quot;_context.PID" action="set" key="&quot;URL&quot;" />
</request>
<response type='EnsLib.Workflow.TaskResponse' >
<assign property="context.WorkFlowMsg" value="$case(callresponse.%Action,&quot;承認&quot;:&quot;approved&quot;,&quot;却下&quot;:&quot;rejected&quot;,:&quot;pending&quot;)" action="set" />
<assign property="context.RejectedReason" value="callresponse.%FormValues.GetAt(&quot;RejectedReason&quot;)" action="set" />
</response>
</call>
<sync name='ワークフローの応答待機' calls='判断ワークフロー呼び出し' type='all' xpos='200' ypos='450' />
<code name='更新・通知データ作成' xpos='200' ypos='550' >
<annotation><![CDATA[JSONデータ作成]]></annotation>
<![CDATA[ set json={}

 set json.Status=context.WorkFlowMsg
 set json.POPID=context.POPID
 set context.UpdateStatusData=json.%ToJSON()
 
 set notify={}
 set notify.Status=json.Status
 set notify.PID=context.PID
 set context.NotifyMsg=##class(Ens.StringRequest).%New(notify.%ToJSON())]]>
</code>
<if name='更新確認' condition='context.WorkFlowMsg="pending"' xpos='200' ypos='650' xend='200' yend='1250' >
<false>
<if name='却下時' condition='context.WorkFlowMsg="rejected"' xpos='335' ypos='800' xend='335' yend='1050' >
<true>
<code name='却下理由追加' xpos='470' ypos='950' >
<![CDATA[ set j={}.%FromJSON(context.UpdateStatusData)
 set j.RejectedReason=context.RejectedReason
 set context.UpdateStatusData=j.%ToJSON()]]>
</code>
</true>
</if>
<call name='ステータス変更' target='POPステータス更新' async='0' xpos='335' ypos='1150' >
<request type='Ens.StringRequest' >
<assign property="callrequest.StringValue" value="context.UpdateStatusData" action="set" />
</request>
<response type='Ens.StreamContainer' >
<assign property="response" value="callresponse" action="set" />
</response>
</call>
</false>
</if>
<call name='登録者への通知' target='登録者へ通知' async='0' xpos='200' ypos='1350' disabled="true">
<request type='Ens.StringRequest' >
<assign property="callrequest" value="context.NotifyMsg" action="set" />
</request>
<response type='Ens.StringResponse' />
</call>
</sequence>
</process>
}

}
