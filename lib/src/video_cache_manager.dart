// Third Party Packages

import 'dart:io';
// ignore: unnecessary_import
import 'dart:typed_data'; // ✅ 处理字节数据
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http; // ✅ 引入 http 包

/// The [VideoCacheManager] is a specialized [CacheManager] for videos cached
/// using the [cached_video_player_plus] package.
///
/// [cached_video_player_plus]: https://pub.dev/packages/cached_video_player_plus
class VideoCacheManager extends CacheManager {
  /// The key used to store the [VideoCacheManager] in the [CacheManager].
  static const key = 'libCachedVideoPlayerPlusData';

  /// The singleton instance of the [VideoCacheManager].
  static final VideoCacheManager _instance = VideoCacheManager._();

  /// Returns the singleton instance of the [VideoCacheManager].
  factory VideoCacheManager() => _instance;

  /// Creates a new instance of the [VideoCacheManager].
  VideoCacheManager._() : super(Config(key, maxNrOfCacheObjects: 200, fileService: CustomHttpFileService()));
}

class CustomHttpFileService extends HttpFileService {
  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final httpClient = HttpClient()..maxConnectionsPerHost = 10; // ✅ 提高最大连接数，加快下载

    final request = await httpClient.getUrl(Uri.parse(url));

    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });

    final response = await request.close();

    // ✅ 读取完整的 body 转为 bytes
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);

    // ✅ 修正 HttpHeaders -> Map<String, String>
    final Map<String, String> responseHeaders = {};
    response.headers.forEach((name, values) {
      responseHeaders[name] = values.join(', '); // 处理多值 headers
    });

    // ✅ 使用 http.StreamedResponse 适配 flutter_cache_manager
    final streamedResponse = http.StreamedResponse(
      Stream.fromIterable([bytes]), // ✅ 将 bytes 转为 Stream
      response.statusCode,
      headers: responseHeaders, // ✅ 传递转换后的 headers
      contentLength: bytes.length, // ✅ 设置内容长度
      reasonPhrase: response.reasonPhrase, // ✅ 设置状态描述
    );

    return HttpGetResponse(streamedResponse);
  }
}
