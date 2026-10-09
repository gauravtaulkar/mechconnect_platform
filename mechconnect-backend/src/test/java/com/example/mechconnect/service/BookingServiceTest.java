
package com.example.mechconnect.service;

import com.example.mechconnect.entity.Booking;
import com.example.mechconnect.entity.Mechanic;
import com.example.mechconnect.repository.BookingRepository;
import com.example.mechconnect.repository.MechanicRepository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BookingServiceTest {

    @Mock
    private BookingRepository bookingRepository;

    @Mock
    private MechanicRepository mechanicRepository;

    @InjectMocks
    private BookingService bookingService;

    private Mechanic mechanic;

    @BeforeEach
    void setUp() {
        mechanic = new Mechanic();
        mechanic.setId(10L);
        mechanic.setUserId(100L);
        mechanic.setAvailable(true);
        mechanic.setOpeningTime(LocalTime.of(9, 0));
        mechanic.setClosingTime(LocalTime.of(18, 0));
    }

    @Test
    void getMyCustomerBookingsReturnsOnlyRepositoryResultsForCustomer() {
        Booking booking = new Booking();
        booking.setCustomerUserId(25L);

        when(bookingRepository.findByCustomerUserIdOrderByBookingTimeDesc(25L))
                .thenReturn(List.of(booking));

        List<Booking> result = bookingService.getMyCustomerBookings(25L);

        assertEquals(1, result.size());
        assertEquals(25L, result.get(0).getCustomerUserId());

        verify(bookingRepository)
                .findByCustomerUserIdOrderByBookingTimeDesc(25L);
    }

    @Test
    void createBookingThrowsWhenMechanicDoesNotExist() {
        Booking booking = validBooking();

        when(mechanicRepository.findById(10L))
                .thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> bookingService.createBooking(booking)
        );

        verify(bookingRepository, never()).save(any(Booking.class));
    }

    @Test
    void createBookingThrowsWhenMechanicIsUnavailable() {
        mechanic.setAvailable(false);

        when(mechanicRepository.findById(10L))
                .thenReturn(Optional.of(mechanic));

        assertThrows(
                IllegalStateException.class,
                () -> bookingService.createBooking(validBooking())
        );

        verify(bookingRepository, never()).save(any(Booking.class));
    }

    @Test
    void createBookingRejectsTimeWithNonzeroMinutes() {
        when(mechanicRepository.findById(10L))
                .thenReturn(Optional.of(mechanic));

        Booking booking = validBooking();
        booking.setBookingTime(LocalDateTime.of(2027, 1, 15, 10, 30));

        assertThrows(
                IllegalStateException.class,
                () -> bookingService.createBooking(booking)
        );

        verify(bookingRepository, never()).save(any(Booking.class));
    }

    @Test
    void createBookingRejectsTimeOutsideShopHours() {
        when(mechanicRepository.findById(10L))
                .thenReturn(Optional.of(mechanic));

        Booking booking = validBooking();
        booking.setBookingTime(LocalDateTime.of(2027, 1, 15, 8, 0));

        assertThrows(
                IllegalStateException.class,
                () -> bookingService.createBooking(booking)
        );

        verify(bookingRepository, never()).save(any(Booking.class));
    }

    @Test
    void createBookingRejectsAlreadyBookedSlot() {
        when(mechanicRepository.findById(10L))
                .thenReturn(Optional.of(mechanic));

        when(bookingRepository.existsByMechanicIdAndBookingTime(
                10L, LocalDateTime.of(2027, 1, 15, 10, 0)))
                .thenReturn(true);

        assertThrows(
                IllegalStateException.class,
                () -> bookingService.createBooking(validBooking())
        );

        verify(bookingRepository, never()).save(any(Booking.class));
    }

    @Test
    void createBookingSavesValidBookingAsPending() {
        Booking booking = validBooking();

        when(mechanicRepository.findById(10L))
                .thenReturn(Optional.of(mechanic));

        when(bookingRepository.existsByMechanicIdAndBookingTime(
                10L, booking.getBookingTime()))
                .thenReturn(false);

        when(bookingRepository.save(booking)).thenReturn(booking);

        Booking result = bookingService.createBooking(booking);

        assertEquals("PENDING", result.getStatus());
        verify(bookingRepository).save(booking);
    }

    @Test
    void updateBookingStatusRejectsAnotherMechanicsBooking() {
        Booking booking = validBooking();
        booking.setMechanicId(10L);

        Mechanic anotherMechanic = new Mechanic();
        anotherMechanic.setId(20L);
        anotherMechanic.setUserId(200L);

        when(bookingRepository.findById(1L))
                .thenReturn(Optional.of(booking));

        when(mechanicRepository.findByUserId(200L))
                .thenReturn(Optional.of(anotherMechanic));

        assertThrows(
                AccessDeniedException.class,
                () -> bookingService.updateBookingStatus(
                        1L, "CONFIRMED", 200L, false)
        );

        verify(bookingRepository, never()).save(any(Booking.class));
    }

    @Test
    void adminCanUpdateBookingStatus() {
        Booking booking = validBooking();

        when(bookingRepository.findById(1L))
                .thenReturn(Optional.of(booking));

        when(bookingRepository.save(booking)).thenReturn(booking);

        Booking result = bookingService.updateBookingStatus(
                1L, "CONFIRMED", 999L, true);

        assertEquals("CONFIRMED", result.getStatus());
        verify(bookingRepository).save(booking);
        verify(mechanicRepository, never()).findByUserId(anyLong());
    }

    @Test
    void getMyShopBookingsThrowsWhenUserHasNoShop() {
        when(mechanicRepository.findByUserId(200L))
                .thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> bookingService.getMyShopBookings(200L)
        );

        verify(bookingRepository, never())
                .findByMechanicIdOrderByBookingTimeDesc(anyLong());
    }

    @Test
    void getMyShopBookingsReturnsBookingsForOwnMechanicId() {
        Booking booking = validBooking();

        when(mechanicRepository.findByUserId(100L))
                .thenReturn(Optional.of(mechanic));

        when(bookingRepository.findByMechanicIdOrderByBookingTimeDesc(10L))
                .thenReturn(List.of(booking));

        List<Booking> result = bookingService.getMyShopBookings(100L);

        assertEquals(1, result.size());
        verify(bookingRepository)
                .findByMechanicIdOrderByBookingTimeDesc(10L);
    }

        private Booking validBooking() {
        Booking booking = new Booking();
        booking.setMechanicId(10L);
        booking.setCustomerUserId(25L);
        booking.setCustomerName("Test Customer");
        booking.setCustomerPhone("9999999999");
        booking.setBikeModel("Test Bike");
        booking.setBookingTime(LocalDateTime.of(2027, 1, 15, 10, 0));
        booking.setProblemDescription("Test problem");
        return booking;
    }
}
