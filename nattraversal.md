# Nat越えしてみよう

　実際にNat越えしてみましょう。徐々に拡張しながら、STUNへ近づけていきます。
 
 
## [1] サーバーに一時的に配布されたIPめPortを教えてもらう

　一時的に配布されているにはどうすれば良いでしょうか?　「実際にサーバーに接続してみて、そのサーバーに、一時的に配布されているIPアドレスとPortが何か教えてもらう。」というのが、STUNの基本的な戦略です。

　インターネットに利用している端末は、IPで管理されているのでした。我々はサーバーのIPアドレスを知っているからサーバーへ接続できます。どうように、サーバーも利用者のIPアドレスを知っているから、データを配信できるのです。
 このサーバーが認識している、IPアドレスを教えてもらいます。

#### Dartで書いてみよう

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





#### TCP よりも UDPの方がP2Pに向いている

TODO



## [2] 他のサーバーからアクセスしてもらう

　実際に利用してみると、[1]の方法では上手くいかない場合があります。上手くいかなかったあなた。おめでとうございます。ついています。

　自分で作成した仕組みを色々試していると、上手くいかないものです。ルーターによっては、一時的に配布されるIPが毎回変わったり。Port番号の対応付け方法が、毎回変わる場合があります。


#### 一時的なIPが変わる場合でも、P2P接続できる
　それでも、相手を選べば、P2P接続可能です。自分自信には接続してもらえなくても、自分から接続しに行けば、つながります。

　P2Pアプリのサービスとして、IPを公開する時に、その端末のIPの状態がわかると、P2P接続がし易いです。 

#### 前もって試しておこう!!

　という事で、前もってIPの状態を調べておきましょう。STUNでは、別IP、別PORTから、接続する機能を持っています。

　
```

```
TODO

#### STUN の分類方法

|\|PP|PS|SP|SS||
|-|-|-|-|-|-|
|Open Internet|o|-|-|o|ifconfigのIPとサーバーが受け取ったIPが同じ|
|||||
|||||

TODO








