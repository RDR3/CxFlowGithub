<%@ page import="java.sql.*" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ include file="/dbconnection.jspf" %>

<%
String username = (String) request.getParameter("username");
String password1 = (String) request.getParameter("password1");
String password2 = (String) request.getParameter("password2");
String usertype = (String) session.getAttribute("usertype");
String userid = (String) session.getAttribute("userid");
String debug = "";
String result = null;
boolean registered = false;

if (request.getMethod().equals("POST") && username != null) {
	if (username == null || username.length() < 5) {
		result = "You must supply a username of at least 5 characters.";
	
	} else if (username.indexOf("@") < 0) {
		result = "Invalid username - please supply a valid email address.";

	} else if (password1 == null || password1.length() < 5) {
		result = "You must supply a password of at least 5 characters.";

	} else if (password1.equals(password2)) {
		//Statement stmt = conn.createStatement();
		//Security Fix
		PreparedStatement ps1 = conn.prepareStatement(sql);
		PreparedStatement ps2 = conn.prepareStatement(sql2);
		try {
            ResultSet rs = null;
            try {
                //stmt.executeQuery("INSERT INTO Users (name, type, password) VALUES ('" + username + "', 'USER', '" + password1 + "')");
                //rs = stmt.executeQuery("SELECT * FROM Users WHERE (name = '" + username + "' AND password = '" + password1 + "')");
                //Security Fix
                String sql1 = "INSERT INTO Users (name, type, password) VALUES ( ? , 'USER', ? )";
                prepareStatement.setString(1, username);
                prepareStatement.setString(2, password1);
                prepareStatement.executeQuery();
                String sql2 = "SELECT * FROM Users WHERE (name = ? AND password = ? )";
                prepareStatement.setString(1, username);
                prepareStatement.setString(2, password1);
                rs = prepareStatement.executeQuery();
                rs.next();
                userid =  "" + rs.getInt("userid");

                session.setAttribute("username", username);
                session.setAttribute("usertype", "USER");
                session.setAttribute("userid", userid);


                if (username.replaceAll("\\s", "").toLowerCase().indexOf("<script>alert(\"xss\")</script>") >= 0) {
                    conn.createStatement().execute("UPDATE Score SET status = 1 WHERE task = 'XSS_USER'");
                }

                registered = true;

                // Update basket
                Cookie[] cookies = request.getCookies();
                String basketId = null;
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        if (cookie.getName().equals("b_id") && cookie.getValue().length() > 0) {
                            basketId = cookie.getValue();
                            break;
                        }
                    }
                }
                if (basketId != null) {
                    debug +=  " userId = " + userid + " basketId = " + basketId;
                    // TODO breaks basket scoring :(
                    //stmt.execute("UPDATE Users SET currentbasketid = " + basketId + " WHERE userid = " + userid);
                    //stmt.execute("UPDATE Baskets SET userid = " + userid + " WHERE basketid = " + basketId);
                    //Security Fix
                    PreparedStatement ps3 = conn.prepareStatement(sql3);
                    PreparedStatement ps4 = conn.prepareStatement(sql4);
                    try {
                        String sql3 = "UPDATE Users SET currentbasketid = ? WHERE userid = ?";
                        prepareStatement.setString(1, basketId);
                        prepareStatement.setString(2, userid);
                        prepareStatement.executeQuery();
                        String sql4 = "UPDATE Baskets SET userid = ? WHERE basketid = ?";
                        prepareStatement.setString(1, userid);
                        prepareStatement.setString(2, basketid);
                        prepareStatement.executeQuery();
                        response.addCookie(new Cookie("b_id", ""));
                    }
                }

            } catch (SQLException e) {
                if (e.getMessage().indexOf("Unique constraint violation") >= 0) {
                    result = "A user with this name already exists.";
                } else {
                    if ("true".equals(request.getParameter("debug"))) {
                        conn.createStatement().execute("UPDATE Score SET status = 1 WHERE task = 'HIDDEN_DEBUG'");
                        out.println("DEBUG System error: " + e + "<br/><br/>");
                    } else {
                        out.println("System error.");
                    }
                }
            } catch (Exception e) {
                if ("true".equals(request.getParameter("debug"))) {
                    conn.createStatement().execute("UPDATE Score SET status = 1 WHERE task = 'HIDDEN_DEBUG'");
                    out.println("DEBUG System error: " + e + "<br/><br/>");
                } else {
                    out.println("System error.");
                }
            } finally {
                prepareStatement.close();
            }
        }
	} else {
		result = "The passwords you have supplied are different.";
	}
}
%>

<jsp:include page="/header.jsp"/>
<h3>Register</h3>
<%
if ("true".equals(request.getParameter("debug"))) {
	conn.createStatement().execute("UPDATE Score SET status = 1 WHERE task = 'HIDDEN_DEBUG'");
	out.println("DEBUG: " + debug + "<br/><br/>");
}

if (registered) {
	out.println("<br/>You have successfully registered with The BodgeIt Store.");
%>
	<jsp:include page="/footer.jsp"/>
<%
	return;
	
} else if (result != null) {
	out.println("<p style=\"color:red\">" + result + "</p><br/>");
}
%>

Please enter the following details to register with us: <br/><br/>
<form method="POST">
	<center>
	<table>
	<tr>
		<td>Username (your email address):</td>
		<td><input id="username" name="username"></input></td>
	</tr>
	<tr>
		<td>Password:</td>
		<td><input id="password1" name="password1" type="password"></input></td>
	</tr>
	<tr>
		<td>Confirm Password:</td>
		<td><input id="password2" name="password2" type="password"></input></td>
	</tr>
	<tr>
		<td></td>
		<td><input id="submit" type="submit" value="Register"></input></td>
	</tr>
	</table>
	</center>
</form>

<jsp:include page="/footer.jsp"/>

