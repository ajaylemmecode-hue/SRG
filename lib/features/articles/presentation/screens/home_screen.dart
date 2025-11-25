import 'package:flutter/material.dart';
import 'package:good_news/core/services/api_service.dart';
import 'package:good_news/core/services/user_service.dart';
import 'package:good_news/core/services/preferences_service.dart';
import 'package:good_news/core/services/social_api_service.dart';
import 'package:good_news/features/articles/presentation/screens/friends_posts_screen.dart';
import 'package:good_news/features/profile/presentation/screens/profile_screen.dart';
import 'package:good_news/features/social/presentation/screens/create_post_screen.dart';
import 'package:good_news/features/social/presentation/screens/friends_modal.dart';
import 'package:good_news/features/settings/presentation/screens/settings_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:good_news/features/articles/presentation/widgets/article_card_widget.dart';
import 'package:good_news/features/articles/presentation/widgets/category_chips.dart';
import 'package:good_news/features/articles/presentation/widgets/social_post_card_widget.dart';
import 'package:good_news/features/articles/presentation/widgets/speed_dial_widget.dart';

// 🔹 AdMob
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 🔹 Ad Variables
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  // 👇 Existing variables (kept unchanged)
  List<Map<String, dynamic>> _allArticles = [];
  List<Map<String, dynamic>> _socialPosts = [];
  Map<int, String> _categoryMap = {};
  List<int> _selectedCategoryIds = [];
  List<Map<String, dynamic>> _displayedItems = [];

  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool _showFab = true;
  bool _isRefreshing = false;
  bool _isInitialLoading = true;
  int _currentIndex = 0;
  int? _selectedCategoryId;
  bool _isSpeedDialOpen = false;

  static const int SOCIAL_CATEGORY_ID = -1;
  static const int LOAD_MORE_THRESHOLD = 2;
  static const int PAGE_SIZE = 20;
  static const int PRELOAD_COUNT = 3;

  final PageController _pageController = PageController(keepPage: true);
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  final Map<String, List<Map<String, dynamic>>> _postComments = {};
  final Map<String, bool> _showCommentsMap = {};
  final Map<String, bool> _isLoadingCommentsMap = {};
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _preloadedImages = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _refreshUserDisplayName();
    _loadInitialData();
    _pageController.addListener(_onPageChanged);

    // 🔹 Load Banner Ad
    _loadBannerAd();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _animationController.dispose();
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }

    // 🔹 Dispose Ad
    _bannerAd.dispose();

    super.dispose();
  }

  // 🔹 Ad Loading Function
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-4875158489726472/5190373225', // तुमचे Banner ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('Banner Ad failed to load: $err');
        },
      ),
    );
    _bannerAd.load();
  }

  // 👇 Rest of your existing code (kept exactly as is)

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  Future<void> _preloadImages(List<Map<String, dynamic>> items, int startIndex) async {
    if (!mounted) return;
    final endIndex = (startIndex + PRELOAD_COUNT).clamp(0, items.length);
    for (int i = startIndex; i < endIndex; i++) {
      final item = items[i];
      String? imageUrl;
      if (item['type'] == 'article' && item['image_url'] != null) {
        imageUrl = item['image_url'];
      } else if (item['type'] == 'social_post' && item['image_url'] != null) {
        imageUrl = item['image_url'];
      }
      if (imageUrl != null && !_preloadedImages.containsKey(imageUrl)) {
        _preloadedImages[imageUrl] = true;
        try {
          await precacheImage(
            CachedNetworkImageProvider(imageUrl, cacheKey: imageUrl, maxWidth: 800, maxHeight: 800),
            context,
          );
        } catch (e) {
          // Silent fail
        }
      }
    }
  }

  Future<void> _refreshUserDisplayName() async {
    try {
      await UserService.refreshUserProfile();
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isInitialLoading = true);
    try {
      _selectedCategoryIds = await PreferencesService.getSelectedCategories();
      final categoryResponse = await ApiService.getCategories();
      if (categoryResponse['status'] == 'success' && categoryResponse['categories'] != null) {
        final List<dynamic> categories = categoryResponse['categories'];
        _categoryMap = {
          for (final cat in categories)
            (cat['id'] as int): (cat['name'] ?? 'Unnamed') as String
        };
      }

      _allArticles.clear();
      _nextCursor = null;
      _hasMore = true;

      await _loadMoreArticles(isInitial: true);
      _loadSocialPosts();

      _updateDisplayedItems();

      if (_displayedItems.isNotEmpty) {
        _preloadImages(_displayedItems, 0);
      }
    } catch (e) {
      print('❌ HOME: Failed to load: $e');
      if (mounted) {
        _showSnackBar('Failed to load data. Please retry.');
      }
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  Future<void> _loadMoreArticles({bool isInitial = false}) async {
    if (_isLoadingMore || (!_hasMore && !isInitial)) {
      print('⏸️ Already loading or no more data');
      return;
    }
    try {
      setState(() => _isLoadingMore = true);
      print('');
      print('═══════════════════════════════════════');
      print('📡 LOADING ARTICLES FROM API');
      print('   Category: ${_selectedCategoryId == null ? "All" : _selectedCategoryId == SOCIAL_CATEGORY_ID ? "Social" : _categoryMap[_selectedCategoryId]}');
      print('   Cursor: $_nextCursor');
      print('   Current total: ${_allArticles.length}');
      print('═══════════════════════════════════════');

      final response = await ApiService.getUnifiedFeed(
        limit: PAGE_SIZE,
        cursor: _nextCursor,
        categoryId: _selectedCategoryId,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        final List<dynamic> items = response['items'] ?? [];
        List<Map<String, dynamic>> newArticles = items
            .where((item) => item['type'] == 'article')
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        print('📥 RECEIVED ${newArticles.length} new articles');
        Map<int?, int> categoryCount = {};
        for (var article in newArticles) {
          final catId = article['category_id'];
          categoryCount[catId] = (categoryCount[catId] ?? 0) + 1;
        }
        print('📊 Articles by category:');
        categoryCount.forEach((catId, count) {
          print('   ${_categoryMap[catId] ?? "Unknown ($catId)"}: $count articles');
        });

        setState(() {
          if (isInitial) {
            _allArticles = newArticles;
          } else {
            _allArticles.addAll(newArticles);
          }
          _nextCursor = response['next_cursor'];
          _hasMore = response['has_more'] ?? (response['next_cursor'] != null);
          print('');
          print('💾 CACHE UPDATED:');
          print('   Total articles: ${_allArticles.length}');
          print('   Next cursor: $_nextCursor');
          print('   Has more: $_hasMore');
        });

        _updateDisplayedItems();

        if (!isInitial && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Loaded ${newArticles.length} more articles'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        }
        print('═══════════════════════════════════════');
      } else {
        print('❌ API returned error: ${response['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ EXCEPTION loading articles: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _updateDisplayedItems() {
    if (!mounted) return;
    setState(() {
      if (_selectedCategoryId == null) {
        _displayedItems = List.from(_allArticles);
        print('📱 Displaying ${_displayedItems.length} articles (All)');
      } else if (_selectedCategoryId == SOCIAL_CATEGORY_ID) {
        _displayedItems = List.from(_socialPosts);
        print('📱 Displaying ${_displayedItems.length} social posts');
      } else {
        _displayedItems = _allArticles
            .where((article) => article['category_id'] == _selectedCategoryId)
            .toList();
        final categoryName = _categoryMap[_selectedCategoryId] ?? 'Unknown';
        print('📱 Displaying ${_displayedItems.length} articles for $categoryName');
        if (_displayedItems.length < 5 && _hasMore && !_isLoadingMore) {
          print('⚠️ Only ${_displayedItems.length} articles in $categoryName. Loading more...');
          Future.delayed(Duration.zero, () => _loadMoreArticles());
        }
      }
    });
  }

  Future<void> _loadSocialPosts() async {
    try {
      final response = await SocialApiService.getPosts();
      if (response['status'] == 'success') {
        final postsList = response['posts'] as List;
        final List<int> locallyLikedPosts = await PreferencesService.getLikedPosts();
        if (mounted) {
          setState(() {
            _socialPosts = postsList.map((post) => _formatSocialPost(post, locallyLikedPosts)).toList();
          });
          if (_selectedCategoryId == SOCIAL_CATEGORY_ID) {
            _updateDisplayedItems();
            _preloadImages(_socialPosts, 0);
          }
        }
      }
    } catch (e) {
      print('❌ Error loading social: $e');
    }
  }

  Map<String, dynamic> _formatSocialPost(Map<String, dynamic> post, List<int> locallyLikedPosts) {
    final authorName = post['display_name'] ?? 'Unknown';
    final likesCount = post['likes_count'] ?? 0;
    final postId = post['id'] is int ? post['id'] : int.tryParse(post['id'].toString()) ?? 0;
    final apiLiked = post['user_has_liked'] == 1 || post['user_has_liked'] == true;
    final localLiked = locallyLikedPosts.contains(postId);
    return {
      'type': 'social_post',
      'id': postId.toString(),
      'author': authorName,
      'avatar': authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
      'title': post['title'] ?? '',
      'content': post['content'] ?? '',
      'created_at': post['created_at'],
      'likes': likesCount,
      'isLiked': apiLiked || localLiked,
      'category_id': SOCIAL_CATEGORY_ID,
      'category': 'Social Posts',
      'image_url': post['image_url'],
    };
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentIndex && page < _displayedItems.length) {
      setState(() => _currentIndex = page);
      final item = _displayedItems[page];
      if (item['type'] == 'article') {
        UserService.addToHistory(item['id'] as int);
      }
      final remainingItems = _displayedItems.length - page;
      if (page + 1 < _displayedItems.length) {
        _preloadImages(_displayedItems, page + 1);
      }
      if (remainingItems <= LOAD_MORE_THRESHOLD) {
        if (_hasMore && !_isLoadingMore) {
          print('🔄 Triggering load more (${_allArticles.length} articles so far)');
          _loadMoreArticles();
        }
      }
    }
  }

  void _toggleSpeedDial() {
    setState(() {
      _isSpeedDialOpen = !_isSpeedDialOpen;
      if (_isSpeedDialOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _selectCategory(int? categoryId) async {
    if (categoryId == _selectedCategoryId) return;
    print('');
    print('🎯 ═══════════════════════════════════════');
    print('🎯 SELECTING CATEGORY: ${categoryId == null ? "All" : categoryId == SOCIAL_CATEGORY_ID ? "Social" : _categoryMap[categoryId]}');
    print('🎯 ═══════════════════════════════════════');
    setState(() {
      _selectedCategoryId = categoryId;
      _currentIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    if (categoryId == SOCIAL_CATEGORY_ID) {
      if (_socialPosts.isEmpty) {
        await _loadSocialPosts();
      }
      _updateDisplayedItems();
    } else {
      setState(() {
        _allArticles.clear();
        _nextCursor = null;
        _hasMore = true;
      });
      await _loadMoreArticles(isInitial: true);
      _updateDisplayedItems();
    }
    if (_displayedItems.isNotEmpty) {
      _preloadImages(_displayedItems, 0);
    }
    print('📱 Now displaying ${_displayedItems.length} items');
    print('🎯 ═══════════════════════════════════════');
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _preloadedImages.clear();
    await _loadInitialData();
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Refreshed!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadInitialData,
        ),
      ),
    );
  }

  void _shareArticle(Map<String, dynamic> article) {
    final title = article['title'] ?? '';
    final summary = article['content'] ?? '';
    final url = article['source_url'] ?? '';
    final shareText = '🗞 Good News!\n'
        '$title\n'
        '${summary.length > 100 ? summary.substring(0, 100) + '...' : summary}\n'
        '${url.isNotEmpty ? '🔗 $url' : ''}';
    Share.share(shareText);
  }

  Future<void> _toggleLike(Map<String, dynamic> post) async {
    final postId = int.parse(post['id']);
    final bool wasLiked = post['isLiked'];
    final int currentLikes = post['likes'];
    setState(() {
      post['isLiked'] = !wasLiked;
      post['likes'] = wasLiked ? currentLikes - 1 : currentLikes + 1;
    });
    try {
      final response = wasLiked
          ? await SocialApiService.unlikePost(postId)
          : await SocialApiService.likePost(postId);
      if (response['status'] == 'success') {
        if (!wasLiked) {
          PreferencesService.saveLikedPost(postId);
        } else {
          PreferencesService.removeLikedPost(postId);
        }
        if (response['likes_count'] != null && mounted) {
          setState(() => post['likes'] = response['likes_count']);
        }
      } else {
        if (mounted) {
          setState(() {
            post['isLiked'] = wasLiked;
            post['likes'] = currentLikes;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          post['isLiked'] = wasLiked;
          post['likes'] = currentLikes;
        });
      }
    }
  }

  Future<void> _toggleCommentsForPost(String postId) async {
    if (_showCommentsMap[postId] == true) {
      setState(() {
        _showCommentsMap[postId] = false;
        _showFab = true;
      });
    } else {
      setState(() => _showFab = false);
      await _loadCommentsForPost(postId);
    }
  }

  Future<void> _loadCommentsForPost(String postId) async {
    if (_isLoadingCommentsMap[postId] == true) return;
    setState(() => _isLoadingCommentsMap[postId] = true);
    try {
      final postIdInt = int.parse(postId);
      final response = await SocialApiService.getComments(postIdInt);
      if (response['status'] == 'success' && mounted) {
        final rawComments = response['comments'] as List;
        final formattedComments = rawComments.map((comment) {
          final authorName = comment['display_name'] ?? 'Anonymous';
          return {
            'id': comment['id'],
            'author': authorName,
            'avatar': authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
            'content': comment['content'] ?? '',
            'timestamp': _formatTimestamp(comment['created_at']),
            'created_at': comment['created_at'],
          };
        }).toList();
        setState(() {
          _postComments[postId] = formattedComments;
          _showCommentsMap[postId] = true;
          _isLoadingCommentsMap[postId] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCommentsMap[postId] = false);
      }
    }
  }

  Future<void> _postCommentOnSocialPost(String postId) async {
    final controller = _commentControllers[postId];
    if (controller == null) return;
    final content = controller.text.trim();
    if (content.isEmpty) return;
    FocusScope.of(context).unfocus();
    try {
      final postIdInt = int.parse(postId);
      final response = await SocialApiService.createComment(postIdInt, content);
      if (response['status'] == 'success' && mounted) {
        final userDisplayName = await PreferencesService.getUserDisplayName().catchError((_) => 'Me');
        final newComment = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'author': userDisplayName ?? 'Me',
          'avatar': (userDisplayName?.isNotEmpty ?? false) ? userDisplayName![0].toUpperCase() : 'M',
          'content': content,
          'timestamp': 'Just now',
          'created_at': DateTime.now().toIso8601String(),
        };
        setState(() {
          _postComments[postId] = [...(_postComments[postId] ?? []), newComment];
          controller.clear();
          _showFab = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Comment posted!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _showFab = true);
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Just now';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dateTime);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${(diff.inDays / 7).floor()}w';
    } catch (e) {
      return 'Just now';
    }
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    if (result != null && result is Map && result['action'] == 'read_article') {
      _navigateToArticle(result['article_id']);
    } else if (mounted) {
      await _loadInitialData();
    }
  }

  void _goToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (mounted) await _loadInitialData();
  }

  void _navigateToArticle(int articleId) {
    final index = _displayedItems.indexWhere(
            (item) => item['type'] == 'article' && item['id'] == articleId
    );
    if (index != -1) {
      setState(() => _currentIndex = index);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final categoryList = _buildCategoryList();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _buildMainContent(categoryList),
            if (_showFab) _buildSpeedDial(),
            if (_isLoadingMore && !_isInitialLoading)
              Positioned(
                bottom: 16 + (_isAdLoaded ? 50 : 0), // 🔹 Ad खाली असल्यामुळे loading indicator वर ठेवा
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('Loading more...', style: TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            // 🔹 Banner Ad at Bottom
            if (_isAdLoaded)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: _bannerAd.size.height.toDouble(),
                  width: _bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(List<Map<String, dynamic>> categoryList) {
    return Column(
      children: [
        CategoryChips(
          categories: categoryList,
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: _selectCategory,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 2.5,
            child: _isInitialLoading
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                : _displayedItems.isEmpty
                ? _buildEmptyState()
                : PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _displayedItems.length,
              itemBuilder: (context, index) {
                final item = _displayedItems[index];
                if (item['type'] == 'social_post') {
                  return _buildSocialPost(item);
                } else {
                  return _buildArticle(item);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticle(Map<String, dynamic> article) {
    return ArticleCardWidget(
      article: article,
      onTrackRead: (_) {},
      onShare: _shareArticle,
    );
  }

  Widget _buildSocialPost(Map<String, dynamic> post) {
    final postId = post['id'] as String;
    _commentControllers.putIfAbsent(postId, () => TextEditingController());
    return SocialPostCardWidget(
      post: post,
      comments: _postComments[postId] ?? [],
      showComments: _showCommentsMap[postId] ?? false,
      isLoadingComments: _isLoadingCommentsMap[postId] ?? false,
      commentController: _commentControllers[postId]!,
      onToggleLike: _toggleLike,
      onToggleComments: _toggleCommentsForPost,
      onPostComment: _postCommentOnSocialPost,
      onShare: _shareArticle,
      onShowFullImage: _showFullImageDialog,
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDialWidget(
      isOpen: _isSpeedDialOpen,
      rotationAnimation: _rotationAnimation,
      onToggle: _toggleSpeedDial,
      actions: [
        SpeedDialAction(
          bottom: 330,
          icon: Icons.person_outline,
          label: 'My Profile',
          onTap: () {
            _toggleSpeedDial();
            _goToProfile();
          },
        ),
        SpeedDialAction(
          bottom: 280,
          icon: Icons.edit,
          label: 'New Post',
          onTap: () async {
            _toggleSpeedDial();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            );
            if (result == true && mounted) {
              await _loadSocialPosts();
              _updateDisplayedItems();
            }
          },
        ),
        SpeedDialAction(
          bottom: 230,
          icon: Icons.post_add_outlined,
          label: 'Friends Posts',
          onTap: () {
            _toggleSpeedDial();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FriendsPostsScreen()),
            );
          },
        ),
        SpeedDialAction(
          bottom: 180,
          icon: Icons.person_add,
          label: 'Add Friend',
          onTap: () {
            _toggleSpeedDial();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const FriendsModal(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedCategoryId == SOCIAL_CATEGORY_ID
                  ? Icons.people_outline
                  : Icons.article_outlined,
              size: 64,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedCategoryId == SOCIAL_CATEGORY_ID
                  ? 'No social posts yet!'
                  : 'No articles in this category!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCategoryId == SOCIAL_CATEGORY_ID
                  ? 'Be the first to share something positive!'
                  : _hasMore
                  ? 'Loading more articles...'
                  : 'Try selecting a different category or refresh.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectedCategoryId == SOCIAL_CATEGORY_ID
                  ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                );
                if (result == true && mounted) {
                  await _loadSocialPosts();
                  _updateDisplayedItems();
                }
              }
                  : _handleRefresh,
              icon: Icon(_selectedCategoryId == SOCIAL_CATEGORY_ID ? Icons.edit : Icons.refresh),
              label: Text(
                _selectedCategoryId == SOCIAL_CATEGORY_ID
                    ? 'Create Post'
                    : 'Refresh',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildCategoryList() {
    final List<Map<String, dynamic>> categoryList = [
      {'id': null, 'name': 'All'},
      {'id': SOCIAL_CATEGORY_ID, 'name': '👥 Social'},
    ];
    if (_selectedCategoryIds.isNotEmpty) {
      for (var categoryId in _selectedCategoryIds) {
        if (_categoryMap.containsKey(categoryId)) {
          categoryList.add({'id': categoryId, 'name': _categoryMap[categoryId]});
        }
      }
    } else {
      categoryList.addAll(
        _categoryMap.entries.map((e) => {'id': e.key, 'name': e.value}).toList(),
      );
    }
    return categoryList;
  }
}