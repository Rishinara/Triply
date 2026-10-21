package com.tripplanner.controller;

import java.io.IOException;

import com.tripplanner.dao.TripDAO;
import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/selectTransport")
public class SelectTransportServlet extends HttpServlet {

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

            int transportId =
                Integer.parseInt(
                    request.getParameter("transportId"));

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
                dao.selectTransport(
                    tripId,
                    user.getUserId(),
                    transportId);

            if (selected) {

                response.sendRedirect(
                    "destinationDetails.jsp?id=" +
                    tripId +
                    "&transportSelected=true");

            } else {

                response.sendRedirect(
                    "destinationDetails.jsp?id=" +
                    tripId +
                    "&error=transport");
            }

        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("myTrips.jsp");
        }
    }
}