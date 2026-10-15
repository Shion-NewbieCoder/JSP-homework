package com.codegym;

import java.security.NoSuchAlgorithmException;

/**
 * Ứng dụng thứ hai sử dụng class Calculator ở thư viện math-lib.jar.
 * Dự án này không chứa bản sao Calculator.java.
 */
public final class Main {
    private Main() {
    }

    public static void main(String[] args) {
        System.out.println("Kết quả gọi từ thư viện đóng gói (.jar):");
        System.out.println("Tổng 2 số (5, 9): " + Calculator.sum(5, 9));
        System.out.println("Hiệu 2 số (5, 9): " + Calculator.sub(5, 9));
        System.out.println("Tích 2 số (5, 9): " + Calculator.mul(5, 9));

        try {
            System.out.println("Thương 2 số (10, 5): " + Calculator.divide(10, 5));
            // Kiểm tra xử lý ngoại lệ: bỏ comment dòng dưới để thử chia cho 0.
            // System.out.println(Calculator.divide(10, 0));
        } catch (NoSuchAlgorithmException e) {
            System.err.println("Lỗi thuật toán: " + e.getMessage());
        }
    }
}
