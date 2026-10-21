<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%@ page import="com.tripplanner.model.User" %>
<%@ page import="com.tripplanner.model.Trip" %>
<%@ page import="com.tripplanner.model.TripMember" %>
<%@ page import="com.tripplanner.model.Expense" %>

<%@ page import="com.tripplanner.dao.TripDAO" %>
<%@ page import="com.tripplanner.dao.TripMemberDAO" %>
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


TripMemberDAO memberDAO =
    new TripMemberDAO();

List<TripMember> members =
    memberDAO.getMembers(tripId);


ExpenseDAO expenseDAO =
    new ExpenseDAO();

List<Expense> expenses =
    expenseDAO.getExpensesByTrip(tripId);


double totalSpent =
    expenseDAO.getTotalSpent(tripId);


int memberCount =
    members == null ? 0 : members.size();

if (memberCount <= 0) {
    memberCount = 1;
}


double equalShare =
    totalSpent / memberCount;


double remainingBudget =
    trip.getTotalBudget() - totalSpent;


Map<Integer, Double> paidAmounts =
    expenseDAO.getPaidAmounts(tripId);
%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width, initial-scale=1.0">

<title>Triply - Trip Expenses</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/style.css">

<style>

.expense-page {
    padding-top: 30px;
    padding-bottom: 60px;
}

.back-link {
    display: inline-block;
    margin-bottom: 20px;
    color: var(--primary);
    text-decoration: none;
    font-weight: 700;
}

/* HEADER */

.expense-header {
    background: #17363c;
    color: white;

    border-radius: 22px;
    padding: 32px;

    margin-bottom: 25px;
}

.expense-header h1 {
    margin: 0 0 7px;
    font-size: 38px;
}

.expense-header p {
    margin: 0;
    opacity: 0.8;
}


/* SUMMARY */

.summary-grid {
    display: grid;
    grid-template-columns:
        repeat(4, minmax(0, 1fr));
    gap: 16px;

    margin-top: 25px;
}

.summary-card {
    background: rgba(255,255,255,0.1);
    border-radius: 15px;
    padding: 18px;
}

.summary-label {
    display: block;
    font-size: 12px;
    opacity: 0.7;
    margin-bottom: 7px;
}

.summary-amount {
    font-size: 21px;
    font-weight: 800;
}

.budget-message {
    margin-top: 18px;
    padding: 13px 16px;
    border-radius: 11px;
    font-weight: 700;
}

.budget-good {
    background: #dcfce7;
    color: #166534;
}

