package com.retail.controller;

import com.retail.model.bean.Product;
import com.retail.model.bean.Sale;
import com.retail.model.bean.SaleItem;
import com.retail.model.bean.User;
import com.retail.model.dao.ProductDAO;
import com.retail.model.dao.SalesDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/sales")
public class SalesServlet extends HttpServlet {
    private SalesDAO salesDAO;
    private ProductDAO productDAO;

    @Override
    public void init() {
        salesDAO = new SalesDAO();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "pos";

        switch (action) {
            case "pos":
                List<Product> products = productDAO.getAllProducts();
                request.setAttribute("products", products);
                request.getRequestDispatcher("WEB-INF/views/sales/pos.jsp").forward(request, response);
                break;
            case "updatePayment":
                int saleId = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                String method = request.getParameter("method");
                salesDAO.updatePaymentStatus(saleId, status, method);
                response.sendRedirect("sales?action=history");
                break;
            default:
                // Redirect to history or dashboard
                response.sendRedirect("dashboard");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        // FR4.1: Retrieve products and quantities from the form
        String[] productIds = request.getParameterValues("productId[]");
        String[] quantities = request.getParameterValues("qty[]");
        String paymentMethod = request.getParameter("paymentMethod");
        String paymentStatus = request.getParameter("paymentStatus");

        double totalAmount = 0;
        List<SaleItem> items = new ArrayList<>();

        if (productIds != null && quantities != null) {
            for (int i = 0; i < productIds.length; i++) {
                int pid = Integer.parseInt(productIds[i]);
                int qty = Integer.parseInt(quantities[i]);
                Product p = productDAO.getProductById(pid);

                if (p != null) {
                    SaleItem item = new SaleItem();
                    item.setProductId(pid);
                    item.setQuantity(qty);
                    item.setUnitPrice(p.getPrice());
                    item.setSubtotal(p.getPrice() * qty);
                    items.add(item);
                    totalAmount += item.getSubtotal();
                }
            }
        }

        Sale sale = new Sale();
        sale.setTotalAmount(totalAmount);
        sale.setPaymentMethod(paymentMethod);
        sale.setPaymentStatus(paymentStatus);
        sale.setUserId(user.getUserId());

        boolean success = salesDAO.recordSale(sale, items);

        if (success) {
            response.sendRedirect("sales?action=pos&success=Sale Recorded");
        } else {
            response.sendRedirect("sales?action=pos&error=Transaction Failed (Check Stock)");
        }
    }
}