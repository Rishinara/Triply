package com.tripplanner.controller;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalTime;

import com.tripplanner.dao.ItineraryDAO;
import com.tripplanner.dao.TripDAO;

import com.tripplanner.model.Itinerary;
import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/addActivity")
public class AddActivityServlet extends HttpServlet {

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

            String activityName =
                request.getParameter("activityName");

            String dateText =
                request.getParameter("activityDate");

            String startTime =
                request.getParameter("startTime");

            String endTime =
                request.getParameter("endTime");

            String placeText =
                request.getParameter("placeId");

            String costText =
                request.getParameter("estimatedCost");

            String notes =
                request.getParameter("notes");


            TripDAO tripDAO = new TripDAO();

            // Organizer controls itinerary changes.
            Trip trip =
                tripDAO.getTripById(
                    tripId,
                    user.getUserId());

            if (trip == null) {
                response.sendRedirect("myTrips.jsp");
                return;
            }


            if (activityName == null ||
                activityName.trim().isEmpty()) {

                response.sendRedirect(
                    "itinerary.jsp?id=" +
                    tripId +
                    "&error=name");

                return;
            }


            Date activityDate =
                Date.valueOf(dateText);


            // Activity must be inside trip dates.
            if (activityDate.before(trip.getStartDate()) ||
                activityDate.after(trip.getEndDate())) {

                response.sendRedirect(
                    "itinerary.jsp?id=" +
                    tripId +
                    "&error=date");

                return;
            }


            LocalTime start =
                LocalTime.parse(startTime);

            LocalTime end =
                LocalTime.parse(endTime);


            if (!end.isAfter(start)) {

                response.sendRedirect(
                    "itinerary.jsp?id=" +
                    tripId +
                    "&error=time");

                return;
            }


            int placeId = 0;

            if (placeText != null &&
                !placeText.trim().isEmpty()) {

                placeId =
                    Integer.parseInt(placeText);
            }


            double estimatedCost = 0;

            if (costText != null &&
                !costText.trim().isEmpty()) {

                estimatedCost =
                    Double.parseDouble(costText);
            }


            if (estimatedCost < 0) {

                response.sendRedirect(
                    "itinerary.jsp?id=" +
                    tripId +
                    "&error=cost");

                return;
            }


            ItineraryDAO itineraryDAO =
                new ItineraryDAO();


            if (itineraryDAO.hasConflict(
                    tripId,
                    activityDate,
                    startTime,
                    endTime)) {

                response.sendRedirect(
                    "itinerary.jsp?id=" +
                    tripId +
                    "&error=conflict");

                return;
            }


            Itinerary item =
                new Itinerary();

            item.setTripId(tripId);
            item.setPlaceId(placeId);
            item.setActivityName(
                activityName.trim());

            item.setActivityDate(activityDate);
            item.setStartTime(startTime);
            item.setEndTime(endTime);
            item.setEstimatedCost(estimatedCost);
            item.setNotes(notes);


            boolean added =
                itineraryDAO.addActivity(item);


            if (added) {

                response.sendRedirect(
                    "itinerary.jsp?id=" +
                    tripId +
                    "&added=true");

            } else {

                response.sendRedirect(
                    "itinerary.jsp?id=" +
                    tripId +
                    "&error=save");
            }


        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("myTrips.jsp");
        }
    }
}