; ====================================================================================================
;
; common.asm
;
; included from main.asm
;
; ====================================================================================================

SECTION code_user

; ====================================================================================================
; キー入力値取得サブルーチン
; @ToDo : 直前の入力値を退避するようにする（連射入力のため）
; ====================================================================================================
GET_CONTROL:
    CALL KILBUF                     ; BIOS キーバッファクリア
    OR A                            ; キャリーフラグクリア

    ; ■プレイヤー操作データ(STICK)を取得
    LD A,0                          ; A <- ジョイスティック番号=0(キーボード)
    CALL GTSTCK                     ; BIOS ジョイスティックの状態取得
                                    ; - Aレジスタに入力値が設定されている
    LD B,A                          ; B <- A

    PUSH BC                         ; BCレジスタを退避
    LD A,1                          ; A <- ジョイスティック番号=1(パッド1)
    CALL GTSTCK                     ; ジョイスティック入力取得
    POP BC                          ; BCレジスタを復帰
    OR B                            ; A=A OR B
                                    ; - キーボードとパッドの入力の OR を取る
                                    ;   最大で15となる

    LD (INPUT_BUFF_STICK), A        ; 現在の入力値を保存

    ; ■プレイヤー操作データ(STRIG)を取得
    LD D,0                          ; D <- 0
    LD A,0                          ; A <- ジョイスティック番号=0(キーボード)
    CALL GTTRIG                     ; BIOS トリガボタンの状態取得
                                    ; - $00 = 押されていない
                                    ; - $0FF = 押されている
    OR A
    JR Z,GET_CONTROL_L1
    LD D,1                          ; D <- 1

GET_CONTROL_L1:
    LD E,0                          ; E <- 0
    LD A,1                          ; A <- ジョイスティック番号=0(パッド1)
    CALL GTTRIG                     ; BIOS トリガボタンの状態取得
    OR A
    JR Z,GET_CONTROL_L2
    LD E,1                          ; E <- 1

GET_CONTROL_L2:
    LD A,D                          ; A=D OR E
    OR E                            

    LD (INPUT_BUFF_STRIG), A        ; 現在の入力値を保存

GET_CONTROL_EXIT:
    RET


; ====================================================================================================
; オフスクリーン初期化
; ====================================================================================================
CLEAR_OFFSCREEN:
    LD B,32*24/4
    LD HL,OFFSCREEN

CLEAR_OFFSCREEN_L1:
    LD (HL),$20
    INC HL
    LD (HL),$20
    INC HL
    LD (HL),$20
    INC HL
    LD (HL),$20
    INC HL
    DJNZ CLEAR_OFFSCREEN_L1

CLEAR_OFFSCREEN_EXIT:
    RET


; ====================================================================================================
; オフスクリーンの内容をVRAMに転送
; ====================================================================================================
DRAW_VRAM:
    LD HL,OFFSCREEN
    LD DE,PTN_NAME_ADDR
    LD BC,32*24
    CALL LDIRVM

DRAW_VRAM_EXIT:
    RET


; ====================================================================================================
; 文字列表示サブルーチン
; IN  : HL = 文字データのアドレス
; ====================================================================================================
PRTSTR:
    LD C,(HL)                       ; BC <- HLアドレスの示すオフセット値データ
    INC HL
    LD B,(HL)

    INC HL                          ; HL <- 文字列データの先頭アドレス
    PUSH HL                         ; HL -> DE
    POP DE

    LD HL,OFFSCREEN                 ; HL <- オフスクリーンバッファの先頭アドレス
    ADD HL,BC                       ; HL=HL+BC

PRTSTR_L1:
	LD A,(DE)				        ; AレジスタにDEレジスタの示すアドレスのデータを取得
	OR 0					        ; 0かどうか
    JR Z,PRTSTR_END			        ; 0の場合はPRTENDへ

    LD (HL),A                       ; オフスクリーンバッファに設定

	INC HL					        ; HL=HL+1
    INC DE					        ; DE=DE+1
    JR PRTSTR_L1

PRTSTR_END:
	RET


