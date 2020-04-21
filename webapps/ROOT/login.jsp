<%-- 
    Document   : login
    Created on : Aug 26, 2013, 10:43:31 AM
    Author     : vtigadi
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Database Self-service </title>
        <link href="./bootstrap/css/bootstrap.css" rel="stylesheet">
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>  
        <script src="./bootstrap/js/bootstrap.js"></script>  
        <script src="./bootstrap/js/bootbox.min.js"></script>
        <style type="text/css">
            #logo {
                padding-top:  55px;
                padding-right: 0px;
                margin-right: 0px;
            }
            #heading {
                padding-top: 50px;
                margin-left: 15px;
                color: #006dcc;
            }
        </style>
            
    </head>
    <body>
        <div class="container">

            <div class="masthead">
                <div class="row">
                    <div class="span2" id="logo">
                        <img src="./img/logo_delphix_small.gif"/>
                    </div>
                    <div class="span4" id="heading">
                        <h3 class="pull-left">Database Self Service</h3>
                    </div>
                </div>
            </div>
            <hr>
            <br>
            <div class="row">
                <div class="span4 offset4">
                    <div class="well">
                        <legend>Please Login</legend>
                        <form method="POST" action="selfservice.jsp" accept-charset="UTF-8">
                            <input class="span3" placeholder="Username" type="text" name="username">
                            <input class="span3" placeholder="Password" type="password" name="password">
                            <button class="btn-info btn" type="submit">Login</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
