package com.codegym.service;

import java.math.BigDecimal;

/** Run using the scripts in scripts/, no JUnit dependency required. */
public class DiscountCalculatorSelfTest {
    private static int checks = 0;

    public static void main(String[] args) {
        check("200.00", calc("1000", "20").getDiscountAmount());
        check("800.00", calc("1000", "20").getDiscountPrice());
        check("0.00", calc("1000", "0").getDiscountAmount());
        check("1000.00", calc("1000", "0").getDiscountPrice());
        check("1000.00", calc("1000", "100").getDiscountAmount());
        check("0.00", calc("1000", "100").getDiscountPrice());
        check("0.00", calc("0", "50").getDiscountAmount());
        check("0.00", calc("0", "50").getDiscountPrice());
        check("15.43", calc("123.45", "12.5").getDiscountAmount());
        check("108.02", calc("123.45", "12.5").getDiscountPrice());
        check("0.01", calc("0.05", "10").getDiscountAmount());
        check("0.04", calc("0.05", "10").getDiscountPrice());
        check("100.00", calc("100", "15.0").getListPrice());
        check("15.0", calc("100", "15.0").getDiscountPercent());
        invalid("-1", "10");
        invalid("10", "-1");
        invalid("10", "101");
        invalid("10.001", "10");
        invalid("10", "2.999");
        invalid("1000000000000", "10");
        invalidNullPrice();
        invalidNullPercent();
        System.out.println("PASS: " + checks + " / " + checks + " checks");
    }

    private static DiscountResult calc(String price, String percent) {
        return DiscountCalculator.calculate(new BigDecimal(price), new BigDecimal(percent));
    }

    private static void check(String expected, BigDecimal actual) {
        if (actual.compareTo(new BigDecimal(expected)) != 0) {
            throw new AssertionError("Expected " + expected + " but got " + actual);
        }
        checks++;
    }

    private static void invalid(String price, String percent) {
        try {
            calc(price, percent);
        } catch (IllegalArgumentException expected) {
            checks++;
            return;
        }
        throw new AssertionError("Should reject price=" + price + ", percent=" + percent);
    }

    private static void invalidNullPrice() {
        try {
            DiscountCalculator.calculate(null, BigDecimal.TEN);
        } catch (IllegalArgumentException expected) {
            checks++;
            return;
        }
        throw new AssertionError("Should reject null price");
    }

    private static void invalidNullPercent() {
        try {
            DiscountCalculator.calculate(BigDecimal.TEN, null);
        } catch (IllegalArgumentException expected) {
            checks++;
            return;
        }
        throw new AssertionError("Should reject null percent");
    }
}
