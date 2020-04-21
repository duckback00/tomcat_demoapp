<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.io.*,java.util.*,java.net.*,javax.xml.parsers.*,org.w3c.dom.*"%>
<%
String sessionid = "";
if (request.getParameter("sessionid") == null) {
   //session.invalidate();
   sessionid = UUID.randomUUID().toString();
} else {
   sessionid = (String) request.getParameter("sessionid");
}

   //
   // Page Banner ...
   //
   String ban = "<center><table border=0 style=\"background-color:black;width:100%;\">\n";
   ban = ban + "<tr><td style=\"padding-left:100px;\" width=\"40%\" align=\"center\" valign=\"top\"><a href=\"index.jsp?sessionid="+sessionid+"\"><image src=\"img/delphix-logo-white.png\" border=0 /></a></td>\n";
//   ban = ban + "<td align=\"center\" width=\"140\" valign=\"middle\">Delphix Rocks</td>\n";
   ban = ban + "<td align=\"right\" valign=\"bottom\"><span style=\"padding-right:160px;font-size:18pt;\"><font color=\"#1AD6F5\">Configure Database Connections</font></span></td>\n";
   ban = ban + "</tr>\n";
//msg = "Hello <b>"+usr+"</b>!";
   //if (msg != null) {
   //  ban = ban + "<tr style=\"background-color:white;width:100%;\"><td align=\"right\" style=\"color:blue;\"><i>:System Message:</i></td><td colspan=2>"+msg+"</td></tr>\n";
   //}
   ban = ban + "</table></center>\n";

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>JSP Reading Text File</title>
<link rel="shortcut icon" href="favicon.ico?v=3" />
<style>
body {
   padding-top: 20px;
   padding-bottom: 60px;
   margin: 0px;
}
fieldset {   
   -moz-border-radius:5px;  
   border-radius: 5px;  
   -webkit-border-radius: 5px; 
   float: left; 
   background-color:#DDDDDD;"
}
legend {
   top:-6px;
   position:relative;
   font-weight: bold;
}
</style>
</head>
<body>
<center>
<%=ban%>
</center>
<a style="padding-left:200px;" href="index.jsp?sessionid=<%=sessionid%>">Back</a><br />
<center>
<table border=0 style="font-size:12pt;">

<tr>
<th align="center">JDBC Database Connection Parameters</th>
</tr>

<%
// out.println("<tr><td align=\"center\" style=\"height:30px;\"><a href=\"read_context.jsp\" target=\"_new\">Show META-INF/context.xml file contents</a></td></tr>");

// 
// XML Strings for Output ...
//
String str_orig = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<!-- delphixdb/delphixdb for orcl db username on demokit -->\n<!-- scott/tiger for hrprod db on dlpx -->\n\n<Context antiJARLocking=\"true\" path=\"/DataLoad\">\n";
String str_new = str_orig;

// 
// Request Parameter ...
//
String submit = null;
submit = request.getParameter("submit");

