[ [Engligh](README.md) | [日本語](README.ja.md) ]

---
# Corridor Runner for MSX

<img src="images/corridor_title.png">

## How to play

[WebMSXで遊ぶ](https://webmsx.org/?MACHINE=MSX1J&ROM=https://github.com/aburi6800/msx-CorridorRunner/raw/v0.3.1/dist/c-runner.rom&FAST_BOOT)

### 操作方法

- カーソルキー 左・右 :
    - プレイヤーの方向転換
- カーソルキー 下 :
    - 押すとパワーチャージ、離すと前進します。

### ゲームルール (暫定)

<img src="images/corridor_game.png">

- アイテムチップを取ると得点になります。
- 連続して取るとスコアがアップします。
- 床から落ちたり、敵に触れるとミスになります。
- 出口まで行くと、ラウンドクリアです。

## ビルド方法

z88dkとcmakeが必要です。あらかじめインストールしておいてください。 
プロジェクトのクローンを作成し、プロジェクトのルートフォルダに入り、以下を実行します。 

```
$ mkdir build && cd build
$ cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/z88dk.cmake ..
$ make clean && make
```
プロジェクトの `dist` ディレクトリに `c-runner.rom` ファイルが出力されます。 
  
  
## openMSXで実行する

OpenMSXは以下から入手可能です:  

[openMSX](https://openmsx.org/)

コマンドラインで、プロジェクトのルートディレクトリから、次のように実行します。

```
$ openmsx ./dist/c-runner.rom
```

または、起動したOpenMSXから `c-runner.rom` を読み込みます。

## ライセンス

MIT License

## Thanks

- [Z88DK - The Development Kit for Z80 Computers](https://github.com/z88dk/z88dk)
- [C-BIOS](http://cbios.sourceforge.net/)
- [openMSX](https://openmsx.org/)
- [LovelyComposer](https://github.com/doc1oo/LovelyComposerDocs)
