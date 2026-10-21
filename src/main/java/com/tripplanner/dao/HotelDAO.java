package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tripplanner.model.Hotel;
import com.tripplanner.util.DBConnection;

public class HotelDAO {

    public List<Hotel> getHotelsByDestination(
            int destinationId) {

        List<Hotel> hotels = new ArrayList<>();

        String sql =
            "SELECT * FROM HOTELS " +
            "WHERE DESTINATION_ID = ? " +
            "ORDER BY PRICE_PER_NIGHT";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, destinationId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Hotel h = new Hotel();

                    h.setHotelId(rs.getInt("HOTEL_ID"));
                    h.setDestinationId(
                        rs.getInt("DESTINATION_ID"));
                    h.setHotelName(
                        rs.getString("HOTEL_NAME"));
                    h.setLocation(
                        rs.getString("LOCATION"));
                    h.setPricePerNight(
                        rs.getDouble("PRICE_PER_NIGHT"));
                    h.setRating(
                        rs.getDouble("RATING"));
                    h.setImageUrl(
                        rs.getString("IMAGE_URL"));

                    hotels.add(h);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return hotels;
    }


    public Hotel getHotelById(int hotelId) {

        String sql =
            "SELECT * FROM HOTELS WHERE HOTEL_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, hotelId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    Hotel h = new Hotel();

                    h.setHotelId(rs.getInt("HOTEL_ID"));
                    h.setDestinationId(
                        rs.getInt("DESTINATION_ID"));
                    h.setHotelName(
                        rs.getString("HOTEL_NAME"));
                    h.setLocation(
                        rs.getString("LOCATION"));
                    h.setPricePerNight(
                        rs.getDouble("PRICE_PER_NIGHT"));
                    h.setRating(
                        rs.getDouble("RATING"));
                    h.setImageUrl(
                        rs.getString("IMAGE_URL"));

                    return h;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}