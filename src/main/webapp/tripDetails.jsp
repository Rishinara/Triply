<%@ page import="java.util.List" %>
<%@ page import="com.tripplanner.model.User" %>
<%@ page import="com.tripplanner.model.Trip" %>
<%@ page import="com.tripplanner.model.TripMember" %>
<%@ page import="com.tripplanner.model.TripPreference" %>
<%@ page import="com.tripplanner.dao.TripDAO" %>
<%@ page import="com.tripplanner.dao.TripMemberDAO" %>
<%@ page import="com.tripplanner.dao.TripPreferenceDAO" %>

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


    TripMemberDAO memberDAO =
        new TripMemberDAO();

    List<TripMember> members =
        memberDAO.getMembers(tripId);

    int memberCount =
        memberDAO.getMemberCount(tripId);


    TripPreferenceDAO preferenceDAO =
        new TripPreferenceDAO();

    TripPreference preference =
        preferenceDAO.getPreference(tripId);


    double budgetPerPerson = 0;

    if (memberCount > 0) {
        budgetPerPerson =
            trip.getTotalBudget() / memberCount;
    }


    long duration =
        java.time.temporal.ChronoUnit.DAYS.between(
            trip.getStartDate().toLocalDate(),
            trip.getEndDate().toLocalDate()
        ) + 1;


    boolean organizer =
        trip.getCreatedBy() == user.getUserId();
%>


<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Trip Details | Trip Planner</title>

<style>

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f4f7fb;
    color: #1f2937;
}

.container {
    width: 90%;
    max-width: 1100px;
    margin: 40px auto;
}

.header {
    background: white;
    padding: 28px;
    border-radius: 14px;
    margin-bottom: 20px;
}

.header h1 {
    margin-top: 0;
}

.back {
    color: #2563eb;
    text-decoration: none;
}

.grid {
    display: grid;
    grid-template-columns:
        repeat(auto-fit, minmax(220px, 1fr));
    gap: 15px;
    margin-bottom: 20px;
}

.info {
    background: white;
    padding: 20px;
    border-radius: 12px;
}

.info h3 {
    margin-top: 0;
    color: #6b7280;
    font-size: 14px;
}

.info strong {
    font-size: 21px;
}

.section {
    background: white;
    padding: 28px;
    border-radius: 14px;
    margin-top: 20px;
}

.member {
    border-bottom: 1px solid #e5e7eb;
    padding: 12px 0;
}

.member:last-child {
    border-bottom: none;
}

.role {
    display: inline-block;
    margin-left: 10px;
    padding: 4px 8px;
    background: #eef2ff;
    color: #4338ca;
    border-radius: 5px;
    font-size: 12px;
}

label {
    display: block;
    margin-top: 15px;
    margin-bottom: 6px;
    font-weight: bold;
}

select,
input {
    width: 100%;
    padding: 11px;
    box-sizing: border-box;
    border: 1px solid #d1d5db;
    border-radius: 7px;
}

button {
    margin-top: 20px;
    padding: 12px 20px;
    background: #2563eb;
    border: none;
    color: white;
    border-radius: 7px;
    cursor: pointer;
}

.success {
    background: #ecfdf3;
    color: #027a48;
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 20px;
}

.preference-value {
    background: #f9fafb;
    padding: 15px;
    border-radius: 8px;
    margin-top: 10px;
}

.invite {
    font-family: monospace;
    font-size: 18px;
}

</style>

</head>


<body>

<div class="container">


    <a href="myTrips.jsp" class="back">
        Back to My Trips
    </a>


    <div class="header">

        <h1>
            <%= trip.getTripName() %>
        </h1>

        <p>
            Starting from
            <strong><%= trip.getStartCity() %></strong>
        </p>

        <p>
            Invite Code:
            <strong class="invite">
                <%= trip.getInviteCode() %>
            </strong>
        </p>

    </div>


    <%
        if ("true".equals(
                request.getParameter("saved"))) {
    %>

        <div class="success">
            Trip preferences saved successfully.
        </div>

    <%
        }
    %>


    <div class="grid">


        <div class="info">

            <h3>Total Budget</h3>

            <strong>
                Rs. <%= String.format("%.2f",
                        trip.getTotalBudget()) %>
            </strong>

        </div>


        <div class="info">

            <h3>Travelers</h3>

            <strong>
                <%= memberCount %>
            </strong>

        </div>


        <div class="info">

            <h3>Budget Per Person</h3>

            <strong>
                Rs. <%= String.format("%.2f",
                        budgetPerPerson) %>
            </strong>

        </div>


        <div class="info">

            <h3>Trip Duration</h3>

            <strong>
                <%= duration %> days
            </strong>

        </div>


    </div>



    <div class="section">

        <h2>Group Members</h2>


        <%
            for (TripMember member : members) {
        %>

            <div class="member">

                <strong>
                    <%= member.getName() %>
                </strong>

                <span class="role">
                    <%= member.getRole() %>
                </span>

                <br>

                <small>
                    <%= member.getEmail() %>
                </small>

            </div>

        <%
            }
        %>

    </div>



    <div class="section">

        <h2>Trip Preferences</h2>


        <%
            if (preference != null) {
        %>

            <div class="preference-value">

                <p>
                    <strong>Interest:</strong>
                    <%= preference.getCategory() %>
                </p>

                <p>
                    <strong>Travel Month:</strong>
                    <%= preference.getTravelMonth() %>
                </p>

                <p>
                    <strong>Preferred Duration:</strong>
                    <%= preference.getDuration() %>
                    days
                </p>

            </div>

        <%
            } else {
        %>

            <p>
                No preferences have been set yet.
            </p>

        <%
            }
        %>


        <%
            if (organizer) {
        %>


        <form action="savePreference"
              method="post">

            <input type="hidden"
                   name="tripId"
                   value="<%= trip.getTripId() %>">


            <label>
                Main Interest
            </label>

            <select name="category" required>

                <option value="">
                    Select Interest
                </option>

                <option value="BEACH">
                    Beach
                </option>

                <option value="ADVENTURE">
                    Adventure
                </option>

                <option value="NATURE">
                    Nature
                </option>

                <option value="HISTORY">
                    History
                </option>

                <option value="FOOD">
                    Food
                </option>

                <option value="RELAXATION">
                    Relaxation
                </option>

            </select>


            <label>
                Travel Month
            </label>

            <select name="travelMonth" required>

                <option value="">
                    Select Month
                </option>

                <option>January</option>
                <option>February</option>
                <option>March</option>
                <option>April</option>
                <option>May</option>
                <option>June</option>
                <option>July</option>
                <option>August</option>
                <option>September</option>
                <option>October</option>
                <option>November</option>
                <option>December</option>

            </select>


            <label>
                Preferred Duration
            </label>

            <input type="number"
                   name="duration"
                   min="1"
                   max="30"
                   value="<%= duration %>"
                   required>


            <button type="submit">
                Save Preferences
            </button>

        </form>


        <%
            }
        %>


    </div>

<div class="section">

    <h2>Destination Planning</h2>

    <%
        if (preference == null) {
    %>

        <p>
            Set the trip preferences first to
            get destination recommendations.
        </p>

    <%
        } else {
    %>

        <a href="recommendations.jsp?id=<%= trip.getTripId() %>"
           style="
               display:inline-block;
               padding:12px 18px;
               background:#2563eb;
               color:white;
               text-decoration:none;
               border-radius:7px;
           ">
            View Recommended Destinations
        </a>

    <%
        }
    %>

</div>

</div>

</body>

</html>