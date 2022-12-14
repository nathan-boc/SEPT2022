import 'package:flutter/material.dart';
import '../Patient_Medical_Details/MedicalDetails_screen.dart';
import '../Patient_Prescribed_Medicine/Prescription_List_screen.dart';

class Profile_screen extends StatelessWidget{

  void onPressAppbarCancel() {
    
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          leading: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed:() {Navigator.pop(context);} ,
            ),
        ),
        body: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                title: const Text('Medical Details'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MedicalDetails_screen()));
                },
              )
            ),
            const Card(
              child: ListTile(
                title: Text('Personal Details'),
                
              )
            ),
            Card(
              child: ListTile(
                title: Text('My medicine'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Prescription_list_screen()));
                }
              )
            ),
            const Card(
              child: ListTile(
                title: Text('Contact Details'),
                
              )
            ),
            const Card(
              child: ListTile(
                title: Text('Settings'),
                
              )
            ),
            const Card(
              child: ListTile(
                title: Text('Sign Out'),
                
              )
            ),
          ]
        ),
      )  
    );
  }
}


