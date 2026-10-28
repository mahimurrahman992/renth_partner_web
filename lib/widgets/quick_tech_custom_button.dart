import '../../consts/consts.dart';

double _buttonHeight(double? height) {
  final double value = height ?? 45.h;
  return value.clamp(48.0, 60.0).toDouble();
}

Widget customButton({
  required String title,
  required onPressed,
  required color,
  txtColor,
  isLoading = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: _buttonHeight(null),
    child: MouseRegion(
      cursor: isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: Material(
        color: color,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    title.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: txtColor ?? gryBlack,
                    ),
                  ),
          ),
        ),
      ),
    ),
  );
}

Widget customButtonWithIcon({
  required String title,
  onPressed,
  required icons,
  backgroundColor,
  txtColor,
}) {
  return SizedBox(
    width: double.infinity,
    height: _buttonHeight(null),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: backgroundColor,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icons, width: 26, color: Colors.white),
              12.horizontalSpace,
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: txtColor ?? gryBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget customButton2({
  IconData? icon,
  String? title,
  Function()? onTap,
  bool? isLoading,
  double? height,
  Color? color,
  TextStyle? style,
  double? iconSize,
  Color? iconColor,
  Color? iconBackground
}) {
  final bool loading = isLoading == true;
  final Color background = color ?? mainColor;

  return SizedBox(
    width: double.infinity,
    height: _buttonHeight(height),
    child: MouseRegion(
      cursor: loading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: Material(
        color: background,
        elevation: 4,
        shadowColor: background.withValues(alpha:0.4),
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Container(
                          padding: EdgeInsets.all(6.r),
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconBackground??Colors.white.withValues(alpha:0.2),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? Colors.white,
                            size: iconSize ?? 18.sp,
                          ),
                        ),
                        12.horizontalSpace,
                      ],
                      Flexible(
                        child: Text(
                          title ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: style ?? QuickTechAppTextStyle.headline4(),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}