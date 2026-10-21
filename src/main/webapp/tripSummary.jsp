<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%@ page import="com.tripplanner.model.User" %>
<%@ page import="com.tripplanner.model.Trip" %>
<%@ page import="com.tripplanner.model.TripMember" %>
<%@ page import="com.tripplanner.model.Destination" %>
<%@ page import="com.tripplanner.model.Hotel" %>
<%@ page import="com.tripplanner.model.Transport" %>
<%@ page import="com.tripplanner.model.Itinerary" %>
<%@ page import="com.tripplanner.model.Expense" %>

<%@ page import="com.tripplanner.dao.TripDAO" %>
<%@ page import="com.tripplanner.dao.TripMemberDAO" %>
<%@ page import="com.tripplanner.dao.DestinationDAO" %>
<%@ page import="com.tripplanner.dao.HotelDAO" %>
<%@ page import="com.tripplanner.dao.TransportDAO" %>
<%@ page import="com.tripplanner.dao.ItineraryDAO" %>
<%@ page import="com.tripplanner.dao.ExpenseDAO" %>

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


String status =
    tripDAO.getAutomaticStatus(trip);


TripMemberDAO memberDAO =
    new TripMemberDAO();

List<TripMember> members =
    memberDAO.getMembers(tripId);

int travelerCount =
    members == null ? 0 : members.size();

if (travelerCount <= 0) {
    travelerCount = 1;
}


Destination destination = null;

if (trip.getDestinationId() > 0) {

    DestinationDAO destinationDAO =
        new DestinationDAO();

    destination =
        destinationDAO.getDestinationById(
            trip.getDestinationId());
}


Hotel hotel = null;

if (trip.getHotelId() > 0) {

    HotelDAO hotelDAO =
        new HotelDAO();

    hotel =
        hotelDAO.getHotelById(
            trip.getHotelId());
}


Transport transport = null;

if (trip.getTransportId() > 0) {

    TransportDAO transportDAO =
        new TransportDAO();

    transport =
        transportDAO.getTransportById(
            trip.getTransportId());
}


ItineraryDAO itineraryDAO =
    new ItineraryDAO();

List<Itinerary> activities =
    itineraryDAO.getActivitiesByTrip(tripId);


ExpenseDAO expenseDAO =
    new ExpenseDAO();

List<Expense> expenses =
    expenseDAO.getExpensesByTrip(tripId);

double totalSpent =
    expenseDAO.getTotalSpent(tripId);

double remainingBudget =
    trip.getTotalBudget() - totalSpent;

double equalShare =
    totalSpent / travelerCount;


long days =
    ((trip.getEndDate().getTime()
    - trip.getStartDate().getTime())
    / (1000L * 60 * 60 * 24)) + 1;

long nights =
    Math.max(1, days - 1);


double hotelCost = 0;

if (hotel != null) {

    hotelCost =
        hotel.getPricePerNight()
        * trip.getRooms()
        * nights;
}


double transportCost = 0;

if (transport != null) {

    transportCost =
        transport.getPricePerPerson()
        * travelerCount;
}


double itineraryCost = 0;

if (activities != null) {

    for (Itinerary item : activities) {

        itineraryCost +=
            item.getEstimatedCost();
    }
}


double plannedCost =
    hotelCost
    + transportCost
    + itineraryCost;


double plannedRemaining =
    trip.getTotalBudget()
    - plannedCost;


Map<Integer, Double> paidAmounts =
    expenseDAO.getPaidAmounts(tripId);


boolean organizer =
    trip.getCreatedBy()
    == user.getUserId();
%>
<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Triply - Trip Summary</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/style.css">

<style>

.summary-page {
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


/* HERO */

.summary-hero {
    min-height: 390px;
    border-radius: 24px;
    overflow: hidden;
    position: relative;
    margin-bottom: 30px;

    background-size: cover;
    background-position: center;
}

.hero-overlay {
    position: absolute;
    inset: 0;

    background:
        linear-gradient(
            to top,
            rgba(12,35,40,0.94),
            rgba(12,35,40,0.20)
        );

    display: flex;
    align-items: flex-end;
}

.hero-content {
    padding: 35px;
    color: white;
    width: 100%;
}

.hero-content h1 {
    margin: 10px 0 8px;
    font-size: 46px;
}

.hero-destination {
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 10px;
}

.hero-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 18px;
}

