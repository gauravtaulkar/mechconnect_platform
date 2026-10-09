
package com.example.mechconnect.service;

import com.example.mechconnect.dto.MechanicProfileDTO;
import com.example.mechconnect.entity.Mechanic;
import com.example.mechconnect.repository.MechanicRepository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MechanicServiceTest {

    @Mock
    private MechanicRepository mechanicRepository;

    @InjectMocks
    private MechanicService mechanicService;

    private Mechanic mechanic;

    @BeforeEach
    void setUp() {
        mechanic = new Mechanic();
        mechanic.setId(10L);
        mechanic.setUserId(100L);
        mechanic.setName("Test Mechanic");
        mechanic.setShopName("Test Garage");
        mechanic.setCity("Pune");
        mechanic.setAvailable(true);
        mechanic.setOpeningTime(LocalTime.of(9, 0));
        mechanic.setClosingTime(LocalTime.of(18, 0));
    }

    @Test
    void getAllMechanicsReturnsRepositoryResults() {
        when(mechanicRepository.findAll()).thenReturn(List.of(mechanic));

        List<Mechanic> result = mechanicService.getAllMechanics();

        assertEquals(1, result.size());
        assertEquals("Test Garage", result.get(0).getShopName());
        verify(mechanicRepository).findAll();
    }

    @Test
    void getMechanicByIdReturnsMatchingMechanic() {
        when(mechanicRepository.findById(10L))
                .thenReturn(Optional.of(mechanic));

        Optional<Mechanic> result = mechanicService.getMechanicById(10L);

        assertTrue(result.isPresent());
        assertEquals(10L, result.get().getId());
    }

    @Test
    void getMechanicByIdReturnsEmptyWhenNotFound() {
        when(mechanicRepository.findById(999L))
                .thenReturn(Optional.empty());

        assertTrue(mechanicService.getMechanicById(999L).isEmpty());
    }

    @Test
    void getMechanicsByCityUsesCaseInsensitivePartialSearch() {
        when(mechanicRepository.findByCityContainingIgnoreCase("pun"))
                .thenReturn(List.of(mechanic));

        List<Mechanic> result = mechanicService.getMechanicsByCity("pun");

        assertEquals(1, result.size());
        assertEquals("Pune", result.get(0).getCity());
        verify(mechanicRepository)
                .findByCityContainingIgnoreCase("pun");
    }

    @Test
    void getMechanicByCityAndAvailableUsesBothFilters() {
        when(mechanicRepository
                .findByCityContainingIgnoreCaseAndAvailable("Pune", true))
                .thenReturn(List.of(mechanic));

        List<Mechanic> result =
                mechanicService.getMechanicByCityAndAvailable("Pune", true);

        assertEquals(1, result.size());
        assertTrue(result.get(0).isAvailable());
        verify(mechanicRepository)
                .findByCityContainingIgnoreCaseAndAvailable("Pune", true);
    }

    @Test
    void getMyProfileReturnsProfileForUserId() {
        when(mechanicRepository.findByUserId(100L))
                .thenReturn(Optional.of(mechanic));

        Optional<Mechanic> result = mechanicService.getMyProfile(100L);

        assertTrue(result.isPresent());
        assertEquals(100L, result.get().getUserId());
    }

    @Test
    void getMyProfileReturnsEmptyWhenProfileDoesNotExist() {
        when(mechanicRepository.findByUserId(200L))
                .thenReturn(Optional.empty());

        assertTrue(mechanicService.getMyProfile(200L).isEmpty());
    }

    @Test
    void saveMyProfileCreatesProfileForAuthenticatedUser() {
        MechanicProfileDTO dto = validProfileDTO();

        when(mechanicRepository.findByUserId(200L))
                .thenReturn(Optional.empty());

        when(mechanicRepository.save(any(Mechanic.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        Mechanic result = mechanicService.saveMyProfile(200L, dto);

        assertEquals(200L, result.getUserId());
        assertEquals(dto.getName(), result.getName());
        assertEquals(dto.getShopName(), result.getShopName());
        assertEquals(dto.getCity(), result.getCity());
        verify(mechanicRepository).save(any(Mechanic.class));
    }

    @Test
    void saveMyProfileUpdatesExistingUsersProfile() {
        MechanicProfileDTO dto = validProfileDTO();
        dto.setShopName("Updated Garage");

        when(mechanicRepository.findByUserId(100L))
                .thenReturn(Optional.of(mechanic));

        when(mechanicRepository.save(any(Mechanic.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        Mechanic result = mechanicService.saveMyProfile(100L, dto);

        assertSame(mechanic, result);
        assertEquals(100L, result.getUserId());
        assertEquals("Updated Garage", result.getShopName());
        verify(mechanicRepository).save(mechanic);
    }

    @Test
    void deleteMechanicDelegatesToRepository() {
        mechanicService.deleteMechanic(10L);

        verify(mechanicRepository).deleteById(10L);
    }

    private MechanicProfileDTO validProfileDTO() {
        MechanicProfileDTO dto = new MechanicProfileDTO();
        dto.setName("Updated Mechanic");
        dto.setShopName("Updated Garage");
        dto.setCity("Pune");
        dto.setStreet("Main Road");
        dto.setLatitude(18.5204);
        dto.setLongitude(73.8567);
        dto.setPhone("9999999999");
        dto.setExperience(5);
        dto.setExpertise("Two-wheelers");
        dto.setAvailable(true);
        dto.setOpeningTime(LocalTime.of(9, 0));
        dto.setClosingTime(LocalTime.of(18, 0));
        return dto;
    }
}
