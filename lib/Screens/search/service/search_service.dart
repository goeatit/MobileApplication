import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:eatit/api/api_repository.dart';
import 'package:eatit/api/network_manager.dart';

class SearchService {
  final ApiRepository _apiRepository;
  CancelToken? _cancelToken;

  SearchService({ApiRepository? apiRepository})
      : _apiRepository =
            apiRepository ?? ApiRepository(NetworkManager(Connectivity()));

  Future<Response?> getResultQuery(String query) async {
    try {
  _cancelToken?.cancel();
  _cancelToken = CancelToken(); // ✅ assign new token
      return await _apiRepository.fetchSearch(query,cancelToken: _cancelToken);
    } on DioException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }
  void cancelOngoingRequest() {
    _cancelToken?.cancel();
    _cancelToken = null;
  }
}
