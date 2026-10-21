package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tripplanner.model.Restaurant;
import com.tripplanner.util.DBConnection;

public class RestaurantDAO {

    public List<Restaurant> getRestaurantsByDestination(
            int destinationId) {

        List<Restaurant> restaurants =
            new ArrayList<>();

        String sql =
            "SELECT * FROM RESTAURANTS " +
            "WHERE DESTINATION_ID = ? " +
            "ORDER BY RATING DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, destinationId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Restaurant r = new Restaurant();

                    r.setRestaurantId(
                        rs.getInt("RESTAURANT_ID"));

                    r.setDestinationId(
                        rs.getInt("DESTINATION_ID"));

                    r.setName(
                        rs.getString("NAME"));

                    r.setCuisine(
                        rs.getString("CUISINE"));

                    r.setLocation(
                        rs.getString("LOCATION"));

                    r.setAvgCostPerPerson(
                        rs.getDouble(
                            "AVG_COST_PER_PERSON"));

                    r.setRating(
                        rs.getDouble("RATING"));

                    r.setImageUrl(
                        rs.getString("IMAGE_URL"));

                    restaurants.add(r);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return restaurants;
    }
}