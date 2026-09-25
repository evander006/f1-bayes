class OpenF1Exception implements Exception {
  const OpenF1Exception(this.kind, [this.message]);

  final OpenF1ErrorKind kind;
  final String? message;

  factory OpenF1Exception.timeout() =>
      const OpenF1Exception(OpenF1ErrorKind.timeout);
  factory OpenF1Exception.network() =>
      const OpenF1Exception(OpenF1ErrorKind.network);
  factory OpenF1Exception.http(int code) =>
      OpenF1Exception(OpenF1ErrorKind.http, '$code');
  factory OpenF1Exception.malformed() =>
      const OpenF1Exception(OpenF1ErrorKind.malformed);
  factory OpenF1Exception.subscription() =>
      const OpenF1Exception(OpenF1ErrorKind.subscription);

  bool get isSubscription =>
      kind == OpenF1ErrorKind.subscription || message == '401' || message == '403';

  @override
  String toString() => 'OpenF1Exception($kind, $message)';
}

enum OpenF1ErrorKind { timeout, network, http, malformed, subscription }
