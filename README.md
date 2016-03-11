# なぜなに STUN 

本書は、"なぜなに Torrent"の姉妹本です。
"なぜなに Torrent"と同様に、実際にSTUN Server と STUN Client を実装して得た知見やノウハウを元に、アレコレP2Pについて解説してきます。

https://github.com/kyorohiro/tetorica

# [1] はじめに

### Webアプリはお金がかかる
私たちは現在、さまざまなWebサービスを利用しています。そのほとんどが無料です。
スマートフォンから地図を開いたり。ソーシャルネットワークを開いたり。Google検索して、Webページを探したり。Youtubeで動画を見たり。

しかし、無料で利用していますが、その運営費は巨額です。

TODO AWS GAE とかの例を書く

### P2Pで実現してみては?

xxx

### STUN は、重要な役割を担っている

xxx




# [2] STUNとは

xx

### NAT越えのたるめに必要

xx

### NATの種類を特定するテクニック


xx


# [3] ルータが隠蔽している世界

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










