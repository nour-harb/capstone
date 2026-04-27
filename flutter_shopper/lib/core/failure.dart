enum FailureType { network, server, unknown }

class AppFailure {
  final FailureType type;
  final String message;

  AppFailure({
    required this.type,
    this.message = "Sorry, an unexpected error has occurred.",
  });

  // predefined factories for common cases
  factory AppFailure.network() => AppFailure(
    type: FailureType.network,
    message: "Cannot connect to the server. Please check your internet.",
  );

  factory AppFailure.server({String? message}) => AppFailure(
    type: FailureType.server,
    message: message ?? "Server is currently unreachable. Please try later.",
  );

  factory AppFailure.unknown([String? details]) => AppFailure(
    type: FailureType.unknown,
    message: details ?? "Something went wrong. Please try again.",
  );

  @override
  String toString() => 'AppFailure(type: $type, message: $message)';
}
