package com.codegym;

import java.math.BigDecimal;

/** Standalone unit tests runnable with javac/java, no extra dependencies. */
public final class CurrencyCalculatorTest {
    private static int passed = 0;

    private static void assertAmount(String rate, String usd, String expected) {
        BigDecimal actual = CurrencyCalculator.convert(new BigDecimal(rate), new BigDecimal(usd));
        if (actual.compareTo(new BigDecimal(expected)) != 0) {
            throw new AssertionError(rate + " * " + usd + " => " + actual + ", expected " + expected);
        }
        passed++;
    }

    private static void expectInvalid(BigDecimal rate, BigDecimal usd) {
        try {
            CurrencyCalculator.convert(rate, usd);
            throw new AssertionError("Expected IllegalArgumentException");
        } catch (IllegalArgumentException expected) {
            passed++;
        }
    }

    public static void main(String[] args) {
        assertAmount("25000", "100", "2500000");
        assertAmount("25000", "0", "0");
        assertAmount("26000.5", "1.2", "31200.60");
        assertAmount("25000", "0.001", "25");
        assertAmount("0.01", "0.01", "0.0001");
        assertAmount("10000000000", "1000000", "10000000000000000");
        expectInvalid(BigDecimal.ZERO, BigDecimal.ONE);
        expectInvalid(new BigDecimal("-1"), BigDecimal.ONE);
        expectInvalid(BigDecimal.ONE, new BigDecimal("-1"));
        expectInvalid(null, BigDecimal.ONE);
        expectInvalid(BigDecimal.ONE, null);
        System.out.println("PASS " + passed + "/11 conversion cases");
    }
}
