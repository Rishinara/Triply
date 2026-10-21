package com.tripplanner.controller;

import java.io.IOException;
import java.sql.Date;

import com.tripplanner.dao.ExpenseDAO;
import com.tripplanner.dao.TripDAO;
import com.tripplanner.dao.TripMemberDAO;

import com.tripplanner.model.Expense;
import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/addExpense")
public class AddExpenseServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
            request.getSession(false);

        if (session == null ||
            session.getAttribute("loggedUser") == null) {

            response.sendRedirect("login.html");
            return;
        }

        try {

            User user =
                (User) session.getAttribute("loggedUser");

            int tripId =
                Integer.parseInt(
                    request.getParameter("tripId"));

            int paidBy =
                Integer.parseInt(
                    request.getParameter("paidBy"));

            String category =
                request.getParameter("category");

            String description =
                request.getParameter("description");

            double amount =
                Double.parseDouble(
                    request.getParameter("amount"));

            Date expenseDate =
                Date.valueOf(
                    request.getParameter("expenseDate"));


            TripDAO tripDAO = new TripDAO();

            Trip trip =
                tripDAO.getAccessibleTripById(
                    tripId,
                    user.getUserId());


            if (trip == null) {

                response.sendRedirect("myTrips.jsp");
                return;
            }


            if (description == null ||
                description.trim().isEmpty() ||
                category == null ||
                category.trim().isEmpty()) {

                response.sendRedirect(
                    "expenses.jsp?id=" +
                    tripId +
                    "&error=input");

                return;
            }


            if (amount <= 0) {

                response.sendRedirect(
                    "expenses.jsp?id=" +
                    tripId +
                    "&error=amount");

                return;
            }


            // Expense must belong to the trip period.
            if (expenseDate.before(trip.getStartDate()) ||
                expenseDate.after(trip.getEndDate())) {

                response.sendRedirect(
                    "expenses.jsp?id=" +
                    tripId +
                    "&error=date");

                return;
            }


            // Prevent selecting a random user as payer.
            TripMemberDAO memberDAO =
                new TripMemberDAO();

            if (!memberDAO.isMember(
                    tripId,
                    paidBy)) {

                response.sendRedirect(
                    "expenses.jsp?id=" +
                    tripId +
                    "&error=member");

                return;
            }


            Expense expense = new Expense();

            expense.setTripId(tripId);
            expense.setPaidBy(paidBy);
            expense.setCategory(category);
            expense.setDescription(
                description.trim());
            expense.setAmount(amount);
            expense.setExpenseDate(expenseDate);


            ExpenseDAO dao = new ExpenseDAO();

            if (dao.addExpense(expense)) {

                response.sendRedirect(
                    "expenses.jsp?id=" +
                    tripId +
                    "&added=true");

            } else {

                response.sendRedirect(
                    "expenses.jsp?id=" +
                    tripId +
                    "&error=save");
            }


        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("myTrips.jsp");
        }
    }
}