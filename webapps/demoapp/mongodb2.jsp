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

String pstr = "";
String pdstr = "";
   try {

      //
      // vi /etc/mongod.conf
      // # network interfaces
      // net:
      //  port: 27017
      //  bindIp: 127.0.0.1,172.16.160.133  # Listen to local interface only, comment to listen on all interfaces.
      // ... or ...
      //  # bindIp: ...
      // 

      //String URL = "mongodb://172.16.160.133:27017";
      String URL = connUrl;
      MongoClientURI connectionString = new MongoClientURI(URL);
      MongoClient dbconn = new MongoClient(connectionString);

      // or ...
      //MongoClient dbconn = new MongoClient("localhost",27017);

      // Use Database ...
      MongoDatabase db = dbconn.getDatabase(sqlSchema);

      // Get Collection ...
      MongoCollection<Document> collection = db.getCollection("medical");
      //out.println("Collection Count: "+collection.count()+"<br />");

      // 
      // Create a sorted cursor ...
      //
      Document query2 = new Document("patient_id", 1);
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
            //out.println(z+"<br />");
/* 
{ "_id" : { "$oid" : "5ac4f2f1ded569daad0c45d3" }
, "patient_id" : 1
, "phone_number" : "803-345-6789"
, "medical_record_number" : "4483838"
, "email" : "raygun@aol.com"i
, "address" : "40 Presidential Dr"
, "patient" : { 
   "firstname" : "Ronald", "lastname" : "Reagan", "social_security_number" : "474-78-1234", "address" : "40 Presidential Dr", "city" : "Simi Valley", "zipcode" : "93065-0987", "dob" : "", "phone_number" : "803-345-6789", "email" : "raygun@aol.com" 
  }
, "patient_details" : {
  "phone_number" : "803-345-6789", "medical_record_number" : "4483838", "account_number" : "83-12345", "cc_number" : "4283897623459088" 
  } 
}
*/
            // Use the simple JSONParser below or should I use the BSON parser???

            JSONParser parser = new JSONParser();
            Object obj = parser.parse(z);
            JSONObject jsonObject = (JSONObject) obj;

            //for(Iterator iterator = jsonObject.keySet().iterator(); iterator.hasNext();) {
            //   String key = (String) iterator.next();
            //   out.println(key + "---" + jsonObject.get(key));
            //   //System.out.println("<br />");
            //}

            Long id = (Long) jsonObject.get("patient_id");
            String mrn = (String) jsonObject.get("medical_record_number");
            String addr = (String) jsonObject.get("address");
            String phone = (String) jsonObject.get("phone_number");
            String email = (String) jsonObject.get("email");
            String zstr = "";
            zstr = "<tr><td>"+id+"</td><td>"+mrn+"</td><td>"+addr+"</td><td>"+phone+"</td><td>"+email+"</td></tr>";
            if (i == 0) {
               out.println("<tr><th>Patient_Id</th><th>Medical Record No</th><th>Address</th><th>Phone Number</th><th>Email</th></tr>");
            }
            out.println(zstr);

            // 
            // Patient ...
            // 
            JSONObject pobj = (JSONObject) jsonObject.get("patient");

            String fname = (String) pobj.get("firstname");
            String lname = (String) pobj.get("lastname");
            String ssn = (String) pobj.get("social_security_number");
            String paddr = (String) pobj.get("address");
            String city = (String) pobj.get("city");
            String pzip = (String) pobj.get("zipcode");
            String phn = (String) pobj.get("phone_number");
            String pmail = (String) pobj.get("email");

            if (i == 0) {
               pstr = pstr + "<tr><th>Patient_Id</th><th>First_Name</th><th>Last_Name</th><th>SSN</th><th>Address</th><th>City</th><th>Zip</th><th>Phone Number</th><th>Email</th></tr>";
            }
            pstr = pstr + "<tr><td>"+id+"</td><td>"+fname+"</td><td>"+lname+"</td><td>"+ssn+"</td><td>"+paddr+"</td><td>"+city+"</td><td>"+pzip+"</td><td>"+phn+"</td><td>"+pmail+"</td></tr>";

            //out.println(pstr);


/*
, "patient_details" : {
  "phone_number" : "803-345-6789", "medical_record_number" : "4483838", "account_number" : "83-12345", "cc_number" : "4283897623459088"
  }
*/
            JSONObject pdobj = (JSONObject) jsonObject.get("patient_details");

            String pdact = (String) pdobj.get("account_number");
            String pdmrn = (String) pdobj.get("medical_record_number");
            String pdccn = (String) pdobj.get("cc_number");
            String pdphn = (String) pdobj.get("phone_number");

            if (i == 0) {
               pdstr = pdstr + "<tr><th>Medical Record No</th><th>Account No</th><th>Credit Card No</th><th>Phone Number</th></tr>";
            }
            pdstr = pdstr + "<tr><td>"+pdmrn+"</td><td>"+pdact+"</td><td>"+pdccn+"</td><td>"+pdphn+"</td></tr>";

            //out.println(pdstr);


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

%>
