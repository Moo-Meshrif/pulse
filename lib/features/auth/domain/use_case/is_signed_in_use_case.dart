import 'package:injectable/injectable.dart';

import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public answer to "is someone signed in on this device?", for other features (the splash).
/// A session may still be expired until the next request.
@injectable
class IsSignedInUseCase {
  IsSignedInUseCase(this._auth);

  final AuthDatasource _auth;

  bool call() => _auth.hasSession;
}
