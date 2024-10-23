import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RatingState extends StatefulWidget {
  const RatingState({super.key});

  @override
  State<RatingState> createState() => _RatingStateState();
}

class _RatingStateState extends State<RatingState> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(



      // appBar: AppBar(
      //    backgroundColor: Colors.blue,
      //    title: Text(
      //   "Rating Details",
      //    style: TextStyle(color: Colors.black),
      //  ),
      //  ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [




            Container(
              height: 150,
              color: Colors.blueAccent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppBar(
                    title: Center(
                      child: Text(
                        "Rating details",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ),
                    backgroundColor: Colors.blueAccent,
                    automaticallyImplyLeading: false,
                  ),
                ],
              ),
            ),


            Container(
              height: 310,
              width: 370,
              margin: EdgeInsets.all(9),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(color: Colors.lightBlueAccent),
                  Center(
                    child: Text(
                      'Average Rating',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR94RDNk0qy32zVqAkTeeSnn32U8rLoCL2zO5iGceJYT29Dgcrm5fDCgx78kRz_DgtX2AI&usqp=CAU',
                          width: 15, // Set the desired width
                          height: 15, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 8), // Space between image and text
                        Text(
                          '4.9/5', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
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
                          width: 15, // Set the desired width
                          height: 15, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '5', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 230,
                          color: Colors.grey,


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 5,
                                width: 190,
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
                            fontSize: 14,
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
                          width: 15, // Set the desired width
                          height: 15, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '4', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 230,
                          color: Colors.grey,


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 5,
                                width: 150,
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
                            fontSize: 14,
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
                          width: 15, // Set the desired width
                          height: 15, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '3', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 230,
                          color: Colors.grey,


                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start, // Center the row
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 5,
                                width: 120,
                                color: Colors.green,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 5),

                        Text(
                          '    5', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
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
                          width: 15, // Set the desired width
                          height: 15, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '2', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 230,
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
                          '    1', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
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
                          width: 15, // Set the desired width
                          height: 15, // Set the desired height
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '1', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 15),


                        Container(
                          height: 5,
                          width: 230,
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
                          '    0', // Replace with your rating value
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  ),








                ],


              ),
            ),



            // SizedBox(height: 215),
            // Container(
            //   width: double.infinity,
            //   child: AppBar(
            //     backgroundColor: Colors.lightGreen,
            //   ),
            // ),
          ],
        ),
      ),

    );
  }
}
