<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"       "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

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
   // Application Variables ...
   //
   //Random rand = new Random(); 
   //int val = rand.nextInt(999); 
   String timeStamp = new SimpleDateFormat("yyyy.MM.dd.HH.mm.ss").format(new Date());
   // out.println(timeStamp);

   String str = "";
   String msg = "";        // Process Request Returned Msg 

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

   String submit = "";
   submit = (request.getParameter("submit") != null) ? request.getParameter("submit") : "";

   String test = "";
   test = (request.getParameter("test") != null) ? request.getParameter("test") : "";

   //
   // Page Banner ...
   //
   String ban = "<center><table border=0 style=\"background-color:black;width:100%;\">\n";
   ban = ban + "<tr><td style=\"padding-left:100px;\" width=\"40%\" align=\"center\" valign=\"top\"><a href=\"index.jsp?sessionid="+sessionid+"\"><image src=\"img/delphix-logo-white.png\" border=0 /></a></td>\n";
//   ban = ban + "<td align=\"center\" width=\"140\" valign=\"middle\">Delphix Rocks</td>\n";
   ban = ban + "<td align=\"right\" valign=\"bottom\"><span style=\"padding-right:140px;font-size:18pt;\"><font color=\"#1AD6F5\">Delphix Platform Connections</font></span></td>\n";
   ban = ban + "</tr>\n";
//msg = "Hello <b>"+usr+"</b>!";
   //if (msg != null) {
   //  ban = ban + "<tr style=\"background-color:white;width:100%;\"><td align=\"right\" style=\"color:blue;\"><i>:System Message:</i></td><td colspan=2>"+msg+"</td></tr>\n";
   //}
   ban = ban + "</table></center>\n";

   String path = application.getRealPath("/").replace('\\', '/');
   String lchar = path.substring(path.length() - 1);
   if ( ! lchar.equals("/") ) {
      path = path + "/";
   }
   // ... or ... path = getServletContext().getRealPath("/").replace('\\', '/');
   //out.println("Path "+path+"<br />");

   String jsonpath = path+"jsonfiles"+File.separator;
   String jsonFile = "delphix_platforms.json";

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

   // 
   // Process Requests ...
   //

   //
   // Form Values ...
   //
   String ename = (request.getParameter("enginename") != null) ? request.getParameter("enginename") : "";
   String type = (request.getParameter("enginetype") != null) ? request.getParameter("enginetype") : "";
   String proto = (request.getParameter("protocol") != null) ? request.getParameter("protocol") : "";
   String host = (request.getParameter("hostname") != null) ? request.getParameter("hostname") : "";
   String usr = (request.getParameter("username") != null) ? request.getParameter("username") : "";
   String pwd = (request.getParameter("userpwd") != null) ? request.getParameter("userpwd") : "";

   //
   // Test Connection Button ...
   // 
   if ( ! test.equals("") && ! engine.equals("") ) { 
      if ( type.equals("Virtualization") ) {
         //out.println("Connection Test: "+path+"api/authentication_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\"<br />");
         str = doCommand(path+"api/authentication_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\"");
      } else if ( type.equals("Masking") ) {
         //out.println("Connection Test: "+path+"api/authmasking.sh "+jsonpath+jsonFile+" "+engine+"<br />");
         str = doCommand(path+"api/authmasking.sh \""+jsonpath+jsonFile+"\" \""+engine+"\"");
      } else {
         str = "Warning: No Engine Type Assigned "+type+" ... "; 
      }
      //out.println(str);
      msg = str;
   }		// end if test ...

   //
   // Process Submit Request ...
   //
   if ( ! submit.equals("")) {
      //out.println("Submit: "+submit+"<br />");

      // 
      // Read Config File ...
      //
      str = doCommand("cat "+jsonpath+jsonFile);
      //out.println(str);

      //
      // Parse Config JSON Data ...
      //
      int delidx = -1;
      String engchk = "New";
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

            // 
            // Check for Unique Name ...
            //
            if ( engine.equals(ename) ) {
               engchk = "Found";
            }
            // 
            // Found Engine Name for either Deleting or Updating ...
            //
            if ( engine.equals(enginename) ) {
               if ( submit.equals("Delete")) { delidx = i; }
               if ( submit.equals("Update")) {
                  pobj.put("enginetype",type);
                  pobj.put("protocol",proto);
                  pobj.put("hostname",host);
                  pobj.put("username",usr);
                  pobj.put("password",pwd);
                  msg = engine + " updated ...";
               }
            }

         }	// end for i=0 jarr ...

         //
         // Delete jarr index ...
         //
         if ( submit.equals("Delete")) { 
            jarr.remove(delidx); 
            msg = engine + " deleted ...";
            engine="";
         }

         // 
         // Add new record if name is unique ...
         // 
         if ( submit.equals("Add") ) {
            // 
            // Have Unique Name ...
            //
            if ( engchk.equals("New") ) {
               JSONObject js = new JSONObject();
               js.put("enginename",ename);
               js.put("enginetype",type);
               js.put("protocol",proto);
               js.put("hostname",host);
               js.put("username",usr);
               js.put("password",pwd);
               jarr.add(js);
               engine=ename;
               msg = engine + " added ...";
            } else {
               msg = "Error: " + engine + " name already Exists ...";
            }
         }	// end if add ...

         // 
         // Convert Object to String for Writing to File ...
         //
         String json = jsonObject.toString();
         //out.println("json: "+json+"<br />");

         // 
         // Write Out New configuration ...
         //
         str = doCommand("mv "+jsonpath+jsonFile+" "+jsonpath+jsonFile+"_"+timeStamp);
         //out.println(str);
         try {
            String configFilename = jsonpath+jsonFile;
            //File configFile = new File(configFilename);
            FileWriter file = new FileWriter(configFilename);
            file.write(json);
            file.flush();
            file.close();
            msg = msg + " config file saved";
         } catch (Exception e) {
            e.printStackTrace();
         }	// end try ...

      }		// end if str isValid ...

   }		// end if submit ...


   ////////////////////////////////////////////////////////////
   // HTML Output ...

