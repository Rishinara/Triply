<%@ page import="java.util.List" %>
<%@ page import="java.time.temporal.ChronoUnit" %>

<%@ page import="com.tripplanner.model.User" %>
<%@ page import="com.tripplanner.model.Trip" %>
<%@ page import="com.tripplanner.model.Destination" %>
<%@ page import="com.tripplanner.model.Place" %>
<%@ page import="com.tripplanner.model.Hotel" %>
<%@ page import="com.tripplanner.model.Restaurant" %>
<%@ page import="com.tripplanner.model.Transport" %>

<%@ page import="com.tripplanner.dao.TripDAO" %>
<%@ page import="com.tripplanner.dao.DestinationDAO" %>
<%@ page import="com.tripplanner.dao.PlaceDAO" %>
<%@ page import="com.tripplanner.dao.HotelDAO" %>
<%@ page import="com.tripplanner.dao.RestaurantDAO" %>
<%@ page import="com.tripplanner.dao.TransportDAO" %>
<%@ page import="com.tripplanner.dao.TripMemberDAO" %>

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

    TripDAO tripDAO = new TripDAO();

    Trip trip =
        tripDAO.getAccessibleTripById(
            tripId,
            user.getUserId());

    if (trip == null) {
        response.sendRedirect("myTrips.jsp");
        return;
    }

    if (trip.getDestinationId() <= 0) {
        response.sendRedirect(
            "recommendations.jsp?id=" + tripId);
        return;
    }

    boolean organizer =
        trip.getCreatedBy() == user.getUserId();


    DestinationDAO destinationDAO =
        new DestinationDAO();

    Destination destination =
        destinationDAO.getDestinationById(
            trip.getDestinationId());


    PlaceDAO placeDAO = new PlaceDAO();

    List<Place> places =
        placeDAO.getPlacesByDestination(
            trip.getDestinationId());


    HotelDAO hotelDAO = new HotelDAO();

    List<Hotel> hotels =
        hotelDAO.getHotelsByDestination(
            trip.getDestinationId());


    RestaurantDAO restaurantDAO =
        new RestaurantDAO();

    List<Restaurant> restaurants =
        restaurantDAO.getRestaurantsByDestination(
            trip.getDestinationId());


    TransportDAO transportDAO =
        new TransportDAO();

    List<Transport> transports =
        transportDAO.getTransportOptions(
            trip.getStartCity(),
            trip.getDestinationId());


    TripMemberDAO memberDAO =
        new TripMemberDAO();

    int travelers =
        memberDAO.getMemberCount(tripId);

    if (travelers <= 0) {
        travelers = 1;
    }


    long days =
        ChronoUnit.DAYS.between(
            trip.getStartDate().toLocalDate(),
            trip.getEndDate().toLocalDate()
        ) + 1;

    if (days <= 0) {
        days = 1;
    }

    // Hotel nights are normally one less than trip days.
    long nights = Math.max(1, days - 1);


    Hotel selectedHotel = null;

    if (trip.getHotelId() > 0) {
        selectedHotel =
            hotelDAO.getHotelById(
                trip.getHotelId());
    }


    Transport selectedTransport = null;

    if (trip.getTransportId() > 0) {
        selectedTransport =
            transportDAO.getTransportById(
                trip.getTransportId());
    }


    double hotelCost = 0;

    if (selectedHotel != null) {

        int rooms = trip.getRooms();

        if (rooms <= 0) {
            rooms = 1;
        }

        hotelCost =
            selectedHotel.getPricePerNight()
            * rooms
            * nights;
    }


    double transportCost = 0;

    if (selectedTransport != null) {

        transportCost =
            selectedTransport.getPricePerPerson()
            * travelers;
    }


    // Estimate food using average restaurant cost.
    double avgFoodPerPerson = 0;

    if (restaurants != null &&
        !restaurants.isEmpty()) {

        double totalFoodPrice = 0;

        for (Restaurant r : restaurants) {
            totalFoodPrice +=
                r.getAvgCostPerPerson();
        }

        avgFoodPerPerson =
            totalFoodPrice / restaurants.size();
    }


    // Two meals per day as a simple academic estimate.
    double foodCost =
        avgFoodPerPerson
        * travelers
        * days
        * 2;


    // Entry fees for all suggested places.
    double activityCost = 0;

    if (places != null) {

        for (Place p : places) {

            activityCost +=
                p.getEntryFee() * travelers;
        }
    }


    double estimatedTotal =
        hotelCost
        + transportCost
        + foodCost
        + activityCost;


    double remainingBudget =
        trip.getTotalBudget()
        - estimatedTotal;


    double usedPercentage = 0;

    if (trip.getTotalBudget() > 0) {

        usedPercentage =
            (estimatedTotal /
             trip.getTotalBudget()) * 100;
    }
