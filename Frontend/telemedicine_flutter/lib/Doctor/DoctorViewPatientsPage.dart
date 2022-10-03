import 'package:flutter/material.dart';
import '../HelperFunctions.dart';
import 'package:http/http.dart' as http;
import '../Model/PatientModel.dart';
import '../Model/AppointmentModel.dart';
import '../Model/PrescriptionModel.dart';
import '../Model/MedicineModel.dart';
import '../Widgets/Accordion.dart';
import 'dart:convert';

// TODO : Temp until logged in doctor data can be retrieved
const int currentDoctorId = 4;

Future<List<Prescription>> fetchPrescriptions(String patientId) async {

  var url = "http://localhost:8085/api/v1/prescription/";

  var response = await http.get(Uri.parse(url),
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Accept": "application/json"
  });

  if(response.statusCode == 200) {

    var jsonData = json.decode(response.body);

    List<Prescription> prescriptions = [];
    
    // Iterate through all users, only adding patient user types
    for(int i = 0; i < jsonData.length; i++) {

      if(jsonData[i]["patientId"] == patientId) {
        prescriptions.add(Prescription.fromJson(jsonData[i]));
      }
    }

    return prescriptions;

  } else {
    throw Exception("Failed to load prescriptions.");
  }
}

Future<List<Medicine>> fetchMedicines() async {

  var url = "http://localhost:8085/api/v1/medicine/";

  var response = await http.get(Uri.parse(url),
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Accept": "application/json"
  });

  if(response.statusCode == 200) {

    var jsonData = json.decode(response.body);

    List<Medicine> medicines = [];
    
    // Iterate through all users, only adding patient user types
    for(int i = 0; i < jsonData.length; i++) {
      medicines.add(Medicine.fromJson(jsonData[i]));
    }

    return medicines;

  } else {
    throw Exception("Failed to load medicines.");
  }
}

Future<List<Appointment>> fetchAppointments() async {

  var url = "http://localhost:8082/api/v1/appointment/";

  var response = await http.get(Uri.parse(url),
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Accept": "application/json"
  });

  if(response.statusCode == 200) {

    var jsonData = json.decode(response.body);

    List<Appointment> appointments = [];
    
    // Iterate through all users, only adding patient user types
    for(int i = 0; i < jsonData.length; i++) {

      if(jsonData[i]["doctorId"] == currentDoctorId.toString()) {
        appointments.add(Appointment.fromJson(jsonData[i]));
      }
    }

    return appointments;

  } else {
    throw Exception("Failed to load appointments.");
  }
}

Future<List<Patient>> fetchPatients(Future<List<Appointment>> appointments) async {

  var url = "http://localhost:8081/api/v1/users";

  var response = await http.get(Uri.parse(url),
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Accept": "application/json"
  });

  if(response.statusCode == 200) {

    var jsonData = json.decode(response.body);

    List<Appointment> myAppointments = await appointments;

    List<Patient> patients = [];
    
    // Iterate through all users, only adding patient user types
    for(int i = 0; i < jsonData["messages"].length; i++) {

      // Check if user type is a patient
      if(jsonData["messages"][i]["userType"] == "Patient") {

        // Check to see if patient has had an appointment with the current doctor
        for(int j = 0; j < myAppointments.length; j++) {
          if(myAppointments.elementAt(j).getPatientId == jsonData["messages"][i]["id"].toString()) {
            patients.add(Patient.fromJson(jsonData["messages"][i]));
            break;
          }
        }
      }
    }

    return patients;

  } else {
    throw Exception("Failed to load patients.");
  }
}

Future<Prescription> createPrescription(Prescription prescription) async {
  
  final response = await http.post(

    Uri.parse('http://localhost:8085/api/v1/prescription/'),
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*"
    },

    // Convert the prescription to JSON
    body: jsonEncode(prescription.toJson())
  );

  print(jsonEncode(prescription.toJson()));

  if (response.statusCode == 201) {
    // Produce the JSOn when creation is successful
    return Prescription.fromJson(jsonDecode(response.body));

  } else {
    throw Exception('Failed to create prescription.');
  }
}

