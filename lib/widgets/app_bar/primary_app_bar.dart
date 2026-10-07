import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:winsguard/core/theme/theme_cubit.dart';
import 'package:winsguard/core/utils/extensions/theme_extension.dart';
import 'package:winsguard/core/utils/styles/app_colors.dart';
import 'package:winsguard/core/utils/styles/app_text_styles.dart';
import 'package:winsguard/core/utils/ui_helpers/paddings.dart';

/// The main app bar for the application.
class PrimaryAppBar extends HookWidget {
  const PrimaryAppBar({super.key});

  @override
  Widget build(BuildContext context) {

    // Holds the application name.
    final appName = useState<String?>(null);

    // Access the theme cubit to handle theme changes.
    final themeCubit = context.read<ThemeCubit>();

    // Fetches and sets the application name.
    void getAppName() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appName.value = packageInfo.appName;
    }

    // Fetches the app name when the widget is initialized.
    useEffect((){
      getAppName();
      return null;
    },[]);

    // Defines the app bar's layout and widgets.
    return Padding(
      padding: paddingH12,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [

          // --- Menu Button ---
          // Opens the side drawer.
          Builder(
              builder: (context) {
                return IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: SvgPicture.asset(
                      "assets/icons/menu_icon.svg",
                      width: 18.w,
                      height: 18.w,
                      colorFilter: ColorFilter.mode(
                        context.colors.iconPrimary,
                        BlendMode.srcIn
                      ),
                    )
                );
              }
          ),


          // --- App Title ---
          // Displays the application name.
          Text(
            "${appName.value ?? ""} VPN".toUpperCase(),
            style: context.appBarTextStyles.copyWith(
              letterSpacing: 3,
              color: context.colors.primary,
            ),
          ),


          // --- Theme Toggle Button ---
          // Switches between light and dark themes.
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              return IconButton(
                  onPressed: themeCubit.changeTheme,
                  icon: Icon(
                    themeCubit.state == ThemeMode.dark ?
                    Icons.light_mode :
                    Icons.dark_mode,
                    color: AppColors.goldColor,
                    size: 30.sp,
                  )
              );
            },
          )

        ],
      ),
    );
  }
}
