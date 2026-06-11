package com.example.mechconnect.dto;

public class AuthResponseDTO {

    public String token;
    public String role;

    public AuthResponseDTO(String token, String role){
        this.token=token;
        this.role=role;
    }

    public String getToken() {
        return token; 
    }
    public String getRole() { 
        return role; 
    }
}
