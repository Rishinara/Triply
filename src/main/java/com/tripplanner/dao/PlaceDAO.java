package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tripplanner.model.Place;
import com.tripplanner.util.DBConnection;

public class PlaceDAO {

    public List<Place> getPlacesByDestination(int destinationId) {

        List<Place> places = new ArrayList<>();

        String sql =
            "SELECT * FROM PLACES " +
            "WHERE DESTINATION_ID = ? " +
            "ORDER BY PLACE_NAME";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, destinationId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Place p = new Place();

                    p.setPlaceId(rs.getInt("PLACE_ID"));
                    p.setDestinationId(
                        rs.getInt("DESTINATION_ID"));
                    p.setPlaceName(
                        rs.getString("PLACE_NAME"));
                    p.setCategory(
                        rs.getString("CATEGORY"));
                    p.setDescription(
                        rs.getString("DESCRIPTION"));
                    p.setEntryFee(
                        rs.getDouble("ENTRY_FEE"));
                    p.setOpenTime(
                        rs.getString("OPEN_TIME"));
                    p.setCloseTime(
                        rs.getString("CLOSE_TIME"));
                    p.setEstimatedDuration(
                        rs.getInt("ESTIMATED_DURATION"));
                    p.setImageUrl(
                        rs.getString("IMAGE_URL"));

                    places.add(p);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return places;
    }
}