package com.example.mechconnect.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalTime;

// NEW: request body for a mechanic creating/updating their OWN shop profile
// via POST/PUT /api/mechanics/me. Deliberately has no "id" or "userId" field
// — those are never trusted from the client, they come from the JWT.
public class MechanicProfileDTO {

    @NotBlank(message = "Name is required")
    private String name;

    @NotBlank(message = "Shop name is required")
    private String shopName;

    @NotBlank(message = "City is required")
    private String city;

    private String street;
    private double latitude;
    private double longitude;

    @NotBlank(message = "Phone is required")
    private String phone;

    private int experience;
    private String expertise;
    private boolean available = true;

    @NotNull(message = "Opening time is required")
    private LocalTime openingTime;

    @NotNull(message = "Closing time is required")
    private LocalTime closingTime;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getStreet() { return street; }
    public void setStreet(String street) { this.street = street; }
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public int getExperience() { return experience; }
    public void setExperience(int experience) { this.experience = experience; }
    public String getExpertise() { return expertise; }
    public void setExpertise(String expertise) { this.expertise = expertise; }
    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }
    public LocalTime getOpeningTime() { return openingTime; }
    public void setOpeningTime(LocalTime openingTime) { this.openingTime = openingTime; }
    public LocalTime getClosingTime() { return closingTime; }
    public void setClosingTime(LocalTime closingTime) { this.closingTime = closingTime; }
}