class _DoctorViewPatientsPageState extends State<DoctorViewPatientsPage> {
  late Future<List<Patient>> futurePatients;
  late Future<List<Appointment>> futureAppointments;

  @override
  void initState() {
    super.initState();
    futureAppointments = fetchAppointments();
    futurePatients = fetchPatients(futureAppointments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Patients")),
      body: FutureBuilder<List<Patient>>(
        future: futurePatients,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color.fromARGB(255, 47, 47, 47))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column( 
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text('${snapshot.data![index].getFirstName} ${snapshot.data![index].getMiddleName} ${snapshot.data![index].getLastName}'),
                          Text('ID: ${snapshot.data![index].getId.toString()}')
                        ]),

                        Row( children: [
                          
                          // Button for managing and viewing the patient details
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: SizedBox(
                              width: screenWidth(context) * 0.15,
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.lightBlue[800],
                                  textStyle: const TextStyle(
                                    fontSize: 10, fontFamily: 'Georgia'
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    // TODO link this up to register account page
                                    context, MaterialPageRoute(builder: (context) => DetailsPatientScreen(patient: snapshot.data![index])));
                                },
                                child: const Text("Details")
                              ),
                            ),
                          ),

                          // Button for viewing the patient prescriptions
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: SizedBox(
                              width: screenWidth(context) * 0.15,
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.orange,
                                  textStyle: const TextStyle(
                                    fontSize: 10, fontFamily: 'Georgia'
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    // TODO link this up to register account page
                                    context, MaterialPageRoute(builder: (context) => DoctorViewPatientPrescriptionPage(patient: snapshot.data![index])));
                                },
                                child: const Text("Prescriptions")
                              ),
                            ),
                          )

                        ])
                      ]
                    ),
                  ),
                );
              }
            );

          } else if(snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // Show loading spinner by default
          return const CircularProgressIndicator();
        }

      ),
    );
  }
}

// Widget for viewing list of patients
class DoctorViewPatientsPage extends StatefulWidget {
  const DoctorViewPatientsPage({super.key});

  @override
  createState() => _DoctorViewPatientsPageState();
}

// Widget for adding a patient prescription
class DoctorAddPrescriptionPage extends StatefulWidget {
  const DoctorAddPrescriptionPage({super.key, required this.patient});

  final Patient patient;

  @override
  createState() => DoctorAddPrescriptionState();
}

// State for adding a patient prescription
class DoctorAddPrescriptionState extends State<DoctorAddPrescriptionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String id = "0";
  late String duration;
  late String description;
  late List<Medicine> medicines;
  late DateTime date;
  late String doctorId;
  late String patientId;

  late Future<List<Medicine>> futureMedicines;

  @override
  void initState() {
    super.initState();
    futureMedicines = fetchMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Prescription for ${widget.patient.getFirstName} ${widget.patient.getMiddleName} ${widget.patient.getLastName}')
      ),

      body: Column( children: [
        Expanded(
          child: FutureBuilder<List<Medicine>>(
            future: futureMedicines,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {

                      return Column( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Medicine ID: ${snapshot.data![index].getId}'),
                          Text('Name: ${snapshot.data![index].getName}'),
                          Text('Description: ${snapshot.data![index].getDescription}'),
                          Text('Dosage: ${snapshot.data![index].getDosage}'),
                      ]);
                    }
                  ),
                );

              } else if(snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // Show loading spinner by default
              return const CircularProgressIndicator(); 
            }
          ),
        ),

        Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                  child: SizedBox(
                    width: screenWidth(context) * 0.6,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Duration',
                      ),
                      
                      validator: (value) {
                        if(value == null || value.isEmpty) {
                          return 'Please enter a prescription duration';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if(value != null) {
                          
                          duration = value;
                        
                        }
                      },                    
                    )
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                  child: SizedBox(
                    width: screenWidth(context) * 0.6,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Description',
                      ),
                      
                      validator: (value) {
                        if(value == null || value.isEmpty) {
                          return 'Please enter a prescription description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if(value != null) {
                          description = value;
                        }
                      },                    
                    )
                  ),
                ),

              
                      // Form submission button
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 0, 30),
                  child: SizedBox(
                    width: screenWidth(context) * 0.4,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if(_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          date = DateTime.now();
                          doctorId = currentDoctorId.toString();;
                          patientId = widget.patient.getId.toString();
                          medicines = [];

                          //duration = "5";
                          
                          //description = "I treid";

                          // Call the POST request method to create the prescription
                          createPrescription(Prescription(id, medicines, duration, description, date, doctorId, patientId));

                          print("Prescription went thru!");
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorViewPatientPrescriptionPage(patient: widget.patient)));
                        }
                      },
                      child: const Text("Create Prescription")
                    ),
                  ),
                )
                    
                    
                  
              ])
          )
        ),
      ])
      
      
      
      
      
    );
  }
}

