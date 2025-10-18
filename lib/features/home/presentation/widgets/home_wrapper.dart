import 'package:eservelink/features/home/presentation/bloc/restaurant_bloc.dart';
import 'package:eservelink/features/home/presentation/bloc/restaurant_state.dart';
import 'package:eservelink/features/home/presentation/pages/home_page.dart';
import 'package:eservelink/features/home/presentation/pages/restaurant_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantShowDetail) {
          return RestaurantDetailPage(
            restaurant: state.restaurant,
            distance: state.distance,
            userLatitude: state.userLatitude,
            userLongitude: state.userLongitude,
          );
        }

        return const HomePage();
      },
    );
  }
}
