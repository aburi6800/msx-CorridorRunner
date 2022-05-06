; ====================================================================================================
;
; game_field.asm
;
; included from game.asm
;
; ====================================================================================================
SECTION code_user

    MAPDATA_SIZE:                   EQU 176

; ====================================================================================================
; フィールド初期化処理
; 対象ラウンドのマップデータをワークにコピーし、オフスクリーンへの描画までを行う。
; オフスクリーン描画時に、アイテム数をカウントしワーク TARGET_LEFT に設定する。
; 対象ラウンドは予めワーク ROUND に設定しておくこと。
; ====================================================================================================
INIT_FIELD:

    ; ■チップセット/BGMデータアドレス設定
    CALL SET_CHIPSET_BGMDATA_ADDR

    ; ■マップデータをワークにコピー
    CALL COPY_MAP_DATA

    ; ■オフスクリーンリセット
    CALL RESET_OFFSCREEN

    ; ■オフスクリーン描画
    CALL DRAW_MAP

    RET


; ====================================================================================================
; チップセット/BGMデータアドレス設定
; ====================================================================================================
SET_CHIPSET_BGMDATA_ADDR:

    ; ■テーブルの要素数を算出
    ;   ラウンド数の2〜3ビット目を要素数とする（＝ラウンド数 / 4）
    LD A,(ROUND)                    ; A <- ラウンド数(0〜)
    SRA A                           ; 右に2ビットシフト
    SRA A
    PUSH AF

    ; ■チップセットテーブルのアドレスをワークに設定する
    LD HL,CHIPSET_TBL
    CALL GET_ADDR_TBL               ; DE <- チップセットデータの先頭アドレス
    LD HL,CHIPSET_WK                ; チップセットデータのアドレスをワークへ設定
    LD (HL),E
    INC HL
    LD (HL),D

    ; ■BGMテーブルのアドレスをワークに設定する
    POP AF
    LD HL,BGM_TBL
    CALL GET_ADDR_TBL               ; DE <- BGMデータの先頭アドレス
    LD HL,BGM_WK                    ; BGMデータのアドレスをワークへ設定
    LD (HL),E
    INC HL
    LD (HL),D

    RET
    

; ====================================================================================================
; マップデータコピールーチン
; 対象ラウンドのマップデータをマップワークにコピーする
; 将来的に圧縮データにしたときの展開ルーチンもサポートできるように、別処理にしておく
; IN  : A = ラウンド数(0〜)
; ====================================================================================================
COPY_MAP_DATA:
    LD A,(ROUND)
    LD HL,MAP_TBL
    CALL GET_ADDR_TBL               ; DE <- マップデータの先頭アドレス

;    ; ■マップデータの先頭アドレスから176byteをマップワークにブロック転送する
;    LD H,D                          ; HL=転送元アドレス(DE)
;    LD L,E
;    LD DE,MAP_WK                    ; DE=転送先アドレス(MAP_WK)
;    LD BC,176                       ; BC=転送データ数(byte)
;    LDIR                            ; ブロック転送(HL->DE * BC)

    LD HL,MAP_WK                    ; マップワークの先頭アドレス
    LD B,MAPDATA_SIZE/4             ; 繰り返し数（マップデータが1/4なので、4で割る）

COPY_MAP_DATA_L1:
    LD A,(DE)                       ; A <- マップデータ(1byte=4チップ分)
    RLCA
    RLCA
    AND @00000011
    LD (HL),A
    INC HL                          ; 設定先のマップワークのアドレスを+1

    LD A,(DE)                       ; A <- マップデータ(1byte=4チップ分)
    SRA A
    SRA A
    SRA A
    SRA A
    AND @00000011
    LD (HL),A
    INC HL                          ; 設定先のマップワークのアドレスを+1

    LD A,(DE)                       ; A <- マップデータ(1byte=4チップ分)
    SRA A
    SRA A
    AND @00000011
    LD (HL),A
    INC HL                          ; 設定先のマップワークのアドレスを+1

    LD A,(DE)                       ; A <- マップデータ(1byte=4チップ分)
    AND @00000011
    LD (HL),A
    INC HL                          ; 設定先のマップワークのアドレスを+1

    INC DE                          ; 設定元のマップデータのアドレスを+1
    DJNZ COPY_MAP_DATA_L1

    RET


