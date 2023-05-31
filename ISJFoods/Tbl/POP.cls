Class ISJFoods.Tbl.POP Extends (%Persistent, %JSON.Adaptor)
{

Property POPID As %String [ Required ];

Property StartDate As %Date [ SqlColumnNumber = 2 ];

Property Period As %String [ SqlColumnNumber = 3 ];

Property Message As %String(MAXLEN = 1000) [ SqlColumnNumber = 4 ];

Property RejectedReason As %String(MAXLEN = 100000) [ SqlColumnNumber = 5 ];

Property Status As %String(VALUELIST = ",rejected,approved,pending") [ InitialExpression = "pending", Required, SqlColumnNumber = 6 ];

/// ワークフロータスク実施用フラグ 1:審査済／0:未済
Property Done As %Boolean [ InitialExpression = 0 ];

Relationship Product As ISJFoods.Tbl.Product [ Cardinality = one, Inverse = POP ];

Index ProductIdx On Product;

Index POPIDIdx On POPID [ Unique ];

Storage Default
{
<Data name="POPDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>POPID</Value>
</Value>
<Value name="3">
<Value>StartDate</Value>
</Value>
<Value name="4">
<Value>Period</Value>
</Value>
<Value name="5">
<Value>Message</Value>
</Value>
<Value name="6">
<Value>RejectedReason</Value>
</Value>
<Value name="7">
<Value>Status</Value>
</Value>
<Value name="8">
<Value>Product</Value>
</Value>
<Value name="9">
<Value>Done</Value>
</Value>
</Data>
<DataLocation>^ISJFoods.Tbl.POPD</DataLocation>
<DefaultData>POPDefaultData</DefaultData>
<IdLocation>^ISJFoods.Tbl.POPD</IdLocation>
<IndexLocation>^ISJFoods.Tbl.POPI</IndexLocation>
<StreamLocation>^ISJFoods.Tbl.POPS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
