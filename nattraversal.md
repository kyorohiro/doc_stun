# Nat越えしてみよう

　実際にNat越えしてみましょう。徐々に拡張しながら、STUNへ近づけていきます。
 
 
## [1] サーバーに一時的に配布されたIPめPortを教えてもらう

　一時的に配布されているにはどうすれば良いでしょうか?　「実際にサーバーに接続してみて、そのサーバーに、一時的に配布されているIPアドレスとPortが何か教えてもらう。」というのが、STUNの基本的な戦略です。

　インターネットに利用している端末は、IPで管理されているのでした。我々はサーバーのIPアドレスを知っているからサーバーへ接続できます。どうように、サーバーも利用者のIPアドレスを知っているから、データを配信できるのです。
 このサーバーが認識している、IPアドレスを教えてもらいます。

#### Dartで書いてみよう

###### Server側のコード
```
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
      socket.send(UTF8.encode(content), dg.address, dg.port);
    }
  });
}

startTCPServer(String host, int port) async {
  ServerSocket server = await ServerSocket.bind(host, port);
  server.listen((Socket socket) {
    String content = "${socket.remoteAddress.address},${socket.remotePort}\n";
    socket.add(UTF8.encode(content));
  });
}
```

これは、サーバーにアクセスしてきた、端末のIPアドレスとPORT番号を返すプログラムです。30行程度ですが、十分機能します。

###### Client側のコード
```
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
```

client側のコードも30行程度ですね!!



#### TCP よりも UDPの方がP2Pに向いている

はい、UDPもTCPもIPアドレスを特定する事ができます。しかし、TCPだと、どのようなPort番号が設定されているかを確認する方法がないですね。

```
RawDatagramSocket socket = await RawDatagramSocket.bind(clAddr, clPort, reuseAddress: true);
socket.send(UTF8.encode("test"), new InternetAddress(svAddr), svPort);
```
```
  Socket socket = await Socket.connect(svAddr, svPort);
  socket.add(UTF8.encode(""));
```

UDPで、サーバーに接続する場合は、サーバーとして動作しているSocketを利用して接続できます。しかし、TCPでは、サーバーに接続する場合は、サーバーへ接続専用のSocketを利用しています。

このため、TCPは、サーバーとして待ち受けしているSocketのIPとPortが実際に何を指しているかを、判定できません。

P2Pアプリを実現する場合、UDPを使用した方が、より高い確率でP2P接続する事ができるようになります。





## [2] 他のサーバーからアクセスしてもらう

　実際に利用してみると、[1]の方法では上手くいかない場合があります。上手くいかなかったあなた。おめでとうございます。自分で作成した仕組みを色々試していると、上手くいかないものです。 上手くいかないといのは、改善のチャンスですね。ついていますね。ルーターによっては、一時的に配布されるIPが毎回変わったり。Port番号の対応付け方法が、毎回変わる場合があります。

#### 一時的なIPが変わる場合でも、P2P接続できる
　それでも、相手を選べば、P2P接続可能です。自分自信には接続してもらえなくても、自分から接続しに行けば、つながります。
 通信相手が、Nat越え可能な場合は、こちらから接続しに行くという方法が残されています。
 
|\|Nat越えできる|Nat越えできない|
|-|-|-|
|Nat越えできる|P2P接続できる|P2P接続できる|
|Nat越えできない|P2P接続できる|P2P接続できない|
 

つまり、その端末のIPの状態がわかると、効率良くP2P接続がいできます。



#### 前もって試しておこう!!

　STUNでは、別IP、別PORTから、接続する機能を持っています。前もってIPの状態を調べておくという訳ですね。

###### Server側

```
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
```


#### STUN の分類方法

|\|PP|PS|SP|SS||
|-|-|-|-|-|-|
|Open Internet|o|-|-|o|ifconfigのIPとサーバーが受け取ったIPが同じ|
|||||
|||||

TODO








