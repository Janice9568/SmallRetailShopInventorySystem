package com.retail.controller;

import com.retail.model.bean.Product;
import com.retail.model.bean.Supplier;
import com.retail.model.dao.ProductDAO;
import com.retail.model.dao.SupplierDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/products")
public class ProductServlet extends HttpServlet {
    private ProductDAO productDAO;
    private SupplierDAO supplierDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
        supplierDAO = new SupplierDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "new":
                showEditForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            default:
                listProducts(request, response);
                break;
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> listProduct = productDAO.getAllProducts();
        request.setAttribute("productList", listProduct);
        request.getRequestDispatcher("WEB-INF/views/product/product-list.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        if (id != null) {
            Product existingProduct = productDAO.getProductById(Integer.parseInt(id));
            request.setAttribute("product", existingProduct);
        }
        List<Supplier> suppliers = supplierDAO.getAllSuppliers();
        request.setAttribute("suppliers", suppliers);
        request.getRequestDispatcher("WEB-INF/views/product/product-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("productId");

        Product product = new Product();
        product.setProductName(request.getParameter("productName"));
        product.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
        product.setSupplierId(Integer.parseInt(request.getParameter("supplierId")));
        product.setModel(request.getParameter("model"));
        product.setPrice(Double.parseDouble(request.getParameter("price")));
        product.setLowStockThreshold(Integer.parseInt(request.getParameter("lowStockThreshold")));

        if (idStr == null || idStr.isEmpty()) {
            product.setStockQuantity(Integer.parseInt(request.getParameter("stockQuantity")));
            productDAO.addProduct(product);
        } else {
            product.setProductId(Integer.parseInt(idStr));
            productDAO.updateProduct(product);
        }
        response.sendRedirect("products");
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        productDAO.deleteProduct(id);
        response.sendRedirect("products");
    }
}