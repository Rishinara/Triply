<%@ page import="java.util.List" %>
<%@ page import="com.tripplanner.model.User" %>
<%@ page import="com.tripplanner.model.Trip" %>
<%@ page import="com.tripplanner.model.Destination" %>
<%@ page import="com.tripplanner.model.TripPreference" %>
<%@ page import="com.tripplanner.dao.TripDAO" %>
<%@ page import="com.tripplanner.dao.DestinationDAO" %>
<%@ page import="com.tripplanner.dao.TripPreferenceDAO" %>
<%@ page import="com.tripplanner.dao.TripMemberDAO" %>
<%@ page import="com.tripplanner.dao.VoteDAO" %>

<%
User user = (User) session.getAttribute("loggedUser");

if (user == null) {
    response.sendRedirect("login.html");
    return;
}

String tripIdParam = request.getParameter("id");

if (tripIdParam == null) {
    response.sendRedirect("myTrips.jsp");
    return;
}

int tripId = Integer.parseInt(tripIdParam);

TripDAO tripDAO = new TripDAO();
DestinationDAO destinationDAO = new DestinationDAO();
TripPreferenceDAO preferenceDAO = new TripPreferenceDAO();
TripMemberDAO memberDAO = new TripMemberDAO();
VoteDAO voteDAO = new VoteDAO();

Trip trip = tripDAO.getAccessibleTripById(
        tripId, user.getUserId());

if (trip == null) {
    response.sendRedirect("myTrips.jsp");
    return;
}

TripPreference preference =
preferenceDAO.getPreference(tripId);

int travelers = memberDAO.getMemberCount(tripId);

if (travelers <= 0) {
    travelers = 1;
}

double budgetPerPerson =
        trip.getTotalBudget() / travelers;

String category = null;
String travelMonth = null;
int duration = 0;

if (preference != null) {
    category = preference.getCategory();
    travelMonth = preference.getTravelMonth();
    duration = preference.getDuration();
}

/*
 * Keep this call exactly the same as the method
 * already present in your DestinationDAO.
 */
 List<Destination> destinations =
 destinationDAO.getRecommendations(
         category,
         travelMonth,
         duration,
         budgetPerPerson);

int userVote = voteDAO.getUserVote(
        tripId, user.getUserId());

boolean organizer =
        trip.getCreatedBy() == user.getUserId();
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Triply - Destination Recommendations</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/style.css">

<style>

.recommend-page {
    padding-top: 35px;
    padding-bottom: 60px;
}

.recommend-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    gap: 25px;
    margin-bottom: 30px;
}

.recommend-header h1 {
    font-size: 38px;
    margin: 0 0 8px;
    color: var(--text);
}

.recommend-header p {
    margin: 0;
    color: var(--muted);
}

.trip-budget-box {
    background: #eaf5f5;
    border-radius: 16px;
    padding: 16px 20px;
    min-width: 220px;
}

.trip-budget-box small {
    display: block;
    color: var(--muted);
    margin-bottom: 5px;
}

.trip-budget-box strong {
    color: var(--primary);
    font-size: 20px;
}

.preference-bar {
    background: white;
    border: 1px solid var(--border);
    border-radius: 16px;

    padding: 18px 22px;
    margin-bottom: 30px;

    display: flex;
    flex-wrap: wrap;
    gap: 25px;
}

.preference-item {
    min-width: 120px;
}

.preference-item span {
    display: block;
    font-size: 12px;
    color: var(--muted);
    margin-bottom: 4px;
}

.preference-item strong {
    font-size: 14px;
    color: var(--text);
}

.destination-grid {
    display: grid;

    grid-template-columns:
        repeat(auto-fit, minmax(290px, 1fr));

    gap: 26px;
}

.destination-card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 22px;

    overflow: hidden;

    transition:
        transform 0.2s ease,
        box-shadow 0.2s ease;
}

.destination-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 16px 35px rgba(0,0,0,0.09);
}

.destination-image {
    position: relative;
    height: 230px;
    overflow: hidden;
    background: #dce7e7;
}

.destination-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;

    transition: transform 0.4s ease;
}

.destination-card:hover .destination-image img {
    transform: scale(1.05);
}

