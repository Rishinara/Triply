package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tripplanner.model.Transport;
import com.tripplanner.util.DBConnection;

public class TransportDAO {

    public List<Transport> getTransportOptions(
            String sourceCity,
            int destinationId) {

        List<Transport> transports =
            new ArrayList<>();

        String sql =
            "SELECT * FROM TRANSPORT " +
            "WHERE UPPER(SOURCE_CITY) = UPPER(?) " +
            "AND DESTINATION_ID = ? " +
            "ORDER BY PRICE_PER_PERSON";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, sourceCity);
            ps.setInt(2, destinationId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Transport t = new Transport();

                    t.setTransportId(
                        rs.getInt("TRANSPORT_ID"));

                    t.setSourceCity(
                        rs.getString("SOURCE_CITY"));

                    t.setDestinationId(
                        rs.getInt("DESTINATION_ID"));

                    t.setTransportType(
                        rs.getString("TRANSPORT_TYPE"));

                    t.setProvider(
                        rs.getString("PROVIDER"));

                    t.setPricePerPerson(
                        rs.getDouble(
                            "PRICE_PER_PERSON"));

                    t.setDepartureTime(
                        rs.getString(
                            "DEPARTURE_TIME"));

                    t.setArrivalTime(
                        rs.getString(
                            "ARRIVAL_TIME"));

                    transports.add(t);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return transports;
    }


    public Transport getTransportById(
            int transportId) {

        String sql =
            "SELECT * FROM TRANSPORT " +
            "WHERE TRANSPORT_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, transportId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    Transport t = new Transport();

                    t.setTransportId(
                        rs.getInt("TRANSPORT_ID"));

                    t.setSourceCity(
                        rs.getString("SOURCE_CITY"));

                    t.setDestinationId(
                        rs.getInt("DESTINATION_ID"));

                    t.setTransportType(
                        rs.getString("TRANSPORT_TYPE"));

                    t.setProvider(
                        rs.getString("PROVIDER"));

                    t.setPricePerPerson(
                        rs.getDouble(
                            "PRICE_PER_PERSON"));

                    t.setDepartureTime(
                        rs.getString(
                            "DEPARTURE_TIME"));

                    t.setArrivalTime(
                        rs.getString(
                            "ARRIVAL_TIME"));

                    return t;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}