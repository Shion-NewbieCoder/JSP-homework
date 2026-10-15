package com.codegym.strategy;

/** Lỗi lưu trữ thống nhất để Controller xử lý như nhau với MySQL và File. */
public class StorageException extends RuntimeException {
    public StorageException(String message) { super(message); }
    public StorageException(String message, Throwable cause) { super(message, cause); }
}
