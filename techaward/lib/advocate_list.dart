import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdvocateListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Advocates')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'advocate').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var advocates = snapshot.data!.docs;
          return ListView.builder(
            itemCount: advocates.length,
            itemBuilder: (context, index) {
              var advocate = advocates[index];
              return ListTile(
                title: Text(advocate['name']),
                subtitle: Text('Experience: ${advocate['experience']} years\nPrice: \$${advocate['price']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Implement booking functionality here
                  },
                  child: Text('Book Consultation'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
