package com.tripplanner.controller;

import java.io.IOException;
import java.util.regex.Pattern;

import com.tripplanner.dao.UserDAO;
import com.tripplanner.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private static final Pattern NAME_PATTERN =
            Pattern.compile("^[A-Za-z ]{3,50}$");


    private static final Pattern EMAIL_PATTERN =
            Pattern.compile(
                "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"
            );


    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[6-9][0-9]{9}$");


    /*
     * Password must contain:
     * - 8 to 50 characters
     * - at least one lowercase letter
     * - at least one uppercase letter
     * - at least one number
     * - at least one special character
     * - no whitespace
     */
    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile(
                "^(?=.*[a-z])" +
                "(?=.*[A-Z])" +
                "(?=.*\\d)" +
                "(?=.*[^A-Za-z0-9\\s])" +
                ".{8,50}$"
            );


    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {


        String name =
                request.getParameter("name");

        String email =
                request.getParameter("email");

        String phone =
                request.getParameter("phone");

        String password =
                request.getParameter("password");

        String confirmPassword =
                request.getParameter(
                    "confirmPassword"
                );


        /*
         * 1. REQUIRED FIELD VALIDATION
         */

        if (name == null ||
            email == null ||
            phone == null ||
            password == null ||
            confirmPassword == null ||

            name.trim().isEmpty() ||
            email.trim().isEmpty() ||
            phone.trim().isEmpty() ||
            password.isEmpty() ||
            confirmPassword.isEmpty()) {


            response.sendRedirect(
                "register.html?error=invalid"
            );

            return;
        }


        /*
         * Remove unnecessary spaces
         */

        name = name.trim();
        email = email.trim().toLowerCase();
        phone = phone.trim();


        /*
         * 2. NAME VALIDATION
         */

        if (!NAME_PATTERN.matcher(name).matches()) {

            response.sendRedirect(
                "register.html?error=name"
            );

            return;
        }


        /*
         * 3. EMAIL VALIDATION
         */

        if (!EMAIL_PATTERN.matcher(email).matches()) {

            response.sendRedirect(
                "register.html?error=emailformat"
            );

            return;
        }


        /*
         * 4. PHONE VALIDATION
         */

        if (!PHONE_PATTERN.matcher(phone).matches()) {

            response.sendRedirect(
                "register.html?error=phone"
            );

            return;
        }


        /*
         * 5. PASSWORD STRENGTH VALIDATION
         */

        if (!PASSWORD_PATTERN
                .matcher(password)
                .matches()) {


            response.sendRedirect(
                "register.html?error=passwordrules"
            );

            return;
        }


        /*
         * 6. CONFIRM PASSWORD
         */

        if (!password.equals(confirmPassword)) {

            response.sendRedirect(
                "register.html?error=password"
            );

            return;
        }


        UserDAO userDAO =
                new UserDAO();


        /*
         * 7. DUPLICATE EMAIL CHECK
         */

        if (userDAO.emailExists(email)) {

            response.sendRedirect(
                "register.html?error=email"
            );

            return;
        }


        /*
         * 8. CREATE USER
         *
         * UserDAO already hashes the password
         * before storing it in Oracle.
         */

        User user =
                new User(
                    name,
                    email,
                    password,
                    phone
                );


        boolean registered =
                userDAO.registerUser(user);


        /*
         * 9. RESULT
         */

        if (registered) {

            response.sendRedirect(
                "login.html?registered=true"
            );

        } else {

            response.sendRedirect(
                "register.html?error=server"
            );
        }
    }
}