%>

<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Triply - Explore <%= destination.getName() %></title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/style.css">

<style>

.explore-page {
    padding-top: 30px;
    padding-bottom: 60px;
}

/* HERO */

.destination-hero {
    height: 430px;
    border-radius: 24px;
    overflow: hidden;
    position: relative;
    margin-bottom: 30px;

    background-image:
        linear-gradient(
            to top,
            rgba(10,30,35,0.88),
            rgba(10,30,35,0.08)
        ),
        url("<%= request.getContextPath() %>/<%= destination.getImageUrl() %>");

    background-size: cover;
    background-position: center;
}

.hero-content {
    position: absolute;
    left: 35px;
    right: 35px;
    bottom: 35px;
    color: white;
}

.hero-content h1 {
    font-size: 48px;
    margin: 0 0 5px;
}

.hero-state {
    font-size: 18px;
    font-weight: 700;
}

.hero-description {
    max-width: 700px;
    line-height: 1.6;
    opacity: 0.9;
}

.hero-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 18px;
}

.hero-meta span {
    background: rgba(255,255,255,0.18);
    backdrop-filter: blur(8px);
    padding: 8px 13px;
    border-radius: 20px;
    font-size: 13px;
}


/* MESSAGES */

.message {
    padding: 14px 18px;
    border-radius: 12px;
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


/* SECTION */

.explore-section {
    margin-top: 45px;
}

.section-heading {
    margin-bottom: 20px;
}

.section-heading h2 {
    margin: 0 0 6px;
    font-size: 30px;
}

.section-heading p {
    margin: 0;
    color: var(--muted);
}


/* BUDGET */

.budget-panel {
    background: #17363c;
    border-radius: 22px;
    padding: 28px;
    color: white;
}

.budget-panel h2 {
    margin-top: 0;
}

.budget-grid {
    display: grid;
    grid-template-columns:
        repeat(auto-fit, minmax(150px, 1fr));
    gap: 14px;
}

.budget-item {
    background: rgba(255,255,255,0.09);
    padding: 17px;
    border-radius: 14px;
}

.budget-label {
    display: block;
    font-size: 12px;
    opacity: 0.7;
    margin-bottom: 7px;
}

.budget-amount {
    font-size: 19px;
    font-weight: 800;
}

.budget-alert {
    margin-top: 18px;
    padding: 14px 17px;
    border-radius: 12px;
}

.budget-good {
    background: #dff5e8;
    color: #166534;
}

.budget-warning {
    background: #fff3d6;
    color: #92400e;
}

.budget-danger {
    background: #fee2e2;
    color: #991b1b;
}


/* CARDS */

.travel-grid {
    display: grid;
    grid-template-columns:
        repeat(auto-fit, minmax(270px, 1fr));
    gap: 22px;
}

.travel-card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 20px;
    overflow: hidden;

    transition:
        transform 0.2s ease,
        box-shadow 0.2s ease;
}

.travel-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 15px 32px rgba(0,0,0,0.08);
}

.card-photo {
    width: 100%;
    height: 190px;
    object-fit: cover;
    display: block;
    background: #dce7e7;
}

.card-body {
    padding: 19px;
}

.card-body h3 {
    margin: 0 0 7px;
    font-size: 21px;
}

.card-body p {
    color: var(--muted);
    line-height: 1.5;
    font-size: 14px;
}

.card-row {
    display: flex;
    justify-content: space-between;
    gap: 15px;

    padding: 7px 0;
    border-bottom: 1px solid #eeeeea;

    font-size: 13px;
}

.card-row span:first-child {
    color: var(--muted);
}

.card-row strong {
    text-align: right;
}

.tag {
    display: inline-block;
    background: #e7f5f5;
    color: var(--primary);

    padding: 6px 10px;
    border-radius: 20px;

    font-size: 11px;
    font-weight: 800;
    margin-bottom: 10px;
}

