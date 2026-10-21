package com.tripplanner.controller;

import java.io.IOException;

import com.tripplanner.dao.TripDAO;
import com.tripplanner.model.Trip;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/joinTrip")
public class JoinTripServlet extends HttpServlet {

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


        User user =
            (User) session.getAttribute("loggedUser");

        String inviteCode =
            request.getParameter("inviteCode");


        if (inviteCode == null ||
            inviteCode.trim().isEmpty()) {

            response.sendRedirect(
                "joinTrip.jsp?error=invalid"
            );

            return;
        }


        TripDAO dao = new TripDAO();

        Trip trip =
            dao.getTripByInviteCode(
                inviteCode.trim()
            );


        if (trip == null) {

            response.sendRedirect(
                "joinTrip.jsp?error=invalid"
            );

            return;
        }


        if (trip.getCreatedBy() ==
            user.getUserId()) {

            response.sendRedirect(
                "joinTrip.jsp?error=own"
            );

            return;
        }


        if (dao.isTripMember(
                trip.getTripId(),
                user.getUserId())) {

            response.sendRedirect(
                "joinTrip.jsp?error=already"
            );

            return;
        }


        boolean joined =
            dao.joinTrip(
                trip.getTripId(),
                user.getUserId()
            );


        if (joined) {

            response.sendRedirect(
                "myTrips.jsp?joined=true"
            );

        } else {

            response.sendRedirect(
                "joinTrip.jsp?error=server"
            );
        }
    }
}