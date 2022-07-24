; ====================================================================================================
;
; sprite.asm
;
; included from main.asm
;
; ====================================================================================================

INCLUDE "player.asm"
INCLUDE "explosion.asm"
INCLUDE "score.asm"
INCLUDE "enemy.asm"

SECTION code_user

; ■スプライトキャラクターワークの最大キャラクター数
MAX_CHR_CNT:                        EQU 20
; ■スプライトキャラクターワークの１キャラクターのサイズ
SPR_CHR_WK_SIZE:                    EQU 16

; ■座標リミット値
X_MAX:                              EQU 256-16
X_MIN:                              EQU 0
Y_MAX:                              EQU 192-16-8
Y_MIN:                              EQU 8

; ■移動方向の定数
DIRECTION_UP:                       EQU 1
DIRECTION_UPRIGHT:                  EQU 2
DIRECTION_RIGHT:                    EQU 3
DIRECTION_DOWNRIGHT:                EQU 4
DIRECTION_DOWN:                     EQU 5
DIRECTION_DOWNLEFT:                 EQU 6
DIRECTION_LEFT:                     EQU 7
DIRECTION_UPLEFT:                   EQU 8


; ====================================================================================================
; スプライトキャラクターワークテーブル初期化
; ====================================================================================================
INIT_SPR_CHR_WK_TBL:
    LD B,MAX_CHR_CNT                ; 最大キャラクター数

INIT_SPR_CHR_WK_TBL_L1:
    LD A,B
    CALL GET_SPR_WK_ADDR            ; スプライトキャラクターワークテーブルのアドレスを取得
    CALL INIT_SPR_CHR_WK            ; スプライトキャラクターワーク初期化
    DJNZ INIT_SPR_CHR_WK_TBL_L1

INIT_SPR_CHR_WK_TBL_EXIT:
    RET 


; ====================================================================================================
; スプライトキャラクターワーク初期化
; IN  : IX = 対象のワークアドレス（GET_SPR_WK_ADDRで取得済を前提）
; OUT : none
; ====================================================================================================
INIT_SPR_CHR_WK:

    LD (IX),$FF                     ; キャラクター番号
    LD (IX+1),0                     ; Y座標(小数)
    LD (IX+2),-17                   ; Y座標(整数)
    LD (IX+3),0                     ; X座標(小数)
    LD (IX+4),-16                   ; X座標(整数)
    LD (IX+5),0                     ; スプライトパターンNo
    LD (IX+5),0                     ; カラーコード
    LD (IX+7),0                     ; 移動方向
    LD (IX+8),0                     ; 移動量
    LD (IX+9),0                     ; アニメーションテーブルアドレス
    LD (IX+10),0                    ; アニメーションテーブルアドレス
    LD (IX+11),0                    ; アニメーションカウンタ
    LD (IX+12),0                    ; 出現中カウンタ

INIT_SPR_CHR_WK_EXIT:
    RET 


; ====================================================================================================
; スプライトキャラクターY座標ランダム値取得処理
; IN  : none
; OUT : A = Y座標(Y_MIN〜Y_MAX)
; ====================================================================================================
GET_RND_SPR_Y:
    CALL GET_RND                    ; 乱数取得(0〜255)
    CP Y_MAX+Y_MIN                  ; Y座標リミット値と比較
    JR NC,GET_RND_SPR_Y             ; Aが範囲外だったら再度乱数取得
    ADD A,Y_MIN                     ; オフセット加算
    RET


; ====================================================================================================
; スプライトキャラクターX座標ランダム値取得処理
; IN  : none
; OUT : A = X座標(X_MIN〜X_MAX)
; ====================================================================================================
GET_RND_SPR_X:
    CALL GET_RND                    ; A <- 乱数(0〜255)
    CP X_MAX                        ; X座標リミット値と比較
    JR NC,GET_RND_SPR_X             ; Aが(255-16)を超えていたら再度乱数取得
    RET


