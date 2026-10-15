package com.codegym.math;

/**
 * Kết quả bất biến của phép giải phương trình ax² + bx + c = 0 trên tập số thực.
 * Nếu không có nghiệm thực thì getX1()/getX2() trả về null.
 */
public final class EquationResult {
    public enum Type {
        TWO_REAL_ROOTS,
        DOUBLE_ROOT,
        NO_REAL_ROOTS,
        LINEAR_ROOT,
        NO_SOLUTION,
        INFINITE_SOLUTIONS
    }

    private final Type type;
    private final Double x1;
    private final Double x2;
    private final Double discriminant;

    private EquationResult(Type type, Double x1, Double x2, Double discriminant) {
        this.type = type;
        this.x1 = x1;
        this.x2 = x2;
        this.discriminant = discriminant;
    }

    static EquationResult of(Type type, Double x1, Double x2, Double discriminant) {
        return new EquationResult(type, x1, x2, discriminant);
    }

    public Type getType() {
        return type;
    }

    /** Nghiệm duy nhất hoặc nghiệm nhỏ hơn (khi có hai nghiệm). */
    public Double getX1() {
        return x1;
    }

    /** Nghiệm lớn hơn, chỉ có khi có hai nghiệm phân biệt. */
    public Double getX2() {
        return x2;
    }

    /** Delta = b*b - 4*a*c, null nếu phương trình suy biến thành bậc nhất. */
    public Double getDiscriminant() {
        return discriminant;
    }
}