.selected-badge {
    display: inline-block;

    background: #dcfce7;
    color: #166534;

    padding: 7px 11px;
    border-radius: 20px;

    font-size: 12px;
    font-weight: 800;

    margin-top: 13px;
}

.select-form {
    margin-top: 15px;
}

.select-form button {
    border: none;
    background: var(--primary);
    color: white;

    padding: 10px 15px;
    border-radius: 9px;

    cursor: pointer;
    font-weight: 700;
}

.select-form button:hover {
    background: var(--primary-dark);
}

.rooms-input {
    width: 55px;
    padding: 8px;
    border: 1px solid var(--border);
    border-radius: 7px;
    margin: 0 7px;
}


/* TRANSPORT */

.transport-card {
    padding: 0;
}

.transport-photo {
    height: 160px;
    overflow: hidden;
}

.transport-photo img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}


/* EMPTY */

.empty-box {
    background: white;
    border: 1px solid var(--border);
    border-radius: 18px;

    padding: 30px;
    color: var(--muted);
}


/* ITINERARY */

.itinerary-cta {
    background: #e7f3f3;
    border-radius: 22px;

    padding: 30px;

    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 25px;
}

.itinerary-cta h2 {
    margin: 0 0 7px;
}

.itinerary-cta p {
    margin: 0;
    color: var(--muted);
}

.back-link {
    display: inline-block;
    color: var(--primary);
    font-weight: 700;
    text-decoration: none;
    margin-bottom: 20px;
}

