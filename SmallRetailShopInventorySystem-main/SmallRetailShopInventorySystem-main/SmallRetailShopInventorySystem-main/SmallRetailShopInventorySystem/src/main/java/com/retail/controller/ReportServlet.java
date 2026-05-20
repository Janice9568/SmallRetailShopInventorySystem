package com.retail.controller;

import com.retail.model.dao.ReportDAO;
import com.retail.model.dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/reports")
public class ReportServlet extends HttpServlet {
    private ReportDAO reportDAO;
    private ProductDAO productDAO;

    @Override
    public void init() {
        reportDAO = new ReportDAO();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "salesSummary";

        switch (action) {
            case "lowStock":
                request.setAttribute("lowStockList", productDAO.getLowStockProducts());
                request.getRequestDispatcher("WEB-INF/views/inventory/low-stock.jsp").forward(request, response);
                break;

            case "performance":
                request.setAttribute("performanceData", reportDAO.getProductPerformance());
                request.getRequestDispatcher("WEB-INF/views/reports/performance.jsp").forward(request, response);
                break;

            // 🔥 1. 这是你的专属高档打印页路由，调用 getDetailedSalesRows！
            case "printReport":
                String printStart = request.getParameter("startDate");
                String printEnd = request.getParameter("endDate");

                // 严格对齐 DAO 里的详细交易方法名
                request.setAttribute("detailedSales", reportDAO.getDetailedSalesRows(printStart, printEnd));
                request.setAttribute("startDate", printStart);
                request.setAttribute("endDate", printEnd);

                request.getRequestDispatcher("WEB-INF/views/reports/print-report.jsp").forward(request, response);
                break;

            // 💡 2. 这是主大面板，调用原本按天统计的 getSalesSummary！
            default:
                String start = request.getParameter("startDate");
                String end = request.getParameter("endDate");

                // 保持原样，查每天的总账
                request.setAttribute("salesData", reportDAO.getSalesSummary(start, end));
                // 同时把旁边那两个小卡片的数据也顺手刷出来
                request.setAttribute("performanceData", reportDAO.getProductPerformance());
                request.setAttribute("lowStockList", productDAO.getLowStockProducts());

                request.getRequestDispatcher("WEB-INF/views/reports/sales-report.jsp").forward(request, response);
                break;
        }
    }
}