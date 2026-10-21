package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.tripplanner.util.DBConnection;

public class VoteDAO {

    public boolean vote(
            int tripId,
            int userId,
            int destinationId) {

        String checkSql =
            "SELECT VOTE_ID FROM VOTES " +
            "WHERE TRIP_ID = ? AND USER_ID = ?";

        String insertSql =
            "INSERT INTO VOTES " +
            "(VOTE_ID, TRIP_ID, USER_ID, DESTINATION_ID) " +
            "VALUES (VOTES_SEQ.NEXTVAL, ?, ?, ?)";

        String updateSql =
            "UPDATE VOTES SET DESTINATION_ID = ?, " +
            "VOTED_AT = SYSDATE " +
            "WHERE TRIP_ID = ? AND USER_ID = ?";


        try (Connection con =
                DBConnection.getConnection()) {

            boolean alreadyVoted = false;

            try (PreparedStatement ps =
                    con.prepareStatement(checkSql)) {

                ps.setInt(1, tripId);
                ps.setInt(2, userId);

                ResultSet rs = ps.executeQuery();

                alreadyVoted = rs.next();
            }


            if (alreadyVoted) {

                try (PreparedStatement ps =
                        con.prepareStatement(updateSql)) {

                    ps.setInt(1, destinationId);
                    ps.setInt(2, tripId);
                    ps.setInt(3, userId);

                    return ps.executeUpdate() > 0;
                }

            } else {

                try (PreparedStatement ps =
                        con.prepareStatement(insertSql)) {

                    ps.setInt(1, tripId);
                    ps.setInt(2, userId);
                    ps.setInt(3, destinationId);

                    return ps.executeUpdate() > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public int getVoteCount(
            int tripId,
            int destinationId) {

        String sql =
            "SELECT COUNT(*) TOTAL " +
            "FROM VOTES " +
            "WHERE TRIP_ID = ? " +
            "AND DESTINATION_ID = ?";

        try (Connection con =
                DBConnection.getConnection();
             PreparedStatement ps =
                con.prepareStatement(sql)) {

            ps.setInt(1, tripId);
            ps.setInt(2, destinationId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("TOTAL");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


    public int getUserVote(
            int tripId,
            int userId) {

        String sql =
            "SELECT DESTINATION_ID FROM VOTES " +
            "WHERE TRIP_ID = ? AND USER_ID = ?";

        try (Connection con =
                DBConnection.getConnection();
             PreparedStatement ps =
                con.prepareStatement(sql)) {

            ps.setInt(1, tripId);
            ps.setInt(2, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("DESTINATION_ID");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}