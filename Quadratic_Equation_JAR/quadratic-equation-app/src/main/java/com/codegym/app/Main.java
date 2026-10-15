package com.codegym.app;

import com.codegym.math.EquationResult;
import com.codegym.math.QuadraticEquation;
import java.util.Locale;

/** Minh họa việc import và sử dụng thư viện từ file JAR bên ngoài. */
public final class Main {
    private Main() { }

    public static void main(String[] args) {
        try {
            if (args.length == 3) {
                display(Double.parseDouble(args[0]), Double.parseDouble(args[1]),
                        Double.parseDouble(args[2]));
            } else if (args.length == 0) {
                System.out.println("DEMO: GỌI THƯ VIỆN PHƯƠNG TRÌNH BẬC HAI TỪ FILE .JAR");
                display(1, -3, 2);    // Hai nghiệm: 1 và 2
                display(1, 2, 1);     // Nghiệm kép: -1
                display(1, 0, 1);     // Không có nghiệm thực
                display(0, 2, -8);    // Bậc nhất: 4
                display(0, 0, 5);     // Vô nghiệm
                display(0, 0, 0);     // Vô số nghiệm
            } else {
                System.err.println("Cách dùng: java ... com.codegym.app.Main [a b c]");
                System.exit(2);
            }
        } catch (RuntimeException ex) {
            System.err.println("Dữ liệu không hợp lệ: " + ex.getMessage());
            System.exit(2);
        }
    }

    private static void display(double a, double b, double c) {
        EquationResult result = QuadraticEquation.solve(a, b, c);
        System.out.printf(Locale.US, "\n%.3fx² %+.3fx %+.3f = 0%n", a, b, c);
        switch (result.getType()) {
            case TWO_REAL_ROOTS -> System.out.printf(Locale.US,
                    "Hai nghiệm thực: x1 = %.6f; x2 = %.6f%n", result.getX1(), result.getX2());
            case DOUBLE_ROOT -> System.out.printf(Locale.US,
                    "Nghiệm kép: x = %.6f%n", result.getX1());
            case NO_REAL_ROOTS -> System.out.println("Phương trình vô nghiệm trên tập số thực.");
            case LINEAR_ROOT -> System.out.printf(Locale.US,
                    "Phương trình bậc nhất: x = %.6f%n", result.getX1());
            case NO_SOLUTION -> System.out.println("Phương trình vô nghiệm.");
            case INFINITE_SOLUTIONS -> System.out.println("Phương trình có vô số nghiệm.");
        }
    }
}
