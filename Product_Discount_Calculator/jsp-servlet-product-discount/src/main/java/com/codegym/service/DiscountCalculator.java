package com.codegym.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Pure Java business logic for the product discount calculation.
 * All money amounts use BigDecimal (never binary floating-point).
 */
public final class DiscountCalculator {
    private static final BigDecimal ONE_HUNDRED = new BigDecimal("100");
    private static final BigDecimal MAX_PRICE = new BigDecimal("999999999999.99");

    private DiscountCalculator() {
    }

    public static DiscountResult calculate(BigDecimal listPrice, BigDecimal discountPercent) {
        if (listPrice == null || discountPercent == null) {
            throw new IllegalArgumentException("Giá và phần trăm giảm giá không được bỏ trống.");
        }
        if (listPrice.signum() < 0 || listPrice.compareTo(MAX_PRICE) > 0) {
            throw new IllegalArgumentException("Giá phải từ 0 đến 999.999.999.999,99.");
        }
        if (listPrice.scale() > 2) {
            throw new IllegalArgumentException("Giá chỉ được có tối đa 2 chữ số thập phân.");
        }
        if (discountPercent.signum() < 0 || discountPercent.compareTo(ONE_HUNDRED) > 0) {
            throw new IllegalArgumentException("Phần trăm giảm giá phải từ 0 đến 100.");
        }
        if (discountPercent.scale() > 2) {
            throw new IllegalArgumentException("Phần trăm giảm giá có tối đa 2 chữ số thập phân.");
        }

        BigDecimal price = listPrice.setScale(2, RoundingMode.UNNECESSARY);
        BigDecimal amount = price.multiply(discountPercent)
                .divide(ONE_HUNDRED, 2, RoundingMode.HALF_UP);
        BigDecimal finalPrice = price.subtract(amount);
        return new DiscountResult(price, discountPercent, amount, finalPrice);
    }
}
