package com.example.mechconnect.service;

import com.example.mechconnect.dto.MechanicProfileDTO;
import com.example.mechconnect.entity.Mechanic;
import com.example.mechconnect.repository.MechanicRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MechanicService {

    private final MechanicRepository mechanicRepository;

    public MechanicService(MechanicRepository mechanicRepository) {
        this.mechanicRepository = mechanicRepository;
    }

    public List<Mechanic> getAllMechanics() {
        return mechanicRepository.findAll();
    }

    public Optional<Mechanic> getMechanicById(Long id) {
        return mechanicRepository.findById(id);
    }

    // FIX: was exact-match + case-sensitive before, silently returning
    // nothing for "pune" vs a seeded "Pune".
    public List<Mechanic> getMechanicsByCity(String city) {
        return mechanicRepository.findByCityContainingIgnoreCase(city);
    }

    public List<Mechanic> getMechanicByCityAndAvailable(String city, boolean available) {
        return mechanicRepository.findByCityContainingIgnoreCaseAndAvailable(city, available);
    }

    public Optional<Mechanic> getMyProfile(Long userId) {
        return mechanicRepository.findByUserId(userId);
    }

    // NEW: create-or-update the shop profile belonging to the currently
    // authenticated mechanic. userId always comes from the server side
    // (the JWT), never from the request body, so one mechanic can never
    // overwrite another mechanic's shop.
    public Mechanic saveMyProfile(Long userId, MechanicProfileDTO dto) {
        Mechanic mechanic = mechanicRepository.findByUserId(userId).orElseGet(Mechanic::new);
        mechanic.setUserId(userId);
        mechanic.setName(dto.getName());
        mechanic.setShopName(dto.getShopName());
        mechanic.setCity(dto.getCity());
        mechanic.setStreet(dto.getStreet());
        mechanic.setLatitude(dto.getLatitude());
        mechanic.setLongitude(dto.getLongitude());
        mechanic.setPhone(dto.getPhone());
        mechanic.setExperience(dto.getExperience());
        mechanic.setExpertise(dto.getExpertise());
        mechanic.setAvailable(dto.isAvailable());
        mechanic.setOpeningTime(dto.getOpeningTime());
        mechanic.setClosingTime(dto.getClosingTime());
        return mechanicRepository.save(mechanic);
    }

    public void deleteMechanic(Long id) {
        mechanicRepository.deleteById(id);
    }
}
