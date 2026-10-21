package com.tripplanner.controller;

import java.io.IOException;

import com.tripplanner.dao.TripDAO;
import com.tripplanner.dao.VoteDAO;
import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/vote")
public class VoteServlet extends HttpServlet {

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

            int destinationId =
                Integer.parseInt(
                    request.getParameter(
                        "destinationId"));


            TripDAO tripDAO = new TripDAO();

            Trip trip =
                tripDAO.getAccessibleTripById(
                    tripId,
                    user.getUserId());


            if (trip == null) {
                response.sendRedirect("myTrips.jsp");
                return;
            }


            VoteDAO voteDAO =
                new VoteDAO();

            voteDAO.vote(
                tripId,
                user.getUserId(),
                destinationId);


            response.sendRedirect(
                "recommendations.jsp?id=" +
                tripId +
                "&voted=true");


        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect("myTrips.jsp");
        }
    }
}