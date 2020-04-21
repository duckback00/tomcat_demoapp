<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"       "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*" %>

<%@ include file="self_classes.jsp" %>

<%

   //
   // Application Variables ...
   //
   Random rand = new Random(); 
   int val = rand.nextInt(999); 

   String str = "";

   String enginename = "";
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
   ban = ban + "<tr><td style=\"padding-left:100px;\" width=\"30%\" align=\"center\" valign=\"top\"><a href=\"index.jsp\"><image src=\"img/delphix-logo-white.png\" border=0 /></a></td>\n";
//   ban = ban + "<td align=\"center\" width=\"140\" valign=\"middle\">Delphix Rocks</td>\n";
   ban = ban + "<td align=\"left\" valign=\"bottom\"><span style=\"padding-left:10px;font-size:14pt;\"><font color=\"#1AD6F5\">Self Service Demo Application</font></span></td>\n";
   ban = ban + "</tr>\n";
//msg = "Hello <b>"+usr+"</b>!";
   //if (msg != null) {
   //  ban = ban + "<tr style=\"background-color:white;width:100%;\"><td align=\"right\" style=\"color:blue;\"><i>:System Message:</i></td><td colspan=2>"+msg+"</td></tr>\n";
   //}
   ban = ban + "</table></center>\n";

   String path = application.getRealPath("/").replace('\\', '/');
   // ... or ... path = getServletContext().getRealPath("/").replace('\\', '/');
   //out.println("Path "+path+"<br />");

   String jsonpath = path+File.separator+"jsonfiles"+File.separator;
   String jsonFile = "masking_platforms.json";

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
   String proto = (request.getParameter("protocol") != null) ? request.getParameter("protocol") : "";
   String host = (request.getParameter("hostname") != null) ? request.getParameter("hostname") : "";
   String usr = (request.getParameter("username") != null) ? request.getParameter("username") : "";
   String pwd = (request.getParameter("userpwd") != null) ? request.getParameter("userpwd") : "";

   if ( ! test.equals("") && ! engine.equals("") ) { 
      //out.println("Connection Test: "+path+"authentication_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\"<br />");
      str = doCommand(path+"authentication_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\"");
      out.println(str);
   }

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
      isValid = isJSONValid(str);
      if (isValid) {
         Object obj = parser.parse(str);
         JSONObject jsonObject = (JSONObject) obj;
         JSONArray jarr = (JSONArray) jsonObject.get("masking");
         for (int i=0; i < jarr.size(); i++) {
            JSONObject pobj = (JSONObject) jarr.get(i);
            // out.println(i);
            // Long id = (Long) pobj.get("employee_id");
            enginename = (String) pobj.get("enginename");

            if ( engine.equals(enginename) ) {

               if ( submit.equals("Delete")) { delidx = i; }

               if ( submit.equals("Update")) {
                  pobj.put("protocol",proto);
                  pobj.put("hostname",host);
                  pobj.put("username",usr);
                  pobj.put("password",pwd);
               }

            }
         }

         if ( submit.equals("Delete")) { 
            jarr.remove(delidx); 
            engine="";
         }
         if ( submit.equals("Add")) {
            JSONObject js = new JSONObject();
            js.put("enginename",ename);
            js.put("protocol",proto);
            js.put("hostname",host);
            js.put("username",usr);
            js.put("password",pwd);
            jarr.add(js);
            engine=ename;
         }

         String json = jsonObject.toString();
         //out.println("json: "+json+"<br />");

         // 
         // Write Out New configuration ...
         //
         str = doCommand("mv "+jsonpath+jsonFile+" "+jsonpath+jsonFile+"_"+val);
         //out.println(str);
         try {
            String configFilename = jsonpath+jsonFile;
            //File configFile = new File(configFilename);
            FileWriter file = new FileWriter(configFilename);
            file.write(json);
            file.flush();
            file.close();
         } catch (Exception e) {
            e.printStackTrace();
         }

      }

   }


   ////////////////////////////////////////////////////////////
   // HTML Output ...

%>
<html>
<head>
<title>Delphix Self Service Rocks</title>
<style>
table { border-collapse: collapse; width: 500px; }
table, th, td { padding:2px; border:1px ridge black; }
</style>
</head>
<body>
<center>

<%=ban%>

<h3>Delphix Dynamic Data Masking Platform Configuration File</h3>

<form name="form0" method="post" action="">
<fieldset>
<legend>Platforms</legend>

Select Masking Platform:
<select name="engine" onchange="this.form.submit()">
<option value="">-- New Config --</option>
<%
   //
   // Engines ...
   //
   str = doCommand("cat "+jsonpath+jsonFile);
   //out.println(str);

   isValid = isJSONValid(str);
   if (isValid) {
      Object obj = parser.parse(str);
      JSONObject jsonObject = (JSONObject) obj;
      JSONArray jarr = (JSONArray) jsonObject.get("masking");
      for (int i=0; i < jarr.size(); i++) {
         JSONObject pobj = (JSONObject) jarr.get(i);
         // out.println(i);
         // Long id = (Long) pobj.get("employee_id");
         enginename = (String) pobj.get("enginename");

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
         }

      }         // end for loop ...

   } else {
      out.println("Error: Invalid JSON String "+str+"<br />");
   }    // end if isValid ...
   //out.println("<hr />");

%>
</select>
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
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<font color=blue><font size=-1>(include :[port]/dmsuite/)</font></font>

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

</center>
</body>
</html>