; ====================================================================================================
; スプライトキャラクターワークテーブルのアドレス値を求める
; SPR_CHR_WK_TBL+(テーブルINDEX*16)のアドレスを求めてIXレジスタに設定します。
; IN  : A = テーブルINDEX(1〜)
; OUT : IX = 対象INDEXのスプライトキャラクターワークアドレス
; USE : DE, HL
; ====================================================================================================
GET_SPR_WK_ADDR:
    PUSH AF

    ; ■スプライトキャラクターワークテーブルの先頭アドレス
    LD IX,SPR_CHR_WK_TBL            ; IXに設定

    ; ■算出対象かチェック
    OR A
    JR Z,GET_SPR_WK_ADDR_EXIT       ; A=0ならそのまま終了する

    ; ■オフセット値算出
    ; HLレジスタに(A-1)*16を求める
    DEC A                           ; INDEX値はDJNZループに使用されているBレジスタを想定しているため、
                                    ; デクリメントしておく
    LD H,0                          ; HL=A
    LD L,A

    ADD HL,HL                       ; HL=HL*16
    ADD HL,HL
    ADD HL,HL
    ADD HL,HL

    ; ■スプライトキャラクターワークテーブルのアドレス算出
    LD DE,SPR_CHR_WK_TBL            ; DE <- スプライトキャラクターワークテーブルの先頭アドレス
    ADD HL,DE                       ; HL=HL+DE

    PUSH HL                         ; HL -> IX
    POP IX

GET_SPR_WK_ADDR_EXIT:
    POP AF
    RET 


; ====================================================================================================
; スプライトキャラクター移動処理
; 事前にIXにスプライトキャラクターワークテーブルの先頭アドレスを設定済であること
; また、(IX+12)がゼロ以外の場合は移動せず、1ブレームごとに表示・非表示を切り替える
; @ToDo:IXレジスタの使用を最小限に抑えたい
; ====================================================================================================
SPRITE_MOVE:
    ; ■出現中カウンタを取得
    LD A,(IX+12)
    OR A
    JR NZ,SPRITE_FLASHING           ; 出現中カウンタ>0の時は点滅処理へ

    ; ■移動量増分を取得
    LD A,(IX+8)                     ; D <- 移動量増分
    OR A
    RET Z                           ; 移動量増分=ゼロなら移動不要のため処理終了
    CP $FF
    JR NZ,SPRITE_MOVE_L1            ; 移動量増分<>$FFなら移動処理を行う

    ; ■移動量1/2の処理    
    LD A,(TICK1)                    ; TICKカウントを取得
    AND @00000001                   ; 下位1ビットを取得
    RET Z                           ; ゼロ(偶数フレーム)の時は処理終了
                                    ; なお、ゼロでない場合は、直前のAND演算でAレジスタは1となっている

SPRITE_MOVE_L1:
    ; ■移動量増分をループカウンタとしてBレジスタに設定
    LD B,A

SPRITE_MOVE_L2:
    ; ■対象スプライトキャラクターの移動方向から移動量データのアドレス算出
    LD A,(IX+7)                     ; A=移動方向
    OR A                            ; 移動方向が0(=移動しない)場合は終了
    RET Z

SPRITE_MOVE_L3:
    ; ■移動量データの取得
    RLCA                            ; A=A*2
    RLCA                            ; A=A*2、ここで移動量データのオフセットがAに設定される

    LD HL,MOVE_DATA                 ; HLレジスタに移動量データのアドレスを設定
    ADD HL,A

    PUSH HL                         ; HL -> IY
    POP IY

    ; ■Y座標計算
    LD H,(IY+1)                     ; HL <- 移動量データ小数部(Y方向)
    LD L,(IY)

    LD D,(IX+2)                     ; DE <- Y座標
    LD E,(IX+1)
    ADC HL,DE                       ; HL=HL+DE

    ; ■Y座標画面下限チェック
    LD A,H                          ; A <- Y座標(整数部)
    CP Y_MAX                        ; 画面下限を超えたか
    JR C,SPRITE_MOVE_L4             ; キャリーフラグがONの場合は画面内なのでSPRITE_MOVE_L0へ
 
    LD H,Y_MAX                      ; Y座標(整数部)=Y_MAX
    LD L,0                          ; Y座標(小数部)=0
    JR C,SPRITE_MOVE_L5             ; 上限の判定は不要なので次のチェックへ

SPRITE_MOVE_L4:
    ; ■Y座標画面上限チェック
    CP Y_MIN                        ; 画面上限を超えたか
    JR NC,SPRITE_MOVE_L5            ; キャリーフラグがOFFの場合は画面内なのでSPRITE_MOVE_L1へ
    LD H,Y_MIN                      ; Y座標(整数部)=Y_MIN
    LD L,0                          ; Y座標(小数部)=0

