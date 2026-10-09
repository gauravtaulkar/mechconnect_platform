package com.example.mechconnect.controller;

import com.example.mechconnect.entity.Booking;
import com.example.mechconnect.entity.Mechanic;
import com.example.mechconnect.entity.Role;
import com.example.mechconnect.entity.User;
import com.example.mechconnect.repository.BookingRepository;
import com.example.mechconnect.repository.MechanicRepository;
import com.example.mechconnect.repository.UserRepository;
import com.example.mechconnect.service.AuthService;
import com.example.mechconnect.security.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.LocalTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
class BookingControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MechanicRepository mechanicRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @BeforeEach
    void cleanDatabase() {
        bookingRepository.deleteAll();
        mechanicRepository.deleteAll();
        userRepository.deleteAll();
    }

    private User createUser(String name, String email, Role role) {
        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode("TestPass123"));
        user.setRole(role);
        return userRepository.save(user);
    }

    private Mechanic createMechanic(User owner) {
        Mechanic mechanic = new Mechanic();
        mechanic.setUserId(owner.getId());
        mechanic.setName("Test Mechanic");
        mechanic.setShopName("Test Garage");
        mechanic.setCity("Pune");
        mechanic.setStreet("Test Street");
        mechanic.setPhone("9876543210");
        mechanic.setAvailable(true);
        mechanic.setOpeningTime(LocalTime.of(9, 0));
        mechanic.setClosingTime(LocalTime.of(18, 0));
        return mechanicRepository.save(mechanic);
    }

    private String tokenFor(User user) {
        return "Bearer " + jwtUtil.generateToken(user.getEmail());
    }

    @Test
    void customerCanCreateBookingAndBookingIsLinkedToTheirAccount() throws Exception {
        User customer = createUser("Customer One", "customer1@example.com", Role.USER);
        User mechanicOwner = createUser("Mechanic One", "mechanic1@example.com", Role.MECHANIC);
        Mechanic mechanic = createMechanic(mechanicOwner);

        String request = """
                {
                  "mechanicId": %d,
                  "customerName": "Customer One",
                  "customerPhone": "9876543210",
                  "bikeModel": "Honda Activa",
                  "bookingTime": "2030-05-15T10:00:00",
                  "problemDescription": "Engine noise"
                }
                """.formatted(mechanic.getId());

        mockMvc.perform(post("/api/bookings")
                        .header("Authorization", tokenFor(customer))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(request))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.customerUserId").value(customer.getId()))
                .andExpect(jsonPath("$.mechanicId").value(mechanic.getId()))
                .andExpect(jsonPath("$.status").value("PENDING"));

        org.junit.jupiter.api.Assertions.assertEquals(
                1, bookingRepository.count()
        );
    }

    @Test
    void customerCanOnlySeeTheirOwnBookingHistory() throws Exception {
        User customerOne = createUser("Customer One", "customer1@example.com", Role.USER);
        User customerTwo = createUser("Customer Two", "customer2@example.com", Role.USER);
        User mechanicOwner = createUser("Mechanic One", "mechanic1@example.com", Role.MECHANIC);
        Mechanic mechanic = createMechanic(mechanicOwner);

        Booking firstBooking = createBooking(customerOne, mechanic, "Customer One");
        Booking secondBooking = createBooking(customerTwo, mechanic, "Customer Two");

        mockMvc.perform(get("/api/bookings/customer/me")
                        .header("Authorization", tokenFor(customerOne)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].id").value(firstBooking.getId()))
                .andExpect(jsonPath("$[0].customerName").value("Customer One"))
                .andExpect(jsonPath("$[0].id").value(org.hamcrest.Matchers.not(secondBooking.getId())));
    }

    @Test
    void unauthenticatedCustomerCannotCreateBooking() throws Exception {
        mockMvc.perform(post("/api/bookings")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "mechanicId": 1,
                                  "customerName": "Guest",
                                  "customerPhone": "9876543210",
                                  "bikeModel": "Honda Activa",
                                  "bookingTime": "2030-05-15T10:00:00"
                                }
                                """))
                .andExpect(status().isForbidden());
    }

    @Test
    void customerCannotAccessAdminBookingList() throws Exception {
        User customer = createUser("Customer", "customer@example.com", Role.USER);

        mockMvc.perform(get("/api/bookings")
                        .header("Authorization", tokenFor(customer)))
                .andExpect(status().isForbidden());
    }

    private Booking createBooking(User customer, Mechanic mechanic, String customerName) {
        Booking booking = new Booking();
        booking.setCustomerUserId(customer.getId());
        booking.setMechanicId(mechanic.getId());
        booking.setCustomerName(customerName);
        booking.setCustomerPhone("9876543210");
        booking.setBikeModel("Honda Activa");
        booking.setBookingTime(LocalDateTime.of(2030, 5, 15, 10, 0));
        booking.setProblemDescription("Test problem");
        booking.setStatus("PENDING");
        return bookingRepository.save(booking);
    }
}