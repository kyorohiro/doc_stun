import 'dart:io';
import 'dart:convert';

main(List<String> args) async {
  String primaryAddr = args[0];
  int primaryPort = int.parse(args[1]);
  String secondaryAddr = args[2];
  int secondaryPort = int.parse(args[3]);
  startUDPServer(primaryAddr, primaryPort, secondaryAddr, secondaryPort);
}

startUDPServer(String primaryAddr, int primaryPort, String secondaryAddr, int secondaryPort) async {
  RawDatagramSocket ppSocket = await RawDatagramSocket.bind(primaryAddr, primaryPort, reuseAddress: true);
  RawDatagramSocket psSocket = await RawDatagramSocket.bind(primaryAddr, secondaryPort, reuseAddress: true);
  RawDatagramSocket spSocket = await RawDatagramSocket.bind(secondaryAddr, primaryPort, reuseAddress: true);
  RawDatagramSocket ssSocket = await RawDatagramSocket.bind(secondaryAddr, secondaryPort, reuseAddress: true);
  Map sockets = {"PP": ppSocket, "PS": psSocket, "SP": spSocket, "SS": ssSocket};
  ppSocket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.READ) {
      try {
        Datagram dg = ppSocket.receive();
        String request = UTF8.decode(dg.data);
        String content = "${dg.address.address},${dg.port}\n";
        print("udp: ${request}");
        RawDatagramSocket socket = sockets[request];
        socket.send(UTF8.encode(content), dg.address, dg.port);
      } catch (e) {}
    }
  });
}
