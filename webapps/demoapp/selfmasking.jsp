<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
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

String sqlSchema = "";
String dboSchema = "";     	// required for SQL Server 
String url = "";
String username = "";
String password = "";
String connUrl = "";

String dbType = "";
if (request.getParameter("dbType") != null) {
   dbType = request.getParameter("dbType");
   session.setAttribute("dbType",dbType);
}

String dbSources = (request.getParameter("dbSources") != null) ? request.getParameter("dbSources") : "";

if (dbSources.equals("")) {
   dbSources="mssql_source,mssql_target,mssql_target2,oracle_source,oracle_target,oracle_target2";
}

String dataSource = (request.getParameter("dataSource") != null) ? request.getParameter("dataSource") : "";

if ( ! dataSource.equals("") && dbType.equals("") ) {
   String[] dtarr = dataSource.split("_");
   dbType = dtarr[0].toLowerCase();
   session.setAttribute("dbType",dbType);
}

String profileSet = (request.getParameter("profileSet") != null) ? request.getParameter("profileSet") : "";

String submit = (request.getParameter("submit") != null) ? request.getParameter("submit") : "";

/*
out.println("dbType: "+dbType+"<br />");
out.println("dbSources: "+dbSources+"<br />");
out.println("dataSource: "+dataSource+"<br />");
out.println("submit: "+submit+"<br />");
*/

// 
// ...
// 
if ( ! submit.equals("") && ! submit.equals("Login") ) {

if ( ! dataSource.equals("") ) {
%>
<%@ include file="read_one.jsp" %>
<%
} else {
   out.println("Error: Missing dataSource "+dataSource+" ... <br />");
}

/*
   out.println("database: "+sqlSchema+"<br />");
   out.println("schema: "+dboSchema+"<br />");
   out.println("connUrl: "+connUrl+"<br />");
   out.println("username: "+username+"<br />");
   out.println("password: "+password+"<br />");
*/

   session.setAttribute("connUrl",connUrl);
   session.setAttribute("dboSchema",dboSchema);
   session.setAttribute("sqlSchema",sqlSchema);
   session.setAttribute("username",username);
   session.setAttribute("password",password);

   //username = (String)session.getAttribute("username");
   //password = (String)session.getAttribute("password");
   //connUrl = (String)session.getAttribute("connUrl");

} 

//
// Defaults ...
//

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
   ban = ban + "<tr><td style=\"padding-left:150px;\" width=\"30%\" align=\"center\" valign=\"top\"><a href=\"index.jsp?sessionid="+sessionid+"\"><image src=\"img/delphix-logo-white.png\" border=0 /></a></td>\n";
//   ban = ban + "<td align=\"center\" width=\"140\" valign=\"middle\">Delphix Rocks</td>\n";
   ban = ban + "<td align=\"right\" valign=\"bottom\"><span style=\"padding-right:150px;font-size:18pt;\"><font color=\"#1AD6F5\">Masking API Demo</font></span></td>\n";
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
   String usernam = "";
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

   String tables = "";
   tables = (request.getParameter("tbl") != null) ? request.getParameter("tbl") : "";

   // 
   // Report Title dbname and action ...
   //
   String rpt_title = "<span style=\"font-family:Arial,sans-serif; font-size:18px; font-weight:bold;\">Action  <font color=blue><b>"+action+"</b></font></span>";

   String enabled = "";
   String runtimestatus = "";

   String job = "";

   String jobstate = "";
   String startTime = ""; 
   String rowsMasked = "";
   String rowsTotal = "";
   String endTime = "";

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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"       "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Delphix Rocks</title>
<link href="./bootstrap/css/bootstrap1.min.css" rel="stylesheet" media="screen"/>
<link href="./css/demoapp.css" rel="stylesheet" media="screen"/>
<!-- link href="./bootstrap/css/bootstrap-responsive.min.css" rel="stylesheet" media="screen"/ -->
<style>
table { border-collapse: collapse; width: 600px; }
table, th, td { padding-left:4px; padding-top:2px; padding-bottom:2px; border:1px ridge black; }
textarea { font-family: inherit; font-size: 10pt; }
</style>
<script type="text/javascript">
function isCheck() {
   if (document.querySelector('input[name="action"]:checked') == null) {
      window.alert("You need to choose an Action option!");
      return false;
   } else {
      return confirm('Confirm Run '+ document.querySelector('input[name=action]:checked').value+' Request?');
   }
}
</script>
</head>
<body bgcolor="white"; border="3px">
<center>
<%=ban%>

