package com.mdonline.AccountService.Patient;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping(path="/api/v1/account/patient")
public class PatientController {

    private final PatientService patientService;

    @Autowired
    public PatientController(PatientService patientService){
        this.patientService = patientService;
    }

    // Returns a patient from specified ID
    @GetMapping(path="/{id}", consumes = "application/json", produces="application/json")
    @ResponseBody
    public Patient getPatientById(@PathVariable int id) {

        return patientService.getPatientById(id);

    }

    // Returns a list of ALL patients
    @GetMapping(path="/all", consumes = "application/json", produces="application/json")
    public List<Patient> getAllPatients() {
        return patientService.getAllPatient();
    }

    // Returns a patient from specified EMAIL
    @RequestMapping(path="/{email}", consumes = "application/json", produces="application/json")
    @ResponseBody
    public Patient getPatientByEmail(@PathVariable String email) {
        return patientService.getPatientByEmail(email);
    }

}