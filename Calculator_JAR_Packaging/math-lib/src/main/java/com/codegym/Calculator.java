package com.codegym;

import java.security.NoSuchAlgorithmException;

/**
 * Thư viện phép tính số nguyên. Không chứa hàm main: ứng dụng khác sẽ gọi lại.
 */
public final class Calculator {
    private Calculator() {
        // Utility class: không cần tạo đối tượng.
    }

    public static int sum(int a, int b) {
        return a + b;
    }

    public static int sub(int a, int b) {
        return a - b;
    }

    public static int mul(int a, int b) {
        return a * b;
    }

    /**
     * Theo đúng bài tập CodeGym, phép chia cho 0 ném NoSuchAlgorithmException.
     * Trong phần mềm thực tế, ArithmeticException phù hợp hơn.
     */
    public static int divide(int a, int b) throws NoSuchAlgorithmException {
        if (b == 0) {
            throw new NoSuchAlgorithmException("Không thể chia cho 0");
        }
        return a / b;
    }
}