; ====================================================================================================
; 16進数表示サブルーチン
; IN  : A = 表示対象データ
;       HL = オフスクリーンバッファの表示オフセット値
; ====================================================================================================
PRTHEX:
    PUSH AF
    ; ■オフスクリーンバッファの設定先アドレス算出
    LD DE,OFFSCREEN                 ; DE <- オフスクリーンバッファの先頭アドレス
    ADD HL,DE                       ; HL=HL+DE

    ; ■表示対象データの上位4ビットに対する表示文字コード算出
    PUSH AF                         ; AFレジスタを一旦スタックに退避
    SRL A                           ; 右シフトx4
    SRL A
    SRL A
    SRL A
    CALL PRTHEX_GETCHR              ; Aレジスタの値からキャラクタコードを求める

    LD (HL),A                       ; オフスクリーンバッファに設定

    ; ■VRAMアドレスをインクリメント
    INC HL

    ; ■表示対象データの下位4ビットに対する表示文字コード算出
    POP AF                          ; AFレジスタをスタックから復帰
    AND @00001111                   ; 下位4ビットを取り出し
    CALL PRTHEX_GETCHR              ; Aレジスタの値からキャラクタコードを求める

    LD (HL),A                       ; オフスクリーンバッファに設定

PRTHEX_EXIT:
    POP AF
    RET

PRTHEX_GETCHR:
    OR A                            ; キャリーフラグリセット
    CP 10                           ; A < 10の場合はキャリーフラグが立つ
    JR C,PRTHEX_GETCHR_L1
    ADD A,$37                       ; A〜F
    RET

PRTHEX_GETCHR_L1:
    ADD A,$30                       ; 0〜9
    RET


; ====================================================================================================
; 絶対値減算サブルーチン
; IN  : A = 値１
;       B = 値２
; OUT : A = A-Bの絶対値
; ====================================================================================================
ABS_SUB:
    OR A
    SUB B                           ; A=A-B
    JP M,ABS_SUB_L1                 ; マイナスだったらABS_SUB_L1へ
    RET

ABS_SUB_L1:
    NEG                             ; 上記の結果を正負反転
	ADD A,$FF                       ; A=A+$FF
    ADD A,1                         ; さらに1加算して一巡させる
    RET


; ====================================================================================================
; アドレステーブルからのデータ取得サブルーチン
; IN  : HL = アドレステーブルのアドレス
;       A = 要素数(0～)
; OUT : DE = アドレステーブルから取得したデータ
; ====================================================================================================
GET_ADDR_TBL:
    RLCA                            ; A=A*2
    LD D,0                          ; DE <- アドレスのオフセット値
    LD E,A

    ADD HL,DE                       ; HL=HL+DE

    LD E,(HL)                       ; DE <- テーブルの値
    INC HL
    LD D,(HL)

GET_ADDR_TBL_EXIT:
    RET


; ====================================================================================================
; アドレステーブルによるジャンプ処理
; ジャンプ先の処理でRETすると、ここの処理に戻ってきます。
; IN  : HL = 対象テーブルの先頭アドレス
;       A = インデックスNo(0～)
; ====================================================================================================
TBL_JP:
    CALL GET_ADDR_TBL               ; アドレステーブルからデータ取得

    LD HL,TBL_JP_EXIT               ; 戻り先のアドレスをスタックに設定
    PUSH HL

    EX DE,HL                        ; HL <-> DE

    JP (HL)

TBL_JP_EXIT:
    RET


; ====================================================================================================
; 乱数初期化サブルーチン
; ====================================================================================================
INIT_RND:
    LD A,(INTCNT)
    LD (RND_WK),A                   ; 乱数のシード値を設定

INIT_RND_EXIT:
    RET


; ====================================================================================================
; 乱数取得サブルーチン
; 事前にINIT_RNDを実行しておくこと
; OUT : A = 0〜255の範囲の乱数
; ====================================================================================================
GET_RND:
    PUSH BC
    
    LD A,(RND_WK)                   ; 乱数のシード値を乱数ワークエリアから取得
    LD B,A
    LD A,B

    ADD A,A                         ; A=A*5
    ADD A,A                         ;
    ADD A,B                         ;

    ADD A,123                       ; 123を加える
    LD (RND_WK),A                   ; 乱数ワークエリアに保存

GET_RND_EXIT:
    POP BC
    RET


