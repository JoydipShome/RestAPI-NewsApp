import 'dart:developer';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proj45_restapi_newsapp/consts/vars.dart';
import 'package:proj45_restapi_newsapp/inner_screens/blog_details.dart';
import 'package:proj45_restapi_newsapp/inner_screens/search_screen.dart';
import 'package:proj45_restapi_newsapp/providers/news_provider.dart';
import 'package:proj45_restapi_newsapp/widgets/articles_widget.dart';
import 'package:proj45_restapi_newsapp/widgets/drawer_widgets.dart';
import 'package:proj45_restapi_newsapp/widgets/empty_screen.dart';
import 'package:proj45_restapi_newsapp/widgets/top_trending.dart';
import 'package:proj45_restapi_newsapp/widgets/verical_spacing.dart';
import 'package:provider/provider.dart';
import '../inner_screens/blog_details.dart';
import '../models/news_model.dart';
import '../services/news_api.dart';
import '../services/utils.dart';
import '../widgets/loading_widget.dart';
import '../widgets/tabs.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var newsType = NewsType.allNews;
  int currentPageIndex = 0;
  String sortBy = SortByEnum.publishedAt.name;
  // List<NewsModel> newsList = [];

  // void didChangeDependencies() {
  //   getNewsList();
  //   super.didChangeDependencies();
  // }
  //
  // Future<List<NewsModel>> getNewsList() async {
  //   List<NewsModel> newsList =
  //       await NewsApiServices.getAllNews(page: currentPageIndex + 1, sortBy: '');
  //   return newsList;
  // }

  @override
  Widget build(BuildContext context) {
    final Color color = Utils(context).getColor;
    Size size = Utils(context).getScreenSize;
    final newsProvider = Provider.of<NewsProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: color),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(
            'News App',
            style: GoogleFonts.lobster(
                textStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.6)),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const SearchScreen(),
                      inheritTheme: true,
                      ctx: context),
                );
              },
              icon: const Icon(
                IconlyLight.search,
              ),
            )
          ],
        ),
        drawer: const DrawerWidget(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  TabsWidget(
                    text: 'All News',
                    color: newsType == NewsType.allNews
                        ? Theme.of(context).cardColor
                        : Colors.transparent,
                    function: () {
                      if (newsType == NewsType.allNews) {
                        return;
                      }
                      setState(() {
                        newsType = NewsType.allNews;
                      });
                    },
                    fontSize: newsType == NewsType.allNews ? 22 : 14,
                  ),
                  const SizedBox(height: 20),
                  TabsWidget(
                    text: 'Top Trending',
                    color: newsType == NewsType.topTrending
                        ? Theme.of(context).cardColor
                        : Colors.transparent,
                    function: () {
                      if (newsType == NewsType.topTrending) {
                        return;
                      }
                      setState(() {
                        newsType = NewsType.topTrending;
                      });
                    },
                    fontSize: newsType == NewsType.topTrending ? 22 : 14,
                  ),
                ],
              ),
              const VerticalSpacing(height: 10),
              newsType == NewsType.topTrending
                  ? Container()
                  : SizedBox(
                      height: kBottomNavigationBarHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          paginationButtons(
                            text: 'Prev',
                            function: () {
                              if (currentPageIndex == 0) {
                                return;
                              }
                              setState(() {
                                currentPageIndex -= 1;
                              });
                            },
                          ),
                          Flexible(
                            flex: 2,
                            child: ListView.builder(
                                itemCount: 6,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Material(
                                      color: currentPageIndex == index
                                          ? Colors.blue
                                          : Theme.of(context).cardColor,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            currentPageIndex = index;
                                          });
                                        },
                                        child: Center(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('${index + 1}'),
                                        )),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          paginationButtons(
                            text: 'Next',
                            function: () {
                              if (currentPageIndex == 5) {
                                return;
                              }
                              setState(() {
                                currentPageIndex += 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
              const VerticalSpacing(height: 10),
              newsType == NewsType.topTrending
                  ? Container()
                  : Align(
                      alignment: Alignment.topRight,
                      child: Material(
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: DropdownButton(
                            value: sortBy,
                            items: dropDownItems,
                            onChanged: (String? value) {
                              setState(() {
                                sortBy = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

              FutureBuilder<List<NewsModel>>(
                  future: newsType == NewsType.topTrending
                      ? newsProvider.fetchTopHeadlines()
                      : newsProvider.fetchAllNews(
                          pageIndex: currentPageIndex + 1, sortBy: sortBy),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return newsType == NewsType.allNews
                          ? LoadingWidget(newsType: newsType)
                          : const Expanded(
                              child:
                                  LoadingWidget(newsType: NewsType.topTrending),
                            );
                    } else if (snapshot.hasError) {
                      return Expanded(
                        child: EmptyNewsWidget(
                          text: "An Error occurred ${snapshot.error}",
                          imagePath: 'assets/images/no-news.png',
                        ),
                      );
                    } else if (snapshot.data == null) {
                      return Expanded(
                        child: EmptyNewsWidget(
                          text: "An Error occurred ${snapshot.error}",
                          imagePath: 'assets/images/no-news.png',
                        ),
                      );
                    }
                    return newsType == NewsType.allNews
                        ? Expanded(
                            child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (ctx, index) {
                                  return ChangeNotifierProvider.value(
                                    value: snapshot.data![index],
                                    child: const ArticlesWidget(
                                        // imageUrl: snapshot.data![index].urlToImage,
                                        // dateToShow:
                                        //     snapshot.data![index].dateToShow,
                                        // readingTime:
                                        //     snapshot.data![index].readingTimeText,
                                        // title: snapshot.data![index].title,
                                        // url: snapshot.data![index].url,
                                        ),
                                  );
                                }),
                          )
                        : SizedBox(
                            height: size.height * 0.6,
                            child: Swiper(
                              autoplayDelay: 8000,
                              autoplay: true,
                              itemWidth: size.width * 0.9,
                              layout: SwiperLayout.STACK,
                              viewportFraction: 0.9,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return ChangeNotifierProvider.value(
                                    value: snapshot.data![index],
                                    child: TopTrendingWidget());
                              },
                            ),
                          );
                  })),

              // LoadingWidget(newsType: NewsType.topTrending),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> get dropDownItems {
    List<DropdownMenuItem<String>> menuItem = [
      DropdownMenuItem(
        value: SortByEnum.relevancy.name,
        child: Text(SortByEnum.relevancy.name),
      ),
      DropdownMenuItem(
        value: SortByEnum.popularity.name,
        child: Text(SortByEnum.popularity.name),
      ),
      DropdownMenuItem(
        value: SortByEnum.publishedAt.name,
        child: Text(SortByEnum.publishedAt.name),
      ),
    ];
    return menuItem;
  }

  Widget paginationButtons({
    required Function function,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: () {
        function();
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.all(6),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
      child: Text(text),
    );
  }
}
