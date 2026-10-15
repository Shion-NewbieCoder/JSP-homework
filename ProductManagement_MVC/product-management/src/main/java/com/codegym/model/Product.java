package com.codegym.model;

import java.math.BigDecimal;

/** JavaBean biểu diễn một sản phẩm. */
public class Product {
    private int id;
    private String name;
    private BigDecimal price;
    private String description;
    private String manufacturer;

    public Product() { }

    public Product(int id, String name, BigDecimal price,
                   String description, String manufacturer) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.description = description;
        this.manufacturer = manufacturer;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getManufacturer() { return manufacturer; }
    public void setManufacturer(String manufacturer) { this.manufacturer = manufacturer; }
}
