<%@ page import="com.tripplanner.model.User" %>

<%
User user =
    (User) session.getAttribute("loggedUser");

if (user == null) {
    response.sendRedirect("login.html");
    return;
}
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">
<title>Join Trip | Trip Planner</title>

<style>

body {
    font-family: Arial, sans-serif;
    background: #f4f7fb;
}

.container {
    width: 450px;
    margin: 100px auto;
    background: white;
    padding: 35px;
    border-radius: 15px;
    box-shadow: 0 8px 25px rgba(0,0,0,0.08);
}

h1 {
    margin-top: 0;
}

p {
    color: #6b7280;
}

input {
    width: 100%;
    padding: 13px;
    box-sizing: border-box;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    margin-top: 15px;
    text-transform: uppercase;
}

button {
    width: 100%;
    margin-top: 20px;
    padding: 13px;
    border: none;
    background: #2563eb;
    color: white;
    border-radius: 8px;
    cursor: pointer;
}

.error {
    color: #dc2626;
}

.success {
    color: #15803d;
}

.back {
    display: inline-block;
    margin-top: 20px;
    color: #2563eb;
    text-decoration: none;
}

</style>

</head>

<body>

<div class="container">

<h1>Join a Trip</h1>

<p>
Enter the invite code shared by your friend.
</p>

<%
String error = request.getParameter("error");

if ("invalid".equals(error)) {
%>

<p class="error">
    Invalid invite code.
</p>

<%
}

if ("already".equals(error)) {
%>

<p class="error">
    You are already part of this trip.
</p>

<%
}

if ("own".equals(error)) {
%>

<p class="error">
    You created this trip, so you're already the organizer.
</p>

<%
}

if ("server".equals(error)) {
%>

<p class="error">
    Unable to join the trip. Please try again.
</p>

<%
}

if ("true".equals(request.getParameter("joined"))) {
%>

<p class="success">
    Trip joined successfully!
</p>

<%
}
%>


<form action="joinTrip" method="post">

<input type="text"
       name="inviteCode"
       placeholder="Enter invite code"
       maxlength="20"
       required>

<button type="submit">
    Join Trip
</button>

</form>


<a href="dashboard.jsp"
   class="back">
    Back to Dashboard
</a>

</div>

</body>
</html>