.hero-meta span {
    background: rgba(255,255,255,0.15);
    backdrop-filter: blur(7px);

    padding: 8px 13px;
    border-radius: 20px;

    font-size: 13px;
}

.status {
    display: inline-block;
    padding: 7px 12px;
    border-radius: 20px;

    font-size: 11px;
    font-weight: 800;
}

.UPCOMING {
    background: #dbeafe;
    color: #1d4ed8;
}

.ONGOING {
    background: #dcfce7;
    color: #15803d;
}

.COMPLETED {
    background: #e5e7eb;
    color: #374151;
}


/* GENERAL */

.summary-section {
    margin-top: 40px;
}

.section-heading {
    margin-bottom: 18px;
}

.section-heading h2 {
    margin: 0 0 5px;
    font-size: 28px;
}

.section-heading p {
    margin: 0;
    color: var(--muted);
}

.white-card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;
    padding: 24px;
}


/* BUDGET */

.budget-panel {
    background: #17363c;
    color: white;

    border-radius: 22px;
    padding: 28px;
}

.budget-panel h2 {
    margin: 0 0 5px;
}

.budget-panel > p {
    margin: 0 0 22px;
    opacity: 0.7;
}

.budget-grid {
    display: grid;
    grid-template-columns:
        repeat(5, minmax(0, 1fr));
    gap: 14px;
}

.budget-card {
    background: rgba(255,255,255,0.09);
    padding: 17px;
    border-radius: 14px;
}

.budget-label {
    display: block;
    opacity: 0.7;
    font-size: 12px;
    margin-bottom: 7px;
}

.budget-value {
    font-size: 19px;
    font-weight: 800;
}

.good {
    color: #86efac;
}

.bad {
    color: #fca5a5;
}


/* TRAVEL */

.travel-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.travel-card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;
    overflow: hidden;
}

.travel-image {
    width: 100%;
    height: 190px;
    object-fit: cover;
    display: block;
}

.travel-content {
    padding: 20px;
}

.travel-label {
    color: var(--primary);
    font-size: 12px;
    font-weight: 800;
}

.travel-content h3 {
    margin: 7px 0;
    font-size: 22px;
}

.travel-content p {
    margin: 6px 0;
    color: var(--muted);
}

.travel-price {
    font-size: 20px;
    font-weight: 800;
    color: #17363c;

    margin-top: 13px;
}


/* MEMBERS */

.member-grid {
    display: grid;
    grid-template-columns:
        repeat(auto-fit, minmax(200px, 1fr));
    gap: 14px;
}

.member-card {
    background: white;
    border: 1px solid var(--border);

    border-radius: 15px;
    padding: 17px;
}

.member-name {
    font-size: 17px;
    font-weight: 800;
}

.member-role {
    display: inline-block;
    margin-top: 7px;

    background: #e7f5f5;
    color: var(--primary);

    padding: 5px 9px;
    border-radius: 15px;

    font-size: 11px;
    font-weight: 800;
}


/* ITINERARY */

.timeline {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;
    padding: 23px;
}

.activity {
    position: relative;

    border-left: 4px solid var(--primary);

    padding: 4px 0 20px 20px;
    margin-bottom: 18px;
}

.activity:last-child {
    margin-bottom: 0;
    padding-bottom: 4px;
}

.activity-date {
    color: var(--primary);
    font-size: 12px;
    font-weight: 800;
}

.activity h3 {
    margin: 6px 0;
}

.activity-time {
    color: var(--muted);
    font-size: 13px;
}

.activity-cost {
    margin-top: 7px;
    font-weight: 700;
}


/* SPLIT */

.split-container {
    background: white;
    border: 1px solid var(--border);

    border-radius: 20px;
    overflow: hidden;
}

.split-row {
    display: grid;
    grid-template-columns:
        1.3fr 1fr 1fr 1.2fr;

    gap: 15px;
    align-items: center;

    padding: 18px 22px;
    border-bottom: 1px solid var(--border);
}

.split-row:last-child {
    border-bottom: none;
}

.split-label {
    display: block;
    color: var(--muted);
    font-size: 11px;
    margin-bottom: 4px;
}

.positive {
    color: #15803d;
    font-weight: 800;
}

.negative {
    color: #dc2626;
    font-weight: 800;
}

.settled {
    color: var(--muted);
    font-weight: 800;
}


/* EXPENSES */

