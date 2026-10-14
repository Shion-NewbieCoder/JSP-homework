package com.codegym.model;

/** Thong tin khach hang mau; pham vi demo, khong luu du lieu nhay cam. */
public class Customer {
    private final String name;
    private final String birthday;
    private final String address;
    private final String photo;

    public Customer(String name, String birthday, String address, String photo) {
        this.name = name;
        this.birthday = birthday;
        this.address = address;
        this.photo = photo;
    }

    public String getName() {
        return name;
    }

    public String getBirthday() {
        return birthday;
    }

    public String getAddress() {
        return address;
    }

    public String getPhoto() {
        return photo;
    }
}
