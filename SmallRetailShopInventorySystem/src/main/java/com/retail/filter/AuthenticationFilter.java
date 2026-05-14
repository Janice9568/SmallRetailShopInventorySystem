package com.retail.filter;

import com.retail.model.bean.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    public void init(FilterConfig fConfig) throws ServletException {}

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        String path = httpRequest.getServletPath();
        String contextPath = httpRequest.getContextPath();

        // 1. Allow Public Access
        boolean isLoginRequest = path.equals("/login") || path.equals("/login.jsp") || path.equals("/index.jsp");
        boolean isStaticResource = path.startsWith("/assets/");

        if (isLoginRequest || isStaticResource) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Check Authentication
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            httpResponse.sendRedirect(contextPath + "/login");
            return;
        }

        // 3. Role-Based Access Control (RBAC)
        String role = user.getRole();
        boolean authorized = true;

        // CASHIER: Manage sales only
        if (role.equals("CASHIER")) {
            // Cashier can ONLY access sales, payments, dashboard, and logout
            if (!(path.startsWith("/sales") || path.startsWith("/payments") || path.startsWith("/dashboard") || path.startsWith("/logout"))) {
                authorized = false;
            }
        }

        // INVENTORY_STAFF: Update inventory and specific reports
        else if (role.equals("INVENTORY_STAFF")) {
            if (path.startsWith("/sales") || path.startsWith("/payments") || path.startsWith("/suppliers")) {
                authorized = false;
            }
            // Logic for Reports: Only allowed to see inventory-related reports
            if (path.startsWith("/reports")) {
                String action = httpRequest.getParameter("action");
                // Inventory staff NOT allowed to see financial/performance reports
                if ("performance".equals(action) || "salesSummary".equals(action) || action == null) {
                    authorized = false;
                }
            }
        }

        // 4. Final Execution
        if (authorized) {
            chain.doFilter(request, response);
        } else {
            // Logged in but unauthorized for this specific page
            httpResponse.sendRedirect(contextPath + "/dashboard?error=AccessDenied");
        }
    }

    public void destroy() {}
}