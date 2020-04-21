<%@ page import="java.io.*,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*,java.net.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ include file="self_classes.jsp" %>

<%
String key = UUID.randomUUID().toString();
String sessionid = "";
if (request.getParameter("sessionid") == null) {
   //session.invalidate();
   sessionid = UUID.randomUUID().toString();
} else {
   sessionid = (String) request.getParameter("sessionid");
}

String platform = "";
platform = (request.getParameter("platform") != null) ? request.getParameter("platform") : "";

String dbType = "";
dbType = (request.getParameter("dbType") != null) ? request.getParameter("dbType") : "";

String dbSources = "";
dbSources = (request.getParameter("dbSources") != null) ? request.getParameter("dbSources") : "";

String engine = "";
engine = (request.getParameter("engine") != null) ? request.getParameter("engine") : "";

String username = "";
username = (request.getParameter("username") != null) ? request.getParameter("username") : "delphix_admin";

String password = "";
password = (request.getParameter("password") != null) ? request.getParameter("password") : "";

String submit = "";
submit = (request.getParameter("submit") != null) ? request.getParameter("submit") : "";

String path = application.getRealPath("/").replace('\\', '/');
// ... or ... path = getServletContext().getRealPath("/").replace('\\', '/');
//out.println("Path "+path+"<br />");

String jsonpath = path+"jsonfiles"+File.separator;
String jsonFile = "delphix_platforms.json";

String msg = "";
String str = "";
String enginename = "";
String enginetype = "";
String protocol = "";
String hostname = "";
String user = "";
String userpwd = "";
String baseurl = "";

//
// JSON Parser ...
//
JSONParser parser = new JSONParser();
boolean isValid;

if (submit.equals("Login")) {
if (! engine.equals("")) {
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
         if (enginetype.equals(platform)) {
            if ( engine.equals(engine) ) {
               protocol = (String) pobj.get("protocol");
               hostname = (String) pobj.get("hostname");
               user = (String) pobj.get("username");
               userpwd = (String) pobj.get("password");
               baseurl = protocol + "://" + hostname + "/resources/json/delphix";
            }   // end if enginename ...
         }      // end if enginetype ...
      }         // end for loop ...

   } else {
      out.println("Error: Invalid JSON String "+str+"<br />");
   }    // end if isValid ...

//   out.println("Login stuff: "+hostname+" "+username+" "+user+" "+password+" "+userpwd+"<br />");

   // 
   // Redirect if Login Successfull ... 
   // 
   if ( username.equals(user) && password.equals(userpwd) ) {
      if (platform.equals("Masking")) {
         response.sendRedirect("selfmasking.jsp"+"?sessionid="+sessionid+"&platform=Masking&engine="+engine+"&dbType="+dbType+"&dbSources="+dbSources);
         return;
      }
      if (platform.equals("Virtualization")) {  
         response.sendRedirect("selfservice.jsp"+"?sessionid="+sessionid+"&platform=Virtualization&engine="+engine);
         return;
      }
   } else { 
      msg = "Username and/or Password do NOT match or are invalid, please try again ...";
   }

} else {
      msg = "Platform NOT selected, please try again ...";
} 	// end if engine.equals("") ...
}       // end if submit.equals("Login") ...

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Delphix Rocks - <%=platform%> API Demo</title>
        <link href="./bootstrap/css/bootstrap.css" rel="stylesheet">
    </head>
    <body>
        <div class="container">

            <div class="masthead">
                <div class="row">
                   <br />
                   <table width="100%"><tr>
                      <td style="text-align:center;" width="40%">
                         <a href="redirect.jsp?sessionid=<%=sessionid%>&logout=yes">
                            <img src="./img/delphix-logo-black_200w.png"/>
                         </a>
                      </td>
                      <td style="padding-top:6px;text-align:center;font-size:18pt;">
                         <%=platform%> API Demo
                      </td>
                   </tr></table>
                </div>
            </div>
            <hr>
            <br>
            <div class="row">
                <div class="span4 offset4">
                    <div class="well">
                        <legend>Please Login</legend>
<% 
if ( ! msg.equals("") ) { 
   out.println(""+msg);
}
if (platform.equals("Virtualization")) {
%>
                        <form method="POST" action="login.jsp" accept-charset="UTF-8">
<%
} else {
%>
                        <form method="POST" action="login.jsp" accept-charset="UTF-8">
                        <input type="hidden" name="dbType" value="<%=dbType%>" />
                        <input type="hidden" name="dbSources" value="<%=dbSources%>" />
<%
}
%>
                        <input type="hidden" name="sessionid" value="<%=sessionid%>" />
                        <input type="hidden" name="platform" value="<%=platform%>" />


Select Delphix Platform:
<select name="engine">
<option value="">[ Select_Delphix_Platform ]</option>
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
      JSONArray jarr = (JSONArray) jsonObject.get("engines");
      for (int i=0; i < jarr.size(); i++) {
         JSONObject pobj = (JSONObject) jarr.get(i);
         // out.println(i);
         // Long id = (Long) pobj.get("employee_id");
         enginename = (String) pobj.get("enginename");
         enginetype = (String) pobj.get("enginetype");
         if (enginetype.equals(platform)) {
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
            }   // end if enginename ...
         }      // end if enginetype ...
      }         // end for loop ...

   } else {
      out.println("Error: Invalid JSON String "+str+"<br />");
   }    // end if isValid ...
%>
</select>

                            <input class="span3" placeholder="Username" type="text" name="username" value="<%=username%>" />
                            <input class="span3" placeholder="Password" type="password" name="password" value="<%=password%>" />
                            <input class="btn-info btn" type="submit" name="submit" value="Login" />
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
