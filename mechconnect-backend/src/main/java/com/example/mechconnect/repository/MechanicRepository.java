package com.example.mechconnect.repository;

import com.example.mechconnect.entity.Mechanic;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;


public interface MechanicRepository extends JpaRepository<Mechanic, Long> {

    List<Mechanic> findByCity(String city);

    List<Mechanic> findByCityAndAvailable(String city, boolean available);
}