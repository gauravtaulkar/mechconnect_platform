package com.example.mechconnect;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.example.mechconnect.repository")
public class MechconnectApplication {

    public static void main(String[] args) {
        SpringApplication.run(MechconnectApplication.class, args);
    }

}