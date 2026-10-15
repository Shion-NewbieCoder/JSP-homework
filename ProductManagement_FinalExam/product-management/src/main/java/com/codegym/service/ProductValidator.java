package com.codegym.service;

import com.codegym.model.Product;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/** Validates all form input on the server, independently of HTML constraints. */
public final class ProductValidator {
    private static final BigDecimal MAX_PRICE = new BigDecimal("9999999999.99");

    private ProductValidator() { }

    public static ValidationResult validate(int id, String rawName,
                                            String rawPrice, String rawQuantity) {
        List<String> errors = new ArrayList<>();
        String name = rawName == null ? "" : rawName.trim();
        String priceText = rawPrice == null ? "" : rawPrice.trim();
        String quantityText = rawQuantity == null ? "" : rawQuantity.trim();

        if (name.isEmpty()) {
            errors.add("Vui lòng nhập tên sản phẩm.");
        } else if (name.length() > 255) {
            errors.add("Tên sản phẩm không được vượt quá 255 ký tự.");
        }

        BigDecimal price = null;
        try {
            price = new BigDecimal(priceText);
            if (price.compareTo(BigDecimal.ZERO) < 0
                    || price.compareTo(MAX_PRICE) > 0
                    || price.scale() > 2) {
                errors.add("Giá phải từ 0 đến 9.999.999.999,99 và có tối đa 2 chữ số thập phân.");
            }
        } catch (NumberFormatException ex) {
            errors.add("Giá phải là một số hợp lệ (dùng dấu chấm cho phần thập phân).");
        }

        int quantity = 0;
        try {
            quantity = Integer.parseInt(quantityText);
            if (quantity < 0) {
                errors.add("Số lượng không được là số âm.");
            }
        } catch (NumberFormatException ex) {
            errors.add("Số lượng phải là số nguyên hợp lệ.");
        }
        Product product = errors.isEmpty() ? new Product(id, name, price, quantity) : null;
        return new ValidationResult(product, errors);
    }

    public static final class ValidationResult {
        private final Product product;
        private final List<String> errors;

        private ValidationResult(Product product, List<String> errors) {
            this.product = product;
            this.errors = List.copyOf(errors);
        }

        public boolean isValid() { return errors.isEmpty(); }
        public Product getProduct() { return product; }
        public List<String> getErrors() { return errors; }
    }
}
