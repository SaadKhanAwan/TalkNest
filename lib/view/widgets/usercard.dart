import 'package:flutter/material.dart';
import 'package:talknest/responsiveness/sizes.dart';

class Usercard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String time;
  final Widget imagePath;
  final VoidCallback onTap;

  const Usercard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.time,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: ResponsiveSizes.width(context, .02), vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: ResponsiveSizes.width(context, .01), vertical: 5),
        child: ListTile(
          leading: CircleAvatar(radius: 30, child: imagePath),
          title: Text(name, style: Theme.of(context).textTheme.bodyLarge),
          subtitle:
              Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
          trailing: Text(time, style: Theme.of(context).textTheme.labelMedium),
        ),
      ),
    );
  }
}
