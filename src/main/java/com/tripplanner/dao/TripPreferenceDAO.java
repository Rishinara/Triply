package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.tripplanner.model.TripPreference;
import com.tripplanner.util.DBConnection;

public class TripPreferenceDAO {

    public TripPreference getPreference(int tripId) {

        String sql =
            "SELECT * FROM TRIP_PREFERENCES " +
            "WHERE TRIP_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                TripPreference preference =
                    new TripPreference();

                preference.setPreferenceId(
                    rs.getInt("PREFERENCE_ID"));

                preference.setTripId(
                    rs.getInt("TRIP_ID"));

                preference.setCategory(
                    rs.getString("CATEGORY"));

                preference.setTravelMonth(
                    rs.getString("TRAVEL_MONTH"));

                preference.setDuration(
                    rs.getInt("DURATION"));

                return preference;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }


    public boolean savePreference(TripPreference preference) {

        TripPreference existing =
            getPreference(preference.getTripId());

        if (existing == null) {
            return insertPreference(preference);
        } else {
            return updatePreference(preference);
        }
    }


    private boolean insertPreference(
            TripPreference preference) {

        String sql =
            "INSERT INTO TRIP_PREFERENCES " +
            "(PREFERENCE_ID, TRIP_ID, CATEGORY, TRAVEL_MONTH, DURATION) " +
            "VALUES (TRIP_PREF_SEQ.NEXTVAL, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, preference.getTripId());
            ps.setString(2, preference.getCategory());
            ps.setString(3, preference.getTravelMonth());
            ps.setInt(4, preference.getDuration());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    private boolean updatePreference(
            TripPreference preference) {

        String sql =
            "UPDATE TRIP_PREFERENCES SET " +
            "CATEGORY = ?, TRAVEL_MONTH = ?, DURATION = ? " +
            "WHERE TRIP_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, preference.getCategory());
            ps.setString(2, preference.getTravelMonth());
            ps.setInt(3, preference.getDuration());
            ps.setInt(4, preference.getTripId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}