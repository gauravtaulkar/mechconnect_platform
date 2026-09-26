package com.example.mechconnect.repository;

import com.example.mechconnect.entity.Mechanic;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MechanicRepository extends JpaRepository<Mechanic, Long> {

    // FIX: original findByCity(String) was an exact, case-sensitive match,
    // so "pune" would not match a seeded "Pune" (depending on DB collation).
    // Using Containing + IgnoreCase makes city search forgiving, the way a
    // user actually expects a search box to behave.
    List<Mechanic> findByCityContainingIgnoreCase(String city);

    List<Mechanic> findByCityContainingIgnoreCaseAndAvailable(String city, boolean available);

    // FIX: needed so a logged-in mechanic can look up / manage their own shop.
    Optional<Mechanic> findByUserId(Long userId);
}
