package com.codegym.service;

import java.math.BigDecimal;

/** Immutable calculation result sent to the JSP through request attributes. */
public final class DiscountResult {
    private final BigDecimal listPrice;
    private final BigDecimal discountPercent;
    private final BigDecimal discountAmount;
    private final BigDecimal discountPrice;

    public DiscountResult(BigDecimal listPrice, BigDecimal discountPercent,
                          BigDecimal discountAmount, BigDecimal discountPrice) {
        this.listPrice = listPrice;
        this.discountPercent = discountPercent;
        this.discountAmount = discountAmount;
        this.discountPrice = discountPrice;
    }

    public BigDecimal getListPrice() {
        return listPrice;
    }

    public BigDecimal getDiscountPercent() {
        return discountPercent;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public BigDecimal getDiscountPrice() {
        return discountPrice;
    }
}
