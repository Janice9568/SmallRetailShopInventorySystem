package com.retail.controller;

import com.retail.model.dao.SalesDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {
    private SalesDAO salesDAO;

    @Override
    public void init() {
        salesDAO = new SalesDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Just forward to the update form
        request.getRequestDispatcher("WEB-INF/views/sales/payment-status.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int saleId = Integer.parseInt(request.getParameter("saleId"));
        String status = request.getParameter("paymentStatus");
        String method = request.getParameter("paymentMethod");

        boolean success = salesDAO.updatePaymentStatus(saleId, status, method);

        if (success) {
            response.sendRedirect("sales?action=history&success=Payment Updated");
        } else {
            response.sendRedirect("sales?action=history&error=Update Failed");
        }
    }
}