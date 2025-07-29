import 'package:fitnessfuel/main.dart';
import 'package:fitnessfuel/provider/auth_provider.dart';
import 'package:fitnessfuel/responsive/screen_dimention.dart';
import 'package:fitnessfuel/utils/my_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthController>(context);

    List<String> getToKnowUs = [
      'About FitnessFuel',
      'Our Trainers',
      'Success Stories',
      'Terms & Conditions',
    ];

    List<String> letUsHelpYou = [
      'Membership Plans',
      'Workout Programs',
      'FAQs',
      'Support',
    ];

    List<IconData> socialIcons = [
      Icons.facebook,
      // Icons.instagram,
      Icons.youtube_searched_for,
      CupertinoIcons.mail,
    ];

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: mq.width > webScreenSize ? mq.width * .02 : 0,
      ),
      width: mq.width,
      decoration: BoxDecoration(
        color: MyColor.background,
        border: Border(top: BorderSide(color: MyColor.borderColor, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mq.width > webScreenSize)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'FitnessFuel',
                    style: TextStyle(
                      fontSize: mq.width > webScreenSize ? 46 : 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  '© 2025, FitnessFuel. All rights reserved.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          buildColumn('Get to Know Us', getToKnowUs),
          buildColumn('Let Us Help You', letUsHelpYou),
          if (mq.width > webScreenSize)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contact Us',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: socialIcons
                      .map(
                        (icon) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Icon(icon, size: 30),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: InkWell(
              onTap: () {},
              child: Text(item, style: TextStyle(fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }
}
