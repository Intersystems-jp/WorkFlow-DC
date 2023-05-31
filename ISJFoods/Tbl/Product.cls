Class ISJFoods.Tbl.Product Extends (%Persistent, %JSON.Adaptor)
{

Property PID As %String [ Required, SqlColumnNumber = 2 ];

Index PIDIdx On PID [ Unique ];

Property ProductName As %String [ SqlColumnNumber = 3 ];

Property Price As %Integer [ SqlColumnNumber = 4 ];

Property Description As %String(MAXLEN = 10000) [ SqlColumnNumber = 5 ];

Property ImageFile As %String(MAXLEN = 100) [ SqlColumnNumber = 6 ];

Relationship POP As ISJFoods.Tbl.POP [ Cardinality = many, Inverse = Product ];

Storage Default
{
<Data name="ProductDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PID</Value>
</Value>
<Value name="3">
<Value>ProductName</Value>
</Value>
<Value name="4">
<Value>Price</Value>
</Value>
<Value name="5">
<Value>Description</Value>
</Value>
<Value name="6">
<Value>ImageFile</Value>
</Value>
</Data>
<DataLocation>^ISJFoods.Tbl.ProductD</DataLocation>
<DefaultData>ProductDefaultData</DefaultData>
<IdLocation>^ISJFoods.Tbl.ProductD</IdLocation>
<IndexLocation>^ISJFoods.Tbl.ProductI</IndexLocation>
<StreamLocation>^ISJFoods.Tbl.ProductS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