.expense-grid {
    display: grid;
    grid-template-columns:
        repeat(auto-fit, minmax(250px, 1fr));
    gap: 15px;
}

.expense-card {
    background: white;
    border: 1px solid var(--border);

    padding: 18px;
    border-radius: 16px;
}

.expense-category {
    display: inline-block;

    background: #e7f5f5;
    color: var(--primary);

    padding: 5px 9px;
    border-radius: 15px;

    font-size: 11px;
    font-weight: 800;
}

.expense-card h3 {
    margin: 10px 0 5px;
}

.expense-amount {
    font-size: 21px;
    font-weight: 800;

    margin: 12px 0;
}

.expense-meta {
    color: var(--muted);
    font-size: 13px;
    line-height: 1.6;
}


/* EMPTY */

.empty-state {
    background: white;
    border: 1px solid var(--border);

    border-radius: 18px;
    padding: 30px;

    color: var(--muted);
}


/* ACTIONS */

.manage-panel {
    background: #e7f3f3;
    border-radius: 22px;

    padding: 28px;

    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 25px;
}

.manage-panel h2 {
    margin: 0 0 6px;
}

.manage-panel p {
    margin: 0;
    color: var(--muted);
}

.manage-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.secondary-button {
    display: inline-block;

    background: white;
    color: var(--primary);

    padding: 10px 15px;
    border-radius: 9px;

    text-decoration: none;
    font-weight: 700;

    border: 1px solid #d5e6e6;
}


@media(max-width:950px) {

    .budget-grid {
        grid-template-columns: 1fr 1fr;
    }
}


@media(max-width:700px) {

    .summary-hero {
        min-height: 360px;
    }

    .hero-content h1 {
        font-size: 36px;
    }

    .travel-grid {
        grid-template-columns: 1fr;
    }

    .budget-grid {
        grid-template-columns: 1fr;
    }

    .split-row {
        grid-template-columns: 1fr 1fr;
    }

    .manage-panel {
        flex-direction: column;
        align-items: flex-start;
    }
}


