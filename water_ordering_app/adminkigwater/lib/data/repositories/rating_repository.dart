import 'package:appwrite/appwrite.dart';
import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/domain/entities/rating.dart';
import 'package:adminkigwater/domain/repositories/rating_repository.dart';
import 'package:adminkigwater/domain/repositories/user_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/constants.dart';

class RatingRepositoryImpl implements RatingRepository {
  late Databases database;
  late Account account;

  UserRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
    account = appwrite.getAccount();
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
  Future<void> submitRating({
    required String orderId,
    required double rating,
    required String comment,
  }) async {
    final userModel =
        await getIt<UserRepository>().getUserById(LocalSavedData().getUserId());

    final ratingData = {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'date': DateTime.now().toIso8601String(),
    };

    await database.createDocument(
      collectionId: ratingsCollectionId,
      documentId: userModel?.ratingId ?? '',
      data: ratingData,
      databaseId: dbId,
    );
  }
}
