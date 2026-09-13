import 'package:flutter/material.dart';

import '../services/api_client.dart';

String apiErrorMessage(Object error) =>
    error is ApiException ? error.message : 'تعذر إكمال العملية. حاول مجدداً.';

class ApiErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback retry;
  const ApiErrorView({super.key, required this.error, required this.retry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(apiErrorMessage(error), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: retry, child: const Text('إعادة المحاولة')),
        ],
      ),
    ),
  );
}
