Class ISJFoods.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="ISJFoods.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="EnsLib.JavaGateway.Service" Category="" ClassName="EnsLib.JavaGateway.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="POPステータス更新" Category="" ClassName="EnsLib.SQL.Operation.GenericOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="{&quot;POPID&quot;:&quot;POP001&quot;,&quot;Status&quot;:&quot;approved&quot;} または {&quot;POPID&quot;:&quot;POP001&quot;,&quot;Status&quot;:&quot;approved&quot;,&quot;RejectedReason&quot;,&quot;ああああ&quot;}  ?に値入ってなくても動く" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="DSN">Test</Setting>
    <Setting Target="Host" Name="InputParameters">*Status,*RejectedReason,*POPID</Setting>
    <Setting Target="Host" Name="Query">UPDATE ISJFoods_Tbl.POP
SET Status=?,RejectedReason=?
WHERE POPID=?</Setting>
    <Setting Target="Host" Name="RequestClass"></Setting>
    <Setting Target="Adapter" Name="JGService">EnsLib.JavaGateway.Service</Setting>
    <Setting Target="Host" Name="ParamSQLTypes">VARCHAR,VARCHAR,INTEGER</Setting>
  </Item>
  <Item Name="POP審査" Category="" ClassName="ISJFoods.BP.JudgmentProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="POPメッセージSQL抽出" Category="" ClassName="EnsLib.SQL.Service.GenericService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">POP審査</Setting>
    <Setting Target="Adapter" Name="DSN">Test</Setting>
    <Setting Target="Adapter" Name="Query"><![CDATA[select StartDate,Period,Message,Product,POPID,Product,Product->PID As PID from ISJFoods_Tbl.POP
WHERE Done=0]]></Setting>
    <Setting Target="Adapter" Name="JGService">EnsLib.JavaGateway.Service</Setting>
    <Setting Target="Adapter" Name="DeleteQuery">UPDATE ISJFoods_Tbl.POP
SET Done=1
WHERE POPID=?</Setting>
    <Setting Target="Adapter" Name="KeyFieldName">POPID</Setting>
  </Item>
  <Item Name="登録者へ通知" Category="" ClassName="ISJFoods.BO.SendMessageToTeams" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="token"></Setting>
    <Setting Target="Adapter" Name="HTTPServer"></Setting>
    <Setting Target="Adapter" Name="SSLConfig">teams</Setting>
    <Setting Target="Adapter" Name="URL">/webhookb2</Setting>
  </Item>
  <Item Name="POP審査ワークフロー" Category="" ClassName="EnsLib.Workflow.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
