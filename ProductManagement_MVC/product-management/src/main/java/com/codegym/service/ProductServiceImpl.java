package com.codegym.service;

import com.codegym.model.Product;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

/** Kho sản phẩm demo thread-safe; dữ liệu mất khi khởi động lại Tomcat. */
public final class ProductServiceImpl implements ProductService {
    private static final ProductServiceImpl INSTANCE = new ProductServiceImpl();
    private final Map<Integer, Product> products = new LinkedHashMap<>();
    private final AtomicInteger nextId = new AtomicInteger(1);

    private ProductServiceImpl() {
        seed("Laptop Dell Inspiron 15", "15990000", "Laptop học tập và văn phòng", "Dell");
        seed("Chuột Logitech M331", "329000", "Chuột không dây yên tĩnh", "Logitech");
        seed("Bàn phím Keychron K2", "1890000", "Bàn phím cơ kết nối Bluetooth", "Keychron");
        seed("Màn hình LG 24 inch", "2990000", "Màn hình IPS Full HD", "LG");
        seed("Tai nghe Sony WH-CH520", "990000", "Tai nghe Bluetooth thời lượng pin tốt", "Sony");
        seed("Ổ cứng SSD Samsung 1TB", "1790000", "Ổ cứng NVMe PCIe", "Samsung");
    }

    public static ProductServiceImpl getInstance() { return INSTANCE; }

    private void seed(String name, String price, String description, String manufacturer) {
        int id = nextId.getAndIncrement();
        products.put(id, new Product(id, name, new BigDecimal(price), description, manufacturer));
    }

    private Product copy(Product p) {
        return p == null ? null : new Product(p.getId(), p.getName(),
                p.getPrice(), p.getDescription(), p.getManufacturer());
    }

    @Override
    public synchronized List<Product> findAll() {
        List<Product> result = new ArrayList<>();
        for (Product product : products.values()) {
            result.add(copy(product));
        }
        return result;
    }

    @Override
    public synchronized List<Product> searchByName(String keyword) {
        String query = keyword == null ? "" : keyword.trim().toLowerCase(Locale.ROOT);
        List<Product> result = new ArrayList<>();
        for (Product product : products.values()) {
            if (product.getName().toLowerCase(Locale.ROOT).contains(query)) {
                result.add(copy(product));
            }
        }
        return result;
    }

    @Override
    public synchronized Product findById(int id) {
        return copy(products.get(id));
    }

    @Override
    public synchronized Product create(Product product) {
        int id = nextId.getAndIncrement();
        Product saved = new Product(id, product.getName(), product.getPrice(),
                product.getDescription(), product.getManufacturer());
        products.put(id, saved);
        return copy(saved);
    }

    @Override
    public synchronized boolean update(int id, Product product) {
        if (!products.containsKey(id)) {
            return false;
        }
        products.put(id, new Product(id, product.getName(), product.getPrice(),
                product.getDescription(), product.getManufacturer()));
        return true;
    }

    @Override
    public synchronized boolean delete(int id) {
        return products.remove(id) != null;
    }
}
