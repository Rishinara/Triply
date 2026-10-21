package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tripplanner.model.Expense;
import com.tripplanner.util.DBConnection;

public class ExpenseDAO {

    public boolean addExpense(Expense expense) {

        String sql =
            "INSERT INTO EXPENSES " +
            "(EXPENSE_ID, TRIP_ID, PAID_BY, CATEGORY, " +
            "DESCRIPTION, AMOUNT, EXPENSE_DATE) " +
            "VALUES (EXPENSES_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, expense.getTripId());
            ps.setInt(2, expense.getPaidBy());
            ps.setString(3, expense.getCategory());
            ps.setString(4, expense.getDescription());
            ps.setDouble(5, expense.getAmount());
            ps.setDate(6, expense.getExpenseDate());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public List<Expense> getExpensesByTrip(int tripId) {

        List<Expense> expenses = new ArrayList<>();

        String sql =
            "SELECT E.*, U.NAME AS PAID_BY_NAME " +
            "FROM EXPENSES E " +
            "JOIN USERS U ON E.PAID_BY = U.USER_ID " +
            "WHERE E.TRIP_ID = ? " +
            "ORDER BY E.EXPENSE_DATE DESC, E.EXPENSE_ID DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Expense e = new Expense();

                    e.setExpenseId(
                        rs.getInt("EXPENSE_ID"));

                    e.setTripId(
                        rs.getInt("TRIP_ID"));

                    e.setPaidBy(
                        rs.getInt("PAID_BY"));

                    e.setPaidByName(
                        rs.getString("PAID_BY_NAME"));

                    e.setCategory(
                        rs.getString("CATEGORY"));

                    e.setDescription(
                        rs.getString("DESCRIPTION"));

                    e.setAmount(
                        rs.getDouble("AMOUNT"));

                    e.setExpenseDate(
                        rs.getDate("EXPENSE_DATE"));

                    expenses.add(e);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return expenses;
    }


    public double getTotalSpent(int tripId) {

        String sql =
            "SELECT NVL(SUM(AMOUNT), 0) AS TOTAL " +
            "FROM EXPENSES WHERE TRIP_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getDouble("TOTAL");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


    public Map<Integer, Double> getPaidAmounts(int tripId) {

        Map<Integer, Double> paidAmounts =
            new HashMap<>();

        String sql =
            "SELECT PAID_BY, SUM(AMOUNT) AS TOTAL " +
            "FROM EXPENSES " +
            "WHERE TRIP_ID = ? " +
            "GROUP BY PAID_BY";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    paidAmounts.put(
                        rs.getInt("PAID_BY"),
                        rs.getDouble("TOTAL")
                    );
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return paidAmounts;
    }


    public boolean deleteExpense(
            int expenseId,
            int tripId) {

        String sql =
            "DELETE FROM EXPENSES " +
            "WHERE EXPENSE_ID = ? AND TRIP_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, expenseId);
            ps.setInt(2, tripId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}