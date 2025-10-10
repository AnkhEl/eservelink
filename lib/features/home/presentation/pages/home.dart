import 'package:eservelink/core/util/app_styles.dart';
import 'package:eservelink/features/home/presentation/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 241, 241),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final userName =
                state.user.displayName ?? state.user.email.split('@')[0];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      child: Image.asset(
                        'assets/home.jpg',
                        width: MediaQuery.of(context).size.width,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 40, left: 20),
                      width: MediaQuery.of(context).size.width,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(90, 0, 0, 0),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "South Africa, Johannesburg",
                                style: AppStyles.whiteTextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Text(
                            "Hi $userName, tell us where you want to dine...",
                            style: AppStyles.whiteTextStyle(fontSize: 24),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.only(bottom: 5, top: 5),
                            margin: EdgeInsets.only(right: 20),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(103, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                hintText: "Search Places...",
                                hintStyle: AppStyles.whiteTextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text(
                    "The most relevant",
                    style: AppStyles.headingTextStyle(fontSize: 25),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 310,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      RestaurantCard(
                        imageAsset: 'assets/hotel1.jpg',
                        restaurantName: 'Hotel Beach',
                        location: 'Eastgate Mall',
                        rating: 1,
                      ),
                      RestaurantCard(
                        imageAsset: 'assets/hotel2.jpg',
                        restaurantName: 'Hotel Beach',
                        location: 'Eastgate Mall',
                        rating: 4,
                      ),
                      RestaurantCard(
                        imageAsset: 'assets/hotel3.jpg',
                        restaurantName: 'Hotel Beach',
                        location: 'Eastgate Mall',
                        rating: 2,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
