<%@ page import="com.tripplanner.model.User" %>
<%@ page import="com.tripplanner.model.Trip" %>
<%@ page import="com.tripplanner.dao.TripDAO" %>

<%

User user =
    (User) session.getAttribute("loggedUser");

if (user == null) {
    response.sendRedirect("login.html");
    return;
}

int tripId;

try {

    tripId =
        Integer.parseInt(
            request.getParameter("id")
        );

} catch (Exception e) {

    response.sendRedirect("myTrips.jsp");
    return;
}


TripDAO dao = new TripDAO();

Trip trip =
    dao.getTripById(
        tripId,
        user.getUserId()
    );


if (trip == null) {

    response.sendRedirect("myTrips.jsp");
    return;
}

%>


<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Edit Trip</title>

<style>

body {
    font-family: Arial;
    background: #f4f7fb;
}

.container {
    width: 500px;
    margin: 50px auto;
    background: white;
    padding: 35px;
    border-radius: 15px;
}

label {
    display: block;
    margin-top: 16px;
    margin-bottom: 6px;
    font-weight: bold;
}

input {
    width: 100%;
    padding: 11px;
    box-sizing: border-box;
}

button {
    width: 100%;
    margin-top: 25px;
    padding: 13px;
    background: #2563eb;
    color: white;
    border: none;
    border-radius: 7px;
}

</style>

</head>

<body>


<div class="container">

<h1>Edit Trip</h1>


<form action="updateTrip"
      method="post">

<input type="hidden"
       name="tripId"
       value="<%= trip.getTripId() %>">


<label>Trip Name</label>

<input type="text"
       name="tripName"
       value="<%= trip.getTripName() %>"
       required>


<label>Starting City</label>

<input type="text"
       name="startCity"
       value="<%= trip.getStartCity() %>"
       required>


<label>Start Date</label>

<input type="date"
       name="startDate"
       value="<%= trip.getStartDate() %>"
       required>


<label>End Date</label>

<input type="date"
       name="endDate"
       value="<%= trip.getEndDate() %>"
       required>


<label>Total Budget</label>

<input type="number"
       name="budget"
       min="1"
       step="0.01"
       value="<%= trip.getTotalBudget() %>"
       required>


<button type="submit">
    Save Changes
</button>

</form>

</div>

</body>

</html>