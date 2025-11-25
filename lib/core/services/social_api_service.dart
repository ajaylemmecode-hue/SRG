import 'dart:io';
import 'package:dio/dio.dart';
import 'package:good_news/core/constants/api_constants.dart';
import 'package:good_news/core/services/api_service.dart';
import 'package:good_news/core/services/preferences_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:convert';
// import 'package:http/src/multipart_file.dart' show MediaType;


class SocialApiService {

  // ✅ Helper method to normalize image URL
  static String _normalizeImageUrl(String imageUrl) {
    // If already a full URL, return as-is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // If relative path (starts with /), prepend base domain
    // ApiConstants.baseUrl = "https://goodnewsapp.lemmecode.com/api/v1"
    // We need: "https://goodnewsapp.lemmecode.com" + "/uploads/posts/abc123.jpg"
    final baseUrl = ApiConstants.baseUrl;
    final uri = Uri.parse(baseUrl);
    final baseDomain = '${uri.scheme}://${uri.host}';

    return '$baseDomain$imageUrl';
  }

  static Future<Map<String, dynamic>> uploadPostImage(File imageFile) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      print('📤 SOCIAL API: Uploading image...');
      print('📤 SOCIAL API: Image path: ${imageFile.path}');

      // Get the API base URL
      final baseUrl = ApiConstants.baseUrl;
      final url = Uri.parse('$baseUrl/posts/upload');

      print('📤 SOCIAL API: Upload URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Get correct MIME type
      final mimeTypeData = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeTypeParts = mimeTypeData.split('/');
      print('📤 SOCIAL API: MIME type: $mimeTypeData');

      // Use correct MediaType from http_parser
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
      );

      request.files.add(multipartFile);

      final imageLength = await imageFile.length();
      print('📤 SOCIAL API: Sending image: ${imageFile.path.split('/').last}');
      print('📤 SOCIAL API: Image size: ${(imageLength / 1024).toStringAsFixed(2)} KB');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📤 SOCIAL API: Upload response status: ${response.statusCode}');
      print('📤 SOCIAL API: Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ SOCIAL API: Image uploaded successfully');
        print('✅ SOCIAL API: Image URL from API: ${responseData['image_url']}');

        // ✅ FIX: Normalize the image URL
        String imageUrl = responseData['image_url'];
        imageUrl = _normalizeImageUrl(imageUrl);

        print('✅ SOCIAL API: Final image URL: $imageUrl');

