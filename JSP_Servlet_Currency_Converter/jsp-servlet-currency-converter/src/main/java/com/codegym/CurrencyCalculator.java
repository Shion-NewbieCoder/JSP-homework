package com.codegym;

import java.math.BigDecimal;

/**
 * Business logic: convert USD to VND using a user-supplied exchange rate.
 * BigDecimal avoids binary floating-point inaccuracies with money.
 */
public final class CurrencyCalculator {
    private CurrencyCalculator() {
    }

    /**
     * @param rate positive VND value per one USD
     * @param usd non-negative amount of USD
     * @return the converted VND amount (exact BigDecimal multiplication)
     * @throws IllegalArgumentException when input is null or outside the allowed range
     */
    public static BigDecimal convert(BigDecimal rate, BigDecimal usd) {
        if (rate == null || usd == null) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ tỉ giá và lượng USD.");
        }
        if (rate.signum() <= 0) {
            throw new IllegalArgumentException("Tỉ giá phải lớn hơn 0.");
        }
        if (usd.signum() < 0) {
            throw new IllegalArgumentException("Lượng USD không được âm.");
        }
        return rate.multiply(usd);
    }
}
