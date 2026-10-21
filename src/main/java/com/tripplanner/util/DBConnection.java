package com.tripplanner.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class DBConnection {

    private static String url;
    private static String username;
    private static String password;

    static {
        try {
            Properties properties = new Properties();

            InputStream input = DBConnection.class
                    .getClassLoader()
                    .getResourceAsStream("db.properties");

            if (input == null) {
                throw new RuntimeException(
                        "db.properties file not found"
                );
            }

            properties.load(input);

            url = properties.getProperty("db.url");
            username = properties.getProperty("db.username");
            password = properties.getProperty("db.password");

            Class.forName("oracle.jdbc.driver.OracleDriver");

            input.close();

        } catch (Exception e) {
            throw new RuntimeException(
                    "Database configuration error", e
            );
        }
    }

    public static Connection getConnection() {

        try {
            return DriverManager.getConnection(
                    url,
                    username,
                    password
            );

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}