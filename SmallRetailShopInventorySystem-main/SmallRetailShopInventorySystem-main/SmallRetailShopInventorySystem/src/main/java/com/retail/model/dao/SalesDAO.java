package com.retail.model.dao;

import com.retail.model.bean.Sale;
import com.retail.model.bean.SaleItem;
import com.retail.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SalesDAO {

    /**
     * FR4.1 - FR4.4: Record a sale, save items, and deduct stock.
     */
    public boolean recordSale(Sale sale, List<SaleItem> items) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Insert Sales Header
            String saleSql = "INSERT INTO sales (total_amount, payment_method, payment_status, user_id) VALUES (?, ?, ?, ?)";
            PreparedStatement psSale = conn.prepareStatement(saleSql, Statement.RETURN_GENERATED_KEYS);
            psSale.setDouble(1, sale.getTotalAmount());
            psSale.setString(2, sale.getPaymentMethod());
            psSale.setString(3, sale.getPaymentStatus());
            psSale.setInt(4, sale.getUserId());
            psSale.executeUpdate();

            ResultSet rs = psSale.getGeneratedKeys();
            int saleId = 0;
            if (rs.next()) {
                saleId = rs.getInt(1);
            }

            // 2. Insert Sale Items & Update Stock (FR3.2)
            String itemSql = "INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?)";
            String stockSql = "UPDATE products SET stock_quantity = stock_quantity - ? WHERE product_id = ? AND stock_quantity >= ?";

            PreparedStatement psItem = conn.prepareStatement(itemSql);
            PreparedStatement psStock = conn.prepareStatement(stockSql);

            for (SaleItem item : items) {
                // Insert Item
                psItem.setInt(1, saleId);
                psItem.setInt(2, item.getProductId());
                psItem.setInt(3, item.getQuantity());
                psItem.setDouble(4, item.getUnitPrice());
                psItem.setDouble(5, item.getSubtotal());
                psItem.addBatch();

                // Deduct Stock
                psStock.setInt(1, item.getQuantity());
                psStock.setInt(2, item.getProductId());
                psStock.setInt(3, item.getQuantity()); // Validation check
                int updatedRows = psStock.executeUpdate();

                if (updatedRows == 0) {
                    throw new SQLException("Insufficient stock for product ID: " + item.getProductId());
                }
            }
            psItem.executeBatch();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * FR5.1: Update payment details.
     */
    public boolean updatePaymentStatus(int saleId, String status, String method) {
        String sql = "UPDATE sales SET payment_status = ?, payment_method = ? WHERE sale_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, method);
            ps.setInt(3, saleId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Sale> getAllSales() {
        List<Sale> sales = new ArrayList<>();
        String sql = "SELECT s.*, u.full_name FROM sales s JOIN users u ON s.user_id = u.user_id ORDER BY s.sale_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Sale s = new Sale();
                s.setSaleId(rs.getInt("sale_id"));
                s.setSaleDate(rs.getTimestamp("sale_date"));
                s.setTotalAmount(rs.getDouble("total_amount"));
                s.setPaymentMethod(rs.getString("payment_method"));
                s.setPaymentStatus(rs.getString("payment_status"));
                s.setSellerName(rs.getString("full_name"));
                sales.add(s);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return sales;
    }
}