package com.tripplanner.controller;

import java.io.IOException;

import com.tripplanner.dao.TripDAO;
import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/selectHotel")
public class SelectHotelServlet extends HttpServlet {

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

            int hotelId =
                Integer.parseInt(
                    request.getParameter("hotelId"));

            int rooms =
                Integer.parseInt(
                    request.getParameter("rooms"));

            if (rooms <= 0) {
                response.sendRedirect(
                    "destinationDetails.jsp?id=" +
                    tripId + "&error=rooms");
                return;
            }

            TripDAO dao = new TripDAO();

            Trip trip =
                dao.getTripById(
                    tripId,
                    user.getUserId());

            if (trip == null ||
                trip.getDestinationId() <= 0) {

                response.sendRedirect("myTrips.jsp");
                return;
            }

            boolean selected =
                dao.selectHotel(
                    tripId,
                    user.getUserId(),
                    hotelId,
                    rooms);

            if (selected) {

                response.sendRedirect(
                    "destinationDetails.jsp?id=" +
                    tripId +
                    "&hotelSelected=true");

            } else {

                response.sendRedirect(
                    "destinationDetails.jsp?id=" +
                    tripId +
                    "&error=hotel");
            }

        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("myTrips.jsp");
        }
    }
}