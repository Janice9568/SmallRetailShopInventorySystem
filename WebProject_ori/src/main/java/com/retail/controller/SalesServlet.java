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

            case "status":
                request.getRequestDispatcher("WEB-INF/views/sales/payment-status.jsp").forward(request, response);
                break;

            case "history":
                List<Sale> salesList = salesDAO.getAllSales();
                request.setAttribute("salesList", salesList);
                request.getRequestDispatcher("WEB-INF/views/sales/sales-history.jsp").forward(request, response);
                break;

            // 🔥 新增：处理删除订单的 Function 🔥
            case "delete":
                try {
                    int deleteSaleId = Integer.parseInt(request.getParameter("saleId"));

                    // 调用 DAO 层执行删除 (我们需要去 SalesDAO 里面补上这个方法，见第三步)
                    boolean isDeleted = salesDAO.deleteSaleById(deleteSaleId);

                    if (isDeleted) {
                        // 删除成功后，刷新历史记录页面，并带上成功提示
                        response.sendRedirect("sales?action=history&msg=Deleted Successfully");
                    } else {
                        response.sendRedirect("sales?action=history&error=Delete Failed");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect("sales?action=history&error=Invalid Sale ID");
                }
                break;

            case "updatePayment":
                int saleId = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("status");
                String method = request.getParameter("method");
                salesDAO.updatePaymentStatus(saleId, status, method);
                response.sendRedirect("sales?action=history");
                break;

            default:
                response.sendRedirect("dashboard");
                break;
        }


    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        // 💡 🔥 核心安全改动：防止登录过期导致空指针崩溃引发 405 报错
        if (user == null) {
            // 如果发现 Session 里的用户丢了，优雅地把他重定向到登录页，不让代码往下死掉
            response.sendRedirect(request.getContextPath() + "/login.jsp"); // 如果登录页叫别的名字，改成对应的
            return; // 必须 return，切断执行！
        }

        // FR4.1: Retrieve products and quantities from the form
        String[] productIds = request.getParameterValues("productId[]");
        String[] quantities = request.getParameterValues("qty[]");
        String paymentMethod = request.getParameter("paymentMethod");
        String paymentStatus = request.getParameter("paymentStatus");

        if (productIds == null || productIds.length == 0 || quantities == null || quantities.length == 0) {
            // 如果什么商品都没带过来，直接狠狠弹回 POS 页面，并带上警告错误信息！
            response.sendRedirect("sales?action=pos&error=Cannot confirm an empty sale! Please add products first.");
            return; // 强制切断，绝对不允许往数据库插数据！
        }


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

        // 此时有了上面的防护，这里绝对百分之百安全，不会再报空指针！
        sale.setUserId(user.getUserId());

        boolean success = salesDAO.recordSale(sale, items);

        if (success) {
            session.setAttribute("paymentMethod", paymentMethod);
            session.setAttribute("paymentStatus", paymentStatus);
            session.setAttribute("totalAmount", totalAmount);
            session.setAttribute("txnId", "SAL-" + sale.getSaleId());

            response.sendRedirect("sales?action=status");
        } else {
            response.sendRedirect("sales?action=pos&error=Transaction Failed (Check Stock)");
        }
    }
}