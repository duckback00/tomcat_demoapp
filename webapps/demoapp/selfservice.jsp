<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"       "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*,java.net.*" %>

<%@ include file="self_classes.jsp" %>

<%
String sessionid = "";
if (request.getParameter("sessionid") == null) {
   //session.invalidate();
   sessionid = UUID.randomUUID().toString();
} else {
   sessionid = (String) request.getParameter("sessionid");
}

//
// Defaults ...
//
String newVDB = "VBITT";
String mountPath = "/mnt/provision";
String delphixGroup = "Oracle_Target";
String envName = "Linux Host";
String envInstance = "/u01/app/oracle/product/11.2.0.4/db_1";
String configTpl = "200M";
String archLog = "false";
/*
String newVDB = "mssql1";
String mountPath = "";
String delphixGroup = "Windows_Target";
String envName = "Window Target";
String envInstance = "MSSQLSERVER";
String configTemplate = "";
String archiveLog = "";
*/

//
// No changes required below here ...
//
if (session.getAttribute("vname") == null) { session.setAttribute("vname",newVDB); }
if (session.getAttribute("mntPath") == null) {  session.setAttribute("mntPath",mountPath); }
if (session.getAttribute("dpxGrp") == null) { session.setAttribute("dpxGrp",delphixGroup); }
if (session.getAttribute("envNm") == null) { session.setAttribute("envNm",envName); }
if (session.getAttribute("envInst") == null) { session.setAttribute("envInst",envInstance); }
if (session.getAttribute("configTemplate") == null) { session.setAttribute("configTemplate",configTpl); }
if (session.getAttribute("archiveLog") == null) { session.setAttribute("archiveLog",archLog); }


newVDB = (String)session.getAttribute("vname");
mountPath = (String)session.getAttribute("mntPath");
delphixGroup = (String)session.getAttribute("dpxGrp");
envName = (String)session.getAttribute("envNm");
envInstance = (String)session.getAttribute("envInst");
configTpl = (String)session.getAttribute("configTemplate");
archLog = (String)session.getAttribute("archiveLog");

   //PrintWriter requestOutput=response.getWriter();

   String path = application.getRealPath("/").replace('\\', '/');
   String lchar = path.substring(path.length() - 1); 
   if ( ! lchar.equals("/") ) {
      path = path + "/";
   }
   // ... or ... path = getServletContext().getRealPath("/").replace('\\', '/');
   //out.println("Path "+path+"<br />");

   String jsonpath = path+"jsonfiles"+File.separator;
   String jsonFile = "delphix_platforms.json";

   //
   // Page Banner ...
   //
   String ban = "<center><table border=0 style=\"background-color:black;width:100%;\">\n";
   ban = ban + "<tr><td style=\"padding-left:100px;\" width=\"30%\" align=\"center\" valign=\"top\"><a href=\"index.jsp?sessionid="+sessionid+"\"><image src=\"img/delphix-logo-white.png\" border=0 /></a></td>\n";
//   ban = ban + "<td align=\"center\" width=\"140\" valign=\"middle\">Delphix Rocks</td>\n";
   ban = ban + "<td align=\"left\" valign=\"bottom\"><span style=\"padding-left:10px;font-size:14pt;\"><font color=\"#1AD6F5\">API Demo Application</font></span></td>\n";
   ban = ban + "</tr>\n";
