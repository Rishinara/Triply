package com.tripplanner.controller;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.UUID;

import com.tripplanner.dao.TripDAO;
import com.tripplanner.dao.TripMemberDAO;
import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/createTrip")
public class CreateTripServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("loggedUser") == null) {

            response.sendRedirect("login.html");
            return;
        }

        try {

            User user =
                (User) session.getAttribute("loggedUser");

            String tripName =
                request.getParameter("tripName").trim();

            String startCity =
                request.getParameter("startCity").trim();

            LocalDate start =
                LocalDate.parse(request.getParameter("startDate"));

            LocalDate end =
                LocalDate.parse(request.getParameter("endDate"));

            double budget =
                Double.parseDouble(request.getParameter("budget"));


            if (tripName.isEmpty() ||
                startCity.isEmpty() ||
                budget <= 0 ||
                end.isBefore(start)) {

                response.sendRedirect(
                    "createTrip.jsp?error=invalid"
                );

                return;
            }


            Trip trip = new Trip();

            trip.setTripName(tripName);
            trip.setCreatedBy(user.getUserId());
            trip.setStartCity(startCity);

            trip.setStartDate(
                Date.valueOf(start)
            );

            trip.setEndDate(
                Date.valueOf(end)
            );

            trip.setTotalBudget(budget);

            trip.setStatus(
                calculateStatus(start, end)
            );

            String inviteCode =
                UUID.randomUUID()
                    .toString()
                    .substring(0, 8)
                    .toUpperCase();

            trip.setInviteCode(inviteCode);


            TripDAO dao = new TripDAO();

            if (dao.createTrip(trip)) {

                TripMemberDAO memberDAO =
                    new TripMemberDAO();

                memberDAO.addOrganizerByInviteCode(
                    inviteCode,
                    user.getUserId()
                );

                response.sendRedirect(
                    "myTrips.jsp?created=true"
                );
            }else {

                response.sendRedirect(
                    "createTrip.jsp?error=server"
                );
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                "createTrip.jsp?error=invalid"
            );
        }
    }


    private String calculateStatus(
            LocalDate start,
            LocalDate end) {

        LocalDate today = LocalDate.now();

        if (today.isBefore(start)) {
            return "UPCOMING";
        }

        if (today.isAfter(end)) {
            return "COMPLETED";
        }

        return "ONGOING";
    }
}