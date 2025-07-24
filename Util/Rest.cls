Class SearchTable.Util.Rest Extends %CSP.REST
{

XData UrlMap
{
<Routes>
  <Route Url="/*" Method="OPTIONS" Call="GetStatus"/>
  <Route Url="/GetMsgClass" Method="GET" Call="GetMsgClass"/>
  <Route Url="/GetProperty/:ClassName" Method="GET" Call="GetProperty"/>
   <Route Url="/AddSearchTableM" Method="POST" Call="AddSearchTableM"/>
  
</Routes>
}

ClassMethod GetMsgClass() As %Status
{
	set r=##class(Ens.Request).%New()
	
	set searchParms=##class(%ZEN.proxyObject).%New()
	set c=##class(%ZEN.proxyObject).%New()
	set d=##class(%ZEN.proxyObject).%New()
	//w "------",!
	set search = "Ens/Classes"
	set searchParms.system=1
	set searchParms.hideAbstract=1
    set searchParms.super= "Ens.Util.MessageBodyMethods"
	Do ##class(EnsPortal.Dialog.SearchCriteria).GetOptions(search,.searchParms,.c,.d)
	set ob={}
    set result=[]
    for i=1:1:(d.resultCount)
    {
	    set temp={}
	    set temp.Type="other"
	    set temp.Value=d.%data("result"_i)
	    Do result.%Push(temp)
	    
	   }
	   
	   set ob.Body=result

    
    set result=[]
   
	set c=##class(%ZEN.proxyObject).%New()
	set d=##class(%ZEN.proxyObject).%New()
	//w "------",!
	set search = "Ens/VDocClasses"
	set searchParms1=##class(%ZEN.proxyObject).%New()
    	//set searchParms1.segmented=1
	Do ##class(EnsPortal.Dialog.SearchCriteria).GetOptions(search,.searchParms1,.c,.d)
   // zw c
     for i=1:1:(d.resultCount)
    {
	    set temp={}
	    set temp.Type="xml"
	    set temp.Value=d.%data("result"_i)
	    Do result.%Push(temp)
	    
	   }
	   set ob.Vdoc=result
    	/*set search = "Ens/MessageProperties"
    	set searchParms1=##class(%ZEN.proxyObject).%New()
    	set searchParms1.class="JHIPLIB.Util.MSG.JHRequestMsg"
	    set searchParms1.sqlFields=1
	    Do ##class(EnsPortal.Dialog.SearchCriteria).GetOptions(search,.searchParms1,.c,.d)
     zw d*/
     w ob.%ToJSON()
    
	Quit $$$OK
	//	set	searchParms.hideAbstract = 1
		//set	searchParms.classtype = 'persistent'
}

ClassMethod GetProperty(ClassName) As %Status
{
        set searchParms=##class(%ZEN.proxyObject).%New()
	     set c=##class(%ZEN.proxyObject).%New()
	     set d=##class(%ZEN.proxyObject).%New()
	     set search = "Ens/MessageProperties"
    	set searchParms1=##class(%ZEN.proxyObject).%New()
    	set searchParms1.class=ClassName
	    set searchParms1.sqlFields=1
	    Do ##class(EnsPortal.Dialog.SearchCriteria).GetOptions(search,.searchParms1,.c,.d)
	    set result=[]
    for i=1:1:(d.resultCount)
    {
	    set temp={}
	  
	    set temp.Value=d.%data("result"_i)
	    Do result.%Push(temp)
	    
	   }
	   W result.%ToJSON()
	   Quit $$$OK
}

ClassMethod AddSearchTableM() As %Status
{

 // W "-------"
  set input =$zcvt(%request.CgiEnvs("QUERY_STRING"),"I","URL")
  set status= ..CreateSearchTable({}.%FromJSON(input))
  w "{""return"":""success""}"
  Quit $$$OK
}

ClassMethod CreateSearchTable(input) As %Status
{
	try {
	//set itor=ob.%GetIterator()
    set array=input.Content
    set itor=array.%GetIterator()
	    //class名 属性名 每个属性的路径  
	Set class = ##class(%Dictionary.ClassDefinition).%New()
	Set class.Name=input.name 
	Set class.Super="Ens.CustomSearchTable"
	set class.ProcedureBlock=1
      
	set parameterl = ##class(%Dictionary.ParameterDefinition).%New()
	
	set parameterl.Name="DOCCLASS"
	set parameterl.Default=input.messageType
	do class.Parameters.Insert(parameterl)
	set methodl = ##class(%Dictionary.MethodDefinition).%New()
	set methodl.FormalSpec="pDocObj:"_input.messageType_",pSearchTable:"_input.name _""
		//W "1",!
	set methodl.Name = "OnIndexDoc"
	set methodl.ReturnType="%Status"
	set methodl.SqlProc=1
	set methodl.ClassMethod=1
		// W "1",!
	set imp = methodl.Implementation
	do imp.MoveToEnd()
	//set ^test=ob.Type
	IF (input.Type'="xml")
	{
		 WHILE itor.%GetNext(.key,.value)
	     {
		    
		    set nitor=value.%GetIterator()
		    if (value.%Get(0).nodeType="xml")
		    {
		      do imp.WriteLine("   set newxml"_key_"=##class(EnsLib.EDI.XML.Document).ImportFromString(pDocObj."_key_")")
		    
		    }else{
			    
			     do imp.WriteLine("   set JSON"_key_"={}.FromJSON(pDocObj."_key_")")
		       
			 }
		    while nitor.%GetNext(.keyn,.valuen)
		    {
			set Property=##class(%Dictionary.PropertyDefinition).%New()
		    set Property.Name=valuen.name
		    Do Property.Parameters.SetAt("EXACT","COLLATION")
		    do class.Properties.Insert(Property)
		    set index=##class(%Dictionary.IndexDefinition).%New()
		    set index.Name=valuen.name_"idx"
		    SET index.Properties=valuen.name
		    dO class.Indices.Insert(index)
		    
		      if (value.%Get(0).nodeType="xml")
		    {
		      do imp.WriteLine("   Set "_valuen.name_" = newxml"_key_".GetValueAt("""_valuen.path_""")")
		    do imp.WriteLine("   Set pSearchTable."_valuen.name_" = "_valuen.name_"")
		    
		    }else{
			    
			    
			    set str=""
		    set templ=$l(valuen.path,".")
		    set i=1
		    for i=1:1:templ
		    { 
			    set str=str_".%Get("""_$p(valuen.path,".",i)_""")"	    
		    }
			    
			    
			     do imp.WriteLine("   Set "_valuen.name_" = JSON"_key_str)
		          do imp.WriteLine("   Set pSearchTable."_valuen.name_" = "_valuen.name_"")
		       
			 }
		    
		     
			    
			}
		     
			
		   
	    }
	     
	}else{ 
	     do imp.WriteLine("   set newxml=pDocObj")
	     WHILE itor.%GetNext(.key,.value)
	     {
			set Property=##class(%Dictionary.PropertyDefinition).%New()
		    set Property.Name=value.name
		    Do Property.Parameters.SetAt("EXACT","COLLATION")
		    do class.Properties.Insert(Property)
		    set index=##class(%Dictionary.IndexDefinition).%New()
		    set index.Name=value.name_"idx"
		    SET index.Properties=value.name
		    dO class.Indices.Insert(index)
		    do imp.WriteLine("   Set "_value.name_" = newxml.GetValueAt("""_value.path_""")")
		    do imp.WriteLine("   Set pSearchTable."_value.name_" = "_value.name_"")
	    }
		
	}
	
	do imp.WriteLine("   Quit $$$OK")
	Do class.Methods.Insert(methodl)
	Do class.%Save()
	w "/*"
     Do $System.OBJ.Compile(input.name)
    w "*/"
    	
	}catch e{
			
    }

		 Quit $$$OK
		///Property
}

}
