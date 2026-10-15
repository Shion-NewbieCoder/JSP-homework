package com.codegym.service;

import com.codegym.model.Product;
import java.util.List;

/** Quy ước nghiệp vụ quản lý sản phẩm (lưu dữ liệu trong bộ nhớ). */
public interface ProductService {
    List<Product> findAll();
    List<Product> searchByName(String keyword);
    Product findById(int id);
    Product create(Product product);
    boolean update(int id, Product product);
    boolean delete(int id);
}
