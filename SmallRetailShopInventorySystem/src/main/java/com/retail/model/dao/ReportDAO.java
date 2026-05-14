package com.retail.model.dao;

import com.retail.util.DBConnection;
import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

public class ReportDAO {

    /**
     * FR6.1 & 6.2: Sales summary by date range.
     */
    public Map<String, Double> getSalesSummary(String startDate, String endDate) {
        Map<String, Double> reportData = new LinkedHashMap<>();
        String sql = "SELECT DATE(sale_date) as date, SUM(total_amount) as daily_total " +
                "FROM sales WHERE sale_date BETWEEN ? AND ? " +
                "GROUP BY DATE(sale_date) ORDER BY DATE(sale_date) ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");

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
     * FR6.3: Best selling items.
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