; ====================================================================================================
; 画面クリアサブルーチン
; HL,BC,Aレジスタを破壊します
; ====================================================================================================
SCREEN_CLRAR:
    LD HL,$1800+32*2                ; 書き込み開始アドレス
    LD BC,32*22                     ; 書き込みデータ長
    LD A,$20                        ; 書き込むデータ
    CALL FILVRM                     ; BIOS VRAM指定領域同一データ転送

SCREEN_CLRAR_EXIT:
    RET


; ------------------------------------------------------------------------------------------------
; 二進化十進値加算サブルーチン（6桁）
; IN  : HL = 加算対象データの先頭アドレス
;       DE = 加算値(BCD形式で4桁、1/100の値とする。例：12000＝0120)
; ------------------------------------------------------------------------------------------------
ADD_BCD_6:
    INC HL                      ; 6桁の1〜2桁目を最初に処理するため、アドレスを進めておく
    CALL ADD_BCD_4              ; 1〜4桁目までは既存の処理で加算

    ; ■5〜6桁目の加算
    ;   加算値は4桁までしかないので、桁繰り上がりの加算だけ行う
    RET NC                      ; キャリーが立っていなければ終了
    DEC HL
    LD A,(HL)                   ; 5〜6桁目に1加算
    INC A
    DAA
    LD (HL),A
    RET

; ------------------------------------------------------------------------------------------------
; 二進化十進値加算サブルーチン（4桁）
; IN  : HL = 加算対象データの先頭アドレス
;       DE = 加算値(BCD形式で4桁、1/100の値とする。例：12000＝0120)
; ------------------------------------------------------------------------------------------------
ADD_BCD_4:
    ; ■1〜2桁目の加算
    INC HL
	LD A,E					    ; AレジスタにEレジスタの値をロード
    ADD A,(HL)			        ; Aレジスタの値に(HL)の値を加算
    						    ; 桁溢れした場合はキャリーフラグが立つ
    DAA						    ; Aレジスタの値を内部10進に補正
    LD (HL),A				    ; Aレジスタの値を(HL)に格納
    
    ; ■3〜4桁目の加算
    DEC HL
    LD A,D					    ; AレジスタにDレジスタの値をロード
    ADC A,(HL)			        ; Aレジスタの値に(HL)＋キャリーフラグを加算
    						    ; 桁溢れした場合はキャリーフラグが立つが無視する
    DAA						    ; Aレジスタの値を内部10進に補正
    LD (HL),A				    ; Aレジスタの値を(HL)に格納

    RET


; ------------------------------------------------------------------------------------------------
; 内部10進数表示サブルーチン
; オフスクリーンバッファの指定したオフセットアドレスにBCD形式のデータを数値として表示する
; 表示する値のデータは、以下のように格納されたものとする
; [上位桁][下位桁] [上位桁][下位桁]…
; IN  : B = 表示するデータのバイト数(1バイト=2桁)
;       DE = 表示するデータのアドレス
;       HL = オフスクリーンバッファの設定先オフセットアドレス
; ------------------------------------------------------------------------------------------------
PRTBCD:
;    PUSH DE
;    PUSH BC

    PUSH BC
    LD BC,OFFSCREEN
    ADD HL,BC                   ; HLレジスタにオフセットアドレス＋オフスクリーンバッファ先頭アドレスを設定
    POP BC

PRTBCD_L1:
	CALL PRTBCD_L2			    ; データを表示

	INC DE					    ; BCレジスタの値を1加算(＝データの次のアドレスが設定される)
    INC HL					    ; HLレジスタの値を1加算(＝表示位置を1つ右に移動)

    DJNZ PRTBCD_L1              ; B=B-1、ゼロでなければL1へ

;    POP BC
;    POP DE
	RET

PRTBCD_L2:
	; ■上1桁の処理
    LD A,(DE)				    ; Aレジスタに表示データのアドレスの値をロード
    SRL A					    ; Aレジスタの値を4回右シフトして、上位4ビットを取り出す
    SRL A
    SRL A
    SRL A
    CALL PRTBCD_L3			    ; オフスクリーンバッファにデータ設定
    
	; ■下1桁の処理
	LD A,(DE)				    ; Aレジスタに表示データのアドレスの値をロード
    INC HL					    ; HLレジスタの値を1加算(＝データ表示位置を1つ右に移動)

