package com.codegym.model;

/** The four elementary operations for the Servlet calculator. */
public final class Calculator {
    private Calculator() {
        // Utility class - no instances needed.
    }

    /**
     * Calculates firstOperand (operator) secondOperand.
     *
     * @throws ArithmeticException if dividing by zero or the answer overflows
     * @throws IllegalArgumentException if inputs or the operator are invalid
     */
    public static double calculate(double firstOperand, double secondOperand, char operator) {
        if (!Double.isFinite(firstOperand) || !Double.isFinite(secondOperand)) {
            throw new IllegalArgumentException("Hai toán hạng phải là số hữu hạn.");
        }

        double result;
        switch (operator) {
            case '+':
                result = firstOperand + secondOperand;
                break;
            case '-':
                result = firstOperand - secondOperand;
                break;
            case '*':
                result = firstOperand * secondOperand;
                break;
            case '/':
                if (secondOperand == 0.0) {
                    throw new ArithmeticException("Không thể chia cho 0.");
                }
                result = firstOperand / secondOperand;
                break;
            default:
                throw new IllegalArgumentException("Phép toán không hợp lệ.");
        }

        if (!Double.isFinite(result)) {
            throw new ArithmeticException("Kết quả vượt quá giới hạn hỗ trợ.");
        }
        return result;
    }
}
