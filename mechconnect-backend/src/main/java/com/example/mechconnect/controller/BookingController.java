package com.example.mechconnect.controller;

import com.example.mechconnect.dto.BookingRequestDTO;
import com.example.mechconnect.dto.BookingStatusDTO;
import com.example.mechconnect.entity.Booking;
import com.example.mechconnect.entity.User;
import com.example.mechconnect.service.AuthService;
import com.example.mechconnect.service.BookingService;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    private final BookingService bookingService;
    private final AuthService authService;

    public BookingController(BookingService bookingService, AuthService authService) {
        this.bookingService = bookingService;
        this.authService = authService;
    }

    // FIX: now binds to the validated BookingRequestDTO instead of the raw
    // entity, and maps it into a Booking server-side (status is always set
    // to PENDING here, never trusted from the client).
    @PostMapping
    public ResponseEntity<Booking> createBooking(
            @Valid @RequestBody BookingRequestDTO dto,
            Authentication authentication) {

        Booking booking = new Booking();

        User user = authService.getByEmail(authentication.getName());

        booking.setCustomerUserId(user.getId());

        booking.setMechanicId(dto.getMechanicId());
        booking.setCustomerName(dto.getCustomerName());
        booking.setCustomerPhone(dto.getCustomerPhone());
        booking.setBikeModel(dto.getBikeModel());
        booking.setBookingTime(dto.getBookingTime());
        booking.setProblemDescription(dto.getProblemDescription());

        return ResponseEntity.ok(bookingService.createBooking(booking));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public List<Booking> getAllBookings() {
        return bookingService.getAllBookings();
    }

    @GetMapping("/customer/me")
    @PreAuthorize("hasRole('USER')")
    public List<Booking> getMyCustomerBookings(Authentication authentication) {
        return bookingService.getMyCustomerBookings(currentUserId(authentication));
    }

    // FIX: only the mechanic who owns the shop (or an ADMIN) can change a
    // booking's status now — previously any authenticated user could.
    @PutMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('MECHANIC','ADMIN')")
    public Booking updateBookingStatus(@PathVariable Long id,
                                        @Valid @RequestBody BookingStatusDTO body,
                                        Authentication authentication) {
        boolean isAdmin = authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        Long userId = currentUserId(authentication);
        return bookingService.updateBookingStatus(id, body.getStatus(), userId, isAdmin);
    }

    @GetMapping("/mechanic/{mechanicId}")
    @PreAuthorize("hasRole('ADMIN')")
    public List<Booking> getBookingsForMechanic(@PathVariable Long mechanicId) {
        return bookingService.getBookingsForMechanic(mechanicId);
    }

    // NEW: powers the mechanic's own "incoming bookings" dashboard screen.
    @GetMapping("/mechanic/me")
    @PreAuthorize("hasRole('MECHANIC')")
    public List<Booking> getMyShopBookings(Authentication authentication) {
        return bookingService.getMyShopBookings(currentUserId(authentication));
    }

    @GetMapping("/customer")
    public List<Booking> getBookingsForCustomer(@RequestParam String phone) {
        return bookingService.getBookingsForCustomer(phone);
    }

    @GetMapping("/mechanic/{id}/available-slots")
    public List<java.time.LocalTime> getAvailableSlots(@PathVariable Long id, @RequestParam String date) {
        LocalDate bookingDate = LocalDate.parse(date);
        return bookingService.getAvailableSlots(id, bookingDate);
    }

    private Long currentUserId(Authentication authentication) {
        User user = authService.getByEmail(authentication.getName());
        return user.getId();
    }
}
