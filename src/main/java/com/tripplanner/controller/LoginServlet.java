package com.tripplanner.controller;

import java.io.IOException;

import com.tripplanner.dao.UserDAO;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {

            response.sendRedirect("login.html?error=empty");
            return;
        }

        UserDAO userDAO = new UserDAO();

        User user = userDAO.login(
                email.trim(),
                password
        );

        if (user != null) {

            HttpSession session = request.getSession();
            session.setMaxInactiveInterval(30 * 60);

            session.setAttribute("loggedUser", user);

            response.sendRedirect("dashboard.jsp");

        } else {

            response.sendRedirect(
                    "login.html?error=invalid"
            );
        }
    }
}