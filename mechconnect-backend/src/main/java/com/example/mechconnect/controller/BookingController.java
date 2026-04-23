package com.example.mechconnect.controller;

import com.example.mechconnect.service.BookingService;
import com.example.mechconnect.entity.Booking;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;


@RestController
@RequestMapping("api/bookings")
public class BookingController {

    private final BookingService bookingService;

    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @PostMapping
    public ResponseEntity<?> createBooking(@RequestBody Booking booking) {

        try {
            Booking savedBooking = bookingService.createBooking(booking);
            return ResponseEntity.ok(savedBooking);

        } catch (IllegalStateException e) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(e.getMessage());
        }
    }
    @GetMapping
    public List<Booking> getAllBookings() {
        return bookingService.getAllBookings();
    }

    @PutMapping("/{id}/status")
    public Booking updateBookingStatus( @PathVariable Long id,@RequestParam String status) {

        return bookingService.updateBookingStatus(id, status);
    }

    @GetMapping("/mechanic/{mechanicId}")
    public List<Booking> getBookingsForMechanic(@PathVariable Long mechanicId){
        return bookingService.getBookingsForMechanic(mechanicId);
    }

    @GetMapping("/customer")
    public List<Booking> getBookingsForCustomer(@RequestParam String phone){
        return bookingService.getBookingsForCustomer(phone);
    }
    
    @GetMapping("/mechanic/{id}/available-slots")
    public List<LocalTime> getAvailableSlots( @PathVariable Long id, @RequestParam String date) {

        LocalDate bookingDate = LocalDate.parse(date);

        return bookingService.getAvailableSlots(id, bookingDate);
    }
}
