package com.example.mechconnect.dto;

public class AuthResponseDTO {

    public String token;
    public String role;
    public String name;

    public AuthResponseDTO(String token, String role, String name) {
        this.token = token;
        this.role = role;
        this.name = name;
    }

    public String getToken() { return token; }
    public String getRole() { return role; }
    public String getName() { return name; }
}
