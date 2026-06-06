import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:bintar/core/services/auth_service.dart';

class ApiService {
  final AuthService _authService;
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.100.85:8000',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
  ));

  ApiService(this._authService) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authService.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Map<String, dynamic>> analyzeCategory(String description) async {
    try {
      final response = await _dio.post(
        '/transactions/analyze-category',
        queryParameters: {'description': description},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to analyze category');
    }
  }

  Future<void> saveTransaction(Map<String, dynamic> data) async {
    try {
      await _dio.post('/transactions/', data: data);
    } catch (e) {
      throw Exception('Failed to save transaction');
    }
  }

  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await _dio.get('/transactions/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load transactions');
    }
  }

  Future<String> sendChatMessage(String message) async {
    try {
      final response = await _dio.post(
        '/transactions/chat',
        data: {'message': message},
      );
      return response.data['reply'] ?? 'Tidak ada balasan';
    } catch (e) {
      throw Exception('Gagal mengirim pesan chat');
    }
  }

  Future<Map<String, dynamic>> getAnalysis() async {
    try {
      final response = await _dio.get('/transactions/analysis');
      return response.data;
    } catch (e) {
      throw Exception('Gagal mendapatkan analisis AI');
    }
  }
  Future<List<dynamic>> getGoals() async {
    try {
      final response = await _dio.get('/goals/');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load goals');
    }
  }

  Future<void> createGoal(Map<String, dynamic> data) async {
    try {
      await _dio.post('/goals/', data: data);
    } catch (e) {
      throw Exception('Failed to create goal');
    }
  }

  Future<void> updateGoal(int id, Map<String, dynamic> data) async {
    try {
      await _dio.put('/goals/$id', data: data);
    } catch (e) {
      throw Exception('Failed to update goal');
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _dio.delete('/goals/$id');
    } catch (e) {
      throw Exception('Failed to delete goal');
    }
  }

  Future<Map<String, dynamic>> smartInput(String text) async {
    try {
      final response = await _dio.post(
        '/transactions/smart-input',
        queryParameters: {'text': text},
      );
      return response.data;
    } catch (e) {
      throw Exception('AI gagal memahami input tersebut');
    }
  }

  Future<List<dynamic>> importBank(List<int> fileBytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });
      final response = await _dio.post('/transactions/import-bank', data: formData);
      return response.data['transactions'] ?? [];
    } catch (e) {
      throw Exception('Gagal mengimpor file bank');
    }
  }

  Future<String> simulateScenario(String message) async {
    try {
      final response = await _dio.post(
        '/transactions/simulate',
        data: {'message': message},
      );
      return response.data['reply'] ?? 'Tidak ada simulasi';
    } catch (e) {
      throw Exception('Gagal melakukan simulasi AI');
    }
  }

  Future<Map<String, dynamic>> getMonthlyWrapped() async {
    try {
      final response = await _dio.get('/transactions/wrapped');
      return response.data;
    } catch (e) {
      throw Exception('Gagal mendapatkan Monthly Wrapped');
    }
  }

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/transactions/notifications');
      return response.data;
    } catch (e) {
      throw Exception('Gagal mendapatkan notifikasi pintar');
    }
  }
}
