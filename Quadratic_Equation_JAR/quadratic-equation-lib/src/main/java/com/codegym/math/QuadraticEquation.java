package com.codegym.math;

import com.codegym.math.EquationResult.Type;

/**
 * Thư viện giải ax² + bx + c = 0 với a, b, c là số thực hữu hạn.
 * Khi a = 0, tự chuyển sang giải phương trình bậc nhất hoặc suy biến.
 */
public final class QuadraticEquation {
    private final double a;
    private final double b;
    private final double c;

    public QuadraticEquation(double a, double b, double c) {
        if (!Double.isFinite(a) || !Double.isFinite(b) || !Double.isFinite(c)) {
            throw new IllegalArgumentException("a, b, c phải là số thực hữu hạn.");
        }
        this.a = a;
        this.b = b;
        this.c = c;
    }

    public static EquationResult solve(double a, double b, double c) {
        return new QuadraticEquation(a, b, c).solve();
    }

    /** Giải phương trình trên tập số thực (không tính nghiệm phức). */
    public EquationResult solve() {
        if (a == 0.0) {
            if (b != 0.0) {
                return EquationResult.of(Type.LINEAR_ROOT, -c / b, null, null);
            }
            return EquationResult.of(c == 0.0 ? Type.INFINITE_SOLUTIONS : Type.NO_SOLUTION,
                    null, null, null);
        }

        double delta = b * b - 4.0 * a * c;
        if (!Double.isFinite(delta)) {
            throw new ArithmeticException("Delta vượt phạm vi biểu diễn của kiểu double.");
        }
        if (delta < 0.0) {
            return EquationResult.of(Type.NO_REAL_ROOTS, null, null, delta);
        }
        if (delta == 0.0) {
            return EquationResult.of(Type.DOUBLE_ROOT, -b / (2.0 * a), null, delta);
        }

        // Công thức tương đương (-b ± sqrt(delta)) / (2a),
        // viết theo dạng ổn định số để hạn chế mất chữ số khi trừ hai số gần nhau.
        double sqrtDelta = Math.sqrt(delta);
        double q = -0.5 * (b + Math.copySign(sqrtDelta, b));
        double x1;
        double x2;
        if (q != 0.0) {
            x1 = q / a;
            x2 = c / q;
        } else {
            x1 = (-b - sqrtDelta) / (2.0 * a);
            x2 = (-b + sqrtDelta) / (2.0 * a);
        }
        if (!Double.isFinite(x1) || !Double.isFinite(x2)) {
            throw new ArithmeticException("Nghiệm vượt phạm vi biểu diễn của kiểu double.");
        }
        if (x1 > x2) {
            double temp = x1;
            x1 = x2;
            x2 = temp;
        }
        return EquationResult.of(Type.TWO_REAL_ROOTS, x1, x2, delta);
    }

    public double getA() { return a; }
    public double getB() { return b; }
    public double getC() { return c; }
}