<table>

<form name="form0" method="post" action="">
<input type="hidden" name="sessionid" value="<%=sessionid%>" />
<input type="hidden" name="dbSources" value="<%=dbSources%>" />
<%
if (! engine.equals("")) {
   out.println("<input type=\"hidden\" name=\"engine\" value=\""+engine+"\" />");
}
%>

<legend>Profiling and Masking Job</legend>

<tr>
<td align="right">Masking Platform: </td>
<td align="left" style="padding-top:2px;padding-left:8px;">

<%
if ( engine.equals("") ) {
%>

<select name="engine" onchange="this.form.submit()">
<option value=""></option>

<%
}	// end if engine.equals ...

   //
   // Engines ...
   //
   str = doCommand("cat "+jsonpath+jsonFile);
   //out.println(str);

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
         if (enginetype.equals("Masking")) {
            if ( engine.equals(enginename) ) {
               protocol = (String) pobj.get("protocol");
               hostname = (String) pobj.get("hostname");
               usernam = (String) pobj.get("username");
               userpwd = (String) pobj.get("password");
               baseurl = protocol + "://" + hostname + "/resources/json/delphix";
               //out.println("enginename: "+enginename+" baseurl: "+baseurl+"<br />");
if (engine.equals("")) {
%>
   <option value="<%=enginename%>" selected><%=enginename%></option>
<%
} else {
   out.println(enginename);
}
            } else { 
if (engine.equals("")){
%>
   <option value="<%=enginename%>"><%=enginename%></option>
<%
}  	// end if engine.equals ...

            }	// end if enginename ...
         } 	// end if enginetype ...
      }		// end for loop ...

   } else {
      out.println("Error: Invalid JSON String "+str+"<br />");
   }	// end if isValid ...
   //out.println("<hr />");

if ( engine.equals("") ) {
%>
</select>
<%
} 	// end if engine.equals ...
%>
</td>
</tr>

<!-- tr>
<td align="right">Database: </td>
<td align="left"><%=dbType %></td>
</tr -->

<tr>
<td align="right">Select dataSource: </td>
<td align="left" style="padding-top:14px;padding-left:8px;">
<select name="dataSource">
<%
if (! dbSources.equals("")) {
   String[] dbarr = dbSources.split(",");
   for( int i = 0; i < dbarr.length; i++) {
      String s = dbarr[i];
      out.println("<option value="+s);
      if ( s.equals(dataSource) ) { out.println(" selected"); }
      out.println(">"+s+"</option>"); 
   }
}
%>
</select>
</td>
</tr>

<!-- tr>
<td align="right">Connection URL: </td>
<td align="left"><%=connUrl %></td>
</tr -->

<!-- tr>
<td align="right">Schema: </td>
<td align="left"><%=sqlSchema %></td>
</tr -->

<tr>
<td align="right">Select Tables: </td>
<td align="left" style="padding-top:14px;padding-left:8px;">
<select name="tbl">
<%
out.println("<option value=\"EMPLOYEES\"");
if ( tables.equals("EMPLOYEES")) { out.println(" selected"); }
out.println(">EMPLOYEES</option>");
out.println("<option value=\"MEDICAL_RECORDS,PATIENT,PATIENT_DETAILS\"");
if ( tables.equals("MEDICAL_RECORDS,PATIENT,PATIENT_DETAILS")) { out.println(" selected"); }
out.println(">MEDICAL</option>"); 
%>
</select>
</td>
</tr>

<tr>
<td align="right">Select Profile Set: </td>
<td align="left" style="padding-top:14px;padding-left:8px;">
<select name="profileSet">
<%
out.println("<option value=\"Financial\"");
if ( profileSet.equals("Financial")) { out.println(" selected"); }
out.println(">Financial</option>");
out.println("<option value=\"HIPAA\"");
if ( profileSet.equals("HIPAA")) { out.println(" selected"); }
out.println(">HIPAA</option>");
%>
</select>
</td>
</tr>

