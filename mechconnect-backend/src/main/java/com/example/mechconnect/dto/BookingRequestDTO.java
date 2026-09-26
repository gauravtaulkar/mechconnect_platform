package com.example.mechconnect.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

// FIX: this DTO existed before but the controller was binding straight to the
// Booking entity, so none of this validation ever actually ran. It's now the
// real request body type for POST /api/bookings.
public class BookingRequestDTO {

    @NotNull(message = "Mechanic ID is required")
    private Long mechanicId;

    @NotBlank(message = "Customer name is required")
    private String customerName;

    @NotBlank(message = "Phone is required")
    private String customerPhone;

    @NotBlank(message = "Bike model is required")
    private String bikeModel;

    @NotNull(message = "Booking time is required")
    private LocalDateTime bookingTime;

    private String problemDescription;

    public Long getMechanicId() { return mechanicId; }
    public void setMechanicId(Long mechanicId) { this.mechanicId = mechanicId; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }
    public String getBikeModel() { return bikeModel; }
    public void setBikeModel(String bikeModel) { this.bikeModel = bikeModel; }
    public LocalDateTime getBookingTime() { return bookingTime; }
    public void setBookingTime(LocalDateTime bookingTime) { this.bookingTime = bookingTime; }
    public String getProblemDescription() { return problemDescription; }
    public void setProblemDescription(String problemDescription) { this.problemDescription = problemDescription; }
}
