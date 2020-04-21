<%@ page import="java.io.*,java.util.*,java.net.*,javax.xml.parsers.*,org.w3c.dom.*" %>
<%

//
// Read context.xml file ...
//

//String url = "";
//String username = ""; 
//String password = "";
String rstr = "";

//String dbType = "mongo";
//String dataSource = "mongo_target3";
//String sqlSchema = "";
//String connUrl = "";

try {

   //Integer counter;
   String name = "";
   String auth = ""; 
   String type = "";
   String driverClassName = "";
   String maxActive = "";
   String maxIdle = ""; 
   String validationQuery = ""; 
   String testOnBorrow = "";
   String maxWait = "";

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
      String[] dsarr = name.split("/");

      //if (name.equals("jdbc/mongo_source")) {
      if (dataSource.equals(dsarr[1])) {

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

         rstr = "    &lt;Resource name=\""+name+"\" auth=\""+auth+"\"\n          type=\""+type+"\" driverClassName=\""+driverClassName+"\"\n          url=\""+url+"\"\n          username=\""+username+"\" password=\""+password+"\" maxActive=\""+maxActive+"\" maxIdle=\""+maxIdle+"\" validationQuery=\""+validationQuery+"\"\n          testOnBorrow=\""+testOnBorrow+"\" maxWait=\""+maxWait+"\"/&gt;\n";

          //out.println("<pre>"+rstr+"</pre>");

      } 

   }    // end of loop 	

} catch(Exception e) {
   out.println(e.getMessage()); 
}

//out.println(""+rstr+"<br />");

//out.println(""+url+" : "+username+" : "+password+"<br />");

//
// Mongo requires a different JDBC Connect String ...
//
if (dbType.equals("mongo")) {
   //      0       1        2               3
   //jdbc:mongodb://172.16.160.133:27017/delphixdb
   String[] arr = url.split("/");
   //out.println("parts[2]: "+arr[2]+"<br />");
   //out.println("parts[3]: "+arr[3]+"<br />");

   if (arr != null && 2 >= 0 && 2 < arr.length && arr[2] != null) {
      // arr[i] exists and is not null
      //connUrl = "mongodb://"+arr[2];
      connUrl = "mongodb://"+username+":"+password+"@"+arr[2]+"/"+arr[3]+"";
   } else {
      connUrl = "missing";
   }
   if (arr != null && 3 >= 0 && 3 < arr.length && arr[3] != null) {
      // arr[i] exists and is not null
      sqlSchema = arr[3];
   } else {
      sqlSchema = "missing";
   }
} else if (dbType.equals("oracle")) {
   //         0                1              		// arr
   //                           0          1		// arr1
   //                                   0     1		// arr2
   // jdbc:oracle:thin:@172.16.160.133:1521/orcl 
   String[] arr = url.split("@");
   if (arr != null && arr[1] != null) {
      String[] arr1 = arr[1].split(":");
      String[] arr2 = arr1[1].split("/");
      connUrl = url;  // "xxxxxx://"+username+":"+password+"@"+arr2[0]+"/"+arr2[1]+"";
      sqlSchema = arr2[1];
   } else {
      connUrl = "missing";
      sqlSchema = "missing";
   }
} else if (dbType.equals("mssql")) {
   // url: jdbc:sqlserver://172.16.160.134:1433;DatabaseName=delphix_demo;Schema=dbo
   String[] arr3 = url.split(";");
   if (arr3 != null && arr3[1] != null) {
      String[] arr4 = arr3[1].split("=");
      sqlSchema = arr4[1];
   } else {
      sqlSchema = "";
   }
   if (arr3 != null && arr3[2] != null) {
      String[] arr5 = arr3[2].split("=");
      dboSchema = arr5[1];
   } else {
      dboSchema = "";
   } 
   connUrl = url;
} else {
   connUrl = url;
   sqlSchema = "";
}
//out.println("schema: "+dboSchema+"<br />");
//out.println("database: "+sqlSchema+"<br />");
//out.println("connUrl: "+connUrl+"<br />");

%>
