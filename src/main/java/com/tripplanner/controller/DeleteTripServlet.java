package com.tripplanner.controller;

import java.io.IOException;

import com.tripplanner.dao.TripDAO;
import com.tripplanner.model.User;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/deleteTrip")
public class DeleteTripServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

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
                    request.getParameter("id")
                );

            TripDAO dao = new TripDAO();

            dao.deleteTrip(
                tripId,
                user.getUserId()
            );

        } catch (Exception e) {

            e.printStackTrace();
        }

        response.sendRedirect("myTrips.jsp");
    }
}