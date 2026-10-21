package com.tripplanner.controller;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;

import com.tripplanner.dao.TripDAO;
import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/updateTrip")
public class UpdateTripServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request,
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
                    request.getParameter("tripId")
                );

            LocalDate start =
                LocalDate.parse(
                    request.getParameter("startDate")
                );

            LocalDate end =
                LocalDate.parse(
                    request.getParameter("endDate")
                );

            double budget =
                Double.parseDouble(
                    request.getParameter("budget")
                );


            if (end.isBefore(start) ||
                budget <= 0) {

                response.sendRedirect(
                    "editTrip.jsp?id=" + tripId
                );

                return;
            }


            Trip trip = new Trip();

            trip.setTripId(tripId);

            trip.setCreatedBy(
                user.getUserId()
            );

            trip.setTripName(
                request.getParameter("tripName").trim()
            );

            trip.setStartCity(
                request.getParameter("startCity").trim()
            );

            trip.setStartDate(
                Date.valueOf(start)
            );

            trip.setEndDate(
                Date.valueOf(end)
            );

            trip.setTotalBudget(budget);


            TripDAO dao =
                new TripDAO();

            dao.updateTrip(trip);


            response.sendRedirect(
                "myTrips.jsp"
            );


        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                "myTrips.jsp"
            );
        }
    }
}