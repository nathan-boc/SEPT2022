package com.mdonline.PrescriptionService.Medicine;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicineServiceImpl implements MedicineService {

    @Autowired
    private MedicineRepository repository;

    @Override
    public MedicineEntity saveMedicine(MedicineEntity medicineEntity) {
        return repository.save(medicineEntity);
    }

    @Override
    public MedicineEntity updateMedicine(MedicineEntity medicineEntity) {
        return repository.save(medicineEntity);
    }

    @Override
    public void deleteMedicine(MedicineEntity medicineEntity) {
        repository.delete(medicineEntity);
    }

    @Override
    public void deleteById(int id) { repository.deleteById(id); }

    @Override
    public MedicineEntity getMedicineById(int id) {
        return repository.findById(id).get();
    }

    @Override
    public MedicineEntity getMedicineByName(String name) {
        return repository.findByMedicineName(name);
    }

    @Override
    public List<MedicineEntity> getAllMedicines() {
        return repository.findAll();
    }
}