package com.retail.model.dao;

import com.retail.util.DBConnection;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {

    /**
     * 1. 获取指定日期范围内的所有交易及商品详细流水明细 (修复时区越界版)
     */
    public List<Map<String, Object>> getDetailedSalesRows(String startDate, String endDate) {
        List<Map<String, Object>> list = new ArrayList<>();

        // 防空判定：如果没传，默认只看今天
        if (startDate == null || startDate.trim().isEmpty() || endDate == null || endDate.trim().isEmpty()) {
            endDate = LocalDate.now().toString();
            startDate = LocalDate.now().toString();
        }

        // 💡 使用 DATE(s.sale_date) 强行按天对比，无视时分秒时区差
        String sql = "SELECT s.sale_id, p.product_name, si.quantity, si.subtotal, " +
                "s.payment_method, s.payment_status, s.sale_date " +
                "FROM sale_items si " +
                "JOIN sales s ON si.sale_id = s.sale_id " +
                "JOIN products p ON si.product_id = p.product_id " +
                "WHERE DATE(s.sale_date) >= ? AND DATE(s.sale_date) <= ? " +
                "ORDER BY s.sale_id DESC, p.product_name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, startDate);
            ps.setString(2, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("saleId", rs.getInt("sale_id"));
                    row.put("productName", rs.getString("product_name"));
                    row.put("quantity", rs.getInt("quantity"));
                    row.put("subtotal", rs.getDouble("subtotal"));
                    row.put("paymentMethod", rs.getString("payment_method"));
                    row.put("paymentStatus", rs.getString("payment_status"));
                    row.put("saleDate", rs.getTimestamp("sale_date"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 2. 按日期统计每天的总额（大看板主表使用）
     */
    public Map<String, Double> getSalesSummary(String startDate, String endDate) {
        Map<String, Double> reportData = new LinkedHashMap<>();

        if (startDate == null || startDate.trim().isEmpty() || endDate == null || endDate.trim().isEmpty()) {
            endDate = LocalDate.now().toString();
            startDate = LocalDate.now().minusDays(30).toString(); // 默认查30天
        }

        String sql = "SELECT DATE(sale_date) as date, SUM(total_amount) as daily_total " +
                "FROM sales WHERE DATE(sale_date) >= ? AND DATE(sale_date) <= ? " +
                "GROUP BY DATE(sale_date) ORDER BY DATE(sale_date) ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reportData.put(rs.getString("date"), rs.getDouble("daily_total"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reportData;
    }

    /**
     * 3. Top 10 畅销排行
     */
    public Map<String, Integer> getProductPerformance() {
        Map<String, Integer> performance = new LinkedHashMap<>();
        String sql = "SELECT p.product_name, SUM(si.quantity) as total_sold " +
                "FROM sale_items si " +
                "JOIN products p ON si.product_id = p.product_id " +
                "GROUP BY p.product_id ORDER BY total_sold DESC LIMIT 10";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                performance.put(rs.getString("product_name"), rs.getInt("total_sold"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return performance;
    }

    public double getTodaySales() {
        String sql = "SELECT SUM(total_amount) FROM sales WHERE DATE(sale_date) = CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0.0;
    }

    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int getLowStockCount() {
        String sql = "SELECT COUNT(*) FROM products WHERE stock_quantity <= low_stock_threshold";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int getTodayTransactions() {
        String sql = "SELECT COUNT(*) FROM sales WHERE DATE(sale_date) = CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
}