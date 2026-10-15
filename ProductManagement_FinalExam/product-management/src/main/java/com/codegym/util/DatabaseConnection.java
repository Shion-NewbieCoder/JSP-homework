package com.codegym.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/** Loads local DB settings from environment variables, not hard-coded passwords. */
public final class DatabaseConnection {
    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/product_management?useUnicode=true"
            + "&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh";

    private DatabaseConnection() { }

    public static Connection getConnection() throws SQLException {
        String url = getSetting("PRODUCT_DB_URL", DEFAULT_URL);
        String username = getSetting("PRODUCT_DB_USER", "root");
        String password = System.getenv("PRODUCT_DB_PASSWORD");
        return DriverManager.getConnection(url, username, password == null ? "" : password);
    }

    private static String getSetting(String key, String fallback) {
        String value = System.getenv(key);
        return value == null || value.isBlank() ? fallback : value;
    }
}
