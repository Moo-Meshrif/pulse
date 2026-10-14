import 'package:permission_handler/permission_handler.dart';

import '../enums/permission_access.dart';

/// How a `permission_handler` status reads for the app's permission flows.
PermissionAccess permissionAccessOf(PermissionStatus status) {
  if (status.isGranted || status.isLimited || status.isProvisional) {
    return PermissionAccess.granted;
  }
  if (status.isPermanentlyDenied) return PermissionAccess.blocked;
  if (status.isRestricted) return PermissionAccess.restricted;
  return PermissionAccess.denied;
}