.budget-danger {
    background: #fee2e2;
    color: #991b1b;
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


/* SECTION */

.expense-section {
    margin-top: 35px;
}

.section-title {
    margin-bottom: 20px;
}

.section-title h2 {
    margin: 0 0 6px;
    font-size: 29px;
}

.section-title p {
    margin: 0;
    color: var(--muted);
}


/* FORM */

.expense-form-card {
    background: white;
    border: 1px solid var(--border);

    padding: 27px;
    border-radius: 20px;
}

.form-grid {
    display: grid;
    grid-template-columns:
        repeat(2, minmax(0, 1fr));
    gap: 18px;
}

.form-group label {
    display: block;
    margin-bottom: 7px;
    font-size: 13px;
    font-weight: 700;
}

.form-group input,
.form-group select {
    width: 100%;
    box-sizing: border-box;

    padding: 11px 12px;

    border: 1px solid #d8ddd9;
    border-radius: 9px;

    background: white;
    font-family: inherit;
    font-size: 14px;
}

.form-group input:focus,
.form-group select:focus {
    outline: none;
    border-color: var(--primary);
}

.add-button {
    margin-top: 20px;

    border: none;
    background: var(--primary);
    color: white;

    padding: 12px 19px;
    border-radius: 9px;

    font-weight: 800;
    cursor: pointer;
}

.add-button:hover {
    background: var(--primary-dark);
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
        1.4fr 1fr 1fr 1.2fr;

    align-items: center;
    gap: 15px;

    padding: 18px 22px;
    border-bottom: 1px solid var(--border);
}

.split-row:last-child {
    border-bottom: none;
}

.member-name {
    font-weight: 800;
}

.split-label {
    font-size: 11px;
    color: var(--muted);
    display: block;
    margin-bottom: 3px;
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


/* HISTORY */

.expense-history {
    display: grid;
    grid-template-columns:
        repeat(auto-fit, minmax(280px, 1fr));
    gap: 18px;
}

.expense-card {
    background: white;
    border: 1px solid var(--border);
    border-radius: 18px;
    padding: 20px;

    position: relative;
}

.expense-card h3 {
    margin: 12px 0 8px;
}

.category-tag {
    display: inline-block;

    background: #e7f5f5;
    color: var(--primary);

    padding: 6px 10px;
    border-radius: 20px;

    font-size: 11px;
    font-weight: 800;
}

.expense-amount {
    font-size: 24px;
    font-weight: 800;
    color: #17363c;

    margin: 13px 0;
}

.expense-detail {
    display: flex;
    justify-content: space-between;

    gap: 10px;
    padding: 6px 0;

    border-bottom: 1px solid #eeeeea;

    font-size: 13px;
}

.expense-detail span:first-child {
    color: var(--muted);
}

.delete-button {
    margin-top: 15px;

    border: none;

    background: #fff0f0;
    color: #b91c1c;

    padding: 9px 13px;
    border-radius: 8px;

    font-weight: 700;
    cursor: pointer;
}


/* EMPTY */

.empty-state {
    background: white;
    border: 1px solid var(--border);

    padding: 40px 25px;
    border-radius: 18px;

    text-align: center;
    color: var(--muted);
}


/* SUMMARY CTA */

.summary-cta {
    margin-top: 40px;

    background: #e7f3f3;
    border-radius: 22px;
    padding: 30px;

    display: flex;
    justify-content: space-between;
    align-items: center;

    gap: 25px;
}

.summary-cta h2 {
    margin: 0 0 7px;
}

.summary-cta p {
    margin: 0;
    color: var(--muted);
}


@media(max-width:850px) {

    .summary-grid {
        grid-template-columns: 1fr 1fr;
    }

    .split-row {
        grid-template-columns: 1fr 1fr;
    }
}


@media(max-width:600px) {

    .expense-header h1 {
        font-size: 32px;
    }

    .summary-grid {
        grid-template-columns: 1fr;
    }

    .form-grid {
        grid-template-columns: 1fr;
    }

    .split-row {
        grid-template-columns: 1fr;
    }

    .summary-cta {
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


<main class="page-container expense-page">


<a href="itinerary.jsp?id=<%= tripId %>"
   class="back-link">
    &larr; Back to Itinerary
</a>


<!-- HEADER -->

<section class="expense-header">

    <h1>Trip Expenses</h1>

    <p>
        <%= trip.getTripName() %>
        &nbsp; | &nbsp;
        <%= memberCount %> traveler(s)
    </p>


    <div class="summary-grid">


        <div class="summary-card">

            <span class="summary-label">
                Trip Budget
            </span>

            <div class="summary-amount">

                Rs. <%= String.format(
                    "%.2f",
                    trip.getTotalBudget()) %>

            </div>

        </div>


        <div class="summary-card">

            <span class="summary-label">
                Actual Spent
            </span>

            <div class="summary-amount">

                Rs. <%= String.format(
                    "%.2f",
                    totalSpent) %>

            </div>

        </div>


        <div class="summary-card">

            <span class="summary-label">
                Remaining
            </span>

            <div class="summary-amount">

                Rs. <%= String.format(
                    "%.2f",
                    remainingBudget) %>

            </div>

        </div>


        <div class="summary-card">

            <span class="summary-label">
                Equal Share / Person
            </span>

            <div class="summary-amount">

                Rs. <%= String.format(
                    "%.2f",
                    equalShare) %>

            </div>

        </div>


    </div>


    <%
    if (remainingBudget >= 0) {
    %>

    <div class="budget-message budget-good">

        Trip expenses are currently within budget.

        Rs. <%= String.format(
            "%.2f",
            remainingBudget) %>
        remains.

    </div>

    <%
    } else {
    %>

    <div class="budget-message budget-danger">

        Budget exceeded by

        Rs. <%= String.format(
            "%.2f",
            Math.abs(remainingBudget)) %>.

    </div>

    <%
    }
    %>


</section>


<!-- SUCCESS / ERROR -->

<%
if ("true".equals(
        request.getParameter("added"))) {
%>

<div class="message success">
    Expense added successfully.
</div>

<%
}
%>


<%
if ("true".equals(
        request.getParameter("deleted"))) {
%>

<div class="message success">
    Expense deleted successfully.
</div>

<%
}
%>


<%
String error =
    request.getParameter("error");

if (error != null) {

    String message =
        "Unable to save expense.";

    if ("amount".equals(error)) {

        message =
            "Expense amount must be greater than zero.";

    } else if ("date".equals(error)) {

        message =
            "Expense date must be inside the trip dates.";

    } else if ("member".equals(error)) {

        message =
            "The selected payer is not a member of this trip.";

    } else if ("input".equals(error)) {

        message =
            "Please complete all required expense details.";
    }
%>

<div class="message error">
    <%= message %>
</div>

<%
}
%>


<!-- ADD EXPENSE -->

<section class="expense-section">


<div class="section-title">

    <h2>Add Expense</h2>

    <p>
        Record money spent during the trip.
    </p>

</div>


<div class="expense-form-card">


<form action="addExpense"
      method="post">


<input type="hidden"
       name="tripId"
       value="<%= tripId %>">


<div class="form-grid">


<div class="form-group">

    <label>Who Paid?</label>

    <select name="paidBy"
            required>

        <%
        for (TripMember member : members) {
        %>

        <option value="<%= member.getUserId() %>">

            <%= member.getName() %>
            (<%= member.getRole() %>)

        </option>

        <%
        }
        %>

    </select>

</div>


<div class="form-group">

    <label>Category</label>

    <select name="category"
            required>

        <option value="FOOD">
            Food
        </option>

        <option value="TRANSPORT">
            Transport
        </option>

        <option value="HOTEL">
            Hotel
        </option>

        <option value="ACTIVITY">
            Activity
        </option>

        <option value="SHOPPING">
            Shopping
        </option>

        <option value="OTHER">
            Other
        </option>

    </select>

</div>


<div class="form-group">

    <label>Description</label>

    <input type="text"
           name="description"
           placeholder="Example: Dinner"
           required>

</div>


<div class="form-group">

    <label>Amount</label>

    <input type="number"
           name="amount"
           min="0.01"
           step="0.01"
           placeholder="0.00"
           required>

</div>


<div class="form-group">

    <label>Expense Date</label>

    <input type="date"
           name="expenseDate"
           min="<%= trip.getStartDate() %>"
           max="<%= trip.getEndDate() %>"
           required>

</div>


</div>


<button type="submit"
        class="add-button">

    Add Expense

</button>


</form>


</div>

</section>


<!-- EXPENSE SPLIT -->

<section class="expense-section">


<div class="section-title">

    <h2>Expense Split</h2>

    <p>
        Total expenses are divided equally among
        <%= memberCount %> traveler(s).
    </p>

</div>


<div class="split-container">


<%
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

        <div class="member-name">
            <%= member.getName() %>
        </div>

    </div>


    <div>

        <span class="split-label">
            Paid
        </span>

        <strong>

            Rs. <%= String.format(
                "%.2f",
                paid) %>

        </strong>

    </div>


    <div>

        <span class="split-label">
            Equal Share
        </span>

        <strong>

            Rs. <%= String.format(
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

            Gets back
            Rs. <%= String.format(
                "%.2f",
                balance) %>

        </span>


        <%
        } else if (balance < -0.01) {
        %>

        <span class="negative">

            Owes
            Rs. <%= String.format(
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
%>


</div>

</section>


<!-- EXPENSE HISTORY -->

<section class="expense-section">


<div class="section-title">

    <h2>Expense History</h2>

    <p>
        All recorded spending for this trip.
    </p>

</div>


<%
if (expenses == null ||
    expenses.isEmpty()) {
%>


<div class="empty-state">

    No expenses added yet.

</div>


<%
} else {
%>


<div class="expense-history">


<%
for (Expense expense : expenses) {
%>


<div class="expense-card">


    <span class="category-tag">

        <%= expense.getCategory() %>

    </span>


    <h3>

        <%= expense.getDescription() %>

    </h3>


    <div class="expense-amount">

        Rs. <%= String.format(
            "%.2f",
            expense.getAmount()) %>

    </div>


    <div class="expense-detail">

        <span>Paid by</span>

        <strong>
            <%= expense.getPaidByName() %>
        </strong>

    </div>


    <div class="expense-detail">

        <span>Date</span>

        <strong>
            <%= expense.getExpenseDate() %>
        </strong>

    </div>


    <form action="deleteExpense"
          method="post"
          onsubmit="return confirm('Delete this expense?');">


        <input type="hidden"
               name="tripId"
               value="<%= tripId %>">


        <input type="hidden"
               name="expenseId"
               value="<%= expense.getExpenseId() %>">


        <button type="submit"
                class="delete-button">

            Delete

        </button>


    </form>


</div>


<%
}
%>


</div>


<%
}
%>


</section>


<!-- TRIP SUMMARY -->

<section class="summary-cta">


<div>

    <h2>Complete Trip Overview</h2>

    <p>
        View your destination, group,
        itinerary, budget and expense split
        in one place.
    </p>

</div>


<a href="tripSummary.jsp?id=<%= tripId %>"
   class="btn-primary">

    View Trip Summary &rarr;

</a>


</section>


</main>


<footer class="footer">

    Triply &nbsp; | &nbsp;
    Collaborative Budget-Based Trip Planner

</footer>


</body>

</html>