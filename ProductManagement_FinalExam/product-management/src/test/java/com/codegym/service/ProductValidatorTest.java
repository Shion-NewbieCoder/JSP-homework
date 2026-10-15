package com.codegym.service;

import static org.junit.jupiter.api.Assertions.*;
import java.math.BigDecimal;
import org.junit.jupiter.api.Test;

class ProductValidatorTest {
    @Test void validForm() {
        var r = ProductValidator.validate(9, "  Bàn phím  ", "149000.50", "5");
        assertTrue(r.isValid());
        assertEquals(9, r.getProduct().getId());
        assertEquals("Bàn phím", r.getProduct().getName());
        assertEquals(new BigDecimal("149000.50"), r.getProduct().getPrice());
        assertEquals(5, r.getProduct().getQuantity());
    }
    @Test void freeProductAndEmptyStockAreValid() {
        assertTrue(ProductValidator.validate(0, "Hàng tặng", "0", "0").isValid());
    }
    @Test void missingNameFails() {
        assertFalse(ProductValidator.validate(0, "  ", "1", "1").isValid());
    }
    @Test void missingPriceFails() {
        assertFalse(ProductValidator.validate(0, "A", "", "1").isValid());
    }
    @Test void negativePriceFails() {
        assertFalse(ProductValidator.validate(0, "A", "-1", "1").isValid());
    }
    @Test void excessiveDecimalsFail() {
        assertFalse(ProductValidator.validate(0, "A", "12.345", "1").isValid());
    }
    @Test void priceAboveColumnCapacityFails() {
        assertFalse(ProductValidator.validate(0, "A", "10000000000", "1").isValid());
    }
    @Test void nullPriceFails() {
        assertFalse(ProductValidator.validate(0, "A", null, "1").isValid());
    }
    @Test void negativeStockFails() {
        assertFalse(ProductValidator.validate(0, "A", "10", "-1").isValid());
    }
    @Test void decimalStockFails() {
        assertFalse(ProductValidator.validate(0, "A", "10", "1.5").isValid());
    }
    @Test void overflowingStockFails() {
        assertFalse(ProductValidator.validate(0, "A", "10", "999999999999999").isValid());
    }
    @Test void tooLongNameFails() {
        assertFalse(ProductValidator.validate(0, "a".repeat(256), "10", "5").isValid());
    }
    @Test void exactly255CharactersIsValid() {
        assertTrue(ProductValidator.validate(0, "a".repeat(255), "10", "5").isValid());
    }
    @Test void missingQuantityFails() {
        assertFalse(ProductValidator.validate(0, "A", "10", null).isValid());
    }
}
