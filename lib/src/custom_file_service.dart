import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:math';

class CustomFileService extends HttpFileService {
  // 创建多个 http.Client 实例来提高并发能力
  final List<http.Client> _clients = List.generate(100, (_) => http.Client());
  final Random _random = Random();

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final client = _clients[_random.nextInt(_clients.length)];
    debugPrint('请求url  [$url] begin');
    final req = http.Request('GET', Uri.parse(url));

    if (headers != null) {
      req.headers.addAll(headers);
    }

    final http.StreamedResponse httpResponse = await client.send(req);
    return HttpGetResponse(httpResponse);
  }
}
