import 'package:flutter/material.dart';
import 'package:popcorn_apps/services/movie_api_service.dart';
import 'package:popcorn_apps/models/movie.dart';
import 'package:popcorn_apps/widgets/movie_card.dart';
import 'package:popcorn_apps/screens/search_result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final MovieApiService _apiService = MovieApiService();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  List<Movie> movies = [];
  int currentPage = 1;
  bool isLoading = false;
  String currentSelection = 'popular';
  String greeting = '';

  final List<Map<String, dynamic>> categories = [
    {'label': 'Popular', 'value': 'popular', 'icon': Icons.trending_up},
    {'label': 'Top Rated', 'value': 'top_rated', 'icon': Icons.star},
    {'label': 'Upcoming', 'value': 'upcoming', 'icon': Icons.upcoming},
    {
      'label': 'Now Playing',
      'value': 'now_playing',
      'icon': Icons.play_circle_filled
    },
  ];

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _scrollController.addListener(_onScroll);
    _loadMovies();
  }

  void _setGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
  }

  void _onSearchTap() {
    showSearch(
      context: context,
      delegate: MovieSearchDelegate(),
    );
  }

  Widget _buildPopcornLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Positioned(
          top: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        currentSelection = categories[_tabController.index]['value'];
        movies.clear();
        currentPage = 1;
      });
      _loadMovies();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMovies();
    }
  }

  Future<void> _loadMovies() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final result = await _apiService.getMovies(
        page: currentPage,
        category: currentSelection,
      );

      setState(() {
        if (currentPage == 1) {
          movies = result['movies'];
        } else {
          movies.addAll(result['movies']);
        }
        currentPage++;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load movies'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _refreshMovies() async {
    setState(() {
      movies.clear();
      currentPage = 1;
    });
    await _loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 230,
              floating: true,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.red.shade800,
                        Colors.red.shade600,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildPopcornLogo(),
                            SizedBox(width: 10),
                            Text(
                              'Popcorn',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '$greeting, Movie Lover!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'What would you like to watch today?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Hero(
                            tag: 'search_bar',
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                height: 44,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchResultScreen(query: ''),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.search, color: Colors.grey),
                                      SizedBox(width: 8),
                                      Text(
                                        'Search movies...',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Center(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      indicatorWeight: 3,
                      indicatorColor: Colors.red.shade600,
                      labelPadding: EdgeInsets.symmetric(horizontal: 4),
                      tabs: categories.map((category) {
                        return Tab(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(category['icon']),
                              SizedBox(height: 4),
                              Text(
                                category['label'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _refreshMovies,
          child: movies.isEmpty && !isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No movies available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      ElevatedButton(
                        onPressed: _refreshMovies,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: movies.length + (isLoading ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= movies.length) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red.shade600),
                        ),
                      );
                    }
                    return Hero(
                      tag: 'movie-${movies[index].id}',
                      child: MovieCard(movies[index]),
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class MovieSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) return SizedBox();
    return SearchResultScreen(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_creation_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Search for movies...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search movies...';

  @override
  TextStyle get searchFieldStyle => TextStyle(
        fontSize: 16,
        color: Colors.black87,
      );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 72;
  @override
  double get maxExtent => 72;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