//msg = "Hello <b>"+usr+"</b>!";
   //if (msg != null) {
   //  ban = ban + "<tr style=\"background-color:white;width:100%;\"><td align=\"right\" style=\"color:blue;\"><i>:System Message:</i></td><td colspan=2>"+msg+"</td></tr>\n";
   //}
   ban = ban + "</table></center>\n";

   //
   // Application Variables ...
   //
   String str = "";

   String enginename = "";
   String enginetype = "";
   String protocol = "";
   String hostname = "";
   String username = "";
   String userpwd = "";
   String baseurl = "";
   String dlpxtype = "";
   String parent = "";

   String engine = "";
   engine = (request.getParameter("engine") != null) ? request.getParameter("engine") : "";

   String dbname = "";
   dbname = (request.getParameter("dbname") != null) ? request.getParameter("dbname") : "";
 
   String action = "";
   action = (request.getParameter("action") != null) ? request.getParameter("action") : "";

   // 
   // Report Title dbname and action ...
   //
   String rpt_title = "<span style=\"font-family:Arial,sans-serif; font-size:18px; font-weight:bold;\"> dSource or VDB <font color=blue><b>"+dbname+"</b></font> ... Action  <font color=blue><b>"+action+"</b></font></span>";

   String enabled = "";
   String runtimestatus = "";

   String job = "";

   String jobstate = "";
   String percentcomplete = "";

   String jobcolor = "lightyellow";
   String bgcolor = "lightyellow";

   /////////////////////////////////////////////////////////////
   // Let the fun begin ...
 
   //
   // Method Test ...
   //
   //out.println( doCommand("pwd") );
   //out.println("<hr />");

   //
   // JSON Parser ...
   //
   JSONParser parser = new JSONParser();
   boolean isValid;

   ////////////////////////////////////////////////////////////
   // HTML Output ...

%>
<html>
<head>
<title>Delphix Rocks</title>
<style>
table { border-collapse: collapse; width: 350px; }
table, th, td { text-align:center; padding:2px; border:1px ridge black; }
</style>
<style>
.accordion {
    background-color: #eee;
    color: #444;
    cursor: pointer;
    padding: 2px;
    width: 100%;
    border: none;
    text-align: left;
    outline: none;
    font-size: 15px;
    transition: 0.4s;
}
.active, .accordion:hover {
    background-color: #ccc; 
}
.panel {
    padding: 0 18px;
    display: none;
    background-color: white;
    overflow: hidden;
}
</style>
<link href="./bootstrap/css/bootstrap1.min.css" rel="stylesheet" media="screen"/>
<link href="./css/demoapp.css" rel="stylesheet" media="screen"/>
<link href="./bootstrap/css/bootstrap-responsive.min.css" rel="stylesheet" media="screen"/>
<script>
function f_open() {
   var win = window.open('provision.jsp', 'authWindow','toolbar=yes,scrollbars=yes,resizable=yes,top=100,left=200,width=640,height=480')
} 
var newVDB = "VBITT2";
var mountPath = "/mnt/provision";
var delphixGroup = "Oracle_Target";
var envName = "Linux Host";
var envInstance = "/u01/app/oracle/product/11.2.0.4/db_1";
var configTemplate = "200M";
var archiveLog = "false";
function HandlePopupResult(vname,mntPath,dpxGrp,envNm,envInst) {
    //alert("result of popup is: " + result);
    newVDB=vname;
    mountPath=mntPath;
    delphixGroup=dpxGrp;
    envName=envNm;
    envInstance=envInst;
    configTemplate;
    archiveLog;
    //alert ("Handler: " + newVDB);
}

</script>
</head>
<body bgcolor="white"; border="3px">
<center>
<%=ban%>

<form name="form0" method="post" action="">
<input type="hidden" name="sessionid" value="<%=sessionid%>" />

