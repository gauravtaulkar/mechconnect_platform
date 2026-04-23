package com.example.mechconnect.controller;

import com.example.mechconnect.entity.Mechanic;

import com.example.mechconnect.service.MechanicService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;


import java.util.List;
import java.util.Optional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;



@CrossOrigin(origins = "http://localhost:3000")
@RestController
@RequestMapping("/api/mechanics")
public class MechanicController {


    @Autowired
    private MechanicService mechanicService;


    @PostMapping
    public Mechanic createMechanic(@RequestBody Mechanic mechanic) {
        return mechanicService.createMechanic(mechanic);
    }

    @GetMapping
    public List<Mechanic> getAllMechanics() {
        return mechanicService.getAllMechanics();
    }
     // READ ONE
    @GetMapping("/{id}")
    public Optional<Mechanic> getMechanicById(@PathVariable Long id) {
        return mechanicService.getMechanicById(id);
    }


    //update data
    @PutMapping("{id}")
    public Mechanic updatMechanic(@PathVariable Long id, @RequestBody Mechanic mechanic) {

        return mechanicService.updatMechanic(id,mechanic);
    }

    //delete
    @DeleteMapping("/{id}")
    public String deleteMechanic(@PathVariable Long id){
         mechanicService.deleteMechanic(id);
         return "Mechanic deleted successfully";

    }
    
    //get by city
    

    @GetMapping("/search/city")
    public List<Mechanic> searchMechanicsByCity(@RequestParam String city){
        return mechanicService.getMechanicsByCity(city);
    }
    
    @GetMapping("/search/available")
    public List<Mechanic> seachAvailableMechanics(@RequestParam String city, @RequestParam boolean available){
        return mechanicService.getMechanicByCityAndAvailable(city, available);
    }
    
    
    
}