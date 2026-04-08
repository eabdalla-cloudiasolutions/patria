import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppFieldTile extends StatelessWidget {
  final String text;
  final String prefixImage;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final VoidCallback? onSuffixTap;

  const AppFieldTile({
    super.key,
    required this.text,
    required this.prefixImage,
    this.suffixIcon,
    this.onTap,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: SvgPicture.asset(
          prefixImage,
          width: 24,
          height: 24,
        ),
        title: Text(
          text,
          maxLines: 3,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  size: 24,
                  color: const Color(0xFF20222F),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
      ),
    );
  }
}
