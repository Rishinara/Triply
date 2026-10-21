<%@ page import="java.util.List" %>
<%@ page import="java.sql.Date" %>

<%@ page import="com.tripplanner.model.User" %>
<%@ page import="com.tripplanner.model.Trip" %>
<%@ page import="com.tripplanner.model.Place" %>
<%@ page import="com.tripplanner.model.Itinerary" %>

<%@ page import="com.tripplanner.dao.TripDAO" %>
<%@ page import="com.tripplanner.dao.PlaceDAO" %>
<%@ page import="com.tripplanner.dao.ItineraryDAO" %>

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
            request.getParameter("id"));
} catch (Exception e) {
    response.sendRedirect("myTrips.jsp");
    return;
}


TripDAO tripDAO =
    new TripDAO();

Trip trip =
    tripDAO.getAccessibleTripById(
        tripId,
        user.getUserId());


if (trip == null) {
    response.sendRedirect("myTrips.jsp");
    return;
}


boolean organizer =
    trip.getCreatedBy() == user.getUserId();


PlaceDAO placeDAO =
    new PlaceDAO();

List<Place> places =
    placeDAO.getPlacesByDestination(
        trip.getDestinationId());


ItineraryDAO itineraryDAO =
    new ItineraryDAO();

List<Itinerary> activities =
    itineraryDAO.getActivitiesByTrip(tripId);


double itineraryCost = 0;

for (Itinerary item : activities) {
    itineraryCost +=
        item.getEstimatedCost();
}
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Triply - Trip Itinerary</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/style.css">

<style>

.itinerary-page {
    padding-top: 30px;
    padding-bottom: 60px;
}

.back-link {
    display: inline-block;
    color: var(--primary);
    text-decoration: none;
    font-weight: 700;
    margin-bottom: 20px;
}

/* HEADER */

.itinerary-header {
    background: #17363c;
    color: white;
    border-radius: 22px;
    padding: 32px;

    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 25px;

    margin-bottom: 25px;
}

.itinerary-header h1 {
    margin: 0 0 8px;
    font-size: 38px;
}

.itinerary-header p {
    margin: 5px 0;
    opacity: 0.8;
}

.cost-box {
    background: rgba(255,255,255,0.1);
    border-radius: 16px;
    padding: 18px 22px;
    min-width: 190px;
}

.cost-box span {
    display: block;
    font-size: 12px;
    opacity: 0.7;
    margin-bottom: 6px;
}

.cost-box strong {
    font-size: 23px;
}


/* MESSAGES */

.message {
    padding: 14px 17px;
    border-radius: 11px;
    margin-bottom: 20px;
    font-weight: 600;
}

.success {
    background: #ecfdf3;
    color: #166534;
}

.error {
    background: #fef2f2;
    color: #b91c1c;
}


/* ADD FORM */

.planner-card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;
    padding: 27px;
    margin-bottom: 35px;
}

.planner-card h2 {
    margin: 0 0 6px;
}

.section-subtitle {
    color: var(--muted);
    margin: 0 0 23px;
}

.form-grid {
    display: grid;
    grid-template-columns:
        repeat(2, minmax(0, 1fr));
    gap: 18px;
}

.form-group label {
    display: block;
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 7px;
}

.form-group input,
.form-group select,
.form-group textarea {
    width: 100%;
    box-sizing: border-box;

    padding: 11px 12px;

    border: 1px solid #d8ddd9;
    border-radius: 9px;

    font-family: inherit;
    font-size: 14px;

    background: white;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
    outline: none;
    border-color: var(--primary);
}

.full-width {
    grid-column: 1 / -1;
}

.form-group textarea {
    min-height: 90px;
    resize: vertical;
}

.add-button {
    border: none;
    background: var(--primary);
    color: white;

    padding: 12px 19px;
    border-radius: 9px;

    cursor: pointer;
    font-weight: 800;
    font-family: inherit;

    margin-top: 18px;
}

.add-button:hover {
    background: var(--primary-dark);
}


/* TIMELINE */

.timeline-heading {
    margin: 40px 0 25px;
}

.timeline-heading h2 {
    font-size: 30px;
    margin: 0 0 6px;
}

.timeline-heading p {
    color: var(--muted);
    margin: 0;
}

.day-block {
    margin-bottom: 35px;
}

.day-title {
    display: inline-block;

    background: #e5f3f3;
    color: var(--primary);

    padding: 9px 15px;
    border-radius: 20px;

    font-size: 14px;
    font-weight: 800;

    margin-bottom: 15px;
}