SPRITE_MOVE_L5:
    ; ■Y座標を保存
    LD (IX+2),H                     ; H -> Y座標(整数部)
    LD (IX+1),L                     ; L -> Y座標(小数部)

    ; ■X座標計算
    LD H,(IY+3)                     ; HL <- 移動量データ(X方向)
    LD L,(IY+2)

    LD D,(IX+4)                     ; DE <- X座標
    LD E,(IX+3)
    ADC HL,DE                       ; HL=HL+DE

    ; ■X座標画面端チェック
    LD A,H                          ; 座標値チェック
    CP X_MAX                        ; A=A-X_MAX
    JR C,SPRITE_MOVE_L6             ; キャリーフラグがONの場合は画面内なのでSPRITE_MOVE_L2へ

    ; ■一旦右端として座標値を設定する
    LD H,X_MAX                      ; X座標(整数部)=X_MAX
    LD L,0                          ; X座標(小数部)=0

    OR A
    CP 256-8                        ; 最大移動量を8と仮定した比較
    JR C,SPRITE_MOVE_L6             ; キャリーフラグがOFF(=画面左部にはみ出てた場合)はHはそのままで良いのでSPRITE_MOVE_L2へ

    LD H,X_MIN                      ; X座標(整数部)=0
    LD L,0                          ; X座標(小数部)=0

SPRITE_MOVE_L6:
    ; ■X座標を保存
    LD (IX+4),H
    LD (IX+3),L

    DJNZ SPRITE_MOVE_L2

    CALL SPRITE_ANIM                ; スプライトパターン番号更新

    RET

; ----------------------------------------------------------------------------------------------------
; スプライト点滅処理
; カウンタが奇数の時は現在の座標を退避して画面外に設定、偶数の時は退避した座標を戻す
; 最初に必ずカウンタを-1するので、カウンタの設定値は必ず偶数にすること
; ----------------------------------------------------------------------------------------------------
SPRITE_FLASHING:

    PUSH IX
    POP HL
    INC HL                          ; IX+1

    DEC (IX+12)                     ; 出現中カウンタ -1
    JR Z,SPRITE_FLASHING_L1         ; ゼロなら点滅終了処理へ

    LD A,(IX+12)
    AND @00000001
    JR NZ,SPRITE_FLASHING_L2

SPRITE_FLASHING_L1:

    ; ■偶数フレーム、点滅終了時の処理
    ; ワークから座標値を戻す
    ; Y座標(小数値) → Y座標(整数値) へ設定
    LD A,(HL)                       ; A <- Y座標(小数部)
    LD (IX+2),A                     ; A -> Y座標(整数部)
    LD (HL),0                       ; Y座標(小数部)をクリア
    ; X座標(小数値) → X座標(整数値) へ設定
    INC HL
    INC HL                          ; IX+3
    LD A,(HL)                       ; A <- X座標(小数部)
    LD (IX+4),A                     ; A -> X座標(整数部)
    LD (HL),0                       ; X座標(小数部)をクリア

    RET

SPRITE_FLASHING_L2:
    ; ■奇数フレーム
    ; ワークに座標値を退避して、それぞれ-16に設定する
    ; Y座標(整数値)
    LD A,(IX+2)                     ; A <- Y座標(整数部)
    LD (HL),A                       ; A -> Y座標(小数部)
    LD (IX+2),-16                   ; Y座標(整数部)を-16(画面外)に設定
    ; X座標(整数値)
    LD A,(IX+4)                     ; A <- X座標(整数部)
    INC HL
    INC HL                          ; IX+3
    LD (HL),A                       ; A -> X座標(小数部)
    LD (IX+4),-16                   ; X座標(整数部)を-16(画面外)に設定

    RET


; ====================================================================================================
; 移動量計算サブルーチン
; IN  : HL = 移動量データ(上位＝小数部、下位＝整数部)
;       A = 移動量(ビット7＝0:左シフト、1:右シフト、ビット6〜0＝シフト量) 
; 破壊: BC
; ====================================================================================================
CALCULATE_MOVE_VALUE:
    ; ■移動量のビット7が立っていたら除算、以外は乗算
    PUSH AF
    AND %10000000
    JR NZ,CALCULATE_MOVE_VALUE_DIVIDE

 ALCULATE_MOVE_VALUE_MULTIPLE:
    ; ■Aレジスタの値をBレジスタに設定
    POP AF
    AND %01111111

    OR A
    RET Z

    ; ■Aレジスタの値をBレジスタに設定
    LD B,A

CALCULATE_MOVE_VALUE_MULTIPLE_L1:
;    ADD HL,HL
    SRA H
    JR NC,CALCULATE_MOVE_VALUE_MULTIPLE_L2
    INC L
