package com.tripplanner.filter;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req =
                (HttpServletRequest) request;

        HttpServletResponse res =
                (HttpServletResponse) response;

        // Prevent browser from caching pages
        res.setHeader("Cache-Control",
                "no-cache, no-store, must-revalidate");

        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);

        HttpSession session =
                req.getSession(false);

        String path = req.getRequestURI()
                .substring(req.getContextPath().length());

        boolean loggedIn =
                session != null
                && session.getAttribute("loggedUser") != null;

        // Pages/resources that can be accessed without login
        boolean publicRequest =
                path.equals("/")
                || path.equals("/login.html")
                || path.equals("/register.html")
                || path.equals("/login")
                || path.equals("/register")
                || path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/images/");

        if (loggedIn || publicRequest) {

            chain.doFilter(request, response);

        } else {

            res.sendRedirect(
                req.getContextPath() + "/login.html"
            );
        }
    }
}