.activity-card {
    position: relative;

    background: white;
    border: 1px solid var(--border);
    border-radius: 17px;

    padding: 20px 22px 20px 28px;
    margin-bottom: 13px;

    display: grid;
    grid-template-columns: 120px 1fr auto;
    gap: 20px;
    align-items: center;
}

.activity-card:before {
    content: "";
    position: absolute;

    left: 0;
    top: 17px;
    bottom: 17px;

    width: 5px;
    border-radius: 5px;

    background: var(--primary);
}

.activity-time {
    color: var(--primary);
    font-weight: 800;
    font-size: 14px;
}

.activity-main h3 {
    margin: 0 0 6px;
    font-size: 19px;
}

.activity-main p {
    margin: 4px 0;
    color: var(--muted);
    font-size: 13px;
}

.activity-cost {
    font-weight: 800;
    margin-top: 7px;
}

.delete-button {
    border: none;

    background: #fff0f0;
    color: #b91c1c;

    padding: 9px 13px;
    border-radius: 8px;

    cursor: pointer;
    font-weight: 700;
}

.empty-state {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;

    padding: 50px 25px;
    text-align: center;

    color: var(--muted);
}


/* EXPENSE CTA */

.expense-cta {
    margin-top: 40px;

    background: #e8f4f4;
    border-radius: 20px;
    padding: 28px;

    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 25px;
}

.expense-cta h2 {
    margin: 0 0 7px;
}

.expense-cta p {
    color: var(--muted);
    margin: 0;
}

@media(max-width:750px) {

    .itinerary-header {
        flex-direction: column;
        align-items: flex-start;
    }

    .form-grid {
        grid-template-columns: 1fr;
    }

    .full-width {
        grid-column: auto;
    }

    .activity-card {
        grid-template-columns: 1fr;
        gap: 8px;
    }

    .expense-cta {
        flex-direction: column;
        align-items: flex-start;
    }
}

</style>

</head>


<body>


<nav class="navbar">

    <a href="dashboard.jsp"
       class="logo">
        Triply
    </a>

    <div class="nav-links">

        <a href="dashboard.jsp">Home</a>

        <a href="myTrips.jsp">My Trips</a>

        <a href="joinTrip.jsp">Join Trip</a>

        <span class="nav-user">
            Hi, <%= user.getName() %>
        </span>

        <a href="logout"
           class="btn-primary">
            Logout
        </a>

    </div>

</nav>


<main class="page-container itinerary-page">


<a href="destinationDetails.jsp?id=<%= tripId %>"
   class="back-link">
    &larr; Back to Destination
</a>


<section class="itinerary-header">

    <div>

        <h1>Day-wise Itinerary</h1>

        <p>
            <strong><%= trip.getTripName() %></strong>
        </p>

        <p>
            <%= trip.getStartDate() %>
            to
            <%= trip.getEndDate() %>
        </p>

    </div>


    <div class="cost-box">

        <span>Planned Activity Cost</span>

        <strong>
            Rs. <%= String.format(
                    "%.2f",
                    itineraryCost) %>
        </strong>

    </div>

</section>


<%
if ("true".equals(
        request.getParameter("added"))) {
%>

<div class="message success">
    Activity added successfully.
</div>

<%
}
%>


<%
if ("true".equals(
        request.getParameter("deleted"))) {
%>

<div class="message success">
    Activity deleted successfully.
</div>

<%
}
%>


<%
String error =
    request.getParameter("error");

if (error != null) {

    String message =
        "Unable to save activity.";

    if ("date".equals(error)) {

        message =
            "Activity date must be inside the trip dates.";

    } else if ("time".equals(error)) {

        message =
            "End time must be after start time.";

    } else if ("conflict".equals(error)) {

        message =
            "Time conflict detected. Another activity is already scheduled during this time.";

    } else if ("cost".equals(error)) {

        message =
            "Estimated cost cannot be negative.";

    } else if ("name".equals(error)) {

        message =
            "Please enter an activity name.";
    }
%>

<div class="message error">
    <%= message %>
</div>

<%
}
%>


<!-- ADD ACTIVITY -->

