import 'package:flutter/material.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteButton(
      {super.key, required this.isFavorite, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: onPressed,
            ),
            const SizedBox(width: 8.0),
            Text(
              isFavorite ? 'Added to Favorites' : 'Add to Favorites',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
