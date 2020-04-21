<%@ page import="java.net.*" %> 
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%-- 
    Document   : index
    Created on : Jul 9, 2013, 1:06:39 PM
    Author     : vtigadi
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page errorPage="ShowError.jsp" %>
<%
String serverIP = request.getLocalAddr();
String hostname, serverAddress;
hostname = "error";
serverAddress = "error";
try {
   InetAddress inetAddress;
   inetAddress = InetAddress.getLocalHost();
   hostname = inetAddress.getHostName();
   serverAddress = inetAddress.toString();
} catch (UnknownHostException e) {
   e.printStackTrace();
}
%>
<%@ include file="init.jsp"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%--
        <link rel="stylesheet" type="text/css" href="css/style.css">
        --%>
        <link href="./bootstrap/css/bootstrap.min.css" rel="stylesheet" media="screen"/>
        <title>Delphix Demo Applications</title>
        <link rel="shortcut icon" href="favicon.ico?v=3" />
        <style type="text/css">
            body {
                padding-top: 20px;
                padding-bottom: 60px;
            }

            .source {
                background-color: pink;
            }
            .target {
                background-color: brown;
            }

            /* Custom container */
            .container {
                margin: 0 auto;
                max-width: 1000px;
            }
            .container > hr {
                margin: 60px 0;
            }

            /* Main marketing message and sign up button */
            .jumbotron {
                margin: 80px 0;
                text-align: center;
            }
            .jumbotron h1 {
                font-size: 100px;
                line-height: 1;
            }
            .jumbotron .lead {
                font-size: 24px;
                line-height: 1.25;
            }
            .jumbotron .btn {
                font-size: 21px;
                padding: 14px 24px;
            }

            /* Supporting marketing content */
            .marketing {
                margin: 60px 0;
            }
            .marketing p + h4 {
                margin-top: 28px;
            }

            /* Customize the navbar links to be fill the entire space of the .navbar */ 
            .navbar .navbar-inner {
                padding: 0;
            }
            .navbar .nav {
                margin: 0;
                display: table;
                width: 100%;
            }
            .navbar .nav li {
                display: table-cell;
                width: 0%;
                float: none;
            }
            .navbar .nav li a {
                font-weight: bold;
                text-align: center;
                border-left: 1px solid rgba(255,255,255,.75);
                border-right: 1px solid rgba(0,0,0,.1);
            }
            .navbar .nav li:first-child a {
                border-left: 0;
                border-radius: 3px 0 0 3px;
            }
            .navbar .nav li:last-child a {
                border-right: 0;
                border-radius: 0 3px 3px 0;
            }
            .box {
                width: 800px;
                height: 300px;
                position: relative;
                background: -webkit-linear-gradient(top, #888 0%,#fff 30%);
                box-shadow: 3px 3px 5px #666;
                padding: 12px
            }           
            .box1 {
                width: 800px;
                height: 350px;
                position: relative;
                background: -webkit-linear-gradient(top, #ccebff 0%,#fff 30%);
                box-shadow: 3px 3px 5px #666;
                padding: 12px;
            }           
            .box2 {
                width: 500px;
                height: 110px;
                position: relative;
                background: -webkit-linear-gradient(top, #ccebff 0%,#fff 30%);
                box-shadow: 3px 3px 5px #666;
                padding: 5px;
            }   
            .box3 {
                width: 500px;
                height: 115px;
                position: relative;
                background: -webkit-linear-gradient(top, #ccebff 0%,#fff 30%);
                box-shadow: 3px 3px 5px #666;
                padding: 5px;
                font-size: 12px;
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
        <link href="./bootstrap/css/bootstrap-responsive.min.css" rel="stylesheet" media="screen"/>
    </head>
    <body>

<table border=0 style="background-color:black;width:100%;">
<tr>
<td width="40%" align="center" valign="top" style="padding-left:100px;"><a href=""><image src="img/delphix-logo-white.png" /></a></td>
<td align="center">
<span style="font-size:18pt;"><font color="#1AD6F5">Welcome to Delphix Demo Applications</font></span>
</td>
</tr>
</table>

<hr size="3" color="teal" />

<center>
<div class = "box1">
<table border=0 width="700" style="font-size:11pt;">

<tr>
<th>Database Vendor</th>
<th>Source Applications</th>
<th>Break Fix</th>
<th>Dev</th>
<th>QA</th>
<!-- th>Masking</th -->
</tr>

<!-- MS SQL Server -->
<tr>
<td height=90 align="center"><image src="img/mssql_logo.png" width=125><br /><br /></td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mssql&dataSource=mssql_source&sqlUpper=yes&dbname=winsrc1&envtype=Source%20DB">winsrc1</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mssql&dataSource=mssql_target&sqlUpper=yes&dbname=vwin1&envtype=Break%20Fix">vwin1</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mssql&dataSource=mssql_target2&sqlUpper=yes&dbname=vwindev1&envtype=Dev">vwindev1</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mssql&dataSource=mssql_target3&sqlUpper=yes&dbname=vwinqa1&envtype=QA">vwinqa1</a>
</td>
<!--
<td align="center">
<a href="login.jsp?sessionid=<%=sessionid%>&platform=Masking&dbType=mssql&dbSources=mssql_source,mssql_target,mssql_target2">Mask Data</a>
</td>
-->
</tr>


<!-- Oracle -->
<tr>
<td height=60 align="center">
<image src="img/oracle_logo.png" width=125>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=oracle&dataSource=oracle_source&sqlUpper=yes&dbname=orasrc1&envtype=Source%20DB">orasrc1</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=oracle&dataSource=oracle_target&sqlUpper=yes&dbname=vora1&envtype=Break%20Fix">vora1</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=oracle&dataSource=oracle_target2&sqlUpper=yes&dbname=voradev1&envtype=Dev">voradev1</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=oracle&dataSource=oracle_target3&sqlUpper=yes&dbname=voraqa1&envtype=QA">voraqa1</a>
</td>

<!-- td align="center">
<a href="login.jsp?sessionid=<%=sessionid%>&platform=Masking&dbType=oracle&dbSources=oracle_source,oracle_target,oracle_target2">Mask Data</a>
</td -->
</tr>

<!-- Sybase -->
<tr>
<td height=80 align="center"><image src="img/sybase_logo.png" width=115></td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=sybase&dataSource=sybase_source&sqlUpper=yes">Source Sybase</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=sybase&dataSource=sybase_target&sqlUpper=yes">Target1 Sybase</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=sybase&dataSource=sybase_target2&sqlUpper=yes">Target2 Sybase</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=sybase&dataSource=sybase_target3&sqlUpper=yes">Target3 Sybase</a>
</td>
</tr>

<!-- DB2 --> 
<tr>
<td width="160" height="80" align="center"><image src="img/db2_new.jpg" width=125></td>
<td width="140" align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=db2&dataSource=db2_source&sqlSchema=delphixdb&sqlUpper=yes&sqlQuoted=yes">Source Db2</a>
</td>
<td width="140" align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=db2&dataSource=db2_target&sqlSchema=delphixdb&sqlUpper=yes&sqlQuoted=yes">Target1 Db2</a>
</td>
<td width="140" align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=db2&dataSource=db2_target2&sqlSchema=delphixdb&sqlUpper=yes&sqlQuoted=yes">Target2 Db2</a>
</td>
<td width="140" align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=db2&dataSource=db2_target3&sqlSchema=delphixdb&sqlUpper=yes&sqlQuoted=yes">Target3 Db2</a>
</td>
</tr>

</table>
</div>

<br>
<span class="accordion"><font color=grey>Expand/Collapse other Data Sources</font></span>


<div class="panel">

<table border=0 width="700">

<!-- Postgres -->
<tr>
<td height=80 align="center"><image src="img/postgres_logo.png" width=125></td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=postgresql&dataSource=postgresql_source&sqlSchema=delphixdb&sqlUpper=yes&sqlQuoted=yes">Source PostgreSQL</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=postgresql&dataSource=postgresql_target&sqlSchema=delphixdb&sqlUpper=yes&sqlQuoted=yes">Target1 PostgreSQL</a>
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=postgresql&dataSource=postgresql_target2&sqlSchema=delphixdb&sqlUpper=yes&sqlQuoted=yes">Target2 PostgreSQL</a>
</td>
</tr>

<!-- MySQL -->
<tr>
<td height=80 align="center"><image src="img/mysql_logo.png" width=125></td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mysql&dataSource=mysql_source&sqlUpper=yes">Source MySQL</a><br /> 
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mysql&dataSource=mysql_source"><font color=blue>(lower case)</font></a><br />
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mysql&dataSource=mysql_target&sqlUpper=yes">Target1 MySQL</a><br />
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mysql&dataSource=mysql_target"><font color=blue>(lower case)</font></a><br />
</td>
<td align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mysql&dataSource=mysql_target2&sqlUpper=yes">Target2 MySQL</a><br />
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mysql&dataSource=mysql_target2"><font color=blue>(lower case)</font></a><br />
</td>
</tr>

<!-- Mongo -->
<tr>
<td width="160" height="80" align="center"><image src="img/mongodb.png" width=130></td>
<td width="140" align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mongo&dataSource=mongo_source">Source Mongo</a>
</td>
<td width="140" align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mongo&dataSource=mongo_target">Target1 Mongo</a>
</td>
<td width="140" align="center">
<a href="redirect.jsp?sessionid=<%=sessionid%>&dbType=mongo&dataSource=mongo_target2">Target2 Mongo</a>
</td>
</tr>

<!-- Note -->
<tr>
<td colspan=4 style="text-align:center;font-size:8pt;color:blue;">Note: Postgres, MySQL and Mongo can be implemented through Delphix Toolkits which are community or customer supported.</td>
</tr>

</table>

</div>

</center>

<hr size="3" color="teal" />

<center>
<div class = "box2">
<table border=0 width=610 style="font-size:10pt;">
<tr>
    <td valign="top">
        <h5>Demo Application</h5>
        <a href="read_xml.jsp?sessionid=<%=sessionid%>">Configure Demo Database Connections</a><br />
        <a href="platform_config.jsp?sessionid=<%=sessionid%>">Configure Delphix Platform Connections</a><br />
        <a href="redirect.jsp?reset=yes&page=index.jsp">Reset Session Data</a><br />
    <td>

    <td valign="top">
        <h5>Delphix Platform API Demos</h5>
        <a href="login.jsp?sessionid=<%=sessionid%>&platform=Virtualization">Virtualization API Login</a><br />
        <a href="login.jsp?sessionid=<%=sessionid%>&platform=Masking&dbType=&dbSources=">Masking API Login</a> <font size=-2>(SQL Server &amp; Oracle Only)</font><br />
        <br />
    </td>
</tr>
</table>
</div>

<div class = "box3">
<table>
<tr>
    <td colspan="2" style="text-align: center;">    
        <h5>Information Links</h5>
        <a href="README.txt" target="_new">README.txt</a><br />
        Hostname: <%=hostname %><br />
        Host IP Address: <%=serverIP %><br />
        Host Operating System: <%=System.getProperty("os.name") %><br />
        <br />        
    </td>
</tr>
</table>
</div>
</center>

<hr size="3" color="teal" />

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

<!--
<script src="js/jquery.min.js"></script>
<script src="js/jquery.js"></script>  
-->

</body>
</html>

