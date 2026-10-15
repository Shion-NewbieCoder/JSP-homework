import com.codegym.math.EquationResult;
import com.codegym.math.QuadraticEquation;

/** Test chạy trực tiếp với javac/java (không đòi hỏi JUnit hoặc Maven). */
public final class QuadraticEquationSelfTest {
    private static int checks = 0;

    private static void check(boolean value, String description) {
        checks++;
        if (!value) throw new AssertionError("FAILED: " + description);
    }

    private static void near(double actual, double expected, double eps, String description) {
        check(Math.abs(actual - expected) <= eps, description + ": " + actual);
    }

    public static void main(String[] args) {
        EquationResult two = QuadraticEquation.solve(1, -3, 2);
        check(two.getType() == EquationResult.Type.TWO_REAL_ROOTS, "two roots type");
        near(two.getX1(), 1, 1e-12, "smaller root");
        near(two.getX2(), 2, 1e-12, "larger root");
        near(two.getDiscriminant(), 1, 1e-12, "delta");

        EquationResult doubleRoot = QuadraticEquation.solve(1, 2, 1);
        check(doubleRoot.getType() == EquationResult.Type.DOUBLE_ROOT, "double root type");
        near(doubleRoot.getX1(), -1, 1e-12, "double root x");
        check(doubleRoot.getX2() == null, "no second root for double root");

        EquationResult negative = QuadraticEquation.solve(1, 0, 1);
        check(negative.getType() == EquationResult.Type.NO_REAL_ROOTS, "negative delta");
        check(negative.getX1() == null && negative.getX2() == null, "no roots");

        EquationResult linear = QuadraticEquation.solve(0, 2, -8);
        check(linear.getType() == EquationResult.Type.LINEAR_ROOT, "linear type");
        near(linear.getX1(), 4, 1e-12, "linear root");
        check(linear.getDiscriminant() == null, "delta undefined for linear");

        check(QuadraticEquation.solve(0, 0, 5).getType() == EquationResult.Type.NO_SOLUTION,
                "contradiction");
        check(QuadraticEquation.solve(0, 0, 0).getType() == EquationResult.Type.INFINITE_SOLUTIONS,
                "identity");

        EquationResult zero = QuadraticEquation.solve(1, 0, -4);
        near(zero.getX1(), -2, 1e-12, "zero b first root");
        near(zero.getX2(), 2, 1e-12, "zero b second root");

        EquationResult fractions = QuadraticEquation.solve(2, -7, 3);
        near(fractions.getX1(), .5, 1e-12, "fractional root 1");
        near(fractions.getX2(), 3, 1e-12, "fractional root 2");

        // Quadratic formula's naive subtraction would lose precision in small root.
        EquationResult stable = QuadraticEquation.solve(1, -1e8, 1);
        near(stable.getX1(), 1e-8, 1e-18, "stable small root");
        near(stable.getX2(), 1e8, 1e-6, "stable large root");

        boolean invalid = false;
        try { QuadraticEquation.solve(Double.NaN, 1, 2); }
        catch (IllegalArgumentException expected) { invalid = true; }
        check(invalid, "reject NaN input");
        invalid = false;
        try { QuadraticEquation.solve(Double.POSITIVE_INFINITY, 1, 2); }
        catch (IllegalArgumentException expected) { invalid = true; }
        check(invalid, "reject infinite input");
        System.out.println("PASS " + checks + "/" + checks + " Java library checks");
    }
}
