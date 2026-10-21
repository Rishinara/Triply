package com.tripplanner.util;

import java.sql.Connection;

public class TestConnection {

    public static void main(String[] args) {

        try (Connection con = DBConnection.getConnection()) {

            if (con != null) {
                System.out.println("DATABASE CONNECTED SUCCESSFULLY!");
            } else {
                System.out.println("DATABASE CONNECTION FAILED!");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}