package com.tripplanner.controller;

import java.io.IOException;

import com.tripplanner.dao.TripDAO;
import com.tripplanner.dao.TripMemberDAO;
import com.tripplanner.dao.TripPreferenceDAO;
import com.tripplanner.model.Trip;
import com.tripplanner.model.TripPreference;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/savePreference")
public class SavePreferenceServlet extends HttpServlet {

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

            TripDAO tripDAO = new TripDAO();

            Trip trip =
                tripDAO.getTripById(
                    tripId,
                    user.getUserId());

            /*
             * getTripById currently checks CREATED_BY,
             * so only the organizer can change preferences.
             */
            if (trip == null) {

                response.sendRedirect("myTrips.jsp");
                return;
            }


            String category =
                request.getParameter("category");

            String travelMonth =
                request.getParameter("travelMonth");

            int duration =
                Integer.parseInt(
                    request.getParameter("duration"));


            if (category == null ||
                category.trim().isEmpty() ||
                travelMonth == null ||
                travelMonth.trim().isEmpty() ||
                duration <= 0) {

                response.sendRedirect(
                    "tripDetails.jsp?id=" +
                    tripId +
                    "&error=invalid");

                return;
            }


            TripPreference preference =
                new TripPreference();

            preference.setTripId(tripId);
            preference.setCategory(category);
            preference.setTravelMonth(travelMonth);
            preference.setDuration(duration);


            TripPreferenceDAO preferenceDAO =
                new TripPreferenceDAO();

            boolean saved =
                preferenceDAO.savePreference(preference);


            if (saved) {

                response.sendRedirect(
                    "tripDetails.jsp?id=" +
                    tripId +
                    "&saved=true");

            } else {

                response.sendRedirect(
                    "tripDetails.jsp?id=" +
                    tripId +
                    "&error=server");
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect("myTrips.jsp");
        }
    }
}