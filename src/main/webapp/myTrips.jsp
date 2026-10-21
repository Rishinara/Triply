<%@ page import="java.util.List" %>
<%@ page import="com.tripplanner.model.User" %>
<%@ page import="com.tripplanner.model.Trip" %>
<%@ page import="com.tripplanner.model.Destination" %>
<%@ page import="com.tripplanner.dao.TripDAO" %>
<%@ page import="com.tripplanner.dao.DestinationDAO" %>

<%
User user = (User) session.getAttribute("loggedUser");

if (user == null) {
    response.sendRedirect("login.html");
    return;
}

TripDAO tripDAO = new TripDAO();
DestinationDAO destinationDAO = new DestinationDAO();

List<Trip> trips =
    tripDAO.getTripsByUser(user.getUserId());
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Triply - My Trips</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/style.css">

<style>

.trips-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
    margin-bottom: 30px;
}

.trips-header h1 {
    font-size: 38px;
    margin: 0 0 8px;
}

.trips-header p {
    margin: 0;
    color: var(--muted);
}

.trip-grid {
    display: grid;
    grid-template-columns:
        repeat(auto-fit, minmax(310px, 1fr));
    gap: 25px;
}

.trip-card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;
    overflow: hidden;
    transition: transform 0.2s ease,
                box-shadow 0.2s ease;
}

.trip-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 35px rgba(0,0,0,0.08);
}

.trip-image {
    width: 100%;
    height: 220px;
    position: relative;
    overflow: hidden;
    background: #dce7e7;
}

.trip-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.4s ease;
}

.trip-card:hover .trip-image img {
    transform: scale(1.04);
}

.status-badge {
    position: absolute;
    top: 15px;
    right: 15px;

    background: rgba(255,255,255,0.92);
    color: var(--text);

    padding: 7px 12px;
    border-radius: 20px;

    font-size: 12px;
    font-weight: 800;
}

.trip-content {
    padding: 22px;
}

.trip-title-row {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    align-items: flex-start;
}

.trip-title {
    margin: 0;
    font-size: 24px;
}

.destination-name {
    color: var(--primary);
    font-weight: 700;
    margin-top: 6px;
}

.trip-info {
    margin: 20px 0;
}

.info-row {
    display: flex;
    justify-content: space-between;
    gap: 15px;

    padding: 9px 0;
    border-bottom: 1px solid #eeeeea;

    font-size: 14px;
}

.info-label {
    color: var(--muted);
}

.info-value {
    font-weight: 700;
    text-align: right;
}

.invite-box {
    background: #eef7f7;
    padding: 11px 13px;
    border-radius: 9px;
    margin-bottom: 18px;
    font-size: 13px;
}

.invite-code {
    color: var(--primary);
    font-weight: 800;
    letter-spacing: 1px;
}

.trip-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.trip-action {
    display: inline-block;
    padding: 10px 14px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 700;
    text-decoration: none;
}

.view-btn {
    background: var(--primary);
    color: white;
}

.summary-btn {
    background: #e4f3f4;
    color: var(--primary);
}

.edit-btn {
    background: #f3f4f6;
    color: #374151;
}

.delete-btn {
    background: #fff1f1;
    color: #b91c1c;
}

.empty-state {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;

    padding: 70px 30px;
    text-align: center;
}

.empty-state h2 {
    font-size: 28px;
}

.empty-state p {
    color: var(--muted);
    margin-bottom: 25px;
}

