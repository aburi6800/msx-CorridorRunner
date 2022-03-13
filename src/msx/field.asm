; ====================================================================================================
;
; field.asm
;
; included from main.asm
;
; ====================================================================================================
SECTION code_user

    MAPDATA_SIZE:                   EQU 176

; ====================================================================================================
; マップデータコピールーチン
; 対象ラウンドのマップデータをマップワークにコピーする
; 将来的に圧縮データにしたときの展開ルーチンもサポートできるように、別処理にしておく
; IN  : A = ラウンド数
; ====================================================================================================
COPY_MAP_DATA:
    DEC A
    LD HL,ROUND_TBL
    CALL GET_ADDR_TBL               ; DE <- マップデータの先頭アドレス

    ; ■マップデータの先頭1byte(チップセット番号)からチップセットテーブルのアドレスをおワークに設定する
    PUSH DE
    LD A,(DE)                       ; A <- チップセット番号
    LD HL,CHIPSET_TBL
    CALL GET_ADDR_TBL               ; DE <- チップセットデータの先頭アドレス
    LD HL,CHIPSET_WK
    LD (HL),E
    INC HL
    LD (HL),D
    POP DE
    INC DE

    ; ■マップデータの先頭アドレスから176byteをマップワークにブロック転送する
    LD H,D                          ; HL=転送元アドレス(DE)
    LD L,E
    LD DE,MAP_WK                    ; DE=転送先アドレス(MAP_WK)
    LD BC,176                       ; BC=転送データ数(byte)
    LDIR                            ; ブロック転送(HL->DE * BC)

COPY_MAP_DATA_EXIT:
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


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■ラウンドデータテーブル
ROUND_TBL:
    DW MAP_ROUND1
    DW $0000

; ■マップデータ
;   1byte : チップセット番号(0～3)
; 176byte : フィールドデータ(16byte x 11line)
;   2byte : プレイヤーの初期位置（Y座標、X座標)
;   1byte : 敵番号、$FF=終端。
;   7byte : $FF以外の場合は以降にY座標、X座標、方向、汎用データ（4byte)を設定。
MAP_ROUND1:
    DB 0
    DB 0,1,1,2,0,0,0,1,1,0,0,0,0,1,1,1
    DB 1,1,0,0,0,0,0,2,2,0,0,0,0,1,1,1
    DB 1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1
    DB 1,1,1,1,1,0,0,1,1,0,0,0,0,1,1,1
    DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    DB 1,1,2,2,2,1,1,1,1,1,1,1,1,1,1,1
    DB 1,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1
    DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    DB 1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1
    DB 1,1,1,0,0,0,1,1,1,1,0,0,0,0,1,1
    DB 1,1,1,0,0,0,1,1,3,1,0,0,2,1,1,0

; ■チップセットテーブル
; パターン1
CHIPSET_TBL:
    DW CHIPSET_1
    DW CHIPSET_2
    DW CHIPSET_3
    DW CHIPSET_4
CHIPSET_1:
    DB $20, $20, $20, $20
    DB $60, $61, $62, $63
    DB $64, $65, $66, $67
    DB $69, $6A, $6B, $6C
    DB $68, $68, $00, $00
CHIPSET_2:
    DB $20, $20, $20, $20
    DB $70, $71, $72, $73
    DB $74, $75, $76, $77
    DB $79, $7A, $7B, $7C
    DB $78, $78, $00, $00
CHIPSET_3:
    DB $20, $20, $20, $20
    DB $80, $81, $82, $83
    DB $84, $85, $86, $87
    DB $89, $8A, $8B, $8C
    DB $88, $88, $00, $00
CHIPSET_4:
    DB $20, $20, $20, $20
    DB $90, $91, $92, $93
    DB $94, $95, $96, $97
    DB $99, $9A, $9B, $9C
    DB $98, $98, $00, $00

SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■マップワーク(176byte)
MAP_WK:
    DEFS 176

; ■チップセットテーブルのアドレス(2byte)
CHIPSET_WK:
    DEFS 2
