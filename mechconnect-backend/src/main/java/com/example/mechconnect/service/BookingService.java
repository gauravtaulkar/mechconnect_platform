package com.example.mechconnect.service;

import com.example.mechconnect.entity.Booking;
import com.example.mechconnect.entity.Mechanic;
import com.example.mechconnect.repository.BookingRepository;
import com.example.mechconnect.repository.MechanicRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;

    @Autowired
    private MechanicRepository mechanicRepository;

    public BookingService(BookingRepository bookingRepository) {
        this.bookingRepository = bookingRepository;
    }


    public Booking createBooking(Booking booking) {

        Mechanic mechanic = mechanicRepository
                .findById(booking.getMechanicId())
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));

        LocalTime requestedTime = booking.getBookingTime().toLocalTime();

        if (requestedTime.getMinute() != 0) {
            throw new IllegalStateException("Bookings must be on 1 hour slots");
        }

        if (requestedTime.isBefore(mechanic.getOpeningTime()) ||
            requestedTime.isAfter(mechanic.getClosingTime())) {

            throw new IllegalStateException("Booking outside shop working hours");
        }

        boolean alreadyBooked =
                bookingRepository.existsByMechanicIdAndBookingTime(
                booking.getMechanicId(),booking.getBookingTime());

        if (alreadyBooked) {
            throw new IllegalStateException("Time slot already booked");
        }

        booking.setStatus("PENDING");

        return bookingRepository.save(booking);
    }

    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }

    public Booking updateBookingStatus(long id, String Status){

        Booking booking=bookingRepository.findById(id)
            .orElseThrow(()->new RuntimeException("Booking Not Found"));
        
        booking.setStatus(Status);
        return bookingRepository.save(booking);
    }

    public List<Booking> getBookingsForMechanic(Long mechanicId){
    return bookingRepository.findByMechanicId(mechanicId);
    }

    public List<Booking> getBookingsForCustomer(String customerPhone){
        return bookingRepository.findByCustomerPhone(customerPhone);
    }

    public List<LocalTime> getAvailableSlots(Long mechanicId, LocalDate date) {

        Mechanic mechanic = mechanicRepository.findById(mechanicId)
                .orElseThrow(() -> new RuntimeException("Mechanic not found"));

        LocalTime opening = mechanic.getOpeningTime();
        LocalTime closing = mechanic.getClosingTime();

        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.atTime(23,59);

        List<Booking> bookings =
                bookingRepository.findByMechanicIdAndBookingTimeBetween(mechanicId, start, end);

        List<LocalTime> bookedTimes = bookings.stream()
        .map(b -> b.getBookingTime().toLocalTime().withSecond(0).withNano(0))
        .toList();

        List<LocalTime> availableSlots = new ArrayList<>();

        LocalTime slot = opening;

        while(slot.isBefore(closing)) {

            if(!bookedTimes.contains(slot)) {
                availableSlots.add(slot);
            }

            slot = slot.plusHours(1);
        }

        return availableSlots;
    }

}