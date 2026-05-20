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

    /**
     * 根据 Sale ID 查询订单主表信息
     */
    public Sale getSaleById(int saleId) {
        String sql = "SELECT * FROM sales WHERE sale_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, saleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Sale sale = new Sale();
                    sale.setSaleId(rs.getInt("sale_id"));
                    sale.setTotalAmount(rs.getDouble("total_amount"));
                    sale.setPaymentMethod(rs.getString("payment_method"));
                    sale.setPaymentStatus(rs.getString("payment_status"));
                    sale.setUserId(rs.getInt("user_id"));
                    sale.setSaleDate(rs.getTimestamp("sale_date")); // 获取完整的日期和时间
                    return sale;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 根据 Sale ID 查询该订单下所有的商品明细列表
     */
    public List<SaleItem> getSaleItemsBySaleId(int saleId) {
        List<SaleItem> items = new ArrayList<>();
        String sql = "SELECT * FROM sale_items WHERE sale_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, saleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SaleItem item = new SaleItem();

                    // 💡 严格对应你的数据库列名
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getDouble("unit_price"));
                    item.setSubtotal(rs.getDouble("subtotal"));

                    // 刚才报错的那一行主键，如果你不需要它，直接不写这行即可
                    // 如果你的类里有 setItemId，可以写：item.setItemId(rs.getInt("item_id"));

                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace(); // 🚨 如果这里控制台有报错，一定要去 IDEA 控制台看一下！
        }
        return items;
    }
    /**
     * 根据 Sale ID 删除销售记录及其所有关联的商品明细
     */
    public boolean deleteSaleById(int saleId) {
        // SQL 1: 先删除明细表里的数据（因为外键关联，必须先删这个）
        String deleteItemsSql = "DELETE FROM sale_items WHERE sale_id = ?";
        // SQL 2: 再删除销售主表里的数据
        String deleteSaleSql = "DELETE FROM sales WHERE sale_id = ?";

        Connection conn = null;
        PreparedStatement psItems = null;
        PreparedStatement psSale = null;

        try {
            conn = DBConnection.getConnection();
            // 关闭自动提交，开启事务控制，确保两条 SQL 要么同时成功，要么同时失败
            conn.setAutoCommit(false);

            // 1. 执行删除明细
            psItems = conn.prepareStatement(deleteItemsSql);
            psItems.setInt(1, saleId);
            psItems.executeUpdate();

            // 2. 执行删除主表
            psSale = conn.prepareStatement(deleteSaleSql);
            psSale.setInt(1, saleId);
            int rowsAffected = psSale.executeUpdate();

            // 提交事务
            conn.commit();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            // 发生异常时回滚，不破坏数据完整性
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            // 释放资源闭合连接
            try {
                if (psItems != null) psItems.close();
                if (psSale != null) psSale.close();
                if (conn != null) conn.close();
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}