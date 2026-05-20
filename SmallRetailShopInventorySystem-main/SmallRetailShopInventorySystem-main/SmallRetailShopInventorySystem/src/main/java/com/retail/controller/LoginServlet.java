package com.retail.controller;

import com.retail.model.bean.User;
import com.retail.model.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        if ("/logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect("login.jsp");
        } else {
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userStr = request.getParameter("username");
        String passStr = request.getParameter("password");

        User user = userDAO.authenticate(userStr, passStr);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", user);

            // Redirect based on role
            switch (user.getRole()) {
                case "OWNER":
                    response.sendRedirect("dashboard");
                    break;
                case "CASHIER":
                    response.sendRedirect("sales?action=pos");
                    break;
                case "INVENTORY_STAFF":
                    response.sendRedirect("products");
                    break;
                default:
                    response.sendRedirect("login.jsp?error=Role Not Recognized");
            }
        } else {
            request.setAttribute("errorMessage", "Invalid Username or Password");
            request.getRequestDispatcher("WEB-INF/views/auth/login.jsp").forward(request, response);
        }


    }
}