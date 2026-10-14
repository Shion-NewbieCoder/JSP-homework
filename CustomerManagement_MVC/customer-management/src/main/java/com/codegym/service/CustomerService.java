package com.codegym.service;

import com.codegym.model.Customer;
import java.util.List;

/**
 * Service contract for managing customers (declarations only).
 */
public interface CustomerService {
    /** TODO: Return all customers. */
    List<Customer> findAll();

    /** TODO: Create a customer. */
    void save(Customer customer);

    /** TODO: Find a customer by id. */
    Customer findById(int id);

    /** TODO: Update an existing customer. */
    void update(int id, Customer customer);

    /** TODO: Remove a customer by id. */
    void remove(int id);
}
