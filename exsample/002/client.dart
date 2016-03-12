import 'dart:io';
import 'dart:convert';

main(List<String> args) async {
  String clAddr = args[0];
  int clPort = int.parse(args[1]);
  String svAddr = args[2];
  int svPort = int.parse(args[3]);
  String type = args[4];
  startUDPClient(clAddr, clPort, svAddr, svPort, type);
}

startUDPClient(String clAddr, int clPort, String svAddr, int svPort, String type) async {
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
  print("##send ${type}");
  socket.send(UTF8.encode("${type}"), new InternetAddress(svAddr), svPort);
}
