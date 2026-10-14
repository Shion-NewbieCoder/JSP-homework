package com.codegym.model;

import java.util.List;

/** Danh sach co dinh de thuc hanh JSTL; khong can database. */
public final class CustomerData {
    private CustomerData() {
        // Utility class.
    }

    private static final List<Customer> CUSTOMERS = List.of(
        new Customer("Mai Văn Hoàn", "1983-08-20", "Hà Nội", "customer-1.svg"),
        new Customer("Nguyễn Văn Nam", "1983-08-21", "Bắc Giang", "customer-2.svg"),
        new Customer("Nguyễn Thái Hòa", "1983-08-22", "Nam Định", "customer-3.svg"),
        new Customer("Trần Đăng Khoa", "1983-08-17", "Hà Tây", "customer-4.svg"),
        new Customer("Nguyễn Đình Thi", "1983-08-19", "Hà Nội", "customer-5.svg")
    );

    public static List<Customer> getCustomers() {
        return CUSTOMERS;
    }
}
