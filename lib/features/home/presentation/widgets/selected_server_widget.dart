import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vpn_master/core/helpers/helpers.dart';
import 'package:vpn_master/core/utils/extensions/null_empty_extension.dart';
import 'package:vpn_master/core/utils/extensions/status_extension.dart';
import 'package:vpn_master/core/utils/extensions/theme_extension.dart';
import 'package:vpn_master/core/utils/styles/app_text_styles.dart';
import 'package:vpn_master/core/utils/ui_helpers/paddings.dart';
import 'package:vpn_master/core/utils/ui_helpers/radius.dart';
import 'package:vpn_master/core/utils/ui_helpers/spacing.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_bloc.dart';
import 'package:vpn_master/features/servers/presentation/bloc/servers_event.dart';
import 'package:vpn_master/features/servers/presentation/page/servers_page.dart';

/// A widget that displays the currently selected VPN server and allows navigation to the server list.
class SelectedServerWidget extends HookWidget {
  /// Creates a [SelectedServerWidget].
  const SelectedServerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServersBloc, ServersState>(
      // The listener is triggered only once when servers are successfully loaded.
      listenWhen: (previous, current)=> previous.status.isLoading && current.status.isSuccess,
      // Sets a default server if none is selected after the server list is fetched.
      listener: (context, state){
        if(state.selectedServer.isNullOrEmpty){
          context.read<ServersBloc>().add(DefaultServer(servers: state.vpnServers ?? []));
        }
      },
      builder: (context, state) {
        // Displays a skeleton loading animation while server data is being fetched.
        return Skeletonizer(
          enabled: state.status.isLoading,
          child: InkWell(
            // Navigates to the server selection page on tap.
            onTap: () => context.push(ServersPage.path),
            splashColor: const Color(0xFFD4AF37),
            borderRadius: radius12,
            splashFactory: InkRipple.splashFactory,
            child: Container(
              width: 1.sw,
              padding: padding12,
              decoration: BoxDecoration(
                  borderRadius: radius12,
                  border: Border.all(
                      color: const Color(0xFFD4AF37)
                  )
              ),
              child: Row(
                children: [

                  // Displays the country flag of the selected server.
                  ClipRRect(
                    borderRadius: radiusCircle,
                    child: Image.asset(
                      "assets/flags/${(state.selectedServer?.countryShort ?? "au").toLowerCase()}.png",
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.public, size: 40.w),
                    ),
                  ),

                  gap12,

                  // Displays the server's country and speed.
                  Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.selectedServer?.countryLong ?? "United Kingdom",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                      ),


                      Row(
                        children: [
                          Icon(
                            Icons.signal_cellular_alt_rounded,
                            color: context.colors.primary,
                            size: 18.sp,
                          ),

                          gap6,

                          Text(
                            Helpers.speedFromBitsPerSecond(state.selectedServer?.speed ?? 0),
                            style: context.caption,
                          ),
                        ],
                      ),

                    ],
                  ),
                  ),

                  // An icon indicating that the widget is tappable.
                  Icon(
                    Icons.arrow_forward_ios,
                    color: context.colors.iconPrimary,
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