PRTBCD_L3:
	; ■オフスクリーンバッファにデータ設定
	AND $0F				        ; 上位4ビットをゼロにする(=下位4ビットの値だけ取り出す)
    ADD A,$30				    ; 値にキャラクタコード&H30('0')を加える

    LD (HL),A                   ; オフスクリーンバッファにデータを設定

    RET


; ------------------------------------------------------------------------------------------------
; スコア加算サブルーチン
; スコアデータは3byteを前提とする。
; IN  : DE = 加算する値(BCD形式で1/100の値とする。
;            例)12000点＝0120
; ------------------------------------------------------------------------------------------------
ADDSCORE:

	; ■1〜2桁目の加算
	LD HL,SCORE+2			    ; HLレジスタにスコアデータのアドレス(1〜2桁目)を設定
	LD A,E					    ; AレジスタにEレジスタの値をロード
    ADD A,(HL)			        ; Aレジスタの値に(IX+2)の値を加算
                                ; 桁溢れした場合はキャリーフラグが立つ
    DAA						    ; Aレジスタの値を内部10進に補正
    LD (HL),A				    ; Aレジスタの値を(IX+2)に格納
    
    ; ■3〜4桁目の加算
    DEC HL                      ; HLレジスタにスコアデータのアドレス(3〜4桁目)を設定
    LD A,D					    ; AレジスタにDレジスタの値をロード
    ADC A,(HL)			        ; Aレジスタの値に(IX+1)＋キャリーフラグを加算
    						    ; 桁溢れした場合はキャリーフラグが立つ
    DAA						    ; Aレジスタの値を内部10進に補正
    LD (HL),A				    ; Aレジスタの値を(IX+1)に格納
    
    ; ■5〜6桁目の加算
    DEC HL                      ; HLレジスタにスコアデータのアドレス(5〜6桁目)を設定
    LD A,0					    ; Aレジスタに0をロード
    ADC A,(HL)				    ; Aレジスタに(IX)＋キャリーフラグの値を加算
    						    ; 桁溢れした場合はキャリーフラグが立つ
                                ; が、これ以上桁がないので無視する
    DAA						    ; Aレジスタの値を内部10進に補正
    LD (HL),A				    ; Aレジスタの値を(IX)に格納    

    ; ■エクステンド判定
    LD HL,NEXT_EXTEND_SCORE
    LD DE,SCORE
    LD B,3
ADDSCORE_L1:
    OR A
    LD A,(DE)                   ; A <- スコア
    INC DE                      ; 次の桁へ(2桁ずつ)
    SUB (HL)                    ; A=A-次回エクステンドスコア
    INC HL                      ; 次の桁へ(2桁ずつ)

    JP C,ADDSCORE_EXIT          ; スコア < 次回エクステンドスコアの場合は中断して抜ける

ADDSCORE_L2:
    DJNZ ADDSCORE_L1            ; 上位の桁がゼロの場合があるので、次の桁も調べる

    ; スコアが次回エクステンドスコアと同じ or 超えていたらここに入る
    ; エクステンド音
    LD Hl,SFX_02
    CALL SOUNDDRV_SFXPLAY

    ; 残機増加
    LD HL,LEFT
    INC (HL)
    CALL DRAW_INFO_INIT_L1      ; オフスクリーンに再表示

    ; 次回エクステンドスコア設定
    LD HL,NEXT_EXTEND_SCORE
    LD DE,$0500                 ; +50000pts
    CALL ADD_BCD_6

ADDSCORE_EXIT:
    RET


; ====================================================================================================
; HLレジスタにAレジスタを加算するサブルーチン
; IN  : A = 加算する値
;     : HL = 加算される値
; OUT : HL = 計算後の値
; ====================================================================================================
ADD_HL_A:
    ADD A,L
    JR NC,ADD_HL_A_L1
    INC H
ADD_HL_A_L1:
    LD L,A
    RET


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■乱数ワークエリア
RND_WK:
    DB 0

; ■入力バッファ(STICK)
; +0 : 現在の入力値
; +1 : 前回の入力値
INPUT_BUFF_STICK:
    DEFS 2

; ■入力バッファ(STRIG)
; +0 : 現在の入力値
; +1 : 前回の入力値
INPUT_BUFF_STRIG:
    DEFS 2

; ■オフスクリーンバッファ
OFFSCREEN:
    DEFS 32*24
