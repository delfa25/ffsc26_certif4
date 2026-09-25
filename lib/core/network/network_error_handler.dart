import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// [NetworkErrorHandler] fournit des messages d'erreurs clairs et compréhensibles
/// pour l'utilisateur en cas de coupure réseau, d'échec serveur ou de basculement hors-ligne.
class NetworkErrorHandler {
  /// Retourne un message convivial pour l'utilisateur en fonction du type d'erreur.
  static String getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return 'Pas de connexion Internet. Vos données sont affichées depuis le cache local Hive.';
    } else if (error is NetworkFailure) {
      return error.message;
    } else if (error is ServerException) {
      return 'Le serveur est temporairement inaccessible. Les données hors-ligne sont affichées.';
    } else if (error is ServerFailure) {
      return error.message;
    } else if (error is CacheException) {
      return 'Aucune donnée en cache disponible. Veuillez vous reconnecter pour actualiser.';
    } else if (error is CacheFailure) {
      return error.message;
    } else if (error is AuthFailure) {
      return error.message;
    }
    final message = error.toString().replaceAll('Exception: ', '');
    return message.isNotEmpty ? message : 'Une erreur de communication avec le réseau est survenue.';
  }

  /// Message affiché lors du basculement en mode hors-ligne
  static String getOfflineNotificationMessage({String feature = 'données'}) {
    return 'Mode hors-ligne actif : $feature affichées depuis le cache local Hive.';
  }
}
