package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tripplanner.model.Trip;
import com.tripplanner.util.DBConnection;

public class TripDAO {

    // =========================================================
    // CREATE TRIP
    // =========================================================
    public boolean createTrip(Trip trip) {

        String sql =
            "INSERT INTO TRIPS " +
            "(TRIP_ID, TRIP_NAME, CREATED_BY, START_CITY, " +
            "START_DATE, END_DATE, TOTAL_BUDGET, STATUS, " +
            "INVITE_CODE) " +
            "VALUES (TRIPS_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, trip.getTripName());
            ps.setInt(2, trip.getCreatedBy());
            ps.setString(3, trip.getStartCity());
            ps.setDate(4, trip.getStartDate());
            ps.setDate(5, trip.getEndDate());
            ps.setDouble(6, trip.getTotalBudget());
            ps.setString(7, trip.getStatus());
            ps.setString(8, trip.getInviteCode());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    // =========================================================
    // GET ALL TRIPS FOR USER
    // Includes:
    // 1. Trips created by the user
    // 2. Trips joined by the user
    // =========================================================
    public List<Trip> getTripsByUser(int userId) {

        List<Trip> trips = new ArrayList<>();

        String sql =
            "SELECT DISTINCT T.* " +
            "FROM TRIPS T " +
            "LEFT JOIN TRIP_MEMBERS TM " +
            "ON T.TRIP_ID = TM.TRIP_ID " +
            "WHERE T.CREATED_BY = ? " +
            "OR TM.USER_ID = ? " +
            "ORDER BY T.CREATED_AT DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Trip trip = mapTrip(rs);

                    trips.add(trip);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return trips;
    }


    // =========================================================
    // GET TRIP BY ID
    // OWNER / ORGANIZER ONLY
    // Used for editing and organizer-only operations
    // =========================================================
    public Trip getTripById(int tripId, int userId) {

        String sql =
            "SELECT * FROM TRIPS " +
            "WHERE TRIP_ID = ? " +
            "AND CREATED_BY = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return mapTrip(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }


    // =========================================================
    // GET ACCESSIBLE TRIP
    // Creator OR joined member can access
    // =========================================================
    public Trip getAccessibleTripById(int tripId, int userId) {

        String sql =
            "SELECT DISTINCT T.* " +
            "FROM TRIPS T " +
            "LEFT JOIN TRIP_MEMBERS TM " +
            "ON T.TRIP_ID = TM.TRIP_ID " +
            "WHERE T.TRIP_ID = ? " +
            "AND (T.CREATED_BY = ? OR TM.USER_ID = ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return mapTrip(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }


    // =========================================================
    // GET TRIP USING INVITE CODE
    // Used when another user joins a trip
    // =========================================================
    public Trip getTripByInviteCode(String inviteCode) {

        String sql =
            "SELECT * FROM TRIPS " +
            "WHERE UPPER(INVITE_CODE) = UPPER(?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, inviteCode);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return mapTrip(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }


    // =========================================================
    // UPDATE TRIP
    // Only creator can update
    // =========================================================
    public boolean updateTrip(Trip trip) {

        String sql =
            "UPDATE TRIPS SET " +
            "TRIP_NAME = ?, " +
            "START_CITY = ?, " +
            "START_DATE = ?, " +
            "END_DATE = ?, " +
            "TOTAL_BUDGET = ?, " +
            "STATUS = ? " +
            "WHERE TRIP_ID = ? " +
            "AND CREATED_BY = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, trip.getTripName());
            ps.setString(2, trip.getStartCity());
            ps.setDate(3, trip.getStartDate());
            ps.setDate(4, trip.getEndDate());
            ps.setDouble(5, trip.getTotalBudget());
            ps.setString(6, trip.getStatus());
            ps.setInt(7, trip.getTripId());
            ps.setInt(8, trip.getCreatedBy());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    // =========================================================
    // DELETE TRIP
    // Deletes current child records first so foreign keys
    // do not block deletion.
    // =========================================================
    public boolean deleteTrip(int tripId, int userId) {

        String checkSql =
            "SELECT TRIP_ID FROM TRIPS " +
            "WHERE TRIP_ID = ? AND CREATED_BY = ?";

        String deleteVotes =
            "DELETE FROM VOTES WHERE TRIP_ID = ?";

        String deletePreferences =
            "DELETE FROM TRIP_PREFERENCES WHERE TRIP_ID = ?";

        String deleteMembers =
            "DELETE FROM TRIP_MEMBERS WHERE TRIP_ID = ?";

        String deleteTrip =
            "DELETE FROM TRIPS " +
            "WHERE TRIP_ID = ? AND CREATED_BY = ?";
        
        String deleteItinerary =
        	    "DELETE FROM ITINERARY WHERE TRIP_ID = ?";
        
        String deleteExpenses =
        	    "DELETE FROM EXPENSES WHERE TRIP_ID = ?";

        Connection con = null;

        try {

            con = DBConnection.getConnection();

            con.setAutoCommit(false);

            // Verify that this user owns the trip
            try (PreparedStatement ps =
                    con.prepareStatement(checkSql)) {

                ps.setInt(1, tripId);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        con.rollback();
                        return false;
                    }
                }
            }
            
            try (PreparedStatement ps =
                    con.prepareStatement(deleteItinerary)) {

                ps.setInt(1, tripId);
                ps.executeUpdate();
            }
            
            try (PreparedStatement ps =
                    con.prepareStatement(deleteExpenses)) {

                ps.setInt(1, tripId);
                ps.executeUpdate();
            }


            // Delete votes
            try (PreparedStatement ps =
                    con.prepareStatement(deleteVotes)) {

                ps.setInt(1, tripId);
                ps.executeUpdate();
            }


            // Delete preferences
            try (PreparedStatement ps =
                    con.prepareStatement(deletePreferences)) {

                ps.setInt(1, tripId);
                ps.executeUpdate();
            }


            // Delete members
            try (PreparedStatement ps =
                    con.prepareStatement(deleteMembers)) {

                ps.setInt(1, tripId);
                ps.executeUpdate();
            }


            // Delete trip
            int rows;

            try (PreparedStatement ps =
                    con.prepareStatement(deleteTrip)) {

                ps.setInt(1, tripId);
                ps.setInt(2, userId);

                rows = ps.executeUpdate();
            }


            if (rows > 0) {

                con.commit();
                return true;

            } else {

                con.rollback();
                return false;
            }

        } catch (Exception e) {

            e.printStackTrace();

            if (con != null) {

                try {
                    con.rollback();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

        } finally {

            if (con != null) {

                try {

                    con.setAutoCommit(true);
                    con.close();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        return false;
    }


    // =========================================================
    // CHECK WHETHER USER IS ALREADY A MEMBER
    // =========================================================
    public boolean isTripMember(int tripId, int userId) {

        String sql =
            "SELECT MEMBER_ID " +
            "FROM TRIP_MEMBERS " +
            "WHERE TRIP_ID = ? " +
            "AND USER_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    // =========================================================
    // JOIN TRIP
    // =========================================================
    public boolean joinTrip(int tripId, int userId) {

        String sql =
            "INSERT INTO TRIP_MEMBERS " +
            "(MEMBER_ID, TRIP_ID, USER_ID, ROLE) " +
            "VALUES " +
            "(TRIP_MEMBERS_SEQ.NEXTVAL, ?, ?, 'MEMBER')";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    // =========================================================
    // FINALIZE DESTINATION
    // Only trip creator / organizer can finalize
    // =========================================================
    public boolean finalizeDestination(
            int tripId,
            int userId,
            int destinationId) {

        String sql =
            "UPDATE TRIPS " +
            "SET DESTINATION_ID = ? " +
            "WHERE TRIP_ID = ? " +
            "AND CREATED_BY = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, destinationId);
            ps.setInt(2, tripId);
            ps.setInt(3, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    // =========================================================
    // COMMON RESULTSET -> TRIP MAPPING
    // Avoids repeating the same code everywhere
    // =========================================================
    private Trip mapTrip(ResultSet rs) throws Exception {

        Trip trip = new Trip();

        trip.setTripId(
            rs.getInt("TRIP_ID")
        );

        trip.setTripName(
            rs.getString("TRIP_NAME")
        );

        trip.setCreatedBy(
            rs.getInt("CREATED_BY")
        );

        trip.setStartCity(
            rs.getString("START_CITY")
        );

        trip.setStartDate(
            rs.getDate("START_DATE")
        );

        trip.setEndDate(
            rs.getDate("END_DATE")
        );

        trip.setTotalBudget(
            rs.getDouble("TOTAL_BUDGET")
        );

        trip.setStatus(
            rs.getString("STATUS")
        );

        trip.setInviteCode(
            rs.getString("INVITE_CODE")
        );

        // Newly added column
        trip.setDestinationId(
            rs.getInt("DESTINATION_ID")
        );
        
        trip.setHotelId(
        	    rs.getInt("HOTEL_ID")
        	);

        	trip.setTransportId(
        	    rs.getInt("TRANSPORT_ID")
        	);

        	trip.setRooms(
        	    rs.getInt("ROOMS")
        	);
        	

        return trip;
    }
    
    public boolean selectHotel(
            int tripId,
            int userId,
            int hotelId,
            int rooms) {

        String sql =
            "UPDATE TRIPS " +
            "SET HOTEL_ID = ?, ROOMS = ? " +
            "WHERE TRIP_ID = ? " +
            "AND CREATED_BY = ? " +
            "AND DESTINATION_ID = " +
            "(SELECT DESTINATION_ID FROM HOTELS " +
            "WHERE HOTEL_ID = ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, hotelId);
            ps.setInt(2, rooms);
            ps.setInt(3, tripId);
            ps.setInt(4, userId);
            ps.setInt(5, hotelId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public boolean selectTransport(
            int tripId,
            int userId,
            int transportId) {

        String sql =
            "UPDATE TRIPS " +
            "SET TRANSPORT_ID = ? " +
            "WHERE TRIP_ID = ? " +
            "AND CREATED_BY = ? " +
            "AND DESTINATION_ID = " +
            "(SELECT DESTINATION_ID FROM TRANSPORT " +
            "WHERE TRANSPORT_ID = ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, transportId);
            ps.setInt(2, tripId);
            ps.setInt(3, userId);
            ps.setInt(4, transportId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    
    public String getAutomaticStatus(Trip trip) {

        java.time.LocalDate today =
            java.time.LocalDate.now();

        java.time.LocalDate start =
            trip.getStartDate().toLocalDate();

        java.time.LocalDate end =
            trip.getEndDate().toLocalDate();

        if (today.isBefore(start)) {
            return "UPCOMING";
        }

        if (today.isAfter(end)) {
            return "COMPLETED";
        }

        return "ONGOING";
    }
}