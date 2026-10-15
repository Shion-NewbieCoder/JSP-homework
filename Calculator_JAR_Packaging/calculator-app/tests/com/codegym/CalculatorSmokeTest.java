package com.codegym;

import java.security.NoSuchAlgorithmException;

/** Tự chạy bằng java, không cần JUnit hay Maven. */
public final class CalculatorSmokeTest {
    public static void main(String[] args) throws Exception {
        check(Calculator.sum(5, 9) == 14, "sum");
        check(Calculator.sum(-8, 3) == -5, "sum âm");
        check(Calculator.sub(5, 9) == -4, "sub");
        check(Calculator.mul(5, 9) == 45, "mul");
        check(Calculator.mul(-4, 3) == -12, "mul âm");
        check(Calculator.divide(10, 5) == 2, "divide");
        check(Calculator.divide(7, 2) == 3, "chia nguyên");
        check(Calculator.divide(-7, 2) == -3, "chia nguyên âm");
        boolean caught = false;
        try {
            Calculator.divide(10, 0);
        } catch (NoSuchAlgorithmException expected) {
            caught = true;
        }
        check(caught, "divide by zero throws NoSuchAlgorithmException");
        System.out.println("PASS: 9/9 tests, bao gồm chia cho 0.");
    }

    private static void check(boolean condition, String label) {
        if (!condition) {
            throw new AssertionError("FAILED: " + label);
        }
    }
}