; ====================================================================================================
; マップデータ描画サブルーチン
; マップワークの情報からオフスクリーンにマップを描画する
; 予め、マップデータコピールーチン(COPY_MAP_DATA)を実行してMAP_WKにデータを展開しておくこと
; ====================================================================================================
DRAW_MAP:
    ; ■ターゲット残りをゼロに初期化
    LD HL,TARGET_LEFT
    LD (HL),0

    ; ■マップデータループ回数設定
    LD B,MAPDATA_SIZE               ; B <- マップデータ長 (176byte)
    
DRAW_MAP_L1:
    PUSH BC                         ; マップデータループ回数をスタックに退避
    DEC B

    LD A,B                          ; A <- マップデータオフセット
    CALL GET_MAPDATA                ; A <- マップデータ
    CP 2
    JR NZ,DRAW_MAP_L2               ; マップデータが"2"でなければL2へ

    LD HL,TARGET_LEFT
    INC (HL)                        ; ターゲット残りをインクリメント

DRAW_MAP_L2:
    CALL DRAW_MAPCHIP               ; マップチップ描画
    POP BC                          ; BC <- スタック(マップデータループ回数)
    DJNZ DRAW_MAP_L1

DRAW_MAP_EXIT:
    RET

; ====================================================================================================
; マップチップ描画
; IN  : B=マップデータオフセット値(0～175)
; ====================================================================================================
DRAW_MAPCHIP:

    ; ■マップデータ取得
    LD A,B                          ; A <- マップデータオフセット
    CALL GET_MAPDATA                ; A <- マップデータ
    PUSH AF                         ; マップデータをスタックに退避

    ; ■チップパターンテーブルのアドレスオフセット値を求める
    ADD A,A                         ; A=A*4
    ADD A,A                         ;
    LD H,0
    LD L,A                          ; HL <- チップセットテーブルのアドレスオフセット値
    LD DE,(CHIPSET_WK)              ; DE <- チップセットテーブルのアドレス
    ADD HL,DE                       ; HL=HL+DE

    PUSH HL                         ; HL -> DE
    POP DE

    ; ■オフスクリーンバッファの書き込み開始アドレスを取得
    ;   IN :B = マップデータオフセット値
    ;   OUT:HL = オフスクリーンバッファ書き込み開始アドレス
    CALL GET_OFFSCREEN_WRTADDR

    ; ■マップパターン描画
    ;   HL = オフスクリーンバッファの書き込み先アドレス
    ;   DE = チップパターンの取得元アドレス

    ;   左上
    LD A,(DE)                       ; A <- 左上のマップキャラクタ
    LD (HL),A

    ;   右上
    INC HL
    INC DE
    LD A,(DE)                       ; A <- 右上のマップキャラクタ
    LD (HL),A

    ;   左下
    PUSH BC
    LD BC,31
    ADD HL,BC
    POP BC
    INC DE
    LD A,(DE)                       ; A <- 左下のマップキャラクタ
    LD (HL),A

    ;   右下
    INC HL
    INC DE
    LD A,(DE)                       ; A <- 右下のマップキャラクタ
    LD (HL),A

    POP AF                          ; スタックからマップチップ番号を復元
    OR A
    RET Z                           ; マップチップ番号=0なら抜ける

    ; 画面最下段か
    LD A,B                          ; A <- B
    CP 161                          ; A=A-161
    RET NC                          ; 161以上の場合は最下段なので抜ける

    ; 更に左下の情報を取得
    LD DE,31
    ADD HL,DE
    LD A,(HL)
    CP $20                          ; A > $20(空白)か
    RET NZ                          ; ゼロでなければ抜ける

    ; 描画キャラクターのアドレス取得
    PUSH HL                         ; HL(描画先のVRAMアドレス)をスタックに退避
    LD HL,(CHIPSET_WK)              ; HL <- チップセットテーブルのアドレス
    LD DE,16
    ADD HL,DE                       ; 描画対象キャラクターのデータまでアドレスを加算
    PUSH HL                         ; HL -> DE
    POP DE

    ; 床のさらに下を描画
    POP HL                          ; スタックから描画先のVRAMアドレスを復元
    LD A,(DE)
    LD (HL),A

    INC HL
    INC DE
    LD A,(DE)
    LD (HL),A

    RET


