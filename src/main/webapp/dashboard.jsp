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

<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Triply - Dashboard</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/style.css">

</head>

<body>


<!-- NAVBAR -->

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


<!-- HERO -->

<section class="hero">

    <div class="hero-content">

        <div class="hero-tag">
            Collaborative Trip Planner
        </div>

        <h1>
            Where are we
            going next?
        </h1>

        <p>
            Plan trips with your friends,
            discover destinations that match
            your budget and build the entire
            journey together.
        </p>


        <div class="hero-buttons">

            <a href="createTrip.jsp"
               class="btn-primary">
                Plan a New Trip
            </a>

            <a href="myTrips.jsp"
               class="btn-light">
                View My Trips
            </a>

        </div>

    </div>

</section>


<!-- DASHBOARD -->

<main class="page-container">

    <div class="section-heading">

        <h2>
            Start planning
        </h2>

        <p>
            Everything you need for your next
            group adventure.
        </p>

    </div>


    <div class="dashboard-grid">


        <!-- CREATE -->

        <div class="dashboard-card">

            <div class="card-icon">
                NEW
            </div>

            <h3>
                Create a Trip
            </h3>

            <p>
                Start a new journey, set your
                dates and budget, then invite
                your friends.
            </p>

            <a href="createTrip.jsp"
               class="card-link">
                Start Planning &#x2192;
            </a>

        </div>


        <!-- MY TRIPS -->

        <div class="dashboard-card">

            <div class="card-icon">
                TRIP
            </div>

            <h3>
                My Trips
            </h3>

            <p>
                View your upcoming adventures
                and continue planning with your
                group.
            </p>

            <a href="myTrips.jsp"
               class="card-link">
                Explore Trips &#x2192;
            </a>

        </div>


        <!-- JOIN -->

        <div class="dashboard-card">

            <div class="card-icon">
                JOIN
            </div>

            <h3>
                Join Friends
            </h3>

            <p>
                Got an invite code? Join your
                friend's trip and start planning
                together.
            </p>

            <a href="joinTrip.jsp"
               class="card-link">
                Join a Trip &#x2192;
            </a>

        </div>


    </div>

</main>


<footer class="footer">

    Triply &nbsp; | &nbsp;
    Collaborative Budget-Based Trip Planner

</footer>


</body>

</html>