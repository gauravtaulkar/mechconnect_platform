package com.example.mechconnect.controller;

import com.example.mechconnect.dto.MechanicProfileDTO;
import com.example.mechconnect.entity.Mechanic;
import com.example.mechconnect.entity.User;
import com.example.mechconnect.service.AuthService;
import com.example.mechconnect.service.MechanicService;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mechanics")
public class MechanicController {

    private final MechanicService mechanicService;
    private final AuthService authService;

    public MechanicController(MechanicService mechanicService, AuthService authService) {
        this.mechanicService = mechanicService;
        this.authService = authService;
    }

    @GetMapping
    public List<Mechanic> getAllMechanics() {
        return mechanicService.getAllMechanics();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Mechanic> getMechanicById(@PathVariable Long id) {
        return mechanicService.getMechanicById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/search/city")
    public List<Mechanic> searchMechanicsByCity(@RequestParam String city) {
        return mechanicService.getMechanicsByCity(city);
    }

    @GetMapping("/search/available")
    public List<Mechanic> searchAvailableMechanics(@RequestParam String city, @RequestParam boolean available) {
        return mechanicService.getMechanicByCityAndAvailable(city, available);
    }

    // ---- NEW: "my shop" endpoints used by the mechanic-side app screens ----

    @GetMapping("/me")
    @PreAuthorize("hasRole('MECHANIC')")
    public ResponseEntity<?> getMyProfile(Authentication authentication) {
        Long userId = currentUserId(authentication);
        return mechanicService.getMyProfile(userId)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(404)
                        .body(Map.of("error", "No shop profile yet — create one first")));
    }

    @PostMapping("/me")
    @PreAuthorize("hasRole('MECHANIC')")
    public ResponseEntity<Mechanic> saveMyProfile(Authentication authentication,
                                                   @Valid @RequestBody MechanicProfileDTO dto) {
        Long userId = currentUserId(authentication);
        return ResponseEntity.ok(mechanicService.saveMyProfile(userId, dto));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('MECHANIC','ADMIN')")
    public ResponseEntity<Void> deleteMechanic(@PathVariable Long id) {
        mechanicService.deleteMechanic(id);
        return ResponseEntity.noContent().build();
    }

    private Long currentUserId(Authentication authentication) {
        User user = authService.getByEmail(authentication.getName());
        return user.getId();
    }
}