@media(max-width: 700px) {

    .trips-header {
        align-items: flex-start;
        flex-direction: column;
    }

    .trip-grid {
        grid-template-columns: 1fr;
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

        <a href="dashboard.jsp">
            Home
        </a>

        <a href="myTrips.jsp">
            My Trips
        </a>

        <a href="joinTrip.jsp">
            Join Trip
        </a>

        <span class="nav-user">
            Hi, <%= user.getName() %>
        </span>

        <a href="logout"
           class="btn-primary">
            Logout
        </a>

    </div>

</nav>


<main class="page-container">


<div class="trips-header">

    <div>

        <h1>My Trips</h1>

        <p>
            Your adventures, plans and memories
            all in one place.
        </p>

    </div>

    <a href="createTrip.jsp"
       class="btn-primary">
        Plan New Trip
    </a>

</div>


<%
if ("joined".equals(request.getParameter("success"))) {
%>

<div style="
    background:#ecfdf3;
    color:#166534;
    padding:14px;
    border-radius:10px;
    margin-bottom:20px;
">
    You joined the trip successfully.
</div>

<%
}
%>


<%
if (trips == null || trips.isEmpty()) {
%>


<div class="empty-state">

    <h2>No adventures yet</h2>

    <p>
        Create your first group trip and start
        planning something memorable.
    </p>

    <a href="createTrip.jsp"
       class="btn-primary">
        Create My First Trip
    </a>

</div>


<%
} else {
%>


<div class="trip-grid">


<%
for (Trip trip : trips) {

    Destination destination = null;

    if (trip.getDestinationId() > 0) {

        destination =
            destinationDAO.getDestinationById(
                trip.getDestinationId());
    }


    String imageUrl =
        "images/hero/travel-hero.jpeg";

    String destinationName =
        "Destination not finalized";

    if (destination != null) {

        destinationName =
            destination.getName();

        if (destination.getImageUrl() != null &&
            !destination.getImageUrl().trim().isEmpty()) {

            imageUrl =
                destination.getImageUrl();
        }
    }


    String status =
        tripDAO.getAutomaticStatus(trip);

    boolean organizer =
        trip.getCreatedBy() == user.getUserId();
%>


<div class="trip-card">


    <div class="trip-image">

        <img src="<%= request.getContextPath() %>/<%= imageUrl %>"
             alt="<%= destinationName %>">

        <span class="status-badge">
            <%= status %>
        </span>

    </div>


    <div class="trip-content">


        <div class="trip-title-row">

            <div>

                <h2 class="trip-title">
                    <%= trip.getTripName() %>
                </h2>

                <div class="destination-name">
                    <%= destinationName %>
                </div>

            </div>

        </div>


        <div class="trip-info">


            <div class="info-row">

                <span class="info-label">
                    Starting from
                </span>

                <span class="info-value">
                    <%= trip.getStartCity() %>
                </span>

            </div>


            <div class="info-row">

                <span class="info-label">
                    Dates
                </span>

                <span class="info-value">
                    <%= trip.getStartDate() %>
                    -
                    <%= trip.getEndDate() %>
                </span>

            </div>


            <div class="info-row">

                <span class="info-label">
                    Budget
                </span>

                <span class="info-value">
                    Rs.
                    <%= String.format(
                        "%.2f",
                        trip.getTotalBudget()) %>
                </span>

            </div>


        </div>


        <div class="invite-box">

            Invite Code:

            <span class="invite-code">
                <%= trip.getInviteCode() %>
            </span>

        </div>


        <div class="trip-actions">


            <a href="tripDetails.jsp?id=<%= trip.getTripId() %>"
               class="trip-action view-btn">
                View Trip
            </a>


            <a href="tripSummary.jsp?id=<%= trip.getTripId() %>"
               class="trip-action summary-btn">
                Summary
            </a>


            <%
            if (organizer) {
            %>

            <a href="editTrip.jsp?id=<%= trip.getTripId() %>"
               class="trip-action edit-btn">
                Edit
            </a>


            <a href="deleteTrip?id=<%= trip.getTripId() %>"
               class="trip-action delete-btn"
               onclick="return confirm('Delete this trip?');">
                Delete
            </a>

            <%
            }
            %>


        </div>

    </div>

</div>


<%
}
%>


</div>

<%
}
%>


</main>


<footer class="footer">

    Triply &nbsp; | &nbsp;
    Collaborative Budget-Based Trip Planner

</footer>


</body>

</html>