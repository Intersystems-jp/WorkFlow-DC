Class ISJFoods.Utils
{

ClassMethod IDfromPID(PID As %String) As %Integer
{
	return ##class(ISJFoods.Tbl.Product).PIDIdxOpen(PID).%Id()
}

/// ワークフローに手動で入れる
ClassMethod createWF() As %Status
{
	set req=##class(EnsLib.Workflow.TaskRequest).%New()
	set req.%Actions="承認,却下,保留"
	set req.%Subject="商品ID：P001 新着POPメッセージ"
	set req.%Message="お弁当の隙間にピッタリ"
	set req.%UserName="Manager"
	set req.%FormFields="PID,POPID,URL,RejectedReason"
    do req.%FormValues.SetAt("P001","PID")
    do req.%FormValues.SetAt("POP001","POPID")
    //do req.%FormValues.SetAt("2023-05-03","StartDate")
    //do req.%FormValues.SetAt("8","Period")
    do req.%FormValues.SetAt("http://localhost:5001/product/P001","URL")
    do req.%FormValues.SetAt("","RejectedReason")
	set req.%Priority=3

	set sreq=##class(EnsLib.Testing.Request).%New()
	set sreq.Target="POPJudgment"
	set sreq.Request=req

	set st=##class(Ens.Director).CreateBusinessService("EnsLib.Testing.Service",.bs)
	set st=bs.ProcessInput(sreq)
	if $$$ISERR(st) {
		write $system.Status.GetErrorText(st)
	}
	return st
}

ClassMethod createWF2() As %Status
{
	set req=##class(EnsLib.Workflow.TaskRequest).%New()
	set req.%Actions="承認,却下,保留"
	set req.%Subject="商品ID：P004 新着POPメッセージ"
	set req.%Message="夕飯に出してびっくりさせよう！"
	set req.%UserName="Manager"
	set req.%FormFields="PID,POPID,URL,RejectedReason"
    do req.%FormValues.SetAt("P004","PID")
    do req.%FormValues.SetAt("POP002","POPID")
    //do req.%FormValues.SetAt("2023-05-03","StartDate")
    //do req.%FormValues.SetAt("8","Period")
    do req.%FormValues.SetAt("http://localhost:5001/product/P004","URL")
    do req.%FormValues.SetAt("","RejectedReason")
	set req.%Priority=3

	set sreq=##class(EnsLib.Testing.Request).%New()
	set sreq.Target="POPJudgment"
	set sreq.Request=req

	set st=##class(Ens.Director).CreateBusinessService("EnsLib.Testing.Service",.bs)
	set st=bs.ProcessInput(sreq)
	if $$$ISERR(st) {
		write $system.Status.GetErrorText(st)
	}
	return st
}

/// 画像ファイルはFlask app.pyでデフォルトパス設定してる
ClassMethod CreateData()
{
    set p=##class(ISJFoods.Tbl.Product).%New()
    set p.Price=150
    set p.Description="花形の切り口でゆで卵（固ゆで）を切っています。"
    set p.PID="P001"
    set p.ProductName="ゆで卵（切り口花形）2個"
    set p.ImageFile="food_yudetamago_gizagiza.png"
    set status=p.%Save()

    set p=##class(ISJFoods.Tbl.Product).%New()
    set p.Price=250
    set p.Description="骨取りアジの開き（2枚）"
    set p.PID="P002"
    set p.ProductName="アジの開き"
    set p.ImageFile="food_fish_hiraki.png"
    set status=p.%Save()

    set p=##class(ISJFoods.Tbl.Product).%New()
    set p.Price=60
    set p.Description="日替わり串カツ（1本）"
    set p.PID="P003"
    set p.ProductName="本日の串カツ"
    set p.ImageFile="food_bunka_fry.png"
    set status=p.%Save()

    set p=##class(ISJFoods.Tbl.Product).%New()
    set p.Price=60
    set p.Description="漫画によく出てくるお肉です"
    set p.PID="P004"
    set p.ProductName="漫画肉"
    set p.ImageFile="niku_manga.png"
    set status=p.%Save()

    do ..CreatePOPData()
}

ClassMethod CreatePOPData()
{
    &sql(insert into ISJFoods_Tbl.POP (POPID,Message,StartDate,Period,Product) 
    Values('POP001','お弁当の隙間にピッタリ！',TODATE('2023-04-04','YYYY-MM-DD'),30,1))
    &sql(insert into ISJFoods_Tbl.POP (POPID,Message,StartDate,Period,Product) 
    Values('POP002','夕飯に出してびっくりさせよう！',TODATE('2023-06-01','YYYY-MM-DD'),10,4))
    &sql(insert into ISJFoods_Tbl.POP (POPID,Message,StartDate,Period,Product) 
    Values('POP003','骨がないので食べやすい！',TODATE('2023-05-01','YYYY-MM-DD'),14,2))
    &sql(insert into ISJFoods_Tbl.POP (POPID,Message,StartDate,Period,Product) 
    Values('POP004','運動会のおかずにどうでしょう',TODATE('2023-05-25','YYYY-MM-DD'),15,1))
}

ClassMethod CreateWFUserAndRole()
{
    #dim ex As %Exception.AbstractException
    try {
    // ワークフローユーザの設定（ManagerAとManagerBをワークフローユーザとする）
        $$$ThrowOnError(##class(EnsLib.Workflow.UserDefinition).CreateUser("ManagerA"))
        $$$ThrowOnError(##class(EnsLib.Workflow.UserDefinition).CreateUser("ManagerB"))
        $$$ThrowOnError(##class(EnsLib.Workflow.RoleDefinition).CreateRole("POP審査ワークフロー"))
        $$$ThrowOnError(##class(EnsLib.Workflow.RoleDefinition).AddUserToRole("POP審査ワークフロー","ManagerA"))
        $$$ThrowOnError(##class(EnsLib.Workflow.RoleDefinition).AddUserToRole("POP審査ワークフロー","ManagerB"))
    }
    catch ex {
        write ex.DisplayString(),!
    }
}

}
