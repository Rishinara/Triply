package com.tripplanner.controller;

import java.io.IOException;

import com.tripplanner.dao.ItineraryDAO;
import com.tripplanner.dao.TripDAO;

import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/deleteActivity")
public class DeleteActivityServlet extends HttpServlet {

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

            int itineraryId =
                Integer.parseInt(
                    request.getParameter("itineraryId"));


            TripDAO tripDAO =
                new TripDAO();

            Trip trip =
                tripDAO.getTripById(
                    tripId,
                    user.getUserId());


            if (trip == null) {

                response.sendRedirect("myTrips.jsp");
                return;
            }


            ItineraryDAO dao =
                new ItineraryDAO();

            dao.deleteActivity(
                itineraryId,
                tripId);


            response.sendRedirect(
                "itinerary.jsp?id=" +
                tripId +
                "&deleted=true");


        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("myTrips.jsp");
        }
    }
}