<%
if (engine.equals("")) {
%>
<fieldset>
<legend>Platforms</legend>

Select Delphix Platform: 
<select name="engine" onchange="this.form.submit()">
<option value=""></option>
<%
   //
   // Engines ...
   //
   str = doCommand("cat "+jsonpath+jsonFile);
   out.println(str);

   isValid = isJSONValid(str);
   if (isValid) {
      Object obj = parser.parse(str);
      JSONObject jsonObject = (JSONObject) obj;
      JSONArray jarr = (JSONArray) jsonObject.get("engines");
      for (int i=0; i < jarr.size(); i++) {
         JSONObject pobj = (JSONObject) jarr.get(i);
         // out.println(i);
         // Long id = (Long) pobj.get("employee_id");
         enginename = (String) pobj.get("enginename");
         enginetype = (String) pobj.get("enginetype");
         if (enginetype.equals("Virtualization")) {
            if ( engine.equals(enginename) ) {
               protocol = (String) pobj.get("protocol");
               hostname = (String) pobj.get("hostname");
               username = (String) pobj.get("username");
               userpwd = (String) pobj.get("password");
               baseurl = protocol + "://" + hostname + "/resources/json/delphix";
               //out.println("enginename: "+enginename+" baseurl: "+baseurl+"<br />");
%>
   <option value="<%=enginename%>" selected><%=enginename%></option>
<%
            } else { 
%>
   <option value="<%=enginename%>"><%=enginename%></option>
<%
            }	// end if enginename ...
         } 	// end if enginetype ...
      }		// end for loop ...

   } else {
      out.println("Error: Invalid JSON String "+str+"<br />");
   }	// end if isValid ...
   //out.println("<hr />");
%>
</select>
</fieldset>
</form>

<%
}		// end if engine.equals ...
///out.println("Engine: "+engine+"<br />");
%>

