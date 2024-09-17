import 'package:adminkigwater/domain/entities/rating.dart';

abstract class RatingRepository {
  Future<void> submitRating({
    required String orderId,
    required double rating,
    required String comment,
  });
  Future<Rating> getRating(String ratingId);
}