//
// Read context.xml file ...
//
try {

   //Integer counter;
   String name, auth, type, driverClassName, url, username, password;
   String maxActive, maxIdle, validationQuery, testOnBorrow, maxWait;
   String rstr = "";

   // 
   // Read XML file into Parse Doc ...
   //
   String XmlPath = "/META-INF/context.xml";
   Document doc;
   String appPath = application.getRealPath("/");
   DocumentBuilderFactory dbf=DocumentBuilderFactory.newInstance();
   DocumentBuilder db=dbf.newDocumentBuilder();
   doc=db.parse(appPath + XmlPath);

   //
   // Get all Resource Tags ...
   //
   NodeList nl = doc.getElementsByTagName("Resource");

   // 
   // Loop thru each Resource element ...
   //
   Element el;
   for (int i = 0; i < nl.getLength(); i++) {
      el = (org.w3c.dom.Element) nl.item(i);

      //
      // Get Element Attributes ...
      //
      //counter = Integer.valueOf(el.getAttribute("counter"));
      name = el.getAttribute("name");
      auth = el.getAttribute("auth");
      type = el.getAttribute("type");
      driverClassName = el.getAttribute("driverClassName");
      url = el.getAttribute("url");
      username = el.getAttribute("username");
      password = el.getAttribute("password");
      maxActive = el.getAttribute("maxActive");
      maxIdle = el.getAttribute("maxIdle");
      validationQuery = el.getAttribute("validationQuery");
      testOnBorrow = el.getAttribute("testOnBorrow");
      maxWait = el.getAttribute("maxWait");
      //out.println(i + ") name = " + name + " " + url + " " + username + "/" + password + "<br />");

      rstr = "    <Resource name=\""+name+"\" auth=\""+auth+"\"\n          type=\""+type+"\" driverClassName=\""+driverClassName+"\"\n          url=\""+url+"\"\n          username=\""+username+"\" password=\""+password+"\" maxActive=\""+maxActive+"\" maxIdle=\""+maxIdle+"\" validationQuery=\""+validationQuery+"\"\n          testOnBorrow=\""+testOnBorrow+"\" maxWait=\""+maxWait+"\"/>\n";

      // 
      // Saving Changes ...
      //
      if (submit != null) {       // if (submit != null && !submit.trim().isEmpty()) {...

         //
         // Use HTML Request Parameters to Build New Resource XML String ...
         //
         String str = "    <Resource";
         Integer j = 0;
         Integer found = 0;
         Enumeration paramNames = request.getParameterNames();
         while(paramNames.hasMoreElements()) {

            j = j + 1;
            //if (j == 1) out.println("<div style=\"font-size:11pt;padding-left:10px;\"><table border=1 cellpadding=3 cellspacing=0><tr bgcolor=\"#dddddd\"><th>Param Name</th><th>Param Value(s)</th></tr>");

            // 
            // Get Name Value Pairs ...
            //
            String paramName = (String)paramNames.nextElement();
            String paramValue = request.getParameter(paramName);

            //out.print("<tr><td>" + paramName + "</td>\n");
            //out.println("<td> " + paramValue + "</td></tr>\n");

            // 
            // Build New Resource XML String with User provided values  ...
            //
            if (!paramName.equals("submit")) str = str+" "+paramName+"=\""+paramValue+"\""; 
            if (paramName.equals("name")) {
               if (paramValue.equals(name)) found = 1;
            }

            //
            // Append Line Feeds for Readability where Desired ...
            //
            if (paramName.equals("auth")) str = str+"\n          ";
            if (paramName.equals("driverClassName")) str = str+"\n          ";
            if (paramName.equals("url")) str = str+"\n          ";
            if (paramName.equals("validationQuery")) str = str+"\n          ";

         }

         // 
         // Continue to build XML output strings ...
         //
         if (found > 0) {
            str_new = str_new+str+"/>\n";
            //out.println("New: "+str+"/>\n<br />");
         } else {
            str_new = str_new+rstr;
            str_orig = str_orig+rstr;
            //out.println("Orig: "+rstr+"<br />");
         }
         //if (j > 0) out.println("</table></div>");

      } else {

         out.println("<tr><td colspan=2>&nbsp;</td></tr>");

         // 
         // Build HTML Form Input Table for each Resource ...
         //
         out.println("<tr><td>");
         //out.println("<hr color=teal size=2 width=\"20%\" />");
         out.println("<fieldset><legend>Driver: "+name+"</legend>");

         out.println("<table>");
         out.println("<form name=\"form_"+name.replace("jdbc/","")+"\" method=\"POST\" action=\"\">");
         out.println("<input type=\"hidden\" name=\"sessionid\" value=\""+sessionid+"\" />");
         out.println("<input type=\"hidden\" name=\"name\" value=\""+name+"\" />");
         out.println("<input type=\"hidden\" name=\"auth\" value=\""+auth+"\" />");
         out.println("<input type=\"hidden\" name=\"type\" value=\""+type+"\" />");
         out.println("<input type=\"hidden\" name=\"driverClassName\" value=\""+driverClassName+"\" />");

         out.println("<tr>");
         out.println("<td colspan=2 style=\"padding-left:20px;\">");

            out.println("<table border=0>");
            out.println("<tr><td align=\"right\">URL: </td><td><input type=\"text\" name=\"url\" value=\""+url+"\" size=72 /></td></tr>");
            out.println("<tr><td align=\"right\">Username: </td><td><input type=\"text\" name=\"username\" value=\""+username+"\" /></td></tr>");
            out.println("<tr><td align=\"right\">Password: </td><td><input type=\"password\" name=\"password\" value=\""+password+"\" /></td></tr>");
            out.println("</table>");

         out.println("</td>");
         out.println("</tr>");

         out.println("<input type=\"hidden\" name=\"maxActive\" value=\""+maxActive+"\" />");
         out.println("<input type=\"hidden\" name=\"maxIdle\" value=\""+maxIdle+"\" />");
         out.println("<input type=\"hidden\" name=\"validationQuery\" value=\""+validationQuery+"\" />");
         out.println("<input type=\"hidden\" name=\"testOnBorrow\" value=\""+testOnBorrow+"\" />");
         out.println("<input type=\"hidden\" name=\"maxWait\" value=\""+maxWait+"\" />");

         out.println("<tr>");
         out.println("<td colspan=4 align=\"center\"><input type=\"submit\" name=\"submit\" value=\"Save\" /></td>");
         out.println("</form>");
         out.println("</tr>");

         out.println("</table>");

         out.println("</fieldset>");
         //out.println("<hr color=silver size=3 width=\"30%\" />");
         out.println("</td></tr>");

      }    // end if submit 

   }    // end of loop 	

   // 
   // Close up XML Strings ...
   //
   str_new = str_new+"</Context>";
   str_orig = str_orig+"</Context>";


} catch(Exception e) {
   out.println(e.getMessage()); 
}


//
// Write XML Files ...
//
if (submit != null) {
   //
   // Replace Original and Create Backup File ...
   //
   String oFile = "/META-INF/context.out";
   String oFile1 = "/META-INF/context.xml";
   String appPath = application.getRealPath("/");

   //FileOutputStream ous = application.getResourceAsStream(appPath+oFile);
   try {   

      PrintWriter pw = new PrintWriter(new FileOutputStream(appPath+oFile));
      pw.println(str_orig);
      pw.close();
 
      PrintWriter pw1 = new PrintWriter(new FileOutputStream(appPath+oFile1));
      pw1.println(str_new);
      pw1.close();

      out.println("<tr><td align=\"center\" style=\"height:30px;\"><b>Files Saved</b></td></tr>");

   } catch(IOException e) {
      out.println(e.getMessage());
   }

   out.println("<tr><td align=\"center\" style=\"height:30px;\"><a href=\"read_xml.jsp?sessionid="+request.getParameter("sessionid")+"\">Change another Connection</a></td></tr>");

} else {

   out.println("<tr><td align=\"center\" style=\"height:20px;\"><span style=\"font-size:8pt;\">*** End of Drivers ***</span></td></tr>");

}

%>

</table>
</center>
<br />

</body>
</html> 
