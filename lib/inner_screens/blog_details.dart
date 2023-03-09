import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proj45_restapi_newsapp/models/bookmarks_model.dart';
import 'package:proj45_restapi_newsapp/providers/bookmarks_provider.dart';
import 'package:proj45_restapi_newsapp/providers/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../consts/styles.dart';

import '../models/news_model.dart';
import '../services/global_methods.dart';
import '../services/utils.dart';
import '../widgets/verical_spacing.dart';

class NewsDetailsScreen extends StatefulWidget {
  static const routeName = "/NewsDetailsScreen";
  const NewsDetailsScreen({Key? key}) : super(key: key);

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  bool isInBookmark = false;
  String? publishedAt;
  dynamic currBookmark;

  @override
  void didChangeDependencies() {
    publishedAt = ModalRoute.of(context)!.settings.arguments as String;
    final List<BookmarksModel> bookmarkList =
        Provider.of<BookmarksProvider>(context).getBookmarkList;
    if (bookmarkList.isEmpty) {
      return;
    }
    currBookmark = bookmarkList
        .where((element) => element.publishedAt == publishedAt)
        .toList();
    if (currBookmark.isEmpty) {
      isInBookmark = false;
    } else {
      isInBookmark = true;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final color = Utils(context).getColor;
    final newsProvider = Provider.of<NewsProvider>(context);
    final bookmarksProvider = Provider.of<BookmarksProvider>(context);
    final publishedAt = ModalRoute.of(context)?.settings.arguments as String;
    final currentNews = newsProvider.findByDate(publishedAt: publishedAt);
    // final newsModelProvider = Provider.of<NewsModel>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: color),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          "By ${currentNews.authorName}",
          textAlign: TextAlign.center,
          style: TextStyle(color: color),
        ),
        // leading: IconButton(
        //   icon: Icon(
        //     IconlyLight.arrowLeft,
        //     color: color,
        //   ),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentNews.title,
                  textAlign: TextAlign.justify,
                  style: titleTextStyle,
                ),
                const VerticalSpacing(height: 25),
                Row(
                  children: [
                    Text(
                      currentNews.dateToShow,
                      style: smallTextStyle,
                    ),
                    const Spacer(),
                    Text(
                      currentNews.readingTimeText,
                      style: smallTextStyle,
                    ),
                  ],
                ),
                const VerticalSpacing(height: 20),
              ],
            ),
          ),
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Hero(
                    tag: currentNews.publishedAt,
                    child: FancyShimmerImage(
                      boxFit: BoxFit.fill,
                      errorWidget: Image.asset('assets/images/empty_image.png'),
                      imageUrl: currentNews.urlToImage,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            await Share.share(currentNews.url,
                                subject: 'Look what I made!');
                          } catch (e) {
                            GlobalMethods.errorDialog(
                                errorMessage: e.toString(), context: context);
                          }
                        },
                        child: Card(
                          elevation: 10,
                          shape: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              IconlyLight.send,
                              size: 28,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (!isInBookmark) {
                            await bookmarksProvider.deleteBookMark(
                                key: currBookmark[0].bookmarkKey);
                          } else {
                            await bookmarksProvider.addToBookmark(
                                newsModel: currentNews);
                          }
                          await bookmarksProvider.fetchBookmarks();
                        },
                        child: Card(
                          elevation: 10,
                          shape: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              isInBookmark
                                  ? IconlyBold.bookmark
                                  : IconlyLight.bookmark,
                              size: 28,
                              color: isInBookmark ? Colors.green : color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const VerticalSpacing(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextContent(
                  label: "Description",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const VerticalSpacing(height: 10),
                TextContent(
                  label: currentNews.description,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                const VerticalSpacing(height: 20),
                const TextContent(
                  label: 'Contents',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                const VerticalSpacing(height: 10),
                TextContent(
                  label: currentNews.content,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextContent extends StatelessWidget {
  const TextContent({
    Key? key,
    required this.label,
    required this.fontSize,
    required this.fontWeight,
  }) : super(key: key);

  final String label;
  final double fontSize;
  final FontWeight fontWeight;
  @override
  Widget build(BuildContext context) {
    return SelectableText(
      label,
      textAlign: TextAlign.justify,
      style: GoogleFonts.roboto(fontSize: fontSize, fontWeight: fontWeight),
    );
  }
}
