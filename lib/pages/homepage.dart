import 'package:flutter/material.dart';
import 'package:task_crudfirebase/pages/create.dart';
import 'package:task_crudfirebase/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_crudfirebase/pages/update.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Home Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreatePage()));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var car = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.fromLTRB(
                  16,
                  index == 0 ? 16 : 8,
                  16,
                  index == snapshot.data!.docs.length - 1 ? 80 : 8,
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.network(
                        car['image'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car['nama'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              car['description'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            ButtonBar(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // mengarahkan ke halaman update dengan membawa id dokumen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdatePage(
                                          cars: car.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text('Update'),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                      (states) {
                                        return Colors.black;
                                      },
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // menampilkan dialog konfirmasi sebelum menghapus dokumen
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Delete Confirmation'),
                                          content: Text(
                                              'Are you sure you want to delete this car?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Delete'),
                                              onPressed: () async {
                                                // menghapus dokumen dengan id yang sesuai dengan dokumen yang ditekan tombol hapus
                                                await FirebaseFirestore.instance
                                                    .collection('cars')
                                                    .doc(car.id)
                                                    .delete();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text('Delete'),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                      (states) {
                                        return Colors.red;
                                      },
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
