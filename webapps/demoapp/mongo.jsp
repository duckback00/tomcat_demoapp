<%@ page import="java.io.*,java.sql.*,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*,java.net.*" %>
<%

String sessionid = "";
if (request.getParameter("sessionid") == null) {
   //session.invalidate();
   sessionid = UUID.randomUUID().toString();
} else {
   sessionid = (String) request.getParameter("sessionid");
}

String dbType = (String)session.getAttribute("dbType");
String dataSource = (String)session.getAttribute("dataSource");
String sqlSchema = (String)session.getAttribute("sqlSchema");
String username = (String)session.getAttribute("username");
String password = (String)session.getAttribute("password");
String connUrl = (String)session.getAttribute("connUrl");

session.setAttribute("employee_id","YES");
%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page errorPage="ShowError.jsp" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <%--
        <link rel="stylesheet" type="text/css" href="css/style.css">
        --%>
        <link href="./bootstrap/css/bootstrap1.min.css" rel="stylesheet" media="screen"/>
        <title><%=session.getAttribute("page_title")%></title>
        <style type="text/css">
            body {
                padding-top: 20px;
                padding-bottom: 20px;
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
            
        </style>
        <link href="./bootstrap/css/bootstrap-responsive.min.css" rel="stylesheet" media="screen"/>

    </head>
    <body>

    <a name="top"></a>
    <%=session.getAttribute("html_banner")%>

        <script>
            function validateInput()
            {
                var empid = document.getElementById("empid").value;
                var firstname = document.getElementById("firstname").value;
                var lastname = document.getElementById("lastname").value;
                var deptname = document.getElementById("deptname").value;
                var city = document.getElementById("city").value;
                
                if (empid == "" || firstname == "" || lastname == "" || deptname == "" || city == "")
                {
                    bootbox.alert("One or more input fields are empty!");
                    return false;
                }
            }            
        </script>

        <div class="container">
            <div class="row">
                <div class="span10">
                    <div class="masthead">
                        <h3 class="muted">Delphix Demo</h3>
                        <div class="navbar">
                            <div class="navbar-inner">
                                <div class="container">
                                    <ul class="nav">
                                        <li class="active"><a href="mongo.jsp?sessionid=<%=sessionid%>">&nbsp;&nbsp;&nbsp;Employees&nbsp;&nbsp;&nbsp;</a></li>
                                        <li><a href="mongo_masking.jsp?sessionid=<%=sessionid%>">Medical Records</a><li> 
                                        <!-- li><a href="login.jsp?sessionid=<%=sessionid%>&platform=Virtualization">API Demo</a></li -->
                                    </ul>
                                </div>
                            </div>
                        </div><!-- /.navbar -->
                    </div>
                </div>
                <div class="span2">
                </div>
            </div>
        </div>

        <div class='container'>


<table border=0 width="100%" style="border-collapse:collapse;"><tr><td><h3>Employees</h3></td>

<td>&nbsp;&nbsp;&nbsp;&nbsp;</td><!--td align="right"><a href="#top"><image src="images/back2top-icon-2.gif" height="30px" border=0 alt="Back to Top" /></a></td--></tr></table>


            <div class="row">
                <div class="span10">

                    <table id="" class="table table-striped">
                        <!-- column headers -->
                        <!-- column data -->

<%@ include file="mongodb.jsp" %>

                    </table>
                    <br/>
                    <br/>
                </div>
                <div class="span2">
                </div>
            </div>
        </div>


        <div class="container">
            <div class="row">
                <div class="span5">
                    <form class="form-horizontal" onsubmit="return validateInput()" action="mongo.jsp?sessionid=<%=sessionid%>" method="POST">
                       <input type="hidden" name="dbType" value="<%=dbType%>" />
                       <input type="hidden" name="dataSource" value="<%=dataSource%>" />
                       <input type="hidden" name="sqlSchema" value="<%=sqlSchema%>" />

                        <fieldset>
                            <legend> Add Employee </legend>

                            <div class="control-group">
                                <label class="control-label" for="empid">Employee ID</label>
                                <div class="controls">
                                    <input type="text" name="empid" id="empid" placeholder="empid">
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label" for="firstname">First Name</label>
                                <div class="controls">
                                    <input type="text" name="firstname" id="firstname" placeholder="firstname">
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label" for="lastname">Last Name</label>
                                <div class="controls">
                                    <input type="text" name="lastname" id="lastname" placeholder="lastname">
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label" for="deptname">Dept Name</label>
                                <div class="controls">
                                    <input type="text" name="deptname" id="deptname" placeholder="dept">
                                </div>
                            </div>
                            <div class="control-group">
                                <label class="control-label" for="city">City</label>
                                <div class="controls">
                                    <input type="text" name="city" id="city" placeholder="city">
                                </div>
                            </div>
                            <div class="control-group">
                                <div class="controls">
                                    <input type="submit" name="submit" value="Add" class="btn btn-inverse" />
                                </div>
                            </div>
                        </fieldset>
                    </form>
                </div>
                <div class="span5">
                    <form class="form-horizontal" action="mongo.jsp?sessionid=<%=sessionid%>" method="POST">
                       <input type="hidden" name="dbType" value="<%=dbType%>" />
                       <input type="hidden" name="dataSource" value="<%=dataSource%>" />
                       <input type="hidden" name="sqlSchema" value="<%=sqlSchema%>" />
                        <fieldset>
                            <legend> Remove Employee </legend>
                            <div class="control-group">
                                <label class="control-label" for="empid">Employee ID</label>
                                <div class="controls">
                                    <input type="text" name="empid" placeholder="empid" value="" />
                                </div>
                            </div> 
                            <div class="control-group">
                                <div class="controls">
                                    <input type="submit" name="submit" value="Delete" class="btn btn-inverse" />
                                </div>
                            </div>                      
                        </fieldset>                       
                    </form>
                    <br/>
                    <br/> 
                </div>
            </div>
        </div>

        <script src="./bootstrap/js/bootstrap.min.js"></script>  
        <script src="./bootstrap/js/bootbox.min.js"></script>
<%
/*
out.println("dataSource: "+dataSource+"<br />");
out.println("database: "+sqlSchema+"<br />");
out.println("connUrl: "+connUrl+"<br />");
out.println("username: "+username+"<br />");
//out.println("password: "+password+"<br />");
out.println("employee_id "+session.getAttribute("employee_id")+"<br />");
out.println("dbType "+session.getAttribute("dbType")+"<br />");
*/
%>
</body>
</html>
