const ERROR_TYPE_NETWORK = "NETWORK_ERROR";

// 错误的类型, 方便照展示和谐的提示
String errorType(String error) {
  // EXCEPTION
  // Get "https://picaapi.picacomic.com/categories": net/http: TLS handshake timeout
  // Get "https://picaapi.picacomic.com/comics?c=%E9%95%B7%E7%AF%87&s=ua&page=1": proxyconnect tcp: dial tcp 192.168.123.217:1080: connect: connection refused
  // Get "https://picaapi.picacomic.com/comics?c=%E5%85%A8%E5%BD%A9&s=ua&page=1": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
  if (error.contains("timeout") ||
      error.contains("connection refused") ||
      error.contains("deadline")) {
    return ERROR_TYPE_NETWORK;
  }
  return "";
}