CALCULATE_MOVE_VALUE_MULTIPLE_L2:
    DJNZ CALCULATE_MOVE_VALUE_MULTIPLE_L1

    RET

CALCULATE_MOVE_VALUE_DIVIDE:
    ; ■Aレジスタの0〜6ビット目だけ取得
    POP AF
    AND %01111111

    OR A
    RET Z

    ; ■Aレジスタの値をBレジスタに設定
    LD B,A

CALCULATE_MOVE_VALUE_DIVIDE_L1:
    SRL H
    JR NC,CALCULATE_MOVE_VALUE_DIVIDE_L2
;    RR L
    DEC L
CALCULATE_MOVE_VALUE_DIVIDE_L2:
    DJNZ CALCULATE_MOVE_VALUE_DIVIDE_L1

    RET


; ====================================================================================================
; キャラクター衝突判定処理
; 2つのキャラクターの座標を比較して、衝突していた場合はキャリーフラグを立てて戻る
; DE,HLレジスタの値を破壊します
; IN  : A = 比較先のスプライトキャラクターワークテーブルのインデックス
; OUT : キャリーフラグ(ON=衝突している、OFF=衝突していない)
; ====================================================================================================
HIT_CHECK:

    ; ■比較先のキャラクター番号からスプライトキャラクターワークテーブルのアドレスを求める
    ; - IXレジスタは比較元の情報として残しておきたいので、一度スタックに退避し、
    ;   ここで取得したアドレスはHLレジスタに入れておく
    PUSH IX                         ; 現在のIXを退避
    CALL GET_SPR_WK_ADDR
    PUSH IX                         ; IX -> HL
    POP HL
    POP IX                          ; 元のIXを復元

    ; ■Y座標の比較
    OR A                            ; キャリーフラグリセット
    LD A,(IX+2)                     ; A <- 比較元のY座標
    INC HL                          ; B <- 比較先のY座標
    INC HL
    LD B,(HL)                   
    CALL ABS_SUB                    ; 差分を絶対値で取得
    CP 10                           ; A < 10 の場合はキャリーフラグが立つ
    JR NC,HIT_CHECK_EXIT            ; キャリーフラグが立っていない場合は終了

    ; ■X座標の比較
    LD A,(IX+4)                     ; A <- 比較元のX座標
    INC HL                          ; B <- 比較先のX座標
    INC HL
    LD B,(HL)
    CALL ABS_SUB                    ; 差分を絶対値で取得
    CP 10                           ; A < 10 の場合はキャリーフラグが立つ

HIT_CHECK_EXIT:
    RET


; ====================================================================================================
; スプライトパターン番号更新サブルーチン
; ====================================================================================================
SPRITE_ANIM:

    ; ■アニメーションテーブルのアドレスを取得
    LD L,(IX+9)
    LD A,L
    LD H,(IX+10)
    OR H
    RET Z                           ; ゼロ（未設定）なら抜ける

    ; ■アニメーションカウンタからアニメーションパターン番号のアドレス算出
    LD A,(IX+11)                    ; A <- アニメーションカウンタ
SPRITE_ANIM_L1:
    LD B,0                          ; BC <- アニメーションカウンタ
    LD C,A
    ADD HL,BC                       ; HL=HL+BC
    ; ■アニメーションカウンタを１つ進める
    INC A
    LD (IX+11),A

	; ■アニメーションパターン番号を取得する
	LD A,(HL)					    ; A <- (HL) (=アニメーションテーブルから取得したパターン番号)
    CP $FF                          ; $FF(=アニメーションパターンの終端)かどうか
    JR NZ,SPRITE_ANIM_L2            ; 終端でない場合はSPRITE_ANIM_L3にジャンプ

    ; ■終端のときの処理
    ;   アニメーションカウンタをリセットして再度アドレス算出
    ;   アニメーションテーブルのアドレスを設定し、テーブルに$FF歯科設定されてない場合は
    ;   無限ループしてしまうので、必ずパターン番号を１つでも設定すること。
    XOR A
    LD (IX+11),A
    LD L,(IX+9)
    LD H,(IX+10)
    JP SPRITE_ANIM_L1

SPRITE_ANIM_L2:
	LD (IX+5),A		                ; A -> スプライトパターン番号
    RET

