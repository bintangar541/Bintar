import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

final apiServiceProvider = Provider((ref) => ApiService(ref.watch(authServiceProvider)));

final transactionCategoryProvider = FutureProvider.family<String, String>((ref, desc) async {
  final api = ref.read(apiServiceProvider);
  final result = await api.analyzeCategory(desc);
  return result['category'] ?? 'Lainnya';
});

final recentTransactionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getTransactions();
});

enum TimeFrame { weekly, monthly, yearly }

final timeFrameProvider = StateProvider<TimeFrame>((ref) => TimeFrame.monthly);

final analysisProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getAnalysis();
});

final smartNotificationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getNotifications();
});

final aiEngineProvider = StateProvider<String>((ref) => 'Groq Llama 3.3');

final lastPasswordChangeProvider = StateProvider<String>((ref) => 'Terakhir diubah 2 bulan lalu');
final linkedDevicesCountProvider = StateProvider<int>((ref) => 2);
