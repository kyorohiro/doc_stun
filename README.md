# なぜなに STUN 

本書は、"なぜなに Torrent"の姉妹本です。
"なぜなに Torrent"と同様に、実際にSTUN Server と STUN Client を実装して得た知見やノウハウを元に、アレコレP2Pについて解説してきます。

[TODO] ミニマムスペックはできたので紹介する
https://github.com/kyorohiro/tetorica


# [1] はじめに

### Webアプリはお金がかかる
私たちは現在、さまざまなWebサービスを利用しています。そのほとんどが無料です。
スマートフォンから地図を開いたり。ソーシャルネットワークを開いたり。Google検索して、Webページを探したり。Youtubeで動画を見たり。

しかし、無料で利用していますが、その運営費は巨額です。
[TODO] AWS GAE mBaaSとかの例を書く


ある一定の規模を越えると、サーバー代がかさみ運営が困難になります。または、サービスの質が落ちます。

緩やかに、増減するようなものでは、やりくりできます。急激に成長するような場合、
破綻してしまいます。


### P2Pで実現してみては?

ひとつの解決方法として、P2Pが有ります。サーバーの負荷を利用者に分担することで、
サーバーへの負荷を減らします。

たとえば、BitTorrent というファイル共有サービスは、利用者が増えるほど、
ファイルが配信される性能は上がります。

BitTorrentでは、ファイルをダウンロードしてもらう人が、データを配信する側に加わることで、
サーバーの配信コストを減らしています。

P2Pにより、このレベルまで最適化が進むと、配信者は企業という体裁を持たなくとも、
個人でもスケール可能なサービスを展開できます。

[TODO スケースするとかは、言い方を変える



### STUN は、重要な役割を担っている

本書では、その中でも STUN について紹介します。STUNはP2Pアプリでも、P2Pを利用してユーザーになんらかのサービスを提供するようなものではありません。P2Pサービスの中の要素技術のひとつです。

有名なところでは、WebRTCという、リアルタイムコミュニケーションアプリを作るためのフレームワークなどで利用されています。たとえば、WebRTCはファイルを交換したり、ビデオチャットをしたり、といった事がサーバーを経由しないで実現する事ができます。

この、サーバーを経由しないで、ネットワーク上でユーザー同士が繋がるには、さまざまな障壁があります。
その障壁を越えるためには、ユーザーの端末の状態や情報を知る必要があります。
この、ユーザーの端末の状態を知るための要素技術がSTUNです。






# [2] STUNとは

### インターネット上の端末はIPアドレスを持っている
インターネットに繋がっている端末には、すべてIPアドレスが振られています。このIPアドレスをもとに、相手の端末に接続する事ができます。

GoogleのWebページは、"www.google.jp"というアドレスをもっていますね。GoogleのWebページにアクセスすると、ブラウザーの上のほうに表示されています。

```
$nslookup www.google.jp
Non-authoritative answer:
Name:	www.google.jp
Address: 216.58.197.3
```

この、"216.58.197.3"というIPアドレスを、ブラウザーに入力してみてください。
GoogleのWebページが表示されるはずです。

インターネットの凄いところは、このIPアドレスさえわかれば、世界中のコンピュータに接続できるという事です。
もちろん、私たち利用者のコンピュータにも接続ができます。


### ほとんどのユーザーは、利用している時だけIPが配布されている

　しかし、さまざまな、経緯から、IPアドレスはサーバー側にしか所持していません。もちろん、ネットワークゲームをハードに利用するために、プロバイダーとIPアドレスを所持する契約をしている人や、IPアドレスを豊富に所持しているプロバイダーを利用しているユーザーは、IPを持っています。

良く持ちいられる話としては、現在、もっとも利用されているIPv4が、枯渇しているのが理由です。
IPv4は、2の32乗=43億のIPアドレスしか管理できません。
一見、大きな数字ですが、地球の人口はすでに、70億をこえていまから、一人にひとつのIPを割り振る事ができない状態な訳です。

　このような背景から、他の端末からアクセスされる端末には、固定のIPアドレスを割り振りますが、他の端末からアクセスされる事が発生しにくい端末には、利用する時だけIPを割り当てるという事が行われています。


### P2P接続は考慮されていない場合がほとんど。
 利用時に割り振られている、IPアドレスを調べ、相手に伝える事ができれば、P2Pアプリを作成できます。固定IPを持つサーバーでなくても、サーバーが提供するようなサービスを作成する事ができます。サーバー以上に、P2P独自のサーバーでは実現できない、より優れたサービスを提供する事もできます。

 しかし、残念な事にこの割り振られIPが、一時的なものであったり、複数の端末で共有しているものだったりして、P2Pアプリとして利用できない場合があります。
 もちろん、企業などてはセキュリティーを確保するたるにも、P2Pとして利用できないように制限をかけていたりする事もありのます。
 
 
 試しに、自分の端末に割り振られているIPをチェックしてみましょう。
 
```
$ifconfig
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
	options=3<RXCSUM,TXCSUM>
	inet6 ::1 prefixlen 128 
	inet 127.0.0.1 netmask 0xff000000 
	inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1 
	nd6 options=1<PERFORMNUD>
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=10b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV>
	ether 10:dd:b1:d1:b1:37 
	inet6 fe80::12dd:b1ff:fed1:b137%en0 prefixlen 64 scopeid 0x4 
	inet 192.168.10.101 netmask 0xffffff00 broadcast 192.168.10.255
	nd6 options=1<PERFORMNUD>
	media: autoselect (100baseTX <full-duplex,flow-control>)
	status: active
```

といった、情報が表示されます。"127.0.0.1" "192.168.10.101"が割れ振られているIPv4です。残念ながら、グローバルに固定なIPではないはずです。
"10." "192." "172." "168."で始まるIPは、プライベートアドレスと言われているものです。ご家庭のインターネットに接続する機器(ルータ)が、あなたの端末に割り振っているIPです。

一時的にせよ、固定にせよ、実際に割り振られているIPはルーターが知っています。　ルーターから、IPアドレスを教えてもらわないと、P2Pアプリを実現できません。



### STUN を利用して、これらの状態を知る事ができる。

　本書では、STUNを利用する方法を紹介します。姉妹本である　"なぜなに Torrent" では UPnP Port Mapという方法を紹介しました。詳しくはそちらをみて欲しいのですが、軽く説明すると。

　ルータにどのようなIPが設定されているかを聞くための方式がま、UPnPという仕様で定められています。実際のこの仕様にそってルータに問い合わせる事で、IPとPortを知る事ができます。
 
 ただ、UPnP Portmap 自体をサポートとしていない場合や、ルータもIPアドレスを知らない場合があります。そのような場合、STUNを利用すると上手くいく事があります。





# [3] Nat越えしてみよう



### インターネット上のコンピュータは、IPアドレスでつながっている
xxx

### コンピュータは知らない
xx

# [4] TCPよりもUDPが適当

### 通信相手は、IPアドレスを知っている
xxx
### UDPなら通信相手から聞ける
xxx

# [5] NAT越えの方法
### IPを、公開する

### IPと、Portを返してもらう

### Aの場合
xxx

### Bの場合

xxx

# [6] STUNで、どの方法でNAT越えができるか確認する

### ようは、前もってNat越えできるか確認しておくということ

xxx



# [7] 実装編
## Attibute
xx

## Header
xx

## HMAC
xx


# [8] あとがき

xxx


# [9] 次回

なぜなに UPnP Portmap
なぜなに TURN










