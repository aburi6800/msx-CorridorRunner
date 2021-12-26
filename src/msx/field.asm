; ====================================================================================================
;
; field.asm
;
; included from main.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; マップデータコピールーチン
; 対象ラウンドのマップデータをマップワークにコピーする
; 将来的に圧縮データにしたときの展開ルーチンもサポートできるように、別処理にしておく
; IN  : A = ラウンド数(0=タイトル)
; ====================================================================================================
COPY_MAP_DATA:
;    LD A,(ROUND)
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
; マップワークの情報から画面にマップを描画する
; 予め、マップデータコピールーチン(COPY_MAP_DATA)を実行してMAP_WKにデータを展開しておくこと
; ====================================================================================================
DRAW_MAP:
    ; ■ラウンドデータの取得先アドレス算出
    ; - 遡って取得するので、末端のアドレスを算出する
    LD HL,MAP_WK                    ; HL <- マップワーク
    LD BC,175                       ; BC <- ラウンドデータのbyte数-1
    ADD HL,BC                       ; HL=HL+BC

    ; ■フィールド描画ループ回数設定
    LD B,176                        ; フィールドデータカウント (176byte)
    
DRAW_MAP_L1:
    PUSH HL                         ; ラウンドデータの取得先アドレスをスタックに退避
    PUSH BC                         ; フィールドデータカウントをスタックに退避

    ; ■ラウンドデータからマップチップデータを取得
    LD A,(HL)                       ; A <- (HL)   
    CALL DRAW_MAPCHIP

DRAW_MAP_L2:
    POP BC                          ; BC <- スタック(フィールドデータカウント)
    POP HL                          ; HL <- スタック(ラウンドデータの取得先アドレス)
    DEC HL
    DJNZ DRAW_MAP_L1

DRAW_MAP_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; マップチップ描画
; IN  : A=マップチップ番号(0～3)
;       B=マップデータ番号(1～176)
; ----------------------------------------------------------------------------------------------------
DRAW_MAPCHIP:

    ; ■マップチップ番号からチップセットテーブルのアドレスオフセット値を求める
    PUSH AF                         ; マップチップ番号をスタックに退避
    ADD A,A                         ; A=A*4
    ADD A,A                         ;

    LD E,A                          ; BC <- チップセットテーブルのアドレスオフセット値
    LD D,0

    LD HL,(CHIPSET_WK)              ; HL <- チップセットテーブルのアドレス
    ADD HL,DE                       ; HL=HL+DE
    PUSH HL                         ; HL -> DE
    POP DE

    ; 左上
    CALL GET_CHIP_VRAMADDR
    LD A,(DE)
    CALL WRTVRM

    ; 右上
    INC HL                          ; HL=HL+1
    INC DE
    LD A,(DE)
    CALL WRTVRM

    ; 左下
    PUSH BC
    LD BC,31                        ; HL=HL+31
    ADD HL,BC                   
    POP BC
    INC DE
    LD A,(DE)
    CALL WRTVRM

    ; 右下
    INC HL                          ; HL=HL+1
    INC DE
    LD A,(DE)
    CALL WRTVRM

    POP AF                          ; スタックからマップチップ番号を復元
    OR A
    RET Z                           ; マップチップ番号=0なら抜ける

    ; 画面最下段か
    LD A,B                          ; A <- B
    CP 160                          ; A=A-160
    RET NC                          ; 160以上の場合は最下段なので抜ける

    ; 更に左下の情報を取得
    LD DE,31
    ADD HL,DE
    CALL RDVRM                      ; BIOS RDVRM
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
    CALL WRTVRM

    INC HL
    INC DE
    LD A,(DE)
    CALL WRTVRM

    RET


; ====================================================================================================
; マップデータ番号からマップチップ左上のVRAMアドレスを求める
; IN  : B = マップデータの番号(1～176)
; OUT : HL = 描画先のVRAMアドレス(左上)
; ====================================================================================================
GET_CHIP_VRAMADDR:
    PUSH DE

    DEC B                           ; BはDJNZする都合上1～なので、-1する

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

    ; ■HLに左上(=$1820)のVRAMアドレスを加算
    LD D,$18
    LD E,$20    
    ADD HL,DE

    INC B                           ; -1したBの値を+1して元に戻す

    POP DE
    RET


; ====================================================================================================
; キャラクター座標からマップデータの番号を求める
; IN  : BC = キャラクター座標(B=Y座標、C=X座標)
; OUT : A = マップデータ番号(1〜176)
; ====================================================================================================
GET_MAPDATA_NO:
    ; ■プレイヤーキャラクターのY座標から、オフセット値を求める
    LD A,B                          ; A <- スプライトキャラクターのY座標(整数部)
    SUB 2                           ; A=A-2
                                    ; - Y座標は16～なので-16
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
    INC A

;DEBUG
    LD HL,32+30
    CALL PRTHEX
;DEBUG END

GET_MAPDATA_NO_EXIT:
    RET


; ====================================================================================================
; マップデータ取得サブルーチン
; マップデータ番号からマップデータの取得を行う
; IN  : A = マップデータ番号
; OUT : A = マップデータ
; ====================================================================================================
GET_MAPDATA:
    SUB 1                           ; A=A-1(1〜176 <- 0〜175にする)
    LD H,0                          ; HL <- A
    LD L,A

    ; ■マップワークの先頭アドレスにオフセットアドレスを加算
    LD DE,MAP_WK                    ; マップワークの先頭アドレス
    ADD HL,DE                       ; HL=HL+DE

    ; ■マップデータを取得
    LD A,(HL)
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■ラウンドデータテーブル
ROUND_TBL:
    DW MAP_TITLE
    DW MAP_ROUND1
    DW $0000

; ■マップデータ
; 16byte x 11 = 176byte
MAP_TITLE:
    DB 1
    DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    DB 1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,1
    DB 1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,1
    DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

MAP_ROUND1:
    DB 0
    DB 0,1,1,2,0,0,0,1,1,0,0,0,0,1,1,1
    DB 1,1,0,0,0,0,0,2,2,0,0,0,0,1,1,1
    DB 1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1
    DB 1,1,1,1,1,0,0,1,1,0,0,0,0,1,1,1
    DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    DB 1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1
    DB 1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1
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
