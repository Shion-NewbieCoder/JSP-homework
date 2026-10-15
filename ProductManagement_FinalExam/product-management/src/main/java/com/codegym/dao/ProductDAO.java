package com.codegym.dao;

import com.codegym.model.Product;
import com.codegym.util.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/** All database operations are parameterized to prevent SQL injection. */
public class ProductDAO {
    private static final String SELECT_ALL =
            "SELECT id, name, price, quantity FROM products ORDER BY id DESC";
    private static final String SELECT_ONE =
            "SELECT id, name, price, quantity FROM products WHERE id = ?";
    private static final String INSERT =
            "INSERT INTO products (name, price, quantity) VALUES (?, ?, ?)";
    private static final String UPDATE =
            "UPDATE products SET name = ?, price = ?, quantity = ? WHERE id = ?";
    private static final String DELETE = "DELETE FROM products WHERE id = ?";

    public List<Product> findAll() throws SQLException {
        List<Product> products = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(SELECT_ALL);
             ResultSet results = statement.executeQuery()) {
            while (results.next()) {
                products.add(mapRow(results));
            }
        }
        return products;
    }

    public Product findById(int id) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(SELECT_ONE)) {
            statement.setInt(1, id);
            try (ResultSet results = statement.executeQuery()) {
                return results.next() ? mapRow(results) : null;
            }
        }
    }

    public int insert(Product product) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     INSERT, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, product.getName());
            statement.setBigDecimal(2, product.getPrice());
            statement.setInt(3, product.getQuantity());
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("MySQL did not return a product ID");
                }
                return keys.getInt(1);
            }
        }
    }

    public boolean update(Product product) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(UPDATE)) {
            statement.setString(1, product.getName());
            statement.setBigDecimal(2, product.getPrice());
            statement.setInt(3, product.getQuantity());
            statement.setInt(4, product.getId());
            return statement.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(DELETE)) {
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        }
    }

    private Product mapRow(ResultSet row) throws SQLException {
        return new Product(
                row.getInt("id"),
                row.getString("name"),
                row.getBigDecimal("price"),
                row.getInt("quantity"));
    }
}