<tr>
<td align="right">Action: </td>
<td align="left" style="padding-top:2px;padding-left:8px;"> 
<input id="RadioBtn" type="radio" name="action" value="Profile" 
<%
   if (action.equals("Profile")) { out.print(" checked"); }
%>
/>
Profile Only 
&nbsp;&nbsp;<font color=grey>|</font>&nbsp;&nbsp;
<input id="RadioBtn" type="radio" name="action" value="ProfileMask" 
<%
   if (action.equals("ProfileMask")) { out.print(" checked"); }
%>
/>
Profile and Mask 
</td>
</tr>

</table>

</fieldset>

<br />
<input type="submit" name="submit" value="Submit" onclick="return isCheck();" />
<br />
<font size=-1><font color=blue>Note: Jobs take a few moments to start after being submitted.</font></font>
</form>

<hr color=teal size=2 />

<%

// 
// Process Request ...
//
if ( ! engine.equals("") && ! action.equals("") ) {

   //out.println("Action: "+action+"<br />");

   // 
   // Build Masking Stuff ...
   //
/*

database: orcl
connUrl: jdbc:oracle:thin:@172.16.160.133:1521/orcl
username: delphixdb
password: delphixdb

profileSet
PSNAME="${#}"

tables
TBL="${#}"
*/

   String conn = "";
   if (dbType.equals("oracle")) { 
      String uarr[] = connUrl.split("@");
      String harr[] = uarr[1].split(":");
      String parr[] = harr[1].split("/");

      conn = "[{";
      conn = conn + "  \"username\": \""+username.toUpperCase()+"\",";
      conn = conn + "  \"password\": \""+password+"\",";
      conn = conn + "  \"databaseType\": \""+dbType.toUpperCase()+"\",";
      conn = conn + "  \"host\": \""+harr[0]+"\",";
      conn = conn + "  \"port\": "+parr[0]+",";
      conn = conn + "  \"schemaName\": \""+username.toUpperCase()+"\",";
      conn = conn + "  \"profileSetName\": \""+profileSet+"\",";
      conn = conn + "  \"connNo\": 1,";
      conn = conn + "  \"sid\": \""+sqlSchema+"\"";
      conn = conn + "}]";
   } 

   if (dbType.equals("mssql")) {
      String uarr[] = connUrl.split("//");
      String harr[] = uarr[1].split(":");
      String parr[] = harr[1].split(";");

      conn = "[{";
      conn = conn + "  \"username\": \""+username+"\",";
      conn = conn + "  \"password\": \""+password+"\",";
      conn = conn + "  \"databaseType\": \""+dbType.toUpperCase()+"\",";
      conn = conn + "  \"host\": \""+harr[0]+"\",";
      conn = conn + "  \"port\": "+parr[0]+",";
      if (dboSchema.equals("")) { 
         dboSchema = "dbo";		// default schema ..
      }
      conn = conn + "  \"schemaName\": \""+dboSchema+"\",";
      conn = conn + "  \"profileSetName\": \""+profileSet+"\",";
      conn = conn + "  \"connNo\": 1,";
      conn = conn + "  \"databaseName\": \""+sqlSchema+"\",";     // sid 
      conn = conn + "  \"instanceName\": \"\"";
      conn = conn + "}]";
   }
   //out.println("Conn: "+conn+"<br />");

   String connFile=jsonpath+sessionid+".json";

   out.println("<b>Results</b><br />");
   // out.println("<a href=\"jsonfiles/"+sessionid+".json\" target=\"_blank\">Connection File</a><br />");

   //
   // Write Out New configuration ...
   //
   try {
      FileWriter file = new FileWriter(connFile);
      file.write(conn);
      file.flush();
      file.close();
   } catch (Exception e) {
      e.printStackTrace();
   }       // end try ...

   //                                                1                   2             3               4               5
   String cmd = path+"api/masking_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" \""+action+"\" \""+connFile+"\" \""+tables+"\"";
   //out.println(cmd+" <br />");

   str = doCommand(cmd);
   //out.println(str+"<br />");

//
// Profile Only ...
//
if ( action.equals("Profile") ) {
   //out.println(str+"<br />");

   isValid = isJSONValid(str);
   if (isValid) {

      //
      // All other init commands ...
      //
      JSONObject jsonObj5 = (JSONObject) parser.parse(str);
      if ( (String) jsonObj5.get("profile_execution_results") != null ) {
         job = (String) jsonObj5.get("profile_execution_results");
      } else {
         out.println("Error: Missing Job Key "+str+"<br />");
         job = "";
      }
      //out.println(job);
      //out.println("<hr />");
      out.println("Profile Execution Results Status: "+job+"<br />");

   } else {
         out.println("Error: Invalid JSON String "+str+"<br />");
   }    // end if isValid ...


}

//
// Profile and Masking ...
//
if ( action.equals("ProfileMask") ) {

   isValid = isJSONValid(str);
   if (isValid) {

      // 
      // All other init commands ...
      //
      JSONObject jsonObj1 = (JSONObject) parser.parse(str);
      if ( (String) jsonObj1.get("masking_execution_id") != null ) {
         job = (String) jsonObj1.get("masking_execution_id");
      } else { 
         out.println("Error: Missing Job Key "+str+"<br />");
         job = "";
      }
      //out.println(job);
      //out.println("<hr />");

   } else {
         out.println("Error: Invalid JSON String "+str+"<br />");
   }   	// end if isValid ...

   //out.println ("Masking Execution Id: "+job+"<br />");

   // 
   // Job ...
   //

//,{"executionId":336,"jobId":302,"status":"SUCCEEDED","rowsMasked":10,"rowsTotal":10,"startTime":"2018-05-14T04:50:23.378+0000","endTime":"2018-05-14T04:50:54.407+0000"}

///Users/abitterman/tomcat/webapps/demoapp/api/masking_status_tc.sh "/Users/abitterman/tomcat/webapps/demoapp/jsonfiles/delphix_platforms.json" "Mac2" "336" YES

      str = doCommand(path+"api/masking_status_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" "+job+"");
      //out.println(str+"<br />");

      if ( job != "" ) {
         isValid = isJSONValid(str);
         if (isValid) {
            JSONObject jsonObj3 = (JSONObject) parser.parse(str);
            if ( (String) jsonObj3.get("status") != null ) {
               jobstate = (String) jsonObj3.get("status");
               startTime = (String) jsonObj3.get("startTime");
               rowsMasked = "0";
               rowsTotal = "0";
               endTime = "";
            } else {
               out.println("Error: Missing Job Key "+str+"<br />");
               jobstate = "missing"; 
            }
            //out.println(jobstate+"<br />");
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
<script src="js/jquery.min.js"></script>
<script>
   auto = setInterval(    function refresh() {
      //alert ('<%=job%>');
      $("#result").load("masking_job.jsp?engine=<%=urlengine%>&job=<%=job%>");
   }, 5000); // 10s  refresh every 5000 milliseconds
   refresh();
</script>

<%=rpt_title%>

<!-- This div is dynamically updated --> 
<div id="result">
<table class="tid">
<tr>
<th>Exec<br />Id</th>
<th>Status</th>
<th>Row<br />Masked</th>
<th>Rows<br />Total</th>
<th>Start Time</th>
<th>End Time</th>
</tr>

<tr>
<td><%= job %></td>
<td id=jobstate style="background-color:<%=jobcolor%>"><%=jobstate%></td>
<td><%=rowsMasked%></td>
<td><%=rowsTotal%></td>
<td><%=startTime%></td>
<td><%=endTime%></td>
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

} 	// end if action masking

   out.println("<br />");
   out.println("<i>Report available after Profile Job completed Successfully</i><br />");
   //out.println("<a href=\"jsonfiles/inventory_job.out1\" target=\"_blank\">Inventory List</a><br />");
   out.println("<a href=\"jsonfiles/json.out1\" target=\"_blank\">Inventory Report (JSON)</a><br />");
   // 
   // HTML Inventory Report ...
   // 
   cmd = jsonpath+"report.sh \""+jsonpath+"json.out1\"";
   //out.println("CMD: "+cmd+"<br />");
   str = doCommand(cmd);
   //out.println(str+"<br />");
   out.println("<a href=\"jsonfiles/json.out1.html\" target=\"_blank\">Inventory Report (HTML)</a><br />");

} 		// end if engine and action ...

%>
</center>
</body>
</html>
