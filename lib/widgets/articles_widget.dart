import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proj45_restapi_newsapp/consts/vars.dart';
import 'package:proj45_restapi_newsapp/inner_screens/blog_details.dart';
import 'package:proj45_restapi_newsapp/inner_screens/news_details_web.dart';
import 'package:proj45_restapi_newsapp/models/bookmarks_model.dart';
import 'package:proj45_restapi_newsapp/models/news_model.dart';
import 'package:proj45_restapi_newsapp/widgets/verical_spacing.dart';
import 'package:provider/provider.dart';

import '../inner_screens/bookmarks_screen.dart';
import '../providers/news_provider.dart';
import '../services/utils.dart';

class ArticlesWidget extends StatelessWidget {
  const ArticlesWidget({
    Key? key,
    this.isBookmark = false,
    // required this.imageUrl,
    // required this.title,
    // required this.url,
    // required this.dateToShow,
    // required this.readingTime,
  }) : super(key: key);
  final bool isBookmark;
  // final String imageUrl, title, url, dateToShow, readingTime;

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    dynamic newsModelProvider = isBookmark
        ? Provider.of<BookmarksModel>(context)
        : Provider.of<NewsModel>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Theme.of(context).cardColor,
        child: GestureDetector(
          onTap: () {
            // navigate to another screen
            Navigator.pushNamed(context, NewsDetailsScreen.routeName,
                arguments: newsModelProvider.publishedAt);
          },
          child: Stack(
            children: [
              Container(
                height: 60,
                width: 60,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 60,
                  width: 60,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Container(
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Hero(
                        tag: newsModelProvider.publishedAt,
                        child: FancyShimmerImage(
                          height: size.height * 0.12,
                          width: size.width * 0.12,
                          boxFit: BoxFit.fill,
                          imageUrl: newsModelProvider.urlToImage,
                          // "https://techcrunch.com/wp-content/uploads/2022/01/locket-app.jpg?w=1390&crop=1",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            newsModelProvider.title,
                            maxLines: 2,
                            textAlign: TextAlign.justify,
                            overflow: TextOverflow.ellipsis,
                            style: smallTextStyle,
                          ),
                          const VerticalSpacing(height: 5),
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              '${newsModelProvider.readingTimeText}',
                              style: smallTextStyle,
                            ),
                          ),
                          FittedBox(
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: NewsDetailsWebView(
                                                url: newsModelProvider.url),
                                            inheritTheme: true,
                                            ctx: context));
                                  },
                                  icon: const Icon(
                                    Icons.link,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  newsModelProvider.dateToShow,
                                  maxLines: 1,
                                  style: smallTextStyle,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
