import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eservelink/features/auth/presentation/bloc/auth_event.dart';
import 'package:eservelink/features/home/presentation/pages/Home.dart';
import 'package:eservelink/features/history/presentation/pages/history.dart';
import 'package:eservelink/features/profile/presentation/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> pages;

  late Home home;
  late History history;
  late Profile profile;

  int _currentTabIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    home = Home();
    history = History();
    profile = Profile();
    pages = [home, history, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       context.read<AuthBloc>().add(const SignOutEvent());
        //     },
        //     icon: Icon(Icons.logout, size: 30, color: Colors.black),
        //   ),
        // ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        height: 70,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: [
          Icon(Icons.home, color: Colors.white, size: 30),
          Icon(Icons.history, color: Colors.white, size: 30),
          Icon(Icons.person, color: Colors.white, size: 30),
        ],
      ),
      body: IndexedStack(index: _currentTabIndex, children: pages),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child:
            _currentTabIndex == 0
                ? FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.qr_code),
                )
                : null,
      ),
    );
  }
}
