package com.example.mechconnect.entity;

import jakarta.persistence.*;
import java.time.LocalTime;

@Entity
public class Mechanic {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String shopName;
    private String city;
    private String street;

    private double latitude;
    private double longitude;
    private String phone;
    private int experience;
    private String expertise;
    private boolean available;

    private LocalTime openingTime;
    private LocalTime closingTime;

    public Mechanic() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }
    public String getStreet() {
        return street;
    }
     public void setStreet(String street) {
        this.street = street;
    }
    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getExperience() {
        return experience;
    }

    public void setExperience(int experience) {
        this.experience = experience;
    }

    public String getExpertise() {
        return expertise;
    }

    public void setExpertise(String expertise) {
        this.expertise = expertise;
    }

    public boolean isAvailable() {
        return available;
    }

    public void setAvailable(boolean available) {
        this.available = available;
    }

    public LocalTime getOpeningTime(){
        return openingTime;
    }

    public void setOpeningTime(LocalTime openingTime){
        this.openingTime=openingTime;
    }

     public LocalTime getClosingTime(){
        return closingTime;
    }

    public void setClosingTime(LocalTime closingTime){
        this.closingTime=closingTime;
    }

}