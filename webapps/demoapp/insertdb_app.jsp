<%@ page import="java.io.*,java.sql.*,com.ibm.db2.jcc.*,oracle.jdbc.driver.*,oracle.jdbc.OracleDriver,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*,java.net.*" %>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%-- 
    Document   : insertdb
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
<%@page errorPage="ShowError.jsp" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Adding Employee</title>
    </head>
    <body>

        <sql:update var="newemp" dataSource="<%=session.getAttribute(\"dataSource\")%>">
<%
if ( session.getAttribute("employee_id").equals("YES") ) {
   if (session.getAttribute("dbType").equals("mysql")) {
   %>
      insert into employees (employee_id,first_name,last_name,dept_name,city) VALUES ('${param.empid}','${param.firstname}','${param.lastname}','${param.deptname}','${param.city}')
   <%
   } else if (session.getAttribute("dbType").equals("db2")) {
   %>
     INSERT INTO DELPHIXDB.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) VALUES ('${param.empid}','${param.firstname}','${param.lastname}','${param.deptname}','${param.city}')
   <%
   } else if (session.getAttribute("dbType").equals("postgresql")) {
   %>
      INSERT into "EMPLOYEES" ("EMPLOYEE_ID","FIRST_NAME","LAST_NAME","DEPT_NAME","CITY") values('${param.empid}','${param.firstname}','${param.lastname}','${param.deptname}','${param.city}')
   <%
   } else {  
   %>
    INSERT INTO EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) VALUES ('${param.empid}','${param.firstname}','${param.lastname}','${param.deptname}','${param.city}')
   <%
   }
} else {
   if (session.getAttribute("dbType").equals("mysql")) {
   %>
      insert into employees (first_name,last_name,dept_name,city) VALUES ('${param.firstname}','${param.lastname}','${param.deptname}','${param.city}')
   <%
   } else if (session.getAttribute("dbType").equals("postgresql")) {
   %>
      INSERT INTO "EMPLOYEES" ("FIRST_NAME","LAST_NAME","DEPT_NAME","CITY") VALUES ('${param.firstname}','${param.lastname}','${param.deptname}','${param.city}')
   <%
   } else {
   %>
      INSERT INTO EMPLOYEES (FIRST_NAME,LAST_NAME,DEPT_NAME,CITY) VALUES ('${param.firstname}','${param.lastname}','${param.deptname}','${param.city}')
   <%
   }
}
%>
        </sql:update> 

<%
itotal = itotal + 1;
%>
<%@ include file="write_session.jsp" %>

        <c:redirect url="index_app.jsp?sessionid=${param.sessionid}"/>

    </body>
</html>
