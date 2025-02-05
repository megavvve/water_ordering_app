import 'package:appwrite/appwrite.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/user_model/rating/rating.dart';
import 'package:vodovoz/domain/entities/user_model/rating/review.dart';
import 'package:vodovoz/domain/repositories/user/rating_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/utils/constants.dart';


class RatingRepositoryImpl implements RatingRepository {
  late Databases database;

  RatingRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
  }
  @override
  Future<Rating> getRating(String ratingId) async {
    try {
      final response = await database.getDocument(
        collectionId: ratingsCollectionId,
        documentId: ratingId,
        databaseId: dbId,
      );

      // Parse the response data into a Rating object
      return Rating.fromMap(response.data);
    } catch (e) {
      // Handle errors, e.g., document not found or network issues
      throw Exception('Error fetching rating: $e');
    }
  }

  @override
  Future<List<Review>> getReviews({
    required String userId,
    bool isDeliverer = false,
  }) async {
    try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: reviewsCollectionId,
    queries: [Query.limit(5000)]
      );

      final reviews = response.documents.map((doc) {
        return Review.fromMap(doc.data);
      }).toList();

      return reviews
          .where(
              (x) => x.toWhomUserId == userId && x.isDeliverer == isDeliverer)
          .toList();
    } catch (e) {
      print('Error retrieving reviews: $e');
      return [];
    }
  }

 
  @override
  Future<void> addReviewForRating({
    required Review review,
  }) async {
    try {
      // Создание нового документа с отзывом
      await database.createDocument(
        collectionId: reviewsCollectionId,
        documentId: review.id,
        data: review.toMap(),
        databaseId: dbId,
      );

      // Получение текущего рейтинга пользователя
      final rating = await getRating(review.toWhomUserId);

      // Получение всех отзывов для данного пользователя
      final reviews = await getReviews(
        userId: review.toWhomUserId,
        isDeliverer: review.isDeliverer,
      );

      rating.reviewsId.add(review.id);
      int numberOfRatings = reviews
          .where((x) => x.isReviewForCanceledOrder == false && x.rating > 0)
          .length;
      double currentRating =
          (review.isDeliverer) ? rating.delivererRating : rating.overallRating;

      // Рассчитываем новый рейтинг
       double newRating =
          ((currentRating * numberOfRatings.toDouble()) + review.rating) /
              (numberOfRatings.toDouble() + 1.0);
      newRating = double.parse(newRating.toStringAsFixed(1));
      // Обновляем рейтинг и дату обновления
      rating.lastUpdated = dateTimeCorrectForm;
      if (review.isDeliverer) {
        rating.delivererRating = newRating;
      } else {
        rating.overallRating = newRating;
      }

      // Обновление документа с рейтингом в базе данных
      await database.updateDocument(
        collectionId: ratingsCollectionId,
        documentId: rating.id,
        data: rating.toMap(),
        databaseId: dbId,
      );
    } catch (e) {
      print('Error adding review for rating: $e');
      rethrow;
    }
  }

  @override
  Future<void> createRating(String ratingId) async {
    try {
      await database.createDocument(
        databaseId: dbId,
        collectionId: ratingsCollectionId,
        documentId: ratingId,
        data: Rating(
                id: ratingId,
                userId: LocalSavedData().getUserId(),
                overallRating: 0.0,
                delivererRating: 0.0,
                reviewsId: [],
                lastUpdated: dateTimeCorrectForm)
            .toMap(),
      );
      print('Rating created successfully');
    } on AppwriteException catch (e) {
      print('Failed to create rating: ${e.message}');
    }
  }
   @override
  Future<void> addReview({
    required Review review,
  }) async {
   await database.createDocument(
        collectionId: reviewsCollectionId,
        documentId: review.id,
        data: review.toMap(),
        databaseId: dbId,
      );
  }
  
  @override
  Future<Review> getReview(String reviewId) async {
    try {
      final response = await database.getDocument(
        collectionId: ratingsCollectionId,
        documentId: reviewsCollectionId,
        databaseId: dbId,
      );

      // Parse the response data into a Rating object
      return Review.fromMap(response.data);
    } catch (e) {
      // Handle errors, e.g., document not found or network issues
      throw Exception('Error fetching rating: $e');
    }
  }
}
