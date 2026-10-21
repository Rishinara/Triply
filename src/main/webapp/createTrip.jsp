<%@ page import="com.tripplanner.model.User" %>

<%
User user = (User) session.getAttribute("loggedUser");

if (user == null) {
    response.sendRedirect("login.html");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">
<title>Create Trip | Trip Planner</title>

<style>

body {
    font-family: Arial, sans-serif;
    background: #f4f7fb;
    margin: 0;
}

.container {
    width: 500px;
    margin: 50px auto;
    background: white;
    padding: 35px;
    border-radius: 15px;
    box-shadow: 0 8px 25px rgba(0,0,0,0.08);
}

h1 {
    margin-top: 0;
}

label {
    display: block;
    margin-top: 18px;
    margin-bottom: 7px;
    font-weight: bold;
}

input {
    width: 100%;
    padding: 12px;
    box-sizing: border-box;
    border: 1px solid #d1d5db;
    border-radius: 8px;
}

button {
    width: 100%;
    margin-top: 25px;
    padding: 13px;
    background: #2563eb;
    border: none;
    color: white;
    border-radius: 8px;
    cursor: pointer;
    font-size: 16px;
}

.back {
    display: inline-block;
    margin-top: 20px;
    text-decoration: none;
    color: #2563eb;
}

.error {
    color: #dc2626;
}

</style>

</head>

<body>

<div class="container">

<h1>Create a New Trip</h1>

<p>Enter the basic details. You can invite friends after creating it.</p>

<%
if (request.getParameter("error") != null) {
%>

<p class="error">
    Please check your trip details.
</p>

<%
}
%>


<form action="createTrip"
      method="post"
      onsubmit="return validateTrip()">

<label>Trip Name</label>

<input type="text"
       name="tripName"
       id="tripName"
       placeholder="Example: Goa Trip"
       required>


<label>Starting City</label>

<input type="text"
       name="startCity"
       id="startCity"
       placeholder="Example: Hyderabad"
       required>


<label>Start Date</label>

<input type="date"
       name="startDate"
       id="startDate"
       required>


<label>End Date</label>

<input type="date"
       name="endDate"
       id="endDate"
       required>


<label>Total Group Budget</label>

<input type="number"
       name="budget"
       id="budget"
       min="1"
       step="0.01"
       placeholder="Example: 50000"
       required>


<button type="submit">
    Create Trip
</button>

</form>


<a href="dashboard.jsp"
   class="back">
    Back to Dashboard
</a>

</div>


<script>

function validateTrip() {

    const start =
        document.getElementById("startDate").value;

    const end =
        document.getElementById("endDate").value;

    const budget =
        Number(document.getElementById("budget").value);


    if (end < start) {

        alert("End date cannot be before start date.");
        return false;
    }


    if (budget <= 0) {

        alert("Budget must be greater than zero.");
        return false;
    }


    return true;
}

</script>

</body>
</html>