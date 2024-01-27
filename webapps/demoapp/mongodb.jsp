<%@ page import="java.io.*,java.sql.*,com.mongodb.*,com.mongodb.client.*,com.mongodb.client.model.*,com.mongodb.client.result.*,com.mongodb.client.model.Filters.*,com.mongodb.client.model.Projections.*,org.bson.*,java.util.*,javax.servlet.*,org.json.simple.*,org.json.simple.parser.*,java.net.*" %>
<%

/*
out.println("dbType: "+dbType+"<br />");
out.println("dataSource: "+dataSource+"<br />");
out.println("database: "+sqlSchema+"<br />");
out.println("connUrl: "+connUrl+"<br />");
out.println("username: "+username+"<br />");
out.println("password: "+password+"<br />");
*/

   try {

      //
      // vi /etc/mongod.conf
      // # network interfaces
      // net:
      //  port: 27017
      //  bindIp: 127.0.0.1,172.16.160.133  # Listen to local interface only, comment to listen on all interfaces.
      // ... or ...
      //  #bindIp: ....
      //

      //hard-coded-test//
      //MongoClientURI connectionString  = new MongoClientURI("mongodb://delphix:********@172.16.160.133:27017/********");

      String URL = connUrl;
      MongoClientURI connectionString = new MongoClientURI(URL);
      MongoClient dbconn = new MongoClient(connectionString);

      // or ...
      //MongoClient dbconn = new MongoClient("localhost",27017);

      // Use Database ...
      MongoDatabase db = dbconn.getDatabase(sqlSchema);

      // Get Collection ...
      MongoCollection<Document> collection = db.getCollection("employees");
      //out.println("Collection Count: "+collection.count()+"<br />");

      // 
      // Delete DB Document ...
      //

if (request.getParameter("submit") != null ) {

      boolean bs; 
      int did = -1;
      String ldid = "";

      if (request.getParameter("submit").equals("Delete")) {
      if (request.getParameter("empid") != "") {
         ldid = request.getParameter("empid");
         try {
            Integer.valueOf(ldid);
            bs = true;
         } catch (NumberFormatException e) {
            bs = false;
         }
         if (bs) {
            did = Integer.parseInt(ldid);
         }
         out.println( "Integer Check: " + did + "<br />");
         if (did > 0) {
            out.println( "Using deleteOneFromCollection to delete ID: " + did + "<br />");
            BasicDBObject query = new BasicDBObject();
            query.append("employee_id", did);
            DeleteResult deleteResult = collection.deleteOne(query);
            out.println(deleteResult+"<br />");
         } else {
            out.println("Invalid Employee_Id: "+ldid+"<br />");
         }
      } else {
         out.println("Missing Employee_Id");
      }
      }

      // 
      // Insert DB Document ...
      // 
      if (request.getParameter("submit").equals("Add")) { 
      if (request.getParameter("empid") != "") {
         ldid = request.getParameter("empid");
         try {
            Integer.valueOf(ldid);
            bs = true;
         } catch (NumberFormatException e) {
            bs = false;
         }
         if (bs) {
            did = Integer.parseInt(ldid);
         }
         out.println( "Integer Check: " + did + "<br />");

         String jsonString;
         boolean status = true;
         String fn = request.getParameter("firstname");
         String ln = request.getParameter("lastname");
         String dn = request.getParameter("deptname");
         String cn = request.getParameter("city");
         if (did > 0) {
            //
            // Insert JSON into MongoDB
            //
            jsonString = "{ \"employee_id\": "+did+", \"first_name\": \""+fn+"\", \"last_name\": \""+ln+"\", \"dept_name\": \""+dn+"\", \"city\": \""+cn+"\" }";
            out.println("JSON: " + jsonString + "<br />");
            try {
               Document doc2 = Document.parse(jsonString);
               collection.insertOne(doc2);
            } catch (MongoWriteException mwe) {
               status = false;
            } catch (Exception e) {
               status = false;
            }
            out.println("Status of Insert: " + status + "<br />");
         } else {
            out.println("Invalid Employee_Id: "+ldid+"<br />");
         }
      } else {
         out.println("Missing Employee_Id");
      }
      }

}

      // 
      // Create a sorted cursor ...
      //
      Document query2 = new Document("employee_id", 1);
      MongoCursor<Document> cursor = collection.find().sort(query2).iterator();
      String z = "";
      Integer i = 0;
      try {
         //
         // Loop through Collection ...
         //
         while (cursor.hasNext()) {
            //out.println(cursor.next().toJson());
            z = cursor.next().toJson();
            //out.println(z);
// { "_id" : { "$oid" : "5ac1ae0105e6259dfcafedda" }, "employee_id" : 1, "first_name" : "Woody", "last_name" : "Evans", "dept_name" : "Pre-Sales", "city" : "Hoboken" }  
            // Use the simple JSONParser below or should I use the BSON parser???

            JSONParser parser = new JSONParser();
            Object obj = parser.parse(z);
            JSONObject pobj = (JSONObject) obj;

            Long id = (Long) pobj.get("employee_id");
            String fname = (String) pobj.get("first_name");
            String lname = (String) pobj.get("last_name");
            String dname = (String) pobj.get("dept_name");
            String city = (String) pobj.get("city");
            String zstr = "";
            zstr = "<tr><td>"+id+"</td><td>"+fname+"</td><td>"+lname+"</td><td>"+dname+"</td><td>"+city+"</td></tr>";
            if (i == 0) {
               out.println("<tr><th>Employee_Id</th><th>First_Name</th><th>Last_Name</th><th>Dept_Name</th><th>City</th></tr>");
            }
            out.println(zstr);

            //out.println(itmp);

            i = i + 1;
            //out.println(i);
         }
      } finally {
         cursor.close();
      }


   } catch (Exception e) {
      //response.getWriter().println(e.getMessage());
      out.println(e.getMessage());
   }

//out.println("<hr />");

%>
