import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proj45_restapi_newsapp/inner_screens/search_screen.dart';
import 'package:proj45_restapi_newsapp/models/bookmarks_model.dart';
import 'package:proj45_restapi_newsapp/widgets/drawer_widgets.dart';
import 'package:proj45_restapi_newsapp/widgets/empty_screen.dart';
import 'package:provider/provider.dart';

import '../consts/vars.dart';
import '../models/news_model.dart';
import '../providers/bookmarks_provider.dart';
import '../services/utils.dart';
import '../widgets/articles_widget.dart';
import '../widgets/loading_widget.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).getColor;
    Size size = Utils(context).getScreenSize;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: color),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          'Book Marks',
          style: GoogleFonts.lobster(
              textStyle: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.6)),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<List<BookmarksModel>>(
              future: Provider.of<BookmarksProvider>(context, listen: false)
                  .fetchBookmarks(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(newsType: NewsType.allNews);
                } else if (snapshot.hasError) {
                  return Expanded(
                    child: EmptyNewsWidget(
                      text: "An Error occurred ${snapshot.error}",
                      imagePath: 'assets/images/no-news.png',
                    ),
                  );
                } else if (snapshot.data == null) {
                  return const Expanded(
                    child: EmptyNewsWidget(
                      text: "No bookmark yet",
                      imagePath: 'assets/images/bookmarks.png',
                    ),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, index) {
                      return ChangeNotifierProvider.value(
                        value: snapshot.data![index],
                        child: const ArticlesWidget(isBookmark: true),
                      );
                    },
                  ),
                );
              })),
        ],
      ),
    );
  }
}
