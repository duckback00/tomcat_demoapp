<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"       "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*" %>

<%@ include file="self_classes.jsp" %>

<%

   String path = application.getRealPath("/").replace('\\', '/');
   // ... or ... path = getServletContext().getRealPath("/").replace('\\', '/');
   //out.println("Path "+path+"<br />");

   String jsonpath = path+File.separator+"jsonfiles"+File.separator;
   String jsonFile = "delphix_platforms.json";

   //String baseurl = request.getParameter("baseurl");
   //String username = request.getParameter("username");
   //String userpwd = request.getParameter("userpwd");

   String engine = request.getParameter("engine");
   String job = request.getParameter("job");

   //out.println(path+"api/job_status_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" "+job+"<br />");
   String str = doCommand(path+"api/job_status_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" "+job+"");
   //out.println(str+"<br />");

   JSONParser parser = new JSONParser();
   String jobstate = "";
   String percentcomplete = "";
   String jobcolor = "lightpink";
   String bgcolor = "lightpink";

   if (str != "") {
      JSONObject jsonObject = (JSONObject) parser.parse(str);
      jobstate = (String) jsonObject.get("JobState");
      percentcomplete = (String) jsonObject.get("PercentComplete");
      //out.println(jobstate+" "+percentcomplete);
      //out.println("<hr />");
      if ( Integer.parseInt(percentcomplete) < 100 ) {
         bgcolor="lightpink";
      } else { 
         bgcolor="lightgreen";
      }
      jobcolor = "pink";
      if ( jobstate.equals("RUNNING")) { jobcolor="lightgreen"; }
      if ( jobstate.equals("COMPLETED")) { jobcolor="lightgreen"; }
   }
%>
<table>
<tr><th>JobNo</th><th>Job State</th><th>% Complete</th></tr>
<tr>
   <td><%= job %></td>
   <td style="background-color:<%=jobcolor%>;"><%= jobstate %></td>
   <td id="pc" style="background-color:<%=bgcolor%>;"><%= percentcomplete %>%</td>
</tr>
</table>
