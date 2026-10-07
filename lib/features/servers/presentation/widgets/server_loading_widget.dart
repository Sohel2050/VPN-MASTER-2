import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:winsguard/features/servers/presentation/widgets/item_view/server_item_view.dart';

/// A widget that displays a skeleton loading animation for the server list.
class ServerLoadingWidget extends StatelessWidget {
  /// Creates a [ServerLoadingWidget].
  const ServerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return const ServerItemView(
              flag: "assets/flags/au.png",
              country: "United Kingdom",
              speed: "256 Mbps",
              ping: "12 Ms",
              users: "143",
              isSelected: false
          );
        }
      ),
    );
  }
}
