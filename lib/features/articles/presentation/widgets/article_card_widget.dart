import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for displaying a news article card
class ArticleCardWidget extends StatefulWidget {
  final Map<String, dynamic> article;
  final Function(Map<String, dynamic>) onTrackRead;
  final Function(Map<String, dynamic>) onShare;

  const ArticleCardWidget({
    Key? key,
    required this.article,
    required this.onTrackRead,
    required this.onShare,
  }) : super(key: key);

  @override
  State<ArticleCardWidget> createState() => _ArticleCardWidgetState();
}

class _ArticleCardWidgetState extends State<ArticleCardWidget> {
  bool _isExpandedSummary = false;
  static const int SUMMARY_CHAR_LIMIT = 300;

  String _getShortTitle(String fullTitle) {
    final words = fullTitle.trim().split(' ');
    if (words.length <= 6) return fullTitle;
    return words.take(5).join(' ') + '...';
  }

  Widget _buildDefaultArticleImage() {
    final title = widget.article['title'] ?? 'No Title';
    final shortTitle = _getShortTitle(title);
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF673AB7),
            const Color(0xFFFF9800),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            shortTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  String _getSummaryText() {
    final cleanContent = _removeAiText(widget.article['content'] ?? 'No content available');
    return cleanContent;
  }

  bool _isSummaryLong() {
    return _getSummaryText().length > SUMMARY_CHAR_LIMIT;
  }

  String _getTruncatedSummary() {
    final summary = _getSummaryText();
    if (summary.length <= SUMMARY_CHAR_LIMIT) {
      return summary;
    }
    return summary.substring(0, SUMMARY_CHAR_LIMIT).replaceAll(RegExp(r'\s+\S*$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryTimeRow(context, colorScheme),
                  const SizedBox(height: 16),
                  _buildImageSection(context),
                  _buildTitle(context),
                  const SizedBox(height: 12),
                  _buildSourceAndAiTag(context),
                  const SizedBox(height: 16),
                  _buildSummarySection(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildReadButton(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white70 : Colors.grey[800];
    final isSummaryLong = _isSummaryLong();
    final displaySummary = _isExpandedSummary ? _getSummaryText() : _getTruncatedSummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displaySummary,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            fontSize: 16,
            color: contentColor,
          ),
        ),

      ],
    );
  }

  Widget _buildCategoryTimeRow(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeColor = isDark ? Colors.white70 : Colors.grey[600];
    final createdAt = widget.article['created_at'];
    final timeText = _formatRelativeTime(createdAt);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.article['category'] ?? 'News',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const Spacer(),
        Text(
          timeText,
          style: TextStyle(
            color: timeColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final imageUrl = widget.article['image_url'] as String?;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              memCacheHeight: 440,
              placeholder: (context, url) =>
                  _buildImagePlaceholder(isLoading: true),
              errorWidget: (context, url, error) =>
                  _buildDefaultArticleImage(),
            )
                : _buildDefaultArticleImage(),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.black87, size: 20),
              onPressed: () => widget.onShare(widget.article),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.article['title'] ?? 'No Title',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        height: 1.4,
        fontSize: 22,
      ),
    );
  }

  Widget _buildSourceAndAiTag(BuildContext context) {
    final sourceDomain = _getDomainFromUrl(widget.article['source_url']);
    final isAiRewritten = widget.article['is_ai_rewritten'] == 1 ||
        widget.article['is_ai_rewritten'] == true ||
        widget.article['is_ai_rewritten'] == '1';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            sourceDomain ?? 'News Source',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ),
        if (isAiRewritten) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'AI Enhanced',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String? _getDomainFromUrl(String? url) {
    if (url == null) return null;
    try {
      final uri = Uri.parse(url);
      var host = uri.host;
      if (host.startsWith('www.')) host = host.substring(4);
      return host;
    } catch (e) {
      return null;
    }
  }

  String _removeAiText(String content) {
    final aiPatterns = [
      '[This article was rewritten using A.I.]',
      '(This article was rewritten using A.I.)',
      'This article was rewritten using A.I.',
      '[Rewritten by AI]',
      '(Rewritten by AI)',
      'Rewritten by AI:',
      'AI Rewritten:',
      '[This article was rewritten using AI.]',
      '(This article was rewritten using AI.)',
      'This article was rewritten using AI.',
    ];

    var result = content;
    for (var pattern in aiPatterns) {
      result = result.replaceAll(pattern, '');
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Widget _buildReadButton(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 25, bottom: 15),
        child: GestureDetector(
          onTap: () {
            widget.onTrackRead(widget.article);
            _openInAppBrowser();
          },
          child: Container(
            height: 40,
            width: 240,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.onTrackRead(widget.article);
                  _openInAppBrowser();
                },
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withOpacity(0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.open_in_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Read Full Article',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({bool isLoading = false}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? Colors.grey[850] : Colors.grey[200];
        final iconColor = isDark ? Colors.grey[600] : Colors.grey[400];
        final textColor = isDark ? Colors.grey[500] : Colors.grey[500];

        return Container(
          color: bgColor,
          child: Center(
            child: isLoading
                ? CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: iconColor),
                const SizedBox(height: 8),
                Text('No Image',
                    style:
                    TextStyle(color: textColor, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatRelativeTime(dynamic dateStr) {
    if (dateStr == null) return 'Recent';
    try {
      DateTime date = dateStr is String
          ? (dateStr.contains('GMT')
          ? _parseGMTDate(dateStr)
          : DateTime.parse(dateStr))
          : dateStr is DateTime
          ? dateStr
          : DateTime.now();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    } catch (e) {
      return 'Recent';
    }
  }

  DateTime _parseGMTDate(String dateStr) {
    final parts = dateStr.split(' ');
    if (parts.length < 5) throw FormatException('Invalid GMT format');
    final day = int.parse(parts[1]);
    final month = _monthToNumber(parts[2]);
    final year = int.parse(parts[3]);
    final timeParts = parts[4].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = int.parse(timeParts[2]);
    return DateTime.utc(year, month, day, hour, minute, second);
  }

  int _monthToNumber(String month) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return months[month] ?? 1;
  }

  Future<void> _openInAppBrowser() async {
    final url = widget.article['source_url'] ?? '';
    if (url.isNotEmpty) {
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
      } catch (e) {
        print('❌ Error opening URL: $e');
      }
    }
  }
}