@media(max-width:700px) {

    .destination-hero {
        height: 380px;
    }

    .hero-content {
        left: 22px;
        right: 22px;
        bottom: 22px;
    }

    .hero-content h1 {
        font-size: 36px;
    }

    .travel-grid {
        grid-template-columns: 1fr;
    }

    .itinerary-cta {
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


<main class="page-container explore-page">


<a href="tripDetails.jsp?id=<%= tripId %>"
   class="back-link">
    &larr; Back to Trip
</a>


<section class="destination-hero">

    <div class="hero-content">

        <div class="hero-state">
            <%= destination.getState() %>
        </div>

        <h1>
            <%= destination.getName() %>
        </h1>

        <p class="hero-description">
            <%= destination.getDescription() %>
        </p>

        <div class="hero-meta">

            <span>
                Trip: <%= trip.getTripName() %>
            </span>

            <span>
                <%= travelers %> Travelers
            </span>

            <span>
                <%= days %> Days
            </span>

            <span>
                <%= nights %> Nights
            </span>

        </div>

    </div>

</section>


<%
if ("true".equals(
        request.getParameter("hotelSelected"))) {
%>

<div class="message success">
    Hotel selected successfully.
</div>

<%
}
%>


<%
if ("true".equals(
        request.getParameter("transportSelected"))) {
%>

<div class="message success">
    Transport selected successfully.
</div>

<%
}
%>


<%
if (request.getParameter("error") != null) {
%>

<div class="message error">
    Unable to save the selection.
    Please check your input.
</div>

<%
}
%>


<!-- BUDGET -->

<section class="explore-section budget-panel">

<h2>Budget Overview</h2>

<div class="budget-grid">

    <div class="budget-item">
        <span class="budget-label">Total Budget</span>
        <div class="budget-amount">
            Rs. <%= String.format(
                    "%.2f",
                    trip.getTotalBudget()) %>
        </div>
    </div>

    <div class="budget-item">
        <span class="budget-label">Hotel</span>
        <div class="budget-amount">
            Rs. <%= String.format(
                    "%.2f", hotelCost) %>
        </div>
    </div>

    <div class="budget-item">
        <span class="budget-label">Transport</span>
        <div class="budget-amount">
            Rs. <%= String.format(
                    "%.2f", transportCost) %>
        </div>
    </div>

    <div class="budget-item">
        <span class="budget-label">Food Estimate</span>
        <div class="budget-amount">
            Rs. <%= String.format(
                    "%.2f", foodCost) %>
        </div>
    </div>

    <div class="budget-item">
        <span class="budget-label">Activities</span>
        <div class="budget-amount">
            Rs. <%= String.format(
                    "%.2f", activityCost) %>
        </div>
    </div>

    <div class="budget-item">
        <span class="budget-label">Estimated Total</span>
        <div class="budget-amount">
            Rs. <%= String.format(
                    "%.2f", estimatedTotal) %>
        </div>
    </div>

    <div class="budget-item">
        <span class="budget-label">Remaining</span>
        <div class="budget-amount">
            Rs. <%= String.format(
                    "%.2f", remainingBudget) %>
        </div>
    </div>

</div>


<%
if (remainingBudget < 0) {
%>

<div class="budget-alert budget-danger">

    Budget exceeded by
    Rs. <%= String.format(
            "%.2f",
            Math.abs(remainingBudget)) %>.

</div>

<%
} else if (usedPercentage >= 85) {
%>

<div class="budget-alert budget-warning">

    Estimated cost is close to your budget.
    Rs. <%= String.format(
            "%.2f",
            remainingBudget) %>
    remains.

</div>

<%
} else {
%>

<div class="budget-alert budget-good">

    This plan is within budget.
    Estimated remaining amount:
    Rs. <%= String.format(
            "%.2f",
            remainingBudget) %>.

</div>

<%
}
%>

</section>


<!-- TRANSPORT -->

<section class="explore-section">

<div class="section-heading">

    <h2>Choose Your Transport</h2>

    <p>
        Travel from <%= trip.getStartCity() %>
        to <%= destination.getName() %>.
    </p>

</div>


<%
if (transports == null || transports.isEmpty()) {
%>

<div class="empty-box">
    No transport options are currently available.
</div>

<%
} else {
%>

<div class="travel-grid">

<%
for (Transport t : transports) {

    String transportImage =
        "images/transport/bus.jpeg";

    if ("FLIGHT".equalsIgnoreCase(
            t.getTransportType())) {

        transportImage =
            "images/transport/flight.jpeg";

    } else if ("TRAIN".equalsIgnoreCase(
            t.getTransportType())) {

        transportImage =
            "images/transport/train.jpeg";
    }
%>

<div class="travel-card transport-card">

    <div class="transport-photo">

        <img src="<%= request.getContextPath() %>/<%= transportImage %>"
             alt="<%= t.getTransportType() %>">

    </div>

    <div class="card-body">

        <span class="tag">
            <%= t.getTransportType() %>
        </span>

        <h3>
            <%= t.getProvider() %>
        </h3>

        <div class="card-row">
            <span>Price / person</span>
            <strong>
                Rs. <%= t.getPricePerPerson() %>
            </strong>
        </div>

        <div class="card-row">
            <span>Departure</span>
            <strong>
                <%= t.getDepartureTime() %>
            </strong>
        </div>

        <div class="card-row">
            <span>Arrival</span>
            <strong>
                <%= t.getArrivalTime() %>
            </strong>
        </div>

        <div class="card-row">
            <span>Group Cost</span>
            <strong>
                Rs. <%= String.format(
                    "%.2f",
                    t.getPricePerPerson()
                    * travelers) %>
            </strong>
        </div>


        <%
        if (trip.getTransportId()
                == t.getTransportId()) {
        %>

        <div class="selected-badge">
            Selected Transport
        </div>

        <%
        }
        %>


        <%
        if (organizer) {
        %>

        <form action="selectTransport"
              method="post"
              class="select-form">

            <input type="hidden"
                   name="tripId"
                   value="<%= tripId %>">

            <input type="hidden"
                   name="transportId"
                   value="<%= t.getTransportId() %>">

            <button type="submit">
                Select Transport
            </button>

        </form>

        <%
        }
        %>

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


<!-- HOTELS -->

<section class="explore-section">

<div class="section-heading">

    <h2>Stay in <%= destination.getName() %></h2>

    <p>
        Select accommodation that fits your
        group and budget.
    </p>

</div>


<%
if (hotels == null || hotels.isEmpty()) {
%>

<div class="empty-box">
    No hotel data available.
</div>

<%
} else {
%>

<div class="travel-grid">

<%
for (Hotel h : hotels) {

    String hotelImage = h.getImageUrl();

    if (hotelImage == null ||
        hotelImage.trim().isEmpty()) {

        hotelImage =
            "images/hero/travel-hero.jpeg";
    }
%>

<div class="travel-card">

    <img class="card-photo"
         src="<%= request.getContextPath() %>/<%= hotelImage %>"
         alt="<%= h.getHotelName() %>">

    <div class="card-body">

        <h3>
            <%= h.getHotelName() %>
        </h3>

        <p>
            <%= h.getLocation() %>
        </p>

        <div class="card-row">
            <span>Rating</span>
            <strong>
                <%= h.getRating() %> / 5
            </strong>
        </div>

        <div class="card-row">
            <span>Price / night</span>
            <strong>
                Rs. <%= h.getPricePerNight() %>
            </strong>
        </div>


        <%
        if (trip.getHotelId()
                == h.getHotelId()) {
        %>

        <div class="selected-badge">

            Selected Hotel -
            <%= trip.getRooms() %>
            room(s)

        </div>

        <%
        }
        %>


        <%
        if (organizer) {
        %>

        <form action="selectHotel"
              method="post"
              class="select-form">

            <input type="hidden"
                   name="tripId"
                   value="<%= tripId %>">

            <input type="hidden"
                   name="hotelId"
                   value="<%= h.getHotelId() %>">

            Rooms

            <input type="number"
                   class="rooms-input"
                   name="rooms"
                   value="1"
                   min="1"
                   max="20"
                   required>

            <button type="submit">
                Select Hotel
            </button>

        </form>

        <%
        }
        %>

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


<!-- TOURIST PLACES -->

<section class="explore-section">

<div class="section-heading">

    <h2>Places to Explore</h2>

    <p>
        Discover attractions for your itinerary.
    </p>

</div>


<%
if (places == null || places.isEmpty()) {
%>

<div class="empty-box">
    No tourist place data available.
</div>

<%
} else {
%>

<div class="travel-grid">

<%
for (Place p : places) {

    String placeImage = p.getImageUrl();

    if (placeImage == null ||
        placeImage.trim().isEmpty()) {

        placeImage =
            destination.getImageUrl();
    }
%>

<div class="travel-card">

    <img class="card-photo"
         src="<%= request.getContextPath() %>/<%= placeImage %>"
         alt="<%= p.getPlaceName() %>">

    <div class="card-body">

        <span class="tag">
            <%= p.getCategory() %>
        </span>

        <h3>
            <%= p.getPlaceName() %>
        </h3>

        <p>
            <%= p.getDescription() %>
        </p>

        <div class="card-row">
            <span>Entry Fee</span>
            <strong>
                Rs. <%= p.getEntryFee() %>
            </strong>
        </div>

        <div class="card-row">
            <span>Opening Hours</span>
            <strong>
                <%= p.getOpenTime() %>
                -
                <%= p.getCloseTime() %>
            </strong>
        </div>

        <div class="card-row">
            <span>Suggested Duration</span>
            <strong>
                <%= p.getEstimatedDuration() %>
                hour(s)
            </strong>
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

</section>


<!-- RESTAURANTS -->

<section class="explore-section">

<div class="section-heading">

    <h2>Where to Eat</h2>

    <p>
        Restaurant options around
        <%= destination.getName() %>.
    </p>

</div>


<%
if (restaurants == null ||
    restaurants.isEmpty()) {
%>

<div class="empty-box">
    No restaurant data available.
</div>

<%
} else {
%>

<div class="travel-grid">

<%
for (Restaurant r : restaurants) {

    String restaurantImage =
        r.getImageUrl();

    if (restaurantImage == null ||
        restaurantImage.trim().isEmpty()) {

        restaurantImage =
            "images/hero/travel-hero.jpeg";
    }
%>

<div class="travel-card">

    <img class="card-photo"
         src="<%= request.getContextPath() %>/<%= restaurantImage %>"
         alt="<%= r.getName() %>">

    <div class="card-body">

        <span class="tag">
            <%= r.getCuisine() %>
        </span>

        <h3>
            <%= r.getName() %>
        </h3>

        <p>
            <%= r.getLocation() %>
        </p>

        <div class="card-row">
            <span>Average Cost / person</span>
            <strong>
                Rs.
                <%= r.getAvgCostPerPerson() %>
            </strong>
        </div>

        <div class="card-row">
            <span>Rating</span>
            <strong>
                <%= r.getRating() %> / 5
            </strong>
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

</section>


<!-- ITINERARY -->

<section class="explore-section">

<div class="itinerary-cta">

    <div>

        <h2>Build Your Day-wise Plan</h2>

        <p>
            Add these places and activities
            to your trip itinerary.
        </p>

    </div>

    <a href="itinerary.jsp?id=<%= tripId %>"
       class="btn-primary">
        Plan Itinerary &rarr;
    </a>

</div>

</section>


</main>


<footer class="footer">

    Triply &nbsp; | &nbsp;
    Collaborative Budget-Based Trip Planner

</footer>


</body>
</html>