// Widget for viewing patient's prescriptions
class DoctorViewPatientPrescriptionPage extends StatefulWidget {
  const DoctorViewPatientPrescriptionPage({super.key, required this.patient});

  final Patient patient;

  @override
  createState() => PrescriptionsPatientState();
}

// Screen for viewing patient prescriptions
class PrescriptionsPatientState extends State<DoctorViewPatientPrescriptionPage> {

  late Future<List<Prescription>> futurePrescriptions;

  @override
  void initState() {
    super.initState();
    futurePrescriptions = fetchPrescriptions(widget.patient.getId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient.getFirstName} ${widget.patient.getMiddleName} ${widget.patient.getLastName}')
      ),
      body:
        FutureBuilder<List<Prescription>>(
          future: futurePrescriptions,
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              
              // List of all current patient prescriptions
              return Column( children: [

                // Button for adding a new prescription
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: SizedBox(
                    width: screenWidth(context) * 0.15,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                        textStyle: const TextStyle(
                          fontSize: 10, fontFamily: 'Georgia'
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context, MaterialPageRoute(builder: (context) => DoctorAddPrescriptionPage(patient: widget.patient)));
                      },
                      child: const Text("New Prescription")
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 0, 30),
                        child: Column( 
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text('Prescription ID: ${snapshot.data![index].getId}'),
                          Text('Duration: ${snapshot.data![index].getDuration}'),
                          Text('Description: ${snapshot.data![index].getDescription}'),
                          Text('Prescribed On: ${snapshot.data![index].getDate.toString()}'),
                          Text('Prescribing Doctor ID: ${snapshot.data![index].getDoctorId}'),

                          Accordion(
                            title: 'View Medicines',
                            medicineList: snapshot.data![index].getMedicines,
                          )

                        ]),
                      );
                    }
                  ),
                ),
              ]);

            } else if(snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // Show loading spinner by default
            return const CircularProgressIndicator();
          }
        )
    );
  }
}

// Screen for viewing patient details
class DetailsPatientScreen extends StatelessWidget {

  const DetailsPatientScreen({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.getFirstName} ${patient.getMiddleName} ${patient.getLastName}')
      ),
      body: ListView( children: [
        Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient ID: ${patient.getId.toString()}'),
            Text('Name: ${patient.getFirstName} ${patient.getMiddleName} ${patient.getLastName}'),
            Text('Gender: ${patient.getGender}'),
            Text('DOB: ${patient.getBirth}'),
            Text('Email: ${patient.getEmail}'),
            Text('Phone: ${patient.getPhone}'),
            Text('Health Status: ${patient.getHealthStatus}'),
            Text('Health Information: ${patient.getHealthInformation}'),
            Text('Height: ${patient.getHeight.toString()}cm'),
            Text('Weight: ${patient.getWeight.toString()}kg'),
          ]
        )
      ])
    );
  }
}
