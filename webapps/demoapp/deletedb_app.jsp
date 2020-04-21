<%@ page import="java.io.*,java.sql.*,com.ibm.db2.jcc.*,oracle.jdbc.driver.*,oracle.jdbc.OracleDriver,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*,java.net.*" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%-- 
    Document   : deletedb
    Created on : Jul 16, 2013, 12:05:18 PM
    Author     : vtigadi
--%>

<%
String sessionid = "";
sessionid = (String) request.getParameter("sessionid");
String uri = request.getRequestURI();
String pageName = "index_app.jsp"; // uri.substring(uri.lastIndexOf("/")+1);
String cdsid = (String)session.getAttribute("cdsid");
String marr[] = new String[3];
marr[0] = "index";
marr[1] = "index_app";
marr[2] = "masking_app";
%>
<%@ include file="read_session.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Deleting Employee</title>
        <link rel="stylesheet" type="text/css" href="css/style.css">
    </head>
    <body>

        <sql:update var="emp" dataSource="<%=session.getAttribute(\"dataSource\")%>">
<%
if ( session.getAttribute("employee_id").equals("YES") ) {
   if (session.getAttribute("dbType").equals("mysql")) {
   %>
      delete from employees where employee_id = '${param.empid}'
   <%
   } else if (session.getAttribute("dbType").equals("postgresql")) {
   %>
      delete from "EMPLOYEES" where "EMPLOYEE_ID" = '${param.empid}'
   <%
   } else if (session.getAttribute("dbType").equals("db2")) {
   %>
      delete from DELPHIXDB.EMPLOYEES where EMPLOYEE_ID = '${param.empid}'
   <%
   } else {
   %>
      DELETE from EMPLOYEES where EMPLOYEE_ID = '${param.empid}'
   <%
   }
} else {
   if (session.getAttribute("dbType").equals("mysql")) {
   %>
      delete from employees where first_name = '${param.firstname}'
   <%
   } else if (session.getAttribute("dbType").equals("postgresql")) {
   %>
      delete from "EMPLOYEES" where "FIRST_NAME" = '${param.firstname}'
   <%
   } else {
//      DELETE from EMPLOYEES where FIRST_NAME = '${param.firstname}'
//      DELETE from "EMPLOYEES" where "FIRST_NAME" = '${param.firstname}'
   %>
      DELETE from "EMPLOYEES" where "FIRST_NAME" = '${param.firstname}'
   <%
   }
}
%>
        </sql:update>   

<%
itotal = itotal - 1;
%>        
<%@ include file="write_session.jsp" %>

        <c:redirect url="index_app.jsp?sessionid=${param.sessionid}" />

    </body>
</html>
