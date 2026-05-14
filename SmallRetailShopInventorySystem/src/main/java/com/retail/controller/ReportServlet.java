package com.retail.controller;

import com.retail.model.dao.ReportDAO;
import com.retail.model.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@WebServlet("/reports")
public class ReportServlet extends HttpServlet {
    private ReportDAO reportDAO;
    private ProductDAO productDAO;

    public void init() {
        reportDAO = new ReportDAO();
        productDAO = new ProductDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "salesSummary";

        switch (action) {
            case "lowStock":
                // FR6.4: Inventory status/low-stock reports
                request.setAttribute("lowStockList", productDAO.getLowStockProducts());
                request.getRequestDispatcher("WEB-INF/views/inventory/low-stock.jsp").forward(request, response);
                break;

            case "inventoryStatus":
                // FR6.4: Full inventory status
                request.setAttribute("productList", productDAO.getAllProducts());
                request.getRequestDispatcher("WEB-INF/views/product/product-list.jsp").forward(request, response);
                break;

            case "performance":
                // FR6.3: Product performance (Owner Only via Filter)
                request.setAttribute("performanceData", reportDAO.getProductPerformance());
                request.getRequestDispatcher("WEB-INF/views/reports/performance.jsp").forward(request, response);
                break;

            default: // salesSummary
                // FR6.1/6.2: Financial reports (Owner Only via Filter)
                String start = request.getParameter("startDate");
                String end = request.getParameter("endDate");
                request.setAttribute("salesData", reportDAO.getSalesSummary(start, end));
                request.getRequestDispatcher("WEB-INF/views/reports/sales-report.jsp").forward(request, response);
                break;
        }
    }
}