; ====================================================================================================
; キャラクター登録サブルーチン
; １．スプライトキャラクターワークテーブルの空きを調べる
; ２．空いてなかったら終了する
; ３．空いていたらその要素に対して指定されたキャラクター番号の初期化処理を実行する
;
; 最大キャラクター数に達している場合は何もせずに終了する
; キャラクター登録可能な場合は、キャラクター登録数を増加させて対象キャラクター番号の
; データをスプライトキャラクターワークテーブルに登録する
; IN  : A = 対象のキャラクター番号(1〜)
; ====================================================================================================
ADD_CHARACTER:
    ; ■レジスタ退避
    PUSH HL
    PUSH DE
    PUSH BC
    PUSH AF

    LD B,MAX_CHR_CNT                ; B=最大キャラクター数
    LD HL,SPR_CHR_WK_TBL            ; HL <- スプライトキャラクターワークテーブル
    LD DE,16                        ; アドレス増分

ADD_CHARACTER_L1:
    LD A,(HL)                       ; A <- キャラクター番号
    OR A
    JR Z,ADD_CHARACTER_L2           ; キャラクター番号がゼロなら登録処理へ
    CP $FF
    JR Z,ADD_CHARACTER_L2           ; キャラクター番号が$FFでも登録処理へ

    ADD HL,DE                       ; HL=HL+16
    DJNZ ADD_CHARACTER_L1

    ; ■レジスタ復帰
    POP AF
ADD_CHARACTER_EXIT:
    POP BC
    POP DE
    POP HL
    RET

ADD_CHARACTER_L2:
    LD IX,HL                        ; IX <- HL

    POP AF                          ; AFレジスタ(=キャラクター番号)をスタックから復元
    DEC A
    LD HL,CHARACTER_INIT_TABLE      ; HL <- キャラクター初期化テーブルのアドレス
    CALL TBL_JP                     ; 各キャラクタの初期処理を呼び出す
                                    ; 各初期処理では、IXレジスタの指すアドレスに
                                    ; 各値を設定していく
    JP ADD_CHARACTER_EXIT


; ====================================================================================================
; キャラクター削除サブルーチン
; IN  : IX = 対象のスプライトキャラクターワークテーブルの先頭アドレス
; ====================================================================================================
DEL_CHARACTER:
    ; ■属性を$FFにする
    LD (IX),$FF
    ; ■座標値を画面外に設定
    LD (IX+2),-16
    LD (IX+4),-16

DEL_CHARACTER_EXIT:
    RET


; ====================================================================================================
; キャラクターワークテーブル除去サブルーチン
; 属性が$FFのものについて、$00に更新する
; この処理を単独で実行してもスプライトの表示は残るので注意。
; DEL_CHARACTERを使用すること。
; IN  : IX = 対象のスプライトキャラクターワークテーブルの先頭アドレス
; ====================================================================================================
REMOVE_CHARACTER:
    ; ■属性を$00にする
    LD (IX),$00

REMOVE_CHARACTER_EXIT:
    RET


; ====================================================================================================
; スプライトキャラクターワークテーブルからスプライトアトリビュートワークテーブルを設定する
; ====================================================================================================
SET_SPR_ATR_WK:
    LD B,MAX_CHR_CNT                ; スプライトキャラクター分繰り返し
    LD HL,SPR_CHR_WK_TBL            ; スプライトキャラクターワークテーブルの先頭アドレス
    LD DE,SPR_ATR_WK_TBL            ; スプライトアトリビュートワークテーブルの先頭アドレス

SET_SPR_ATR_WK_L1:
    ; ■Y座標
    INC HL                          ; HL=HL+2 (Y座標の上位1バイトのアドレス)
    INC HL
    LD A,(HL)                       ; (HL)→A
    LD (DE),A                       ; A→(DE)

    ; ■X座標
    INC HL                          ; HL=HL+2 (X座標の上位1バイトのアドレス)
    INC HL
    LD A,(HL)                       ; (HL)→A
    INC DE                          ; DE=DE+1
    LD (DE),A                       ; A→(DE)

    ; ■スプライトパターンNo
    INC HL                          ; HL=HL+1
    LD A,(HL)                       ; (HL)→A
    ADD A,A                         ; A=A*4 (スプライトが16x16なので、パターンNoを4倍する)
    ADD A,A
    INC DE                          ; DE=DE+1
    LD (DE),A                       ; A→(DE)

    ; ■カラーコード
    INC HL                          ; HL=HL+1
    LD A,(HL)                       ; (HL)→A
    INC DE                          ; DE=DE+1
    LD (DE),A                       ; A→(DE)

    ; ■設定元のスプライトキャラクターワークテーブルのアドレスを次の先頭アドレスへ
    PUSH BC                         ; 3
    LD BC,10                        ; 3 HL=HL+10
    ADD HL,BC                       ; 3
    POP BC                          ; 3
    
    ; ■設定先のスプライトアトリビュートワークテーブルのアドレスを次の先頭アドレスへ
    INC DE                          ; DE=DE+1

    DJNZ SET_SPR_ATR_WK_L1

