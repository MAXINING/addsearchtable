Class SearchTable.Util.Setting
{

ClassMethod Setting() As %Status
{
	//
	D $system.OBJ.Load("/usr/irissys/csp_user_searchtableAdd.xml","cbrpsuy")
	set ns=$namespace
	zn "%SYS"
	Set sc("DispatchClass")="SearchTable.Util.Rest",sc("AutheEnabled")=64,sc("IsNameSpaceDefault")=0,sc("MatchRoles")=":%All",sc("GroupById")="%ISCMgtPortal",sc("NameSpace")=ns,sc("DeepSeeEnabled")=1
	Set tSC=##Class(Security.Applications).Create("/SearchTable",.sc)
	zn ns
	Quit tSC
}

ClassMethod zpm() As %Status
{
	set ns=$namespace
	zn "%SYS"
	Set tSC=##Class(Security.Applications).%OpenId("/csp/user",.a)
    SET tSC.ServeFiles=2
    Do tSC.%Save()
    zn ns
	Quit tSC
}

}
