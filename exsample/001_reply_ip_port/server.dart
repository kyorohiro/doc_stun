import 'dart:io';
import 'dart:convert';

main(List<String> args) async {
  String svAddr = args[0];
  int svPort = int.parse(args[1]);
  startUDPServer(svAddr, svPort);
  startTCPServer(svAddr, svPort);
}

startUDPServer(String svAddr, int svPort) async {
  RawDatagramSocket socket = await RawDatagramSocket.bind(svAddr, svPort, reuseAddress: true);
  socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.READ) {
      Datagram dg = socket.receive();
      String content = "${dg.address.address},${dg.port}\n";
      print("udp: ${content}");
      socket.send(UTF8.encode(content), dg.address, dg.port);
    }
  });
}

startTCPServer(String host, int port) async {
  ServerSocket server = await ServerSocket.bind(host, port);
  server.listen((Socket socket) {
    String content = "${socket.remoteAddress.address},${socket.remotePort}\n";
    print("tcp: ${content}");
    socket.add(UTF8.encode(content));
  });
}
