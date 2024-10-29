import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talknest/responsiveness/sizes.dart';

Widget buildShimmer(BuildContext context) {
  return Shimmer.fromColors(
    baseColor: Theme.of(context).colorScheme.onPrimaryContainer,
    highlightColor: Colors.grey[100]!,
    child: Container(
      margin: EdgeInsets.symmetric(
          horizontal: ResponsiveSizes.width(context, .03), vertical: 5),
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSizes.width(context, .02), vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          child: Container(
            width: 40,
            height: 40,
            color: Colors.grey[700],
          ),
        ),
        title: Container(
          width: double.infinity,
          height: 10,
          color: Colors.grey[700],
        ),
        subtitle: Container(
          width: 100,
          height: 10,
          color: Colors.grey[700],
        ),
      ),
    ),
  );
}