%>
<html>
<head>
<title>Delphix Self Service Rocks</title>
<style>
body {
   padding-top: 20px;
   padding-bottom: 60px;
   margin: 0px;
}
table { border-collapse: collapse; width: 540px; }
table, th, td { padding:2px; border:1px ridge black; }
fieldset
{
  background-color:#EEEEEE;
  max-width:600px;
  padding:16px;	
}
legend
{
  margin-bottom:0px;
  margin-left:16px;
}
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
</head>
<body>
<center>

<%=ban%>

<h3>Delphix Dynamic Data Platform Configuration File</h3>


<fieldset>
<legend>System Messages</legend>
<%
//
// System Message ...
//
if ( ! msg.equals("") ) {
%>
   <span style="background-color:#eee;"><font color=blue>&nbsp;&nbsp;<i>:system message:</i> &nbsp;&nbsp; <%=msg%> &nbsp;&nbsp;</font></span>
<br />
<%
} else { out.println("<br />"); }
%>
</fieldset>
<br />

<form name="form0" method="post" action="">
<input type="hidden" name="sessionid" value="<%=sessionid%>" />

<fieldset>
<legend>Platforms</legend>

Select Delphix Platform:
<select name="engine" onchange="this.form.submit()">
<option value="">-- New Config --</option>
<%
   //
   // Engines ...
   //
   str = doCommand("cat "+jsonpath+jsonFile);
   //out.println(str);

   Writer writer = new JSONWriter(); // this writer adds indentation

String strdb = "";

   isValid = isJSONValid(str);
   if (isValid) {
      Object obj = parser.parse(str);
      JSONObject jsonObject = (JSONObject) obj;

jsonObject.writeJSONString(writer);
strdb = writer.toString();

      JSONArray jarr = (JSONArray) jsonObject.get("engines");
      for (int i=0; i < jarr.size(); i++) {
         JSONObject pobj = (JSONObject) jarr.get(i);
         // out.println(i);
         // Long id = (Long) pobj.get("employee_id");
         enginename = (String) pobj.get("enginename");

         if ( engine.equals(enginename) ) {
            enginetype = (String) pobj.get("enginetype");
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
         }

      }         // end for loop ...

   } else {
      out.println("Error: Invalid JSON String "+str+"<br />");
   }    // end if isValid ...
   //out.println("<hr />");

%>
</select>
<br />

<br />
<span class="accordion"><font color=grey>Expand/Collapse Engines Info</font></span>
<div class="panel" style="text-align:left;">
<pre>
<%
   //strdb
   out.println("Excluding Passwords ...");
   int count = 1;
   String[] lines = strdb.split("\\r?\\n");
   for (String line : lines) {
      if ( ! line.toLowerCase().contains("\"password\"") ) {
         out.println("" + count + " : " + line + "");
      } else { 
         out.println("" + count + " : " + "      \"password\": \"*******\","); 
      }
      count++;
   }
%>
</pre>
</div>

</fieldset>
</form>
<br />

<form name="form1" method="post" action="">
<input type="hidden" name="engine" value="<%=engine%>" />
<fieldset>
<legend>Parameters</legend>

<table>
<tr><th colspan=2>Configure Delphix Platform</th></tr>

<tr>
<td align="right">Engine Name: </td>
<td align="left"> <input size=30 type="text" name="enginename" value="<%=engine%>" />
&nbsp;&nbsp;
<input type="submit" name="test" value="Test" onclick="this.form.submit();" />
<font color=blue><font size=-1>(Saved Configs Only)</font></font>
</td>
</tr>

<tr>
<td align="right">Engine Type: </td>
<td align="left"> 
&nbsp;&nbsp; 
<input type="radio" name="enginetype" value="Virtualization" 
<% 
if ( enginetype.equals("Virtualization")) {
%>
 checked  
<%
}
%>
/>
Virtualization
&nbsp;&nbsp;
<input type="radio" name="enginetype" value="Masking" 
<%  
if ( enginetype.equals("Masking")) { 
%> 
 checked 
<%
}
%>
/>
Masking
</td>
</tr>

<tr>
<td align="right">Protocol: </td>
<td align="left"> <input size=30 type="text" name="protocol" value="<%=protocol%>" /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<font color=blue><font size=-1>(http or https)</font></font>
</td>
</tr>

<tr>
<td align="right">Hostname: </td>
<td align="left"> 
<input size=30 type="text" name="hostname" value="<%=hostname%>" />
&nbsp;&nbsp;
<font color=blue><font size=-1>(for Masking include :[port]/dmsuite/)</font></font>
</td>
</tr>

<tr>
<td align="right">Username: </td>
<td align="left"> <input size=30 type="text" name="username" value="<%=username%>" /></td>
</tr>

<tr>
<td align="right">Password: </td>
<td align="left"> <input size=30 type="password" name="userpwd" value="<%=userpwd%>" /></td>
</tr>

<tr><td align="center" colspan=2>
<%
if ( ! engine.equals("") ) {
%>
<input type="submit" name="submit" value="Update" />&nbsp;&nbsp;
<input type="submit" name="submit" value="Delete" onclick="return confirm('Confirm Delete? ')" />&nbsp;&nbsp;
<%
}       // end if engine ...
%>
<input type="submit" name="submit" value="Add" />
</td></tr>

</table>

</fieldset>
</form>


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

<br />
</center>
</body>
</html>

