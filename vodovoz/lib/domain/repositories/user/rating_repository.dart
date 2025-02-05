import 'package:vodovoz/domain/entities/user_model/rating/rating.dart';
import 'package:vodovoz/domain/entities/user_model/rating/review.dart';

abstract class RatingRepository {
  Future<void> addReviewForRating({
    required Review review,
  });
  Future<Rating> getRating(String ratingId);
   Future<Review> getReview(String reviewId);
  Future<void> createRating(String ratingId);
  Future<List<Review>> getReviews({
    required String userId,
    bool isDeliverer = false,
  });
  Future<void> addReview({
    required Review review,
  });
}