@media(max-width:500px) {

    .split-row {
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


<main class="page-container summary-page">


<a href="myTrips.jsp"
   class="back-link">
    &larr; Back to My Trips
</a>


<!-- HERO -->

<%
String summaryImage =
    "images/hero/travel-hero.jpeg";

if (destination != null &&
    destination.getImageUrl() != null &&
    !destination.getImageUrl().trim().isEmpty()) {

    summaryImage =
        destination.getImageUrl();
}
%>


<section class="summary-hero"
         style="background-image:
         url('<%= request.getContextPath() %>/<%= summaryImage %>');">


<div class="hero-overlay">

<div class="hero-content">


<span class="status <%= status %>">
    <%= status %>
</span>


<h1>
    <%= trip.getTripName() %>
</h1>


<%
if (destination != null) {
%>

<div class="hero-destination">

    <%= destination.getName() %>,
    <%= destination.getState() %>

</div>

<%
}
%>


<div class="hero-meta">

    <span>
        From <%= trip.getStartCity() %>
    </span>

    <span>
        <%= trip.getStartDate() %>
        to
        <%= trip.getEndDate() %>
    </span>

    <span>
        <%= days %> Days
    </span>

    <span>
        <%= nights %> Nights
    </span>

    <span>
        <%= travelerCount %> Travelers
    </span>

</div>


</div>

</div>

</section>


<!-- DESTINATION -->

<section class="summary-section">

<div class="section-heading">

    <h2>Your Destination</h2>

    <p>
        The destination selected by your group.
    </p>

</div>


<%
if (destination != null) {
%>


<div class="white-card">

    <h2>
        <%= destination.getName() %>,
        <%= destination.getState() %>
    </h2>

    <p>
        <%= destination.getDescription() %>
    </p>

    <span class="member-role">
        <%= destination.getCategory() %>
    </span>

</div>


<%
} else {
%>


<div class="empty-state">

    Destination has not been finalized yet.

</div>


<%
}
%>

</section>


<!-- BUDGET -->

<section class="summary-section budget-panel">

<h2>Budget Overview</h2>

<p>
    Planned expenses compared with
    actual trip spending.
</p>


<div class="budget-grid">


<div class="budget-card">

    <span class="budget-label">
        Total Budget
    </span>

    <div class="budget-value">

        Rs.
        <%= String.format(
            "%.2f",
            trip.getTotalBudget()) %>

    </div>

</div>


<div class="budget-card">

    <span class="budget-label">
        Planned Cost
    </span>

    <div class="budget-value">

        Rs.
        <%= String.format(
            "%.2f",
            plannedCost) %>

    </div>

</div>


<div class="budget-card">

    <span class="budget-label">
        Planned Remaining
    </span>

    <div class="budget-value
        <%= plannedRemaining >= 0
            ? "good" : "bad" %>">

        Rs.
        <%= String.format(
            "%.2f",
            plannedRemaining) %>

    </div>

</div>


<div class="budget-card">

    <span class="budget-label">
        Actual Spent
    </span>

    <div class="budget-value">

        Rs.
        <%= String.format(
            "%.2f",
            totalSpent) %>

    </div>

</div>


<div class="budget-card">

    <span class="budget-label">
        Actual Remaining
    </span>

    <div class="budget-value
        <%= remainingBudget >= 0
            ? "good" : "bad" %>">

        Rs.
        <%= String.format(
            "%.2f",
            remainingBudget) %>

    </div>

</div>


</div>

</section>


<!-- HOTEL + TRANSPORT -->

<section class="summary-section">


<div class="section-heading">

    <h2>Travel and Stay</h2>

    <p>
        Your selected accommodation
        and transport.
    </p>

</div>


<div class="travel-grid">


<!-- HOTEL -->

<div class="travel-card">


<%
if (hotel != null) {

    String hotelImage =
        hotel.getImageUrl();

    if (hotelImage == null ||
        hotelImage.trim().isEmpty()) {

        hotelImage =
            "images/hero/travel-hero.jpeg";
    }
%>


<img class="travel-image"
     src="<%= request.getContextPath() %>/<%= hotelImage %>"
     alt="<%= hotel.getHotelName() %>">


<div class="travel-content">

    <span class="travel-label">
        SELECTED HOTEL
    </span>

    <h3>
        <%= hotel.getHotelName() %>
    </h3>

    <p>
        <%= hotel.getLocation() %>
    </p>

    <p>
        <%= trip.getRooms() %>
        room(s) for
        <%= nights %> night(s)
    </p>

    <div class="travel-price">

        Rs.
        <%= String.format(
            "%.2f",
            hotelCost) %>

    </div>

</div>


<%
} else {
%>


<div class="travel-content">

    <span class="travel-label">
        HOTEL
    </span>

    <h3>No hotel selected</h3>

    <p>
        Select your accommodation
        from the destination page.
    </p>

</div>


<%
}
%>


</div>


<!-- TRANSPORT -->

<div class="travel-card">


<%
if (transport != null) {

    String transportImage =
        "images/transport/bus.jpeg";

    if ("FLIGHT".equalsIgnoreCase(
            transport.getTransportType())) {

        transportImage =
            "images/transport/flight.jpeg";

    } else if ("TRAIN".equalsIgnoreCase(
            transport.getTransportType())) {

        transportImage =
            "images/transport/train.jpeg";
    }
%>


<img class="travel-image"
     src="<%= request.getContextPath() %>/<%= transportImage %>"
     alt="<%= transport.getTransportType() %>">


<div class="travel-content">

    <span class="travel-label">
        SELECTED TRANSPORT
    </span>

    <h3>
        <%= transport.getTransportType() %>
    </h3>

    <p>
        <%= transport.getProvider() %>
    </p>

    <p>
        <%= transport.getDepartureTime() %>
        -
        <%= transport.getArrivalTime() %>
    </p>

    <div class="travel-price">

        Rs.
        <%= String.format(
            "%.2f",
            transportCost) %>

    </div>

</div>


<%
} else {
%>


<div class="travel-content">

    <span class="travel-label">
        TRANSPORT
    </span>

    <h3>No transport selected</h3>

    <p>
        Select transport from the
        destination page.
    </p>

</div>


<%
}
%>


</div>


</div>

</section>


<!-- MEMBERS -->

<section class="summary-section">


<div class="section-heading">

    <h2>Travel Group</h2>

    <p>
        <%= travelerCount %>
        traveler(s) are part of this trip.
    </p>

</div>


<div class="member-grid">


<%
if (members != null) {

    for (TripMember member : members) {
%>


<div class="member-card">

    <div class="member-name">

        <%= member.getName() %>

    </div>

    <span class="member-role">

        <%= member.getRole() %>

    </span>

</div>


<%
    }
}
%>


</div>

</section>


<!-- ITINERARY -->

<section class="summary-section">


<div class="section-heading">

    <h2>Day-wise Itinerary</h2>

    <p>
        Your planned activities
        and estimated activity costs.
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
%>


<div class="timeline">


<%
for (Itinerary item : activities) {
%>


<div class="activity">


<div class="activity-date">

    <%= item.getActivityDate() %>

</div>


<h3>

    <%= item.getActivityName() %>

</h3>


<div class="activity-time">

    <%= item.getStartTime() %>
    -
    <%= item.getEndTime() %>

</div>


<div class="activity-cost">

    Estimated Cost:
    Rs.
    <%= String.format(
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
}
%>


</div>


<%
}
%>


</section>


<!-- EXPENSE SPLIT -->

<section class="summary-section">


<div class="section-heading">

    <h2>Expense Split</h2>

    <p>
        Equal share per traveler:
        Rs.
        <%= String.format(
            "%.2f",
            equalShare) %>
    </p>

</div>


<div class="split-container">


<%
if (members != null) {

for (TripMember member : members) {

    double paid =
        paidAmounts.containsKey(
            member.getUserId())
        ? paidAmounts.get(
            member.getUserId())
        : 0;

    double balance =
        paid - equalShare;
%>


<div class="split-row">


<div>

    <span class="split-label">
        Traveler
    </span>

    <strong>
        <%= member.getName() %>
    </strong>

</div>


<div>

    <span class="split-label">
        Paid
    </span>

    <strong>

        Rs.
        <%= String.format(
            "%.2f",
            paid) %>

    </strong>

</div>


<div>

    <span class="split-label">
        Share
    </span>

    <strong>

        Rs.
        <%= String.format(
            "%.2f",
            equalShare) %>

    </strong>

</div>


<div>

    <span class="split-label">
        Balance
    </span>


<%
if (balance > 0.01) {
%>


<span class="positive">

    Gets back Rs.
    <%= String.format(
        "%.2f",
        balance) %>

</span>


<%
} else if (balance < -0.01) {
%>


<span class="negative">

    Owes Rs.
    <%= String.format(
        "%.2f",
        Math.abs(balance)) %>

</span>


<%
} else {
%>


<span class="settled">
    Settled
</span>


<%
}
%>


</div>


</div>


<%
}
}
%>


</div>

</section>


<!-- EXPENSE HISTORY -->

<section class="summary-section">


<div class="section-heading">

    <h2>Recent Expenses</h2>

    <p>
        Spending recorded during the trip.
    </p>

</div>


<%
if (expenses == null ||
    expenses.isEmpty()) {
%>


<div class="empty-state">

    No expenses recorded yet.

</div>


<%
} else {
%>


<div class="expense-grid">


<%
for (Expense expense : expenses) {
%>


<div class="expense-card">


<span class="expense-category">

    <%= expense.getCategory() %>

</span>


<h3>

    <%= expense.getDescription() %>

</h3>


<div class="expense-amount">

    Rs.
    <%= String.format(
        "%.2f",
        expense.getAmount()) %>

</div>


<div class="expense-meta">

    Paid by
    <strong>
        <%= expense.getPaidByName() %>
    </strong>

    <br>

    <%= expense.getExpenseDate() %>

</div>


</div>


<%
}
%>


</div>


<%
}
%>


</section>


<!-- MANAGE -->

<section class="summary-section">


<div class="manage-panel">


<div>

    <h2>Manage Your Trip</h2>

    <p>
        Continue planning or update
        your trip information.
    </p>

</div>


<div class="manage-actions">


<%
if (trip.getDestinationId() > 0) {
%>


<a class="secondary-button"
   href="destinationDetails.jsp?id=<%= tripId %>">

    Destination

</a>


<%
}
%>


<a class="secondary-button"
   href="itinerary.jsp?id=<%= tripId %>">

    Itinerary

</a>


<a class="secondary-button"
   href="expenses.jsp?id=<%= tripId %>">

    Expenses

</a>


<%
if (organizer) {
%>


<a class="btn-primary"
   href="editTrip.jsp?id=<%= tripId %>">

    Edit Trip

</a>


<%
}
%>


</div>


</div>

</section>


</main>


<footer class="footer">

    Triply &nbsp; | &nbsp;
    Collaborative Budget-Based Trip Planner

</footer>


</body>

</html>