.category-badge {
    position: absolute;
    left: 15px;
    top: 15px;

    background: rgba(255,255,255,0.92);
    color: var(--primary);

    padding: 7px 12px;
    border-radius: 20px;

    font-size: 11px;
    font-weight: 800;
}

.vote-badge {
    position: absolute;
    right: 15px;
    top: 15px;

    background: rgba(23,37,42,0.88);
    color: white;

    padding: 7px 12px;
    border-radius: 20px;

    font-size: 12px;
    font-weight: 700;
}

.destination-content {
    padding: 22px;
}

.destination-title {
    margin: 0;
    font-size: 25px;
    color: var(--text);
}

.destination-state {
    color: var(--primary);
    font-weight: 700;
    margin-top: 5px;
}

.destination-description {
    color: var(--muted);
    font-size: 14px;
    line-height: 1.6;

    margin: 15px 0 18px;
    min-height: 45px;
}

.destination-details {
    border-top: 1px solid #eeeeea;
    border-bottom: 1px solid #eeeeea;

    padding: 12px 0;
    margin-bottom: 18px;
}

.detail-row {
    display: flex;
    justify-content: space-between;
    gap: 15px;

    padding: 6px 0;
    font-size: 13px;
}

.detail-label {
    color: var(--muted);
}

.detail-value {
    font-weight: 700;
    text-align: right;
}

.destination-actions {
    display: flex;
    gap: 9px;
    flex-wrap: wrap;
}

.destination-actions form {
    margin: 0;
}

.vote-button,
.finalize-button {
    border: none;
    cursor: pointer;

    padding: 11px 17px;
    border-radius: 9px;

    font-weight: 700;
    font-family: inherit;
}

.vote-button {
    background: var(--primary);
    color: white;
}

.vote-button:hover {
    background: var(--primary-dark);
}

.vote-button.selected {
    background: #dff1f2;
    color: var(--primary);
}

.finalize-button {
    background: #17252a;
    color: white;
}

.finalized-box {
    background: #eaf5f5;
    color: var(--primary);

    padding: 12px 14px;
    border-radius: 9px;

    font-size: 13px;
    font-weight: 800;
}

.final-destination {
    margin-bottom: 30px;

    background: #17363c;
    color: white;

    border-radius: 20px;
    padding: 25px;

    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
}

.final-destination h2 {
    margin: 0 0 7px;
}

.final-destination p {
    margin: 0;
    opacity: 0.8;
}

.explore-button {
    display: inline-block;

    background: white;
    color: #17363c;

    padding: 11px 17px;
    border-radius: 9px;

    text-decoration: none;
    font-weight: 800;
}

.empty-state {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;

    text-align: center;
    padding: 60px 25px;
}

.empty-state h2 {
    margin-top: 0;
}

.empty-state p {
    color: var(--muted);
}

.back-link {
    display: inline-block;
    margin-top: 30px;

    color: var(--primary);
    font-weight: 700;
    text-decoration: none;
}