; ====================================================================================================
; マップデータ番号からマップチップ左上のオフスクリーンアドレスを求める
; IN  : B = マップデータの番号(0～175)
; OUT : HL = 描画先のオフスクリーンアドレス(左上)
; ====================================================================================================
GET_OFFSCREEN_WRTADDR:
    PUSH DE

    ; ■Y座標の算出を行う。
    ;  (マップチップ番号-1)を16で割り、64倍することで求める。
    ;  16で割るのは、4ビット右シフトすることで求める。
    ;  64倍は、16で割った結果(0～11)を上位2ビットと下位2ビットに分け、
    ;  上位2ビットは上位レジスタの0～1ビットへ、下位2ビットは下位レジスタの7～6ビットに設定する。
    ;  これを実現するため、以下の処理を行う。
    ;  下位レジスタ＝元の5～4ビットの値を7～6ビットに設定
    ;  上位レジスタ＝元の7～6ビットの値を1～0ビットに設定
    LD A,B
    AND @00110000                   ; 5～4ビット目を取得
    ADD A,A                         ; 2ビット左シフト = 4倍なので2回ADDする。最初の値の5～4ビット目が7～6ビット目になる
    ADD A,A
    LD L,A                          ; 下位8ビットを設定

    LD A,B
    AND @11000000                   ; 7～6ビット目を取得
    RLCA                            ; 2回左ローテート = 1～0ビット目に値が設定される
    RLCA
    LD H,A                          ; 上位8ビットを設定

    ; ■X座標の算出を行う。
    ;  (マップチップ番号-1)の下位4ビットを取得し、2倍することで求める。
    LD A,B
    AND @00001111
    ADD A,A                         ; マップチップは2x2キャラクタなのでA=A*2する

    LD D,0
    LD E,A
    ADD HL,DE                       ; HLに横座標のアドレスを加算

    ; ■HLにオフスクリーンのアドレスを加算
    LD DE,OFFSCREEN+$0020
    ADD HL,DE

    POP DE
    RET


; ====================================================================================================
; マップデータ取得サブルーチン
; マップデータ番号からマップデータの取得を行う
; IN  : A = マップデータオフセット
; OUT : A = マップデータ
; ====================================================================================================
GET_MAPDATA:
    ; ■マップワークの先頭アドレスにマップデータオフセットを加算
    LD H,0                          ; HL <- A
    LD L,A

    LD DE,MAP_WK                    ; マップワークの先頭アドレス
    ADD HL,DE                       ; HL=HL+DE

    ; ■マップデータを取得
    LD A,(HL)
    RET


; ====================================================================================================
; キャラクター座標からマップデータのオフセットを求める
; IN  : BC = キャラクター座標(B=Y座標、C=X座標)
; OUT : A = マップデータ番号(0〜175)
; ====================================================================================================
GET_MAPDATA_OFFSET:
    ; ■プレイヤーキャラクターのY座標から、オフセット値を求める
    LD A,B                          ; A <- スプライトキャラクターのY座標(整数部)
    ADD A,6                         ; A=A+6
                                    ; - Y座標は8～なので-8
                                    ; - 判定座標はY座標+14
    AND %11110000                   ; 16で割って16掛ける＝下位4ビットをゼロにする
    LD D,A                          ; D <- A

    ; ■プレイヤーキャラクターのX座標から、オフセット値を求める
    LD A,C
    ADD A,8                         ; 判定座標を補正 A=A+8

    SRL A                           ; A=A/16
    SRL A
    SRL A
    SRL A
    ADD A,D                         ; A=A+D

;DEBUG
    LD HL,32+30
    CALL PRTHEX
;DEBUG END

GET_MAPDATA_OFFSET_EXIT:
    RET


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■マップワーク(176byte)
MAP_WK:
    DEFS 176

; ■チップセットのアドレス(2byte)
CHIPSET_WK:
    DEFS 2

; ■BGMのアドレス(2byte)
BGM_WK:
    DEFS 2
