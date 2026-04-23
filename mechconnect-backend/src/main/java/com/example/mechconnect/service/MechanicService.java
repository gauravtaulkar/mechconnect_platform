package com.example.mechconnect.service;

import com.example.mechconnect.entity.Mechanic;
import com.example.mechconnect.repository.MechanicRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.util.List;
import java.util.Optional;



@Service
public class MechanicService {
    
    @Autowired
    private MechanicRepository mechanicRepository;

    public Mechanic createMechanic(Mechanic mechanic){
        return mechanicRepository.save(mechanic);
    }

    public List<Mechanic> getAllMechanics(){
        return mechanicRepository.findAll();
    }

    public Optional<Mechanic> getMechanicById(Long id){
        return mechanicRepository.findById(id);
    }

    public Mechanic updatMechanic(Long id, Mechanic mechanicDetails){

       Mechanic mechanic= mechanicRepository.findById(id).orElseThrow();

       mechanic.setName(mechanicDetails.getName());
       mechanic.setShopName(mechanicDetails.getShopName());
       mechanic.setCity(mechanicDetails.getCity());
       mechanic.setStreet(mechanicDetails.getStreet());
       mechanic.setLatitude(mechanicDetails.getLatitude());
       mechanic.setLongitude(mechanicDetails.getLongitude());
       mechanic.setPhone(mechanicDetails.getPhone());
       mechanic.setExperience(mechanicDetails.getExperience());
       mechanic.setExpertise(mechanicDetails.getExpertise());
       mechanic.setAvailable(mechanicDetails.isAvailable());

       return mechanicRepository.save(mechanic);
    }

    public void deleteMechanic(Long id){
        mechanicRepository.deleteById(id);
    }

    public List<Mechanic> getMechanicsByCity(String location){
        return mechanicRepository.findByCity(location);
    }

    public List<Mechanic> getMechanicByCityAndAvailable(String city, boolean available){
        return mechanicRepository.findByCityAndAvailable(city,available);
    }
}
