
package com.example.mechconnect.service;

import com.example.mechconnect.dto.AuthRequestDTO;
import com.example.mechconnect.dto.AuthResponseDTO;
import com.example.mechconnect.dto.RegisterRequestDTO;
import com.example.mechconnect.entity.Role;
import com.example.mechconnect.entity.User;
import com.example.mechconnect.repository.UserRepository;
import com.example.mechconnect.security.JwtUtil;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtUtil jwtUtil;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthService authService;

    private User user;

    @BeforeEach
    void setUp() {
        user = new User();
        user.setName("Test User");
        user.setEmail("test@example.com");
        user.setPassword("encoded-password");
        user.setRole(Role.USER);
    }

    @Test
    void registerCreatesUserAndReturnsToken() {
        RegisterRequestDTO dto = validRegistration();

        when(userRepository.existsByEmail("test@example.com"))
                .thenReturn(false);
        when(passwordEncoder.encode("StrongPassword123"))
                .thenReturn("encoded-password");
        when(jwtUtil.generateToken("test@example.com"))
                .thenReturn("test-jwt");

        AuthResponseDTO result = authService.register(dto);

        assertEquals("test-jwt", result.getToken());
        assertEquals("USER", result.getRole());
        assertEquals("Test User", result.getName());

        ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(captor.capture());

        User savedUser = captor.getValue();
        assertEquals("test@example.com", savedUser.getEmail());
        assertEquals("encoded-password", savedUser.getPassword());
        assertEquals(Role.USER, savedUser.getRole());
    }

    @Test
    void registerDefaultsToUserRoleWhenRoleIsNull() {
        RegisterRequestDTO dto = validRegistration();
        dto.setRole(null);

        when(userRepository.existsByEmail("test@example.com"))
                .thenReturn(false);
        when(passwordEncoder.encode("StrongPassword123"))
                .thenReturn("encoded-password");
        when(jwtUtil.generateToken("test@example.com"))
                .thenReturn("test-jwt");

        authService.register(dto);

        ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
        verify(userRepository).save(captor.capture());

        assertEquals(Role.USER, captor.getValue().getRole());
    }

    @Test
    void registerRejectsExistingEmail() {
        when(userRepository.existsByEmail("test@example.com"))
                .thenReturn(true);

        assertThrows(
                IllegalStateException.class,
                () -> authService.register(validRegistration())
        );

        verify(userRepository, never()).save(any(User.class));
        verifyNoInteractions(passwordEncoder, jwtUtil);
    }

    @Test
    void loginReturnsTokenForValidCredentials() {
        AuthRequestDTO dto = validLogin();

        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(user));
        when(passwordEncoder.matches(
                "StrongPassword123", "encoded-password"))
                .thenReturn(true);
        when(jwtUtil.generateToken("test@example.com"))
                .thenReturn("test-jwt");

        AuthResponseDTO result = authService.login(dto);

        assertEquals("test-jwt", result.getToken());
        assertEquals("USER", result.getRole());
        assertEquals("Test User", result.getName());
    }

    @Test
    void loginRejectsUnknownEmail() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> authService.login(validLogin())
        );

        verifyNoInteractions(passwordEncoder, jwtUtil);
    }

    @Test
    void loginRejectsIncorrectPassword() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(user));
        when(passwordEncoder.matches(
                "StrongPassword123", "encoded-password"))
                .thenReturn(false);

        assertThrows(
                IllegalStateException.class,
                () -> authService.login(validLogin())
        );

        verify(userRepository).findByEmail("test@example.com");
        verify(jwtUtil, never()).generateToken(anyString());
    }

    @Test
    void getByEmailReturnsExistingUser() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(user));

        User result = authService.getByEmail("test@example.com");

        assertSame(user, result);
    }

    @Test
    void getByEmailThrowsWhenUserDoesNotExist() {
        when(userRepository.findByEmail("missing@example.com"))
                .thenReturn(Optional.empty());

        assertThrows(
                IllegalStateException.class,
                () -> authService.getByEmail("missing@example.com")
        );
    }

    private RegisterRequestDTO validRegistration() {
        RegisterRequestDTO dto = new RegisterRequestDTO();
        dto.setName("Test User");
        dto.setEmail("test@example.com");
        dto.setPassword("StrongPassword123");
        return dto;
    }

    private AuthRequestDTO validLogin() {
        AuthRequestDTO dto = new AuthRequestDTO();
        dto.setEmail("test@example.com");
        dto.setPassword("StrongPassword123");
        return dto;
    }
}
