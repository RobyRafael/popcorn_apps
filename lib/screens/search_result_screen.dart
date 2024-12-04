import 'package:flutter/material.dart';
import 'package:popcorn_apps/models/movie.dart';
import 'package:popcorn_apps/services/movie_api_service.dart';
import 'package:popcorn_apps/widgets/movie_card.dart';

class SearchResultScreen extends StatefulWidget {
  final String query;

  SearchResultScreen({required this.query});

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final MovieApiService _apiService = MovieApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> movies = [];
  bool isLoading = false;
  bool hasError = false;
  int currentPage = 1;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _scrollController.addListener(_onScroll);
    _loadSearchResults();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMoreData) {
        _loadSearchResults();
      }
    }
  }

  Future<void> _loadSearchResults() async {
    if (isLoading || _searchController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final result = await _apiService.searchMovies(
        query: _searchController.text,
        page: currentPage,
      );

      setState(() {
        if (currentPage == 1) {
          movies = result['movies'];
        } else {
          movies.addAll(result['movies']);
        }

        hasMoreData = result['movies'].length == 20;
        currentPage++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      currentPage = 1;
      hasMoreData = true;
    });
    await _loadSearchResults();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No results found for "${_searchController.text}"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.red.shade800,
            expandedHeight: 120,
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
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: Container(
                height: 60,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Center(
                  // Added Center widget here
                  child: Hero(
                    tag: 'search_bar',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        height: 44, // Fixed height to match home screen
                        width: MediaQuery.of(context).size.width -
                            32, // Full width minus padding
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
                        child: Center(
                          // Added Center widget for TextField
                          child: TextField(
                            controller: _searchController,
                            textAlignVertical: TextAlignVertical
                                .center, // Center text vertically
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search movies...',
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.black),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              isCollapsed:
                                  true, // Important for vertical centering
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  movies.clear();
                                  currentPage = 1;
                                });
                                _loadSearchResults();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hasError)
            SliverFillRemaining(child: _buildErrorState())
          else if (movies.isEmpty && !isLoading)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == movies.length) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red.shade600),
                        ),
                      );
                    }
                    return MovieCard(movies[index]);
                  },
                  childCount:
                      movies.length + (isLoading && hasMoreData ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
