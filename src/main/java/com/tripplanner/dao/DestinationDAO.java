package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tripplanner.model.Destination;
import com.tripplanner.util.DBConnection;

public class DestinationDAO {

    public List<Destination> getRecommendations(
            String category,
            String month,
            int duration,
            double budgetPerPerson) {

        List<Destination> destinations =
                new ArrayList<>();

        String sql =
            "SELECT * FROM DESTINATIONS " +
            "WHERE MIN_BUDGET <= ? " +
            "AND ? BETWEEN MIN_DAYS AND MAX_DAYS " +
            "AND UPPER(BEST_SEASON) LIKE ? " +
            "ORDER BY " +
            "CASE WHEN UPPER(CATEGORY) = UPPER(?) " +
            "THEN 0 ELSE 1 END, MIN_BUDGET";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                     con.prepareStatement(sql)) {

            ps.setDouble(1, budgetPerPerson);
            ps.setInt(2, duration);

            ps.setString(
                3,
                "%" + month.toUpperCase() + "%"
            );

            ps.setString(4, category);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Destination d =
                    createDestination(rs);

                destinations.add(d);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return destinations;
    }


    public Destination getDestinationById(
            int destinationId) {

        String sql =
            "SELECT * FROM DESTINATIONS " +
            "WHERE DESTINATION_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps =
                     con.prepareStatement(sql)) {

            ps.setInt(1, destinationId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return createDestination(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }


    private Destination createDestination(
            ResultSet rs) throws Exception {

        Destination d = new Destination();

        d.setDestinationId(
            rs.getInt("DESTINATION_ID"));

        d.setName(
            rs.getString("NAME"));

        d.setState(
            rs.getString("STATE"));

        d.setCategory(
            rs.getString("CATEGORY"));

        d.setDescription(
            rs.getString("DESCRIPTION"));

        d.setMinBudget(
            rs.getDouble("MIN_BUDGET"));

        d.setBestSeason(
            rs.getString("BEST_SEASON"));

        d.setMinDays(
            rs.getInt("MIN_DAYS"));

        d.setMaxDays(
            rs.getInt("MAX_DAYS"));

        d.setImageUrl(
            rs.getString("IMAGE_URL"));

        return d;
    }
}