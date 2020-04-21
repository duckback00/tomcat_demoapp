<%!
// 
// Just run local shell commands for now ... 
// FUTURE: Convert to API calls directly to Engine 
//
public String doCommand(String cmd){
   String directory = "";
   try {
      int exitCode;
      // out.println("Setting Shell Environment ...");
      String [] params = new String[]{"/bin/bash", "-c", "cd "+System.getProperty("user.home")+";. ./.delphix_profile 1> /dev/null;set -e;" + cmd };
      //String [] params = new String[]{"/bin/bash", "-c", "cd "+System.getProperty("user.home")+";. ./.delphix_profile 1> /dev/null;set -e;" + ""+request.getParameter("dir")};
      int c;
      BufferedReader b;
      // System.out.println("Parameters ..."+params);
      Process subProc = Runtime.getRuntime().exec(params);
      StringBuffer sb = new StringBuffer();
      // System.out.println("Opening Buffer for Reading ...");
      b = new BufferedReader(new InputStreamReader(subProc.getInputStream()));
      c = b.read();
      while (c != -1) {
        sb.append((char)c);
        c = b.read();
      }
      b.close();
      // System.out.println("Buffer Closed ...");
      exitCode = subProc.waitFor();
      if (exitCode != 0) {
        sb = new StringBuffer();
        b = new BufferedReader(new InputStreamReader(subProc.getErrorStream()));
        c = b.read();
        while (c != -1) {
           sb.append((char)c);
           c = b.read();
        }    //end while
        b.close();
        System.out.println("ERROR: Output from 'doCommand' "+ sb.toString());
      } else {
         //System.out.println("Output from 'doCommand' "+ sb.toString());
         directory =  sb.toString().trim();
      }
   } catch(Exception e) {
      System.out.println("ERROR: "+e.getMessage());
   }
   return directory;
}



public String getJob(String job){
   String str = doCommand("/Users/abitterman/Development/APIs/book/API/job_status.sh "+job+"");
   System.out.println(str+"<br />");
   String jobstate = "";
   String percentcomplete = "";
   try {
      if (str != "") {
         JSONParser parser = new JSONParser();
         JSONObject jsonObject = (JSONObject) parser.parse(str);
         jobstate = (String) jsonObject.get("JobState");
         percentcomplete = (String) jsonObject.get("PercentComplete");
         System.out.println(jobstate+" "+percentcomplete);
      }
   } catch(Exception e) {
      System.out.println("ERROR: "+e.getMessage());
   }
   String result = "[ \""+jobstate+"\", \""+percentcomplete+"\" ]";
   return result;
}


public boolean isJSONValid(String test) {
    try {
        JSONParser parser = new JSONParser();
        JSONObject obj = (JSONObject) parser.parse(test);
    } catch (Exception ex) {
        // e.g. in case JSONArray is valid as well...
        try {
        JSONParser parser1 = new JSONParser();
         JSONArray arr = (JSONArray) parser1.parse(test);
        } catch (Exception ex1) {
            return false;
        }
    }
    return true;
}

/**
 * Sample usage:
 * <pre>
 * Writer writer = new JSONWriter(); // this writer adds indentation
 * jsonobject.writeJSONString(writer);
 * System.out.println(writer.toString());
 * </pre>
 * 
 * @author Elad Tabak
 * @author Maciej Komosinski, minor improvements, 2015
 * @since 28-Nov-2011
 * @version 0.2
 */
public class JSONWriter extends StringWriter
{
	final static String indentstring = "  "; //define as you wish
	final static String spaceaftercolon = " "; //use "" if you don't want space after colon

	private int indentlevel = 0;

	@Override
	public void write(int c)
	{
		char ch = (char) c;
		if (ch == '[' || ch == '{')
		{
			super.write(c);
			super.write('\n');
			indentlevel++;
			writeIndentation();
		} else if (ch == ',')
		{
			super.write(c);
			super.write('\n');
			writeIndentation();
		} else if (ch == ']' || ch == '}')
		{
			super.write('\n');
			indentlevel--;
			writeIndentation();
			super.write(c);
		} else if (ch == ':')
		{
			super.write(c);
			super.write(spaceaftercolon);
		} else
		{
			super.write(c);
		}

	}

	private void writeIndentation()
	{
		for (int i = 0; i < indentlevel; i++)
		{
			super.write(indentstring);
		}
	}
}

%>
