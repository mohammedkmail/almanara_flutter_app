import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(left: 14),

      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 135,

            decoration: const BoxDecoration(
              color: AppTheme.teal100,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),

            child: const Center(
              child: Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: AppTheme.teal950,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}