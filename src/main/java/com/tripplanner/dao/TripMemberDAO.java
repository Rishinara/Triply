package com.tripplanner.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.tripplanner.model.TripMember;
import com.tripplanner.util.DBConnection;

public class TripMemberDAO {

    public List<TripMember> getMembers(int tripId) {

        List<TripMember> members = new ArrayList<>();

        String sql =
            "SELECT U.USER_ID, U.NAME, U.EMAIL, TM.ROLE " +
            "FROM TRIP_MEMBERS TM " +
            "JOIN USERS U ON TM.USER_ID = U.USER_ID " +
            "WHERE TM.TRIP_ID = ? " +
            "ORDER BY CASE WHEN TM.ROLE = 'ORGANIZER' THEN 0 ELSE 1 END, U.NAME";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                TripMember member = new TripMember();

                member.setUserId(rs.getInt("USER_ID"));
                member.setName(rs.getString("NAME"));
                member.setEmail(rs.getString("EMAIL"));
                member.setRole(rs.getString("ROLE"));

                members.add(member);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return members;
    }


    public int getMemberCount(int tripId) {

        String sql =
            "SELECT COUNT(*) AS TOTAL " +
            "FROM TRIP_MEMBERS " +
            "WHERE TRIP_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("TOTAL");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }


    public boolean isMember(int tripId, int userId) {

        String sql =
            "SELECT MEMBER_ID FROM TRIP_MEMBERS " +
            "WHERE TRIP_ID = ? AND USER_ID = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, tripId);
            ps.setInt(2, userId);

            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    
    public boolean addOrganizerByInviteCode(
            String inviteCode,
            int userId) {

        String sql =
            "INSERT INTO TRIP_MEMBERS " +
            "(MEMBER_ID, TRIP_ID, USER_ID, ROLE) " +
            "SELECT TRIP_MEMBERS_SEQ.NEXTVAL, " +
            "TRIP_ID, ?, 'ORGANIZER' " +
            "FROM TRIPS WHERE INVITE_CODE = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, inviteCode);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    } 
}