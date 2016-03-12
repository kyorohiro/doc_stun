import 'dart:io';
import 'dart:convert';

main(List<String> args) async {
  String host = args[0];
  int port = int.parse(args[1]);
  startUDPServer(host, port);
  startTCPServer(host, port);
}

startUDPServer(String host, int port) async {
  RawDatagramSocket socket = await RawDatagramSocket.bind(host, port, reuseAddress: true);
  socket.listen((RawSocketEvent event) {
    print("--receive");
    if (event == RawSocketEvent.READ) {
      Datagram dg = socket.receive();
      String content = "${dg.address}\n${dg.port}\n";
      socket.send(UTF8.encode(content), dg.address, dg.port);
    }
  });
}

startTCPServer(String host, int port) async {
  ServerSocket server = await ServerSocket.bind(host, port);
  server.listen((Socket socket) {
    String content = "${socket.remoteAddress}\n${socket.remotePort}\n";
    socket.add(UTF8.encode(content));
    socket.remoteAddress;
    socket.remotePort;
  });
}
