package com.example.mechconnect.repository;

import com.example.mechconnect.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByMechanicId(Long mechanicId);

    List<Booking> findByMechanicIdOrderByBookingTimeDesc(Long mechanicId);

    List<Booking> findByCustomerPhone(String customerPhone);

    boolean existsByMechanicIdAndBookingTime(Long mechanicId, LocalDateTime bookingTime);

    List<Booking> findByMechanicIdAndBookingTimeBetween(Long mechanicId, LocalDateTime start, LocalDateTime end);
}