<%
if (organizer) {
%>

<section class="planner-card">

<h2>Add Activity</h2>

<p class="section-subtitle">
    Choose a suggested place or create
    your own activity.
</p>


<form action="addActivity"
      method="post">

<input type="hidden"
       name="tripId"
       value="<%= tripId %>">


<div class="form-grid">


<div class="form-group">

    <label>Suggested Place</label>

    <select name="placeId"
            id="placeId"
            onchange="fillPlaceName()">

        <option value="">
            Custom Activity
        </option>

        <%
        for (Place p : places) {
        %>

        <option
            value="<%= p.getPlaceId() %>"
            data-name="<%= p.getPlaceName() %>"
            data-cost="<%= p.getEntryFee() %>">

            <%= p.getPlaceName() %>

        </option>

        <%
        }
        %>

    </select>

</div>


<div class="form-group">

    <label>Activity Name</label>

    <input type="text"
           name="activityName"
           id="activityName"
           placeholder="Example: River rafting"
           required>

</div>


<div class="form-group">

    <label>Date</label>

    <input type="date"
           name="activityDate"
           min="<%= trip.getStartDate() %>"
           max="<%= trip.getEndDate() %>"
           required>

</div>


<div class="form-group">

    <label>Estimated Cost</label>

    <input type="number"
           name="estimatedCost"
           id="estimatedCost"
           min="0"
           step="0.01"
           value="0">

</div>


<div class="form-group">

    <label>Start Time</label>

    <input type="time"
           name="startTime"
           required>

</div>


<div class="form-group">

    <label>End Time</label>

    <input type="time"
           name="endTime"
           required>

</div>


<div class="form-group full-width">

    <label>Notes</label>

    <textarea name="notes"
              placeholder="Optional notes about this activity"></textarea>

</div>


</div>


<button type="submit"
        class="add-button">
    Add to Itinerary
</button>


</form>

</section>

<%
}
%>


<!-- ACTIVITIES -->

<section>

<div class="timeline-heading">

    <h2>Your Trip Plan</h2>

    <p>
        Activities are organized day by day
        and time conflicts are automatically checked.
    </p>

</div>


<%
if (activities == null ||
    activities.isEmpty()) {
%>

<div class="empty-state">

    No activities have been planned yet.

</div>

<%
} else {

    Date previousDate = null;

    for (Itinerary item : activities) {

        if (previousDate == null ||
            !previousDate.equals(
                item.getActivityDate())) {

            if (previousDate != null) {
%>



<%
            }
%>


<div class="day-block">

    <div class="day-title">
        <%= item.getActivityDate() %>
    </div>


<%
            previousDate =
                item.getActivityDate();
        }
%>


<div class="activity-card">


    <div class="activity-time">

        <%= item.getStartTime() %>
        -
        <%= item.getEndTime() %>

    </div>


    <div class="activity-main">

        <h3>
            <%= item.getActivityName() %>
        </h3>

        <div class="activity-cost">

            Estimated Cost:
            Rs. <%= String.format(
                    "%.2f",
                    item.getEstimatedCost()) %>

        </div>


        <%
        if (item.getNotes() != null &&
            !item.getNotes().trim().isEmpty()) {
        %>

        <p>
            <%= item.getNotes() %>
        </p>

        <%
        }
        %>

    </div>


    <%
    if (organizer) {
    %>

    <form action="deleteActivity"
          method="post"
          onsubmit="return confirm('Delete this activity?');">

        <input type="hidden"
               name="tripId"
               value="<%= tripId %>">

        <input type="hidden"
               name="itineraryId"
               value="<%= item.getItineraryId() %>">

        <button type="submit"
                class="delete-button">
            Delete
        </button>

    </form>

    <%
    }
    %>


</div>


<%
    }

    if (previousDate != null) {
%>

</div>

<%
    }
}
%>


</section>


<!-- EXPENSES -->

<section class="expense-cta">

    <div>

        <h2>Track Trip Expenses</h2>

        <p>
            Record actual spending and split
            expenses among your group.
        </p>

    </div>

    <a href="expenses.jsp?id=<%= tripId %>"
       class="btn-primary">
        Manage Expenses &rarr;
    </a>

</section>


</main>


<footer class="footer">

    Triply &nbsp; | &nbsp;
    Collaborative Budget-Based Trip Planner

</footer>


<script>

function fillPlaceName() {

    var select =
        document.getElementById("placeId");

    var option =
        select.options[
            select.selectedIndex
        ];

    var name =
        option.getAttribute("data-name");

    var cost =
        option.getAttribute("data-cost");


    if (name) {

        document.getElementById(
            "activityName"
        ).value = name;

    } else {

        document.getElementById(
            "activityName"
        ).value = "";
    }


    if (cost) {

        document.getElementById(
            "estimatedCost"
        ).value = cost;

    } else {

        document.getElementById(
            "estimatedCost"
        ).value = "0";
    }
}

</script>


</body>
</html>