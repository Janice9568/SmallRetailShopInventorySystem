package com.retail.controller;

import com.retail.model.bean.Supplier;
import com.retail.model.dao.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/suppliers")
public class SupplierServlet extends HttpServlet {
    private SupplierDAO supplierDAO;

    public void init() { supplierDAO = new SupplierDAO(); }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("supplierList", supplierDAO.getAllSuppliers());
        request.getRequestDispatcher("WEB-INF/views/product/supplier-list.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Supplier s = new Supplier();
        s.setSupplierName(request.getParameter("supplierName"));
        s.setContactPerson(request.getParameter("contactPerson"));
        s.setPhone(request.getParameter("phone"));
        s.setEmail(request.getParameter("email"));
        s.setAddress(request.getParameter("address"));

        supplierDAO.addSupplier(s);
        response.sendRedirect("suppliers");
    }
}