        return {
          'status': 'success',
          'image_url': imageUrl,
          'message': responseData['message'] ?? 'Image uploaded successfully',
        };
      } else {
        print('❌ SOCIAL API: Upload failed with status ${response.statusCode}');

        try {
          final errorData = json.decode(response.body);
          return {
            'status': 'error',
            'error': errorData['error'] ?? errorData['message'] ?? 'Failed to upload image',
          };
        } catch (e) {
          return {
            'status': 'error',
            'error': 'Failed to upload image: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('❌ SOCIAL API: uploadPostImage exception: $e');
      return {
        'status': 'error',
        'error': 'Upload failed: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getFriends() async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        throw Exception('No auth token');
      }

      final response = await ApiService.authenticatedRequest(
        '/friends',
        method: 'GET',
        token: token,
      );

      if (response is List) {
        return {
          'status': 'success',
          'data': response,
        };
      }

      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['friends'] ?? [];
        return {
          'status': response['status'] ?? 'success',
          'data': data is List ? data : [],
        };
      }

      return {'status': 'success', 'data': []};

    } catch (e) {
      return {'status': 'error', 'error': e.toString(), 'data': []};
    }
  }

  static Future<Map<String, dynamic>> createPost(
      String content,
      String visibility, {
        String? title,
        String? imageUrl,
      }) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Creating post with visibility: $visibility');
      print('📡 SOCIAL API: Title: ${title ?? 'No title'}');
      print('📡 SOCIAL API: Content: $content');
      print('📡 SOCIAL API: Image URL: ${imageUrl ?? 'No image'}');

      final requestData = {
        'content': content,
        'visibility': visibility,
        'title': title ?? content.split('\n').first,
      };

      // ✅ Add image URL if provided
      if (imageUrl != null && imageUrl.isNotEmpty) {
        requestData['image_url'] = imageUrl;
      }

      print('📡 SOCIAL API: Request data: $requestData');

      final response = await ApiService.authenticatedRequest(
        '/posts',
        method: 'POST',
        token: token,
        data: requestData,
      );

      print('📡 SOCIAL API: createPost response: $response');

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('error')) {
          return {'status': 'error', 'error': response['error']};
        }

        if (response.containsKey('status') && response['status'] == 'success') {
          return response;
        }

        if (response.containsKey('post_id') || response.containsKey('id')) {
          return {'status': 'success', 'post': response};
        }

        return {'status': 'success', 'post': response};
      }

      return {'status': 'error', 'error': 'No response from server'};

    } catch (e) {
      print('❌ SOCIAL API: createPost failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> likePost(int postId) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Liking post $postId');

      final response = await ApiService.authenticatedRequest(
        '/posts/$postId/like',
        method: 'POST',
        token: token,
      );

      print('📡 SOCIAL API: likePost response: $response');

      if (response != null && response is Map<String, dynamic>) {
        // ✅ Extract likes_count from response
        return {
          'status': 'success',
          'likes_count': response['likes_count'] ?? 0,
          'message': response['message'] ?? 'Post liked',
        };
      }

      return response ?? {'status': 'error', 'error': 'No response from server'};

    } catch (e) {
      print('❌ SOCIAL API: likePost failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> unlikePost(int postId) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await ApiService.authenticatedRequest(
        '/posts/$postId/unlike',
        method: 'POST',
        token: token,
      );

      if (response != null && response is Map<String, dynamic>) {
        return {
          'status': 'success',
          'likes_count': response['likes_count'] ?? 0,
          'message': response['message'] ?? 'Post unliked',
        };
      }

      return response is Map<String, dynamic> ? response : {'status': 'success'};
    } catch (e) {
      print('❌ SOCIAL API: unlikePost failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }


  static Future<Map<String, dynamic>> getComments(int postId, {int limit = 10, int offset = 0}) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token for getComments');
        throw Exception('No auth token');
      }

      final url = '/posts/$postId/comments?limit=$limit&offset=$offset';
      print('📡 SOCIAL API: Fetching comments from $url');

      final response = await ApiService.authenticatedRequest(
        url,
        method: 'GET',
        token: token,
      );

      print('📡 SOCIAL API: getComments raw response: $response');
      print('📡 SOCIAL API: Response type: ${response.runtimeType}');

      if (response == null) {
        return {'status': 'success', 'comments': [], 'has_more': false, 'total_count': 0};
      }

      List<dynamic> commentsList = [];
      int totalCount = 0;

      // ✅ FIX: Handle response structure correctly
      if (response is Map<String, dynamic>) {
        // Check for 'data' field first (your API returns this)
        if (response.containsKey('data') && response['data'] is List) {
          commentsList = response['data'] as List;
          // ✅ Try to get total_count from response
          totalCount = response['total_count'] ?? response['comments_count'] ?? commentsList.length;
          print('✅ SOCIAL API: Found ${commentsList.length} comments in data[] field, total_count: $totalCount');
        }
        // Legacy: Check for 'comments' field
        else if (response.containsKey('comments') && response['comments'] is List) {
          commentsList = response['comments'] as List;
          totalCount = response['total_count'] ?? response['comments_count'] ?? commentsList.length;
          print('✅ SOCIAL API: Found ${commentsList.length} comments in comments[] field, total_count: $totalCount');
        }
        // If status=success but no data/comments field, return empty
        else if (response['status'] == 'success') {
          print('⚠️ SOCIAL API: Success response but no data/comments field');
          return {'status': 'success', 'comments': [], 'has_more': false, 'total_count': 0};
        }
      }
      // ✅ If response is directly a List
      else if (response is List) {
        // ✅ Explicitly cast to List<dynamic>
        commentsList = List<dynamic>.from(response as Iterable); // 👈 This is the fix!
        totalCount = commentsList.length;
        print('✅ SOCIAL API: Found ${commentsList.length} comments (direct list)');
      }

      return {
        'status': 'success',
        'comments': commentsList,
        'has_more': response is Map ? (response['has_more'] ?? false) : false,
        'total_count': totalCount, // ✅ Include total count
      };

    } catch (e) {
      print('❌ SOCIAL API: getComments failed: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'comments': [],
        'has_more': false,
        'total_count': 0,
      };
    }
  }

  // Block a friend
  static Future<Map<String, dynamic>> blockFriend(int friendId) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Blocking friend $friendId');

      final response = await ApiService.authenticatedRequest(
        '/friends/$friendId/block',
        method: 'POST',
        token: token,
      );

      print('📡 SOCIAL API: blockFriend response: $response');

      if (response != null && response is Map<String, dynamic>) {
        return {
          'status': 'success',
          'message': response['message'] ?? 'User blocked successfully',
        };
      }

      return {'status': 'success', 'message': 'User blocked'};
    } catch (e) {
      print('❌ SOCIAL API: blockFriend failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getBlockedUsers() async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Fetching blocked users');

      final response = await ApiService.authenticatedRequest(
        '/blocks',
        method: 'GET',
        token: token,
      );

      print('📡 SOCIAL API: getBlockedUsers response: $response');

      List<dynamic> blockedList = [];

      if (response is List) {
        blockedList = List<dynamic>.from(response as Iterable);
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          blockedList = response['data'];
        } else if (response.containsKey('blocked_users') && response['blocked_users'] is List) {
          blockedList = response['blocked_users'];
        }
      }

      return {
        'status': 'success',
        'data': blockedList,
      };
    } catch (e) {
      print('❌ SOCIAL API: getBlockedUsers failed: $e');
      return {'status': 'error', 'error': e.toString(), 'data': []};
    }
  }

  static Future<Map<String, dynamic>> unblockUser(int userId) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Unblocking user $userId');

      final response = await ApiService.authenticatedRequest(
        '/friends/$userId/unblock',
        method: 'POST',
        token: token,
      );

      print('📡 SOCIAL API: unblockUser response: $response');

      return {
        'status': 'success',
        'message': response?['message'] ?? 'User unblocked successfully',
      };
    } catch (e) {
      print('❌ SOCIAL API: unblockUser failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  // ✅ Update createComment to return the new comment count
  static Future<Map<String, dynamic>> createComment(int postId, String content) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token for createComment');
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Creating comment on post $postId: "$content"');

      final response = await ApiService.authenticatedRequest(
        '/posts/$postId/comments',
        method: 'POST',
        token: token,
        data: {'content': content},
      );

      print('📡 SOCIAL API: createComment response: $response');

      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('error')) {
          return {'status': 'error', 'error': response['error']};
        }

        // ✅ Extract comment data and any count info
        return {
          'status': 'success',
          'comment': response['comment'] ?? response,
          'comment_id': response['comment_id'] ?? response['id'],
          // ✅ Try to get updated count from response if available
          'comments_count': response['comments_count'],
          'message': response['message'] ?? 'Comment added successfully',
        };
      }

      return {'status': 'success'};

    } catch (e) {
      print('❌ SOCIAL API: createComment failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

// ✅ Update getPosts to ensure comments_count is always an integer
  static Future<Map<String, dynamic>> getPosts({
    int limit = 20,
    int offset = 0,
    String visibility = 'public'
  }) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      final url = '/posts?limit=$limit&offset=$offset&visibility=$visibility';
      print('📡 SOCIAL API: Making request to $url');

      final response = await ApiService.authenticatedRequest(
        url,
        method: 'GET',
        token: token,
      );

      print('📡 SOCIAL API: getPosts raw response: $response');

      if (response == null) {
        throw Exception('Null response from server');
      }

      // ✅ Helper to normalize image URL
      void _normalizeImageUrlInPost(Map<String, dynamic> post) {
        final rawImageUrl = post['image_url'] as String?;
        if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
          post['image_url'] = _normalizeImageUrl(rawImageUrl);
          print('🖼️ Normalized image URL: ${post['image_url']}');
        } else {
          print('⚠️ Post ${post['id']} has no image');
        }

        // ✅ ENSURE comments_count is always an integer
        if (post['comments_count'] != null) {
          if (post['comments_count'] is String) {
            post['comments_count'] = int.tryParse(post['comments_count']) ?? 0;
          } else if (post['comments_count'] is! int) {
            post['comments_count'] = 0;
          }
        } else {
          post['comments_count'] = 0;
        }
        print('📊 Post ${post['id']}: comments_count = ${post['comments_count']}');
      }

      // Handle LIST response
      if (response is List) {
        print('✅ SOCIAL API: Found ${response.length} posts (list)');
        final processedPosts = (response as List).map((post) {
          if (post is Map<String, dynamic>) {
            _normalizeImageUrlInPost(post);
          }
          return post;
        }).toList();

        return {
          'status': 'success',
          'posts': processedPosts,
          'total_count': processedPosts.length,
          'has_more': processedPosts.length >= limit,
        };
      }

      // Handle MAP response
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          final data = response['data'] as List;
          print('✅ SOCIAL API: Found ${data.length} posts in data[]');
          final processedData = data.map((post) {
            if (post is Map<String, dynamic>) {
              _normalizeImageUrlInPost(post);
            }
            return post;
          }).toList();

          return {
            'status': response['status'] ?? 'success',
            'posts': processedData,
            'total_count': processedData.length,
            'has_more': processedData.length >= limit,
          };
        }

        if (response.containsKey('posts') && response['posts'] is List) {
          final posts = response['posts'] as List;
          final processedPosts = posts.map((post) {
            if (post is Map<String, dynamic>) {
              _normalizeImageUrlInPost(post);
            }
            return post;
          }).toList();

          return {
            'status': 'success',
            'posts': processedPosts,
            'total_count': response['total_count'] ?? processedPosts.length,
            'has_more': response['has_more'] ?? false,
          };
        }

        // Single post object
        if (response.containsKey('id') && response.containsKey('content')) {
          _normalizeImageUrlInPost(response);
          return {
            'status': 'success',
            'posts': [response],
            'total_count': 1,
            'has_more': false,
          };
        }

        return {
          'status': 'success',
          'posts': [],
          'total_count': 0,
          'has_more': false,
        };
      }

      throw Exception('Unexpected response format: ${response.runtimeType}');
    } catch (e) {
      print('❌ SOCIAL API: getPosts failed: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'posts': [],
        'total_count': 0,
        'has_more': false,
      };
    }
  }

  static Future<Map<String, dynamic>> createConversation(int friendId) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Creating conversation with friend $friendId');

      final response = await ApiService.authenticatedRequest(
        '/conversations',
        method: 'POST',
        token: token,
        data: {'friend_id': friendId},
      );

      print('📡 SOCIAL API: createConversation response: $response');

      if (response != null && response['status'] == 'success') {
        return response;
      }

      return {'status': 'error', 'error': 'Failed to create conversation'};

    } catch (e) {
      print('❌ SOCIAL API: createConversation failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> sendMessage(int conversationId, String content) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Sending message to conversation $conversationId');

      final response = await ApiService.authenticatedRequest(
        '/conversations/$conversationId/messages',
        method: 'POST',
        token: token,
        data: {'content': content},
      );

      print('📡 SOCIAL API: sendMessage response: $response');
      return response ?? {'status': 'error', 'error': 'No response from server'};

    } catch (e) {
      print('❌ SOCIAL API: sendMessage failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getFriendRequests() async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Fetching friend requests');

      final response = await ApiService.authenticatedRequest(
        '/friends/requests',
        method: 'GET',
        token: token,
      );

      print('📡 SOCIAL API: getFriendRequests raw response: $response');
      print('📡 SOCIAL API: Response runtimeType: ${response.runtimeType}');

      // ✅ API returns a RAW LIST — not a Map!
      if (response is List) {
        print('✅ SOCIAL API: Received ${response.length} friend requests (raw list)');
        return {
          'status': 'success',
          'data': response, // 👈 Use 'data' to match your UI expectation
        };
      }

      // If somehow it's a Map (legacy), try to extract data
      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['received'] ?? [];
        return {
          'status': response['status'] ?? 'success',
          'data': data is List ? data : [],
        };
      }

      // Fallback
      return {
        'status': 'success',
        'data': [],
      };

    } catch (e) {
      print('❌ SOCIAL API: getFriendRequests failed: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'data': [],
      };
    }
  }

  static Future<Map<String, dynamic>> acceptFriendRequest(int requestId) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Accepting friend request $requestId');

      final response = await ApiService.authenticatedRequest(
        '/friends/requests/$requestId/accept',
        method: 'POST',
        token: token,
      );

      print('📡 SOCIAL API: acceptFriendRequest response: $response');

      if (response['status'] == 'success') {
        // Extract friend_id from response (adjust based on your API)
        final friendId = response['friend_id'] ?? response['user_id'];

        if (friendId != null) {
          // Create conversation automatically
          print('📡 SOCIAL API: Auto-creating conversation with friend $friendId');
          await createConversation(friendId);
        }

        return {
          'status': 'success',
          'message': response['message'] ?? 'Accepted',
        };
      }

      return response;

    } catch (e) {
      print('❌ SOCIAL API: acceptFriendRequest failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> declineFriendRequest(int requestId) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) {
        print('❌ SOCIAL API: No auth token found');
        throw Exception('No auth token');
      }

      print('📡 SOCIAL API: Declining friend request $requestId');

      final response = await ApiService.authenticatedRequest(
        '/friends/requests/$requestId/reject', // ✅ Fixed path
        method: 'POST',
        token: token,
      );

      print('📡 SOCIAL API: declineFriendRequest response: $response');

      return {
        'status': 'success',
        'message': response?['message'] ?? 'Declined',
      };

    } catch (e) {
      print('❌ SOCIAL API: declineFriendRequest failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }


  // Update a post
  static Future<Map<String, dynamic>> updatePost(int postId, String content) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await ApiService.authenticatedRequest(
        '/posts/$postId',
        method: 'PUT',
        token: token,
        data: {'content': content},
      );

      return response is Map<String, dynamic> ? response : {'status': 'success', 'post': response};
    } catch (e) {
      print('❌ SOCIAL API: updatePost failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

// Delete a post
  static Future<Map<String, dynamic>> deletePost(int postId) async {
    try {
      final token = await PreferencesService.getToken();
      if (token == null) throw Exception('No auth token');

      final response = await ApiService.authenticatedRequest(
        '/posts/$postId',
        method: 'DELETE',
        token: token,
      );

      return response is Map<String, dynamic> ? response : {'status': 'success'};
    } catch (e) {
      print('❌ SOCIAL API: deletePost failed: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }
// Replace these methods in your SocialApiService class

  static Future<Map<String, dynamic>> getMessages(int conversationId) async {
    try {
      final token = await PreferencesService.getToken();
      final currentUserId = await PreferencesService.getUserId();

      print('📡 Current user ID: $currentUserId');

      if (token == null || currentUserId == null) {
        throw Exception('Not authenticated');
      }

      final response = await ApiService.authenticatedRequest(
        '/conversations/$conversationId/messages',
        method: 'GET',
        token: token,
      );

      print('📡 SOCIAL API: getMessages raw response: $response');
      print('📡 SOCIAL API: Response type: ${response.runtimeType}');

      // Handle different response formats
      List<dynamic> rawMessages = [];

      if (response is List) {
        rawMessages = List<dynamic>.from(response as Iterable);
        print('✅ Got ${rawMessages.length} messages (direct list)');
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          rawMessages = List<dynamic>.from(response['data']);
          print('✅ Got ${rawMessages.length} messages from data[]');
        } else if (response.containsKey('messages') && response['messages'] is List) {
          rawMessages = List<dynamic>.from(response['messages']);
          print('✅ Got ${rawMessages.length} messages from messages[]');
        }
      }

      // Process messages - FIXED: Compare as integers
      final messages = rawMessages.map((msg) {
        final m = msg as Map<String, dynamic>;
        final senderId = m['sender_id'];
        final senderName = m['display_name'] ?? m['sender_name'] ?? 'Unknown';

        // Convert both to int for proper comparison
        final senderIdInt = senderId is int ? senderId : int.tryParse(senderId.toString()) ?? 0;
        final currentUserIdInt = currentUserId is int ? currentUserId : int.tryParse(currentUserId.toString()) ?? 0;

        final isMe = senderIdInt == currentUserIdInt;

        print('📧 Message ${m['id']}: sender=$senderIdInt, current=$currentUserIdInt, isMe=$isMe');

        return <String, dynamic>{
          'id': m['id'].toString(),
          'text': m['content'] ?? '',
          'isMe': isMe,
          'timestamp': _formatMessageTime(m['created_at']),
          'sender_id': senderIdInt,
          'sender_name': senderName,
        };
      }).toList();

      // Sort by message ID
      messages.sort((a, b) => int.parse(a['id']).compareTo(int.parse(b['id'])));

      print('✅ Processed ${messages.length} messages');
      print('✅ Current user messages: ${messages.where((m) => m['isMe'] == true).length}');
      print('✅ Other user messages: ${messages.where((m) => m['isMe'] == false).length}');

      return {'status': 'success', 'messages': messages};

    } catch (e) {
      print('❌ SOCIAL API: getMessages failed: $e');
      return {'status': 'error', 'error': e.toString(), 'messages': []};
    }
  }

  static String _formatMessageTime(String? timeStr) {
    if (timeStr == null) return 'Now';
    try {
      final dt = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return DateFormat('hh:mm a').format(dt.toLocal());
      return DateFormat('MMM dd, hh:mm a').format(dt.toLocal());
    } catch (e) {
      return 'Now';
    }
  }

  static Future<String> getLastMessage(int conversationId) async {
    try {
      final response = await getMessages(conversationId);

      if (response['status'] == 'success') {
        final messages = response['messages'] as List;
        if (messages.isNotEmpty) {
          final lastMsg = messages.last;
          return lastMsg['text'] ?? 'No messages yet';
        }
      }

      return 'No messages yet';
    } catch (e) {
      print('❌ SOCIAL API: getLastMessage failed: $e');
      return 'Failed to load message';
    }
  }

  static Future<Map<String, dynamic>> getConversations() async {
    try {
      final token = await PreferencesService.getToken();
      final currentUserId = await PreferencesService.getUserId();

      print('📡 SOCIAL API: getConversations called');
      print('📡 Current User ID: $currentUserId');

      if (token == null || currentUserId == null) {
        print('❌ SOCIAL API: Missing auth token or user ID');
        throw Exception('Not authenticated');
      }

      final response = await ApiService.authenticatedRequest(
        '/conversations',
        method: 'GET',
        token: token,
      );

      print('📡 API Response: $response');
      print('📡 Response Type: ${response.runtimeType}');

      if (response == null) {
        return {'status': 'success', 'conversations': []};
      }

      List<dynamic> rawConversations = [];

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is List) {
          rawConversations = List.from(response['data'] as List<dynamic>);
          print('✅ Found ${rawConversations.length} conversations in data[]');
        } else if (response.containsKey('conversations') && response['conversations'] is List) {
          rawConversations = List.from(response['conversations'] as List<dynamic>);
          print('✅ Found ${rawConversations.length} conversations in conversations[]');
        }
      } else if (response is List) {
        rawConversations = List.from(response as Iterable<dynamic>);
        print('✅ Found ${rawConversations.length} conversations (raw list)');
      }

      // Process conversations
      final processed = <Map<String, dynamic>>[];

      for (var conv in rawConversations) {
        if (conv is! Map<String, dynamic>) {
          print('⚠️ Skipping invalid conversation: $conv');
          continue;
        }

        final c = conv as Map<String, dynamic>;

        // Determine friend info
        String friendName;
        int friendId;

        if (c['user1_id'] == currentUserId) {
          friendName = c['user2_name'] ?? 'Unknown User';
          friendId = c['user2_id'];
        } else if (c['user2_id'] == currentUserId) {
          friendName = c['user1_name'] ?? 'Unknown User';
          friendId = c['user1_id'];
        } else {
          print('❌ Conversation does not involve current user: $c');
          continue;
        }

        // Skip conversations with null/unknown users
        if (friendName == 'Unknown User' || friendName.isEmpty || c['user1_name'] == null && c['user2_name'] == null) {
          print('⚠️ Skipping conversation with unknown user: friend_id=$friendId');
          continue;
        }

        processed.add({
          'id': c['id'],
          'friend_id': friendId,
          'friend_name': friendName,
          'last_activity': c['updated_at'],
        });
      }

      print('✅ Processed ${processed.length} valid conversations');

      return {
        'status': 'success',
        'conversations': processed,
      };

    } catch (e) {
      print('❌ SOCIAL API: getConversations failed: $e');
      return {'status': 'error', 'error': e.toString(), 'conversations': []};
    }
  }
}