SET_SPR_ATR_WK_EXIT:
    RET


; ====================================================================================================
; スプライトアトリビュートエリア設定
; ====================================================================================================
SET_SPR_ATTR_AREA:
    LD HL,SPR_ATR_WK_TBL            ; スプライトアトリビュートワークテーブル
    LD DE,SPR_ATR_ADDR              ; スプライトアトリビュートエリア
    LD BC,4*MAX_CHR_CNT             ; 転送バイト数(4byte*キャラクター数)
    CALL LDIRVM                     ; BIOS VRAMブロック転送

SET_SPR_ATTR_AREA_EXIT:
    RET 


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■移動量データ
; 上位：、下位：小数部の加算値
; Y座標、X座標の移動量をSTICKの値の順に定義
; 9以降は両方同時に入力された時のためのダミーデータ(最大15となる)
MOVE_DATA:
    DW $0000,$0000                  ; STICK=0(未入力)
    DW $FF00,$0000                  ; STICK=1(上)
    DW $FF4F,$00B0                  ; STICK=2(右上)
    DW $0000,$0100                  ; STICK=3(右)
    DW $00B0,$00B0                  ; STICK=4(右下)
    DW $0100,$0000                  ; STICK=5(下)
    DW $00B0,$FF4F                  ; STICK=6(左下)
    DW $0000,$FF00                  ; STICK=7(左)
    DW $FF4F,$FF4F                  ; STICK=8(左上)
    DW $0000,$0000                  ; STICK=9
    DW $0000,$0000                  ; STICK=10
    DW $0000,$0000                  ; STICK=11
    DW $0000,$0000                  ; STICK=12
    DW $0000,$0000                  ; STICK=13
    DW $0000,$0000                  ; STICK=14
    DW $0000,$0000                  ; STICK=15

; ■キャラクター初期化テーブル
;   キャラクター番号に対応
CHARACTER_INIT_TABLE:
    DW INIT_PLAYER                  ; PLAYER
    DW INIT_PLAYER2                 ; PLAYER2
    DW INIT_EXPLOSION               ; EXPLOSION
    DW INIT_SCORE                   ; SCORE
    DW INIT_ENEMY1                  ; ENEMY1
    DW INIT_ENEMY2                  ; ENEMY2
    DW INIT_ENEMY3                  ; ENEMY3

; ■キャラクターロジックテーブル
;   キャラクター番号に対応
CHARACTER_UPDATE_TABLE:
    DW UPDATE_PLAYER                ; PLAYER
    DW UPDATE_PLAYER2               ; PLAYER2
    DW UPDATE_EXPLOSION             ; EXPLOSION
    DW UPDATE_SCORE                 ; SCORE
    DW UPDATE_ENEMY1                ; ENEMY1
    DW UPDATE_ENEMY2                ; ENEMY2
    DW UPDATE_ENEMY3                ; ENEMY3


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■スプライトキャラクターワークテーブル(16Byte)
; +0:キャラクター番号
; +1:Y座標(小数部)
; +2:Y座標(整数部)
; +3:X座標(小数部)
; +4:X座標(整数部)
; +5:スプライトパターンNo(1～64)
; +6:カラーコード(0=非表示)
; +7:移動方向(STICKの値に対応)  
; +8:移動量($00=移動なし、$01=1倍速、$02=2倍速,$03=3倍速…、$FF=1/2倍速)
; +9〜10:アニメーションテーブルアドレス
; +11:アニメーションカウンタ
; +12:出現中カウンタ
; +13:汎用
; +14:汎用
; +15:汎用
SPR_CHR_WK_TBL:
    DEFS SPR_CHR_WK_SIZE*MAX_CHR_CNT

; ■スプライトアトリビュートワークテーブル(4byte*n)
; +0:スプライトアトリビュート1バイト目(Y座標)
; +1:スプライトアトリビュート2バイト目(X座標)
; +2:スプライトアトリビュート3バイト目(スプライトパターンNo)
; +3:スプライトアトリビュート4バイト目(カラーコード)
SPR_ATR_WK_TBL:
	DEFS 4*MAX_CHR_CNT
