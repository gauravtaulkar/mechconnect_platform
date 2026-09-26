package com.example.mechconnect.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class BookingStatusDTO {

    @NotBlank
    @Pattern(regexp = "PENDING|CONFIRMED|CANCELLED|COMPLETED", message = "Invalid status")
    private String status;

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
