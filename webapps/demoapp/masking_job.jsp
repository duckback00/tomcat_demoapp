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

   String str = doCommand(path+"api/masking_status_tc.sh \""+jsonpath+jsonFile+"\" \""+engine+"\" "+job+"");
   //out.println(str+"<br />");

   JSONParser parser = new JSONParser();
   String jobstate = "";
   String startTime = "";
   String rowsMasked = "";
   String rowsTotal = "";
   String endTime = "";
   String jobcolor = "lightpink";
   String bgcolor = "lightpink";

   if (str != "") {
      JSONObject jsonObject = (JSONObject) parser.parse(str);
      jobstate = (String) jsonObject.get("status");
      startTime = (String) jsonObject.get("startTime");
      rowsMasked = "0";
      rowsTotal = "0";
      endTime = "";

      //out.println(jobstate+"<br />");
      //out.println("<hr />");
      jobcolor = "pink";
      if ( jobstate.equals("RUNNING")) { jobcolor="lightgreen"; }
      if ( jobstate.equals("SUCCEEDED")) { 
         jobcolor="lightgreen"; 
         long lcnt = (Long) jsonObject.get("rowsMasked"); 
         rowsMasked = String.valueOf(lcnt);
         lcnt = (Long) jsonObject.get("rowsTotal");
         rowsTotal = String.valueOf(lcnt);
         endTime = (String) jsonObject.get("endTime");
      }
   }
%>
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

