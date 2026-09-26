package com.example.mechconnect.service;

import com.example.mechconnect.entity.Booking;
import com.example.mechconnect.entity.Mechanic;
import com.example.mechconnect.repository.BookingRepository;
import com.example.mechconnect.repository.MechanicRepository;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;
    private final MechanicRepository mechanicRepository;

    public BookingService(BookingRepository bookingRepository, MechanicRepository mechanicRepository) {
        this.bookingRepository = bookingRepository;
        this.mechanicRepository = mechanicRepository;
    }

    public Booking createBooking(Booking booking) {
        Mechanic mechanic = mechanicRepository
                .findById(booking.getMechanicId())
                .orElseThrow(() -> new IllegalStateException("Mechanic not found"));

        if (!mechanic.isAvailable()) {
            throw new IllegalStateException("This mechanic is not currently available");
        }

        LocalTime requestedTime = booking.getBookingTime().toLocalTime();

        if (requestedTime.getMinute() != 0) {
            throw new IllegalStateException("Bookings must be on 1 hour slots");
        }

        if (requestedTime.isBefore(mechanic.getOpeningTime()) ||
                requestedTime.isAfter(mechanic.getClosingTime())) {
            throw new IllegalStateException("Booking outside shop working hours");
        }

        boolean alreadyBooked = bookingRepository.existsByMechanicIdAndBookingTime(
                booking.getMechanicId(), booking.getBookingTime());

        if (alreadyBooked) {
            throw new IllegalStateException("Time slot already booked");
        }

        booking.setStatus("PENDING");
        return bookingRepository.save(booking);
    }

    public List<Booking> getAllBookings() {
        return bookingRepository.findAll();
    }

    public Booking updateBookingStatus(Long bookingId, String status, Long requesterUserId, boolean isAdmin) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalStateException("Booking not found"));

        if (!isAdmin) {
            Mechanic ownMechanic = mechanicRepository.findByUserId(requesterUserId)
                    .orElseThrow(() -> new AccessDeniedException("No shop profile for this account"));
            if (!ownMechanic.getId().equals(booking.getMechanicId())) {
                throw new AccessDeniedException("This booking does not belong to your shop");
            }
        }

        booking.setStatus(status);
        return bookingRepository.save(booking);
    }

    public List<Booking> getBookingsForMechanic(Long mechanicId) {
        return bookingRepository.findByMechanicIdOrderByBookingTimeDesc(mechanicId);
    }

    public List<Booking> getMyShopBookings(Long requesterUserId) {
        Mechanic ownMechanic = mechanicRepository.findByUserId(requesterUserId)
                .orElseThrow(() -> new IllegalStateException("You don't have a shop profile yet"));
        return bookingRepository.findByMechanicIdOrderByBookingTimeDesc(ownMechanic.getId());
    }

    public List<Booking> getBookingsForCustomer(String customerPhone) {
        return bookingRepository.findByCustomerPhone(customerPhone);
    }

    public List<LocalTime> getAvailableSlots(Long mechanicId, LocalDate date) {
        Mechanic mechanic = mechanicRepository.findById(mechanicId)
                .orElseThrow(() -> new IllegalStateException("Mechanic not found"));

        LocalTime opening = mechanic.getOpeningTime();
        LocalTime closing = mechanic.getClosingTime();

        LocalDateTime start = date.atStartOfDay();
        LocalDateTime end = date.atTime(23, 59);

        List<Booking> bookings =
                bookingRepository.findByMechanicIdAndBookingTimeBetween(mechanicId, start, end);

        List<LocalTime> bookedTimes = bookings.stream()
                .map(b -> b.getBookingTime().toLocalTime().withSecond(0).withNano(0))
                .toList();

        List<LocalTime> availableSlots = new ArrayList<>();
        LocalTime slot = opening;

        // check if the requested date is today
        boolean isToday = date.equals(LocalDate.now());

        while (slot.isBefore(closing)) {
            // if today, skip slots that have already passed
            if (isToday && !slot.isAfter(LocalTime.now())) {
                slot = slot.plusHours(1);
                continue;
            }
            if (!bookedTimes.contains(slot)) {
                availableSlots.add(slot);
            }
            slot = slot.plusHours(1);
        }

        return availableSlots;
    }
}