@media(max-width: 700px) {

    .recommend-header {
        flex-direction: column;
        align-items: flex-start;
    }

    .trip-budget-box {
        width: 100%;
        box-sizing: border-box;
    }

    .destination-grid {
        grid-template-columns: 1fr;
    }

    .final-destination {
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


<main class="page-container recommend-page">


<div class="recommend-header">

    <div>

        <h1>Choose Your Destination</h1>

        <p>
            Vote together and decide where
            <strong><%= trip.getTripName() %></strong>
            should take you.
        </p>

    </div>


    <div class="trip-budget-box">

        <small>Budget per traveler</small>

        <strong>
            Rs. <%= String.format("%.2f",
                    budgetPerPerson) %>
        </strong>

    </div>

</div>


<div class="preference-bar">

    <div class="preference-item">
        <span>Travelers</span>
        <strong><%= travelers %></strong>
    </div>

    <div class="preference-item">
        <span>Interest</span>
        <strong>
            <%= category != null
                    ? category
                    : "Any" %>
        </strong>
    </div>

    <div class="preference-item">
        <span>Travel Month</span>
        <strong>
            <%= travelMonth != null
                    ? travelMonth
                    : "Flexible" %>
        </strong>
    </div>

    <div class="preference-item">
        <span>Duration</span>
        <strong>
            <%= duration > 0
                    ? duration + " days"
                    : "Flexible" %>
        </strong>
    </div>

</div>


<%
if (trip.getDestinationId() > 0) {

    Destination finalDestination =
            destinationDAO.getDestinationById(
                    trip.getDestinationId());

    if (finalDestination != null) {
%>

<div class="final-destination">

    <div>

        <h2>
            Final Destination:
            <%= finalDestination.getName() %>
        </h2>

        <p>
            Your group destination has been finalized.
            You can now explore places, hotels,
            restaurants and transport.
        </p>

    </div>

    <a class="explore-button"
       href="destinationDetails.jsp?id=<%= tripId %>">
        Explore Destination &rarr;
    </a>

</div>

<%
    }
}
%>


<%
if (destinations == null || destinations.isEmpty()) {
%>

<div class="empty-state">

    <h2>No matching destinations</h2>

    <p>
        Try changing the trip preferences,
        duration or budget.
    </p>

    <a href="tripDetails.jsp?id=<%= tripId %>"
       class="btn-primary">
        Back to Trip
    </a>

</div>

<%
} else {
%>


<div class="destination-grid">


<%
for (Destination destination : destinations) {

    int votes =
            voteDAO.getVoteCount(
                    tripId,
                    destination.getDestinationId());

    boolean selected =
            userVote == destination.getDestinationId();

    boolean finalized =
            trip.getDestinationId()
                    == destination.getDestinationId();

    String imageUrl =
            destination.getImageUrl();

    if (imageUrl == null ||
        imageUrl.trim().isEmpty()) {

        imageUrl =
            "images/hero/travel-hero.jpeg";
    }
%>


<div class="destination-card">


    <div class="destination-image">

        <img
          src="<%= request.getContextPath() %>/<%= imageUrl %>"
          alt="<%= destination.getName() %>">


        <span class="category-badge">
            <%= destination.getCategory() %>
        </span>


        <span class="vote-badge">
            Votes: <%= votes %>
        </span>

    </div>


    <div class="destination-content">


        <h2 class="destination-title">
            <%= destination.getName() %>
        </h2>


        <div class="destination-state">
            <%= destination.getState() %>
        </div>


        <div class="destination-description">
            <%= destination.getDescription() %>
        </div>


        <div class="destination-details">


            <div class="detail-row">

                <span class="detail-label">
                    Minimum budget
                </span>

                <span class="detail-value">
                    Rs.
                    <%= String.format(
                            "%.2f",
                            destination.getMinBudget()) %>
                </span>

            </div>


            <div class="detail-row">

                <span class="detail-label">
                    Recommended stay
                </span>

                <span class="detail-value">
                    <%= destination.getMinDays() %>
                    -
                    <%= destination.getMaxDays() %>
                    days
                </span>

            </div>


            <div class="detail-row">

                <span class="detail-label">
                    Best season
                </span>

                <span class="detail-value">
                    <%= destination.getBestSeason() %>
                </span>

            </div>


        </div>


        <div class="destination-actions">


            <%
            if (finalized) {
            %>

            <div class="finalized-box">
                Final Destination
            </div>

            <%
            } else if (trip.getDestinationId() <= 0) {
            %>


            <form action="vote"
                  method="post">

                <input type="hidden"
                       name="tripId"
                       value="<%= tripId %>">

                <input type="hidden"
                       name="destinationId"
                       value="<%= destination.getDestinationId() %>">

                <button type="submit"
                        class="vote-button <%= selected ? "selected" : "" %>">

                    <%= selected
                            ? "Your Vote"
                            : "Vote" %>

                </button>

            </form>


            <%
            if (organizer) {
            %>

            <form action="finalizeDestination"
                  method="post"
                  onsubmit="return confirm('Finalize <%= destination.getName() %> as the group destination?');">

                <input type="hidden"
                       name="tripId"
                       value="<%= tripId %>">

                <input type="hidden"
                       name="destinationId"
                       value="<%= destination.getDestinationId() %>">

                <button type="submit"
                        class="finalize-button">
                    Finalize
                </button>

            </form>

            <%
            }
            %>


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


<a href="tripDetails.jsp?id=<%= tripId %>"
   class="back-link">
    &larr; Back to Trip Details
</a>


</main>


<footer class="footer">

    Triply &nbsp; | &nbsp;
    Collaborative Budget-Based Trip Planner

</footer>


</body>
</html>