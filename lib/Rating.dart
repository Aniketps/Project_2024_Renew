import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Rating extends StatefulWidget {
  const Rating({super.key});

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Rating Details",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              height: 350,
              width: 350,
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black26,
                  spreadRadius: 1,
                    blurRadius: 1,
                  )
                ]

              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rating',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(color: Colors.redAccent),
                  Center(
                    child: Text(
                      'Average Rating',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                          width: 30, // Set the desired width
                          height: 30, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 8), // Space between image and text
                        Text(
                          '4.9/5', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the row
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                          width: 20, // Set the desired width
                          height: 20, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '5', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 200,
                          color: Colors.grey,


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 5,
                                width: 180,
                                color: Colors.green,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 5),

                        Text(
                          '556', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the row
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                          width: 20, // Set the desired width
                          height: 20, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '4', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 200,
                          color: Colors.grey,


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 5,
                                width: 140,
                                color: Colors.green,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 5),

                        Text(
                          '400', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),


                  SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the row
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                          width: 20, // Set the desired width
                          height: 20, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '3', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 200,
                          color: Colors.grey,


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 5,
                                width: 140,
                                color: Colors.green,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 5),

                        Text(
                          '005', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the row
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                          width: 20, // Set the desired width
                          height: 20, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '2', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 200,
                          color: Colors.grey,


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 5,
                                width: 40,
                                color: Colors.green,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 5),

                        Text(
                          '001', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the row
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                          width: 20, // Set the desired width
                          height: 20, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '1', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 200,
                          color: Colors.grey,


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 5,
                                width: 140,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 5),

                        Text(
                          '000', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),








                ],


              ),
            ),



            SizedBox(height: 255),
            Container(
              width: double.infinity,
              child: AppBar(
                backgroundColor: Colors.lightGreen,
              ),
            ),
          ],
        ),
      ),




    );
  }
}
