package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;

import java.util.ArrayList;
import java.util.List;

import com.tripplanner.model.Itinerary;
import com.tripplanner.util.DBConnection;

public class ItineraryDAO {

    public boolean addActivity(Itinerary item) {

        String sql =
            "INSERT INTO ITINERARY " +
            "(ITINERARY_ID, TRIP_ID, PLACE_ID, " +
            "ACTIVITY_NAME, ACTIVITY_DATE, START_TIME, " +
            "END_TIME, ESTIMATED_COST, NOTES) " +
            "VALUES (ITINERARY_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, item.getTripId());

            if (item.getPlaceId() > 0) {
                ps.setInt(2, item.getPlaceId());
            } else {
                ps.setNull(2, java.sql.Types.NUMERIC);
            }

            ps.setString(3, item.getActivityName());
            ps.setDate(4, item.getActivityDate());
            ps.setString(5, item.getStartTime());
            ps.setString(6, item.getEndTime());
            ps.setDouble(7, item.getEstimatedCost());
            ps.setString(8, item.getNotes());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public List<Itinerary> getActivitiesByTrip(int tripId) {

        List<Itinerary> activities = new ArrayList<>();

        String sql =
            "SELECT * FROM ITINERARY " +
            "WHERE TRIP_ID = ? " +
            "ORDER BY ACTIVITY_DATE, START_TIME";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    Itinerary item = new Itinerary();

                    item.setItineraryId(
                        rs.getInt("ITINERARY_ID"));

                    item.setTripId(
                        rs.getInt("TRIP_ID"));

                    item.setPlaceId(
                        rs.getInt("PLACE_ID"));

                    item.setActivityName(
                        rs.getString("ACTIVITY_NAME"));

                    item.setActivityDate(
                        rs.getDate("ACTIVITY_DATE"));

                    item.setStartTime(
                        rs.getString("START_TIME"));

                    item.setEndTime(
                        rs.getString("END_TIME"));

                    item.setEstimatedCost(
                        rs.getDouble("ESTIMATED_COST"));

                    item.setNotes(
                        rs.getString("NOTES"));

                    activities.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return activities;
    }


    // Checks whether another activity overlaps
    // the requested time on the same day.
    public boolean hasConflict(
            int tripId,
            Date activityDate,
            String startTime,
            String endTime) {

        String sql =
            "SELECT COUNT(*) AS TOTAL " +
            "FROM ITINERARY " +
            "WHERE TRIP_ID = ? " +
            "AND ACTIVITY_DATE = ? " +
            "AND START_TIME < ? " +
            "AND END_TIME > ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);
            ps.setDate(2, activityDate);
            ps.setString(3, endTime);
            ps.setString(4, startTime);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getInt("TOTAL") > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public boolean deleteActivity(
            int itineraryId,
            int tripId) {

        String sql =
            "DELETE FROM ITINERARY " +
            "WHERE ITINERARY_ID = ? " +
            "AND TRIP_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, itineraryId);
            ps.setInt(2, tripId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}