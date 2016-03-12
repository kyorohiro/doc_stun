import 'dart:io';
import 'dart:convert';

main(List<String> args) async {
  String clAddr = args[0];
  int clPort = int.parse(args[1]);
  String svAddr = args[2];
  int svPort = int.parse(args[3]);

  startUDPClient(clAddr, clPort, svAddr, svPort);
  startTCPClient(svAddr, svPort);
}

startUDPClient(String clAddr, int clPort, String svAddr, int svPort) async {
  RawDatagramSocket socket = await RawDatagramSocket.bind(clAddr, clPort, reuseAddress: true);
  socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.READ) {
      Datagram dg = socket.receive();
      print("--");
      print("  [receive udp] ${dg.address.address} ${dg.port}");
      print("  ${UTF8.decode(dg.data,allowMalformed:true)}");
      print("--");
    }
  });
  socket.send(UTF8.encode("test"), new InternetAddress(svAddr), svPort);
}

startTCPClient(String svAddr, int svPort) async {
  Socket socket = await Socket.connect(svAddr, svPort);
  socket.listen((List<int> data) {
    print("--");
    print("  [receive tcp]");
    print("  ${UTF8.decode(data,allowMalformed:true)}");
    print("--");
  });
  socket.add(UTF8.encode(""));
}
