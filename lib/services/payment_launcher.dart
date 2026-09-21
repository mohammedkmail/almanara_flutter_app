import 'package:url_launcher/url_launcher.dart';

Future<void> openPaymentUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !await launchUrl(uri, mode: LaunchMode.platformDefault)) {
    throw Exception('تعذر فتح صفحة الدفع.');
  }
}
