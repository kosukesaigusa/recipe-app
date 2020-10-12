import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('contacts');

    return Scaffold(
      appBar: AppBar(title:Text('Listview'),),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return ListTile(
                title: Text(document.data()['title']),
                // subtitle: new Text(document.data()['inquiry']),
              );
            }).toList(),
          );
        },
      ),
    );
  }

}