<form name="form1" method="post" action="">
<input type="hidden" name="engine" value="<%=engine%>" />
<%
if ( ! engine.equals("") ) {
%>

<fieldset>
<legend>Databases</legend>
<%
   //
   // Databases ...
   //
   str = doCommand(path+"api/get_databases_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\"");
   //out.println(str);

/*
   JSONObject jobj = (JSONObject) parser.parse(str);
   JSONArray jarr1 = (JSONArray) jobj.get("result");
out.println("len: "+jarr1.size()+"<br />");
for (int i = 0; i < jarr1.size(); ++i) {
   JSONObject rec = (JSONObject) jarr1.get(i);
   String zdbname = (String) rec.get("name");
   //int id = rec.getInt("id");
   // ...
}   
*/

String strdb = str;
//str="[\"orcl\",\"VBITT\"]";
      //JSONArray jarr1 = (JSONArray) parser.parse(str);

%>
Select dSource or VDB: <select name="dbname" onchange="this.form.submit()">
<option value=""></option>
<%
   isValid = isJSONValid(str);
   if (isValid) {
      JSONObject jobj = (JSONObject) parser.parse(str);
      JSONArray jarr1 = (JSONArray) jobj.get("result");
      for (int i=0; i < jarr1.size(); i++) {
         JSONObject rec = (JSONObject) jarr1.get(i);
         String zdbname = (String) rec.get("name");
         //out.println(dbname); 
         if (dbname.equals(zdbname)) {
            dlpxtype = (String) rec.get("type");
            parent = (String) rec.get("provisionContainer"); 
            out.println("type: "+dlpxtype+"  parent: "+parent+"<br />");
%>
         <option value="<%=zdbname%>" selected><%=zdbname%></option> 
<%      
         } else {
%>    
         <option value="<%=zdbname%>"><%=zdbname%></option>  
<%
         } 	// end if dbname ...
      }		// end of for ...

   } else {
      out.println("Error: Invalid JSON String "+str+"<br />");
   } 	// end if isValid ...
%>
</select>

<br />
<span class="accordion"><font color=grey>Expand/Collapse Databases Info</font></span>
<div class="panel" style="text-align:left;">
<pre><%=strdb%></pre>
</div>

</fieldset>
</form>
<br />

<form name="form2" method="post" action="">
<input type="hidden" name="engine" value="<%=engine%>" />
<input type="hidden" name="dbname" value="<%=dbname%>" />

<%
if ( ! dbname.equals("") ) {
%>

<fieldset>
<legend>Init and Operations</legend>

<input type="radio" name="action" value="status" <% if (action.equals("status")) { out.println("checked"); } %> /> 
status &nbsp;<font color=grey>|</font>&nbsp;

<%
if ( parent != null) { 
%>
<input type="radio" name="action" value="start" <% if (action.equals("start")) { out.println("checked"); } %> /> 
start &nbsp;<font color=grey>|</font>&nbsp;

<input type="radio" name="action" value="stop" <% if (action.equals("stop")) { out.println("checked"); } %> /> 
stop &nbsp;<font color=grey>|</font>&nbsp;
<%
}
%>
<input type="radio" name="action" value="enable" <% if (action.equals("enable")) { out.println("checked"); } %> /> 
enable &nbsp;<font color=grey>|</font>&nbsp;

<input type="radio" name="action" value="disable" <% if (action.equals("disable")) { out.println("checked"); } %> /> 
disable &nbsp;<font color=grey>|</font>&nbsp;

<input type="radio" name="action" value="delete" <% if (action.equals("delete")) { out.println("checked"); } %> /> 
delete &nbsp;&nbsp;&nbsp;<font color=grey>||</font>&nbsp;&nbsp;&nbsp;

<!--- /fieldset> <br /> <fieldset> <legend>Operations</legend --->
<%
if ( dlpxtype.equals("MSSqlDatabaseContainer") && parent == null ) {
   // MSSqlExistingMostRecentBackupSyncParameters
%>
<input type="radio" onclick="alert('Only Supports MSSqlExistingMostRecentBackupSyncParameters');" name="action" value="sync" <% if (action.equals("sync")) { out.println("checked"); } %> /> 
<%
} else {
%>
<input type="radio" name="action" value="sync" <% if (action.equals("sync")) { out.println("checked"); } %> />
<%
}
%>
sync 

<%
if ( parent != null) {          
%>
 &nbsp;<font color=grey>|</font>&nbsp;
<input type="radio" name="action" value="rollback" <% if (action.equals("rollback")) { out.println("checked"); } %> /> 
rollback &nbsp;<font color=grey>|</font>&nbsp;

<input type="radio" name="action" value="refresh" <% if (action.equals("refresh")) { out.println("checked"); } %> /> 
refresh  
<%
}

//out.println("type: "+dlpxtype+" ");
if ( dlpxtype.equals("OracleDatabaseContainer") || dlpxtype.equals("MSSqlDatabaseContainer") ) {
%>
 &nbsp;<font color=grey>|</font>&nbsp;
<input onclick="f_open()" type="radio" name="action" value="provision" <% if (action.equals("provision")) { out.println("checked"); } %> />
provision
<%
}
%>

</fieldset>
<br />

<input type="submit" name="submit" value="Submit" onclick="return confirm('Confirm --- '+ document.querySelector('input[name=action]:checked').value+' --- Request?')" />

<br />
<font size=-1><font color=blue>Note: Jobs take a few moments to start after being submitted.</font></font>
</form>

<hr color=teal size=2 />

<%
// 
// Process Request ...
//
if ( ! dbname.equals("") && ! action.equals("") ) {

   if ( ! action.equals("sync") && ! action.equals("rollback") && ! action.equals("refresh") && ! action.equals("provision") ) {
      // 
      // VDB Init ...
      //
      str = doCommand(path+"api/vdb_init_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" "+action+" \""+dbname+"\"");
      out.println(str+"<br />");
      isValid = isJSONValid(str);
      if (isValid) {
         // 
         // Status ...
         //
         if ( action.equals("status") ) {
            JSONObject jsonObj1 = (JSONObject) parser.parse(str);
            if ( (String) jsonObj1.get("Enabled") != null && (String) jsonObj1.get("RuntimeStatus") != null ) {
               enabled = (String) jsonObj1.get("Enabled");
               runtimestatus = (String) jsonObj1.get("RuntimeStatus");
            } else {
               out.println("Error: Missing Keys in JSON String "+str+"<br />");
               enabled = "missing key";
               runtimestatus = "missing key";
            }
            //out.println(enabled + " " + runtimestatus);
            //out.println("<hr />");
            String encolor = "lightyellow";
            String runcolor = "lightyellow";
            if ( enabled.equals("DISABLED")) { encolor="lightpink"; }
            if ( enabled.equals("ENABLED")) { encolor="lightgreen"; }
            if ( runtimestatus.equals("INACTIVE")) { runcolor="lightpink"; }
            if ( runtimestatus.equals("RUNNING")) { runcolor="lightgreen"; }
%>

<%=rpt_title%>

<table class="tid">
<tr><th>Enabled</th><th>RuntimeStatus</th></tr>
<tr>
   <td style="background-color:<%=encolor%>;"><%= enabled %></td>
   <td style="background-color:<%=runcolor%>;"><%= runtimestatus %></td>
</tr>
</table>
<%

         } else {

            // 
            // All other init commands ...
            //
            JSONObject jsonObj1 = (JSONObject) parser.parse(str);
            if ( (String) jsonObj1.get("job") != null ) {
               job = (String) jsonObj1.get("job");
            } else { 
               out.println("Error: Missing Job Key "+str+"<br />");
               job = "";
            }
            //out.println(job);
            //out.println("<hr />");
         } 	// end if action ...

      } else {
         out.println("Error: Invalid JSON String "+str+"<br />");
      }   	// end if isValid ...

   } else { 

      // 
      // VDB Operations ...
      //
      // Provision ...
      //
      if ( action.equals("provision")) {
 
/*
         out.println("provision "+dbname+" comming soon ...<br />");
         out.println("1 "+newVDB+"<br />");
         out.println("2 "+mountPath+"<br />");
         out.println("3 "+delphixGroup+"<br />");
         out.println("4 "+envName+"<br />");
         out.println("5 "+envInstance+"<br />");
         out.println("6 "+configTpl+"<br />");
         out.println("7 "+archLog+"<br />");

/Users/abitterman/tomcat/webapps/demoapp/api/provision_sqlserver_tc.sh "/Users/abitterman/tomcat/webapps/demoapp/jsonfiles/delphix_platforms.json" "Mac" "delphix_demo" "Vdelphix_demo" "Windows_Target" "Windows Host" "MSSQLSERVER"

*/
         String cmd = "";
         if ( dlpxtype.equals("OracleDatabaseContainer") ) {
            cmd = path+"api/provision_oracle_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" \""+dbname+"\" \""+newVDB+"\" \""+delphixGroup+"\" \""+envName+"\" \""+envInstance+"\" \""+mountPath+"\" \""+configTpl+"\" \""+archLog+"\"";
         }
         if ( dlpxtype.equals("MSSqlDatabaseContainer") ) {
            cmd = path+"api/provision_sqlserver_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" \""+dbname+"\" \""+newVDB+"\" \""+delphixGroup+"\" \""+envName+"\" \""+envInstance+"\"";
         }
         //out.println("cmd: "+cmd+"<br />");

         if ( dlpxtype.equals("OracleDatabaseContainer") || dlpxtype.equals("MSSqlDatabaseContainer") ) {
            str = doCommand(cmd);
            //out.println(str+"<br />");
            isValid = isJSONValid(str);
            if (isValid) {
               JSONObject jsonObj2 = (JSONObject) parser.parse(str);
               if ( (String) jsonObj2.get("job") != null ) {
                  job = (String) jsonObj2.get("job");
               } else {
                  out.println("Error: Missing Job Key "+str+"<br />");
                  job = "";
               }
               //out.println(job);
               //out.println("<hr />");
            } else {
               out.println ("Error: Invalid JSON String "+str+"<br />");
               job = "";
            }
         } else { 
            out.println ("Warning: Code for MS SQL Server or Oracle Provisioning ...<br />");
            job = "";
         }      // end if dlpxtype ...

      } else { 

         //
         // Sync, Rollback, Refresh ...
         // 
         String cmd = path+"api/vdb_operations_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" "+action+" \""+dbname+"\"";
         out.println("cmd: "+cmd+"<br />");
         str = doCommand(cmd);
         out.println(str+"<br />");
         isValid = isJSONValid(str);
         if (isValid) {
            JSONObject jsonObj2 = (JSONObject) parser.parse(str);
            if ( (String) jsonObj2.get("job") != null ) {
               job = (String) jsonObj2.get("job");
            } else {
               out.println("Error: Missing Job Key "+str+"<br />");
               job = "";
            }
            //out.println(job);
            //out.println("<hr />");
         } else { 
            out.println ("Error: Invalid JSON String "+str+"<br />");
         }
      } 	//end if provision ...

   }		// end if action ...

   // 
   // Job ...
   //
   if ( ! action.equals("status") ) {

      str = doCommand("sleep 1");

      //out.println(path+"api/job_status_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" "+job+"<br />");
      str = doCommand(path+"api/job_status_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" "+job+"");
      //out.println(str+"<br />");

      if ( job != "" ) {
         isValid = isJSONValid(str);
         if (isValid) {
            JSONObject jsonObj3 = (JSONObject) parser.parse(str);
            if ( (String) jsonObj3.get("JobState") != null && (String) jsonObj3.get("PercentComplete") != null ) {
               jobstate = (String) jsonObj3.get("JobState");
               percentcomplete = (String) jsonObj3.get("PercentComplete");
            } else {
               out.println("Error: Missing Job Key "+str+"<br />");
               jobstate = "missing"; 
               percentcomplete = "missing"; 
            }
            //out.println(jobstate+" "+percentcomplete);
            //out.println("<hr />");
         } else {
            out.println("Error: Invalid JSON String "+str+"<br />");
         }
      } else { 
         out.println("Error: Missing Job "+job+"<br />");
      }
      //str = getJob(job);
      //out.println("Job: "+str+"<br />");

      String urlengine = URLEncoder.encode(engine,"UTF-8");
%>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<script>
   auto = setInterval(    function refresh() {
      //alert ('<%=job%>');
      //alert ('<%=urlengine%>');
      $("#result").load("get_job.jsp?engine=<%=urlengine%>&job=<%=job%>");
   }, 5000); // 10s  refresh every 5000 milliseconds
   refresh();
</script>

<%=rpt_title%>

<!-- This div is dynamically updated --> 
<div id="result">
<table class="tid">
<tr><th>JobNo</th><th>Job State</th><th>% Complete</th></tr>
<tr>
   <td><%= job %></td>
   <td id=jobstate style="background-color:<%=jobcolor%>"><%= jobstate %></td>
   <td id="pc" style="background-color:<%=bgcolor%>"><%= percentcomplete %>%</td>
</tr>
</table>
</div>

<script>
// One Time Click Color Change ...
var color_count = 1;
function setColor(btn) {
   var property = document.getElementById(btn);
   if (color_count == 1) {
      property.style.backgroundColor = "#FFBBBB"
      property.innerHTML = "Refreshing Stopped"
      color_count = 0;
   }
}
</script>
<button id="button" onclick="clearInterval(auto);setColor('button')">Stop Updating Job Status</button>

<%
			//alert ('Refresh Stop Done');
   } 		// end if ! status 
} 		// end if dbname and action ...


}       // end if dbname ...
%>

<script>
var acc = document.getElementsByClassName("accordion");
var i;

for (i = 0; i < acc.length; i++) {
    acc[i].addEventListener("click", function() {
        this.classList.toggle("active");
        var panel = this.nextElementSibling;
        if (panel.style.display === "block") {
            panel.style.display = "none";
        } else {
            panel.style.display = "block";
        }
    });
}
</script>

<%
} 	// end if engine ...
%>
</center>
</body>
</html>
