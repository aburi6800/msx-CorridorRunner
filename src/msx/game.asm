; ====================================================================================================
;
; game.asm
;
; included from main.asm
;
; ====================================================================================================

SECTION code_user

; ■最大ラウンド数
MAX_ROUND               EQU 7       ; 最大ラウンド数 - 1 を設定する

; ■ゲーム状態の定数
STATE_INIT:             EQU 0       ; ゲーム状態:初期処理
STATE_TITLE:            EQU 1       ; ゲーム状態:タイトル
STATE_GAME_INIT:        EQU 2       ; ゲーム状態:ゲーム初期化
STATE_ROUND_START:      EQU 3       ; ゲーム状態:ラウンド開始
STATE_GAME_MAIN:        EQU 4       ; ゲーム状態:ゲームメイン
STATE_GAME_OVER:        EQU 5       ; ゲーム状態:ゲームオーバー
STATE_ROUND_CLEAR:      EQU 6       ; ゲーム状態:ラウンドクリアー
STATE_ALL_CLEAR:        EQU 7       ; ゲーム状態:オールクリアー

COLOR_TBL_CHG_DATA_CNT  EQU 12      ; カラーテーブルパターン数

; ====================================================================================================
; ゲーム処理
; ====================================================================================================
GAME:
    ; ■経過時間をカウントアップ
    CALL TICK_COUNT                 ; 初回はゼロフラグが立つ
    PUSH AF                         ; フラグを退避

    ; ■ゲーム状態の値からジャンプテーブルアドレスのオフセット値を求める
    LD A,(GAME_STATE)               ; A <- ゲーム状態
    LD C,A                          ; A=A*3
    ADD A,A
    ADD A,C

    LD B,0                          ; BC <- ジャンプテーブルのオフセット値
    LD C,A

    ; ■ジャンプテーブルの該当ステップにジャンプ
    POP AF                          ; フラグを復元
    LD HL,GAME_RET                  ; 各ルーチンからのRET先のアドレスをスタックに積む
    PUSH HL
    LD HL,GAME_L1                   ; HL <- ジャンプテーブルのアドレス
    ADD HL,BC                       ; HL=HL+BC（ゼロフラグは変化しない）
    JP (HL)

GAME_L1:
    JP GAME_GLOBAL_INIT             ; ゲーム状態:初期処理
    JP GAME_TITLE                   ; ゲーム状態:タイトル
    JP GAME_INIT                    ; ゲーム状態:ゲーム初期化
    JP ROUND_START                  ; ゲーム状態:ラウンド開始
    JP GAME_MAIN                    ; ゲーム状態:ゲームメイン
    JP GAME_OVER                    ; ゲーム状態:ゲームオーバー
    JP ROUND_CLEAR                  ; ゲーム状態:ラウンドクリアー
    JP ALL_CLEAR                    ; ゲーム状態:オールクリアー

GAME_RET:
    ; ■キー入力値取得
    CALL GET_CONTROL

    ; ■画面更新
    CALL DRAW

    RET


; ====================================================================================================
; ゲーム状態変更
; IN A  : 変更するゲーム状態の値
; ====================================================================================================
CHANGE_STATE:
    LD (GAME_STATE),A
    CALL TICK_RESET                 ; 経過時間リセット
    RET


; ====================================================================================================
; 経過時間リセット
; ====================================================================================================
TICK_RESET:
    XOR A                           ; A <- 0
    LD (TICK1+0),A
    LD (TICK1+1),A

    LD (TICK2_WK+0),A
    LD (TICK2_WK+1),A
    LD (TICK2+0),A
    LD (TICK2+1),A

    LD (TICK3_WK+0),A
    LD (TICK3_WK+1),A
    LD (TICK3+0),A
    LD (TICK3+1),A

    RET


; ====================================================================================================
; 経過時間カウント
; 各状態では処理に入った直後にゼロフラグを判定することで、初回処理を行うタイミングを判断できる
; ====================================================================================================
TICK_COUNT:
    ; DEBUG
    LD A,(IS_DEBUG)
    OR A
    JR Z,TICK_COUNT_L0

    LD HL,28
    LD A,(TICK1+1)
    CALL PRTHEX
    LD HL,30
    LD A,(TICK1)
    CALL PRTHEX
    ; DEBUGここまで

TICK_COUNT_L0:
    ; ■TTICK2の処理
    ;   TICK1の処理で設定したゼロフラグの状態を買えたくないので先に処理する
    LD A,(TICK2_WK)
    INC A
    CP 6
    JR NZ,TICK_COUNT_L1

    ; - TICK2_WKが6になったらTICK2をカウントアップし、TICK2_WKをゼロにリセット
    XOR A
    LD HL,TICK2
    INC (HL)

TICK_COUNT_L1:
    LD (TICK2_WK),A

    ; ■TICK3の処理
    ;   TICK1の処理で設定したゼロフラグの状態を買えたくないので先に処理する
    LD A,(TICK3_WK)
    INC A
    CP 60
    JR NZ,TICK_COUNT_L2

    ; - TICK3_WKが60になったらTICK3をカウントアップし、TICK3_WKをゼロにリセット
    XOR A
    LD HL,TICK3
    INC (HL)

TICK_COUNT_L2:
    LD (TICK3_WK),A

    ; ■TICK1の処理
    LD HL,(TICK1)                   ; HL <- TICKの値

    ; - TICK1=ゼロの場合、初回処理のためにゼロフラグを立てる
    LD A,H                          ; HL=0の場合、ゼロフラグが立つ
    OR L

    INC HL                          ; TICKをカウントアップ(フラグは変化しない)
    JR Z,TICK_COUNT_L3              ; ゼロフラグが立っていたら次の処理へ

    ; - インクリメントした結果、一巡した場合はゼロフラグを立てなくないので1に設定する
    LD A,H                          ; ゼロでなければ次の処理へ
    OR L
    JR NZ,TICK_COUNT_L3

    LD L,1                          ; 1にリセット
    LD H,0

TICK_COUNT_L3:
    LD (TICK1),HL

    RET


; ====================================================================================================
; オフスクリーンリセット
; ====================================================================================================
RESET_OFFSCREEN:
    CALL CLEAR_OFFSCREEN
    CALL DRAW_INFO_INIT
    RET


; ====================================================================================================
; 画面更新
; @ToDo ここは本来はVSYNCの処理の中でやるべきか？
; ====================================================================================================
DRAW:
    DI
    ; ■スプライト設定
    CALL SET_SPR_ATR_WK             ; スプライトキャラクターワークテーブルからスプライトアトリビュートワークテーブルを設定
    CALL SET_SPR_ATTR_AREA          ; スプライトアトリビュートエリア設定

    ; ■カラーテーブル更新
    CALL UPDATE_COLOR_TBL

    ; ■パターンネームテーブル設定
    CALL DRAW_INFO                  ; 情報描画
    CALL DRAW_VRAM                  ; オフスクリーンバッファの内容をVRAMに転送
    EI

DRAW_EXIT:
    RET

; -----------------------------------------------------------------------------------------------------
; カラーテーブル更新
; -----------------------------------------------------------------------------------------------------
UPDATE_COLOR_TBL:
    LD A,(TICK1)
    AND %00001111
    CP 1
    RET NZ

    LD A,(COLOR_TBL_CNT)
    OR A
    JR NZ,UPDATE_COLOR_TBL_L1

    LD A,COLOR_TBL_CHG_DATA_CNT
    LD (COLOR_TBL_CNT),A

UPDATE_COLOR_TBL_L1:
    LD HL,COLOR_TBL_CNT
    DEC (HL)

    LD A,(HL)
    ADD A,A                         ; A=A*8
    ADD A,A
    ADD A,A
    LD C,A
    LD B,0
    LD HL,COLOR_TBL_CHG_DATA
    ADD HL,BC

    LD DE,COLOR_TABLE_ADDR+12
    LD BC,8
    CALL LDIRVM				 	    ; BIOS VRAMブロック転送

UPDATE_COLOR_TBL_EXIT:
    RET

; -----------------------------------------------------------------------------------------------------
; 情報描画
; 毎フレーム描画するもの
; -----------------------------------------------------------------------------------------------------
DRAW_INFO:

    ; ■スコア表示
    LD B,3
    LD DE,SCORE
    LD HL,$0006
    CALL PRTBCD

    ; ■タイム表示
    LD B,1
    LD DE,TIME_BCD
    LD HL,$02FE
    CALL PRTBCD

    ; ■パワーチャージメーター
    LD B,16                         ; B <- チャージパワー値

DRAW_INFO_L1:
    ; ■オフスクリーンバッファのオフセット値を算出
    LD D,0
    LD E,B
    LD HL,2+32*23
    ADD HL,DE

    ; ■オフスクリーンバッファのアドレスを算出
    LD DE,OFFSCREEN
    ADD HL,DE

    ; ■描画するキャラクターをチャージパワー値から判定
    LD A,(PLAYER_CHARGE_POWER)

    ; - チャージパワー値 = 0 のとき
    OR A
    JR Z,DRAW_INFO_L3

    ; - チャージパワー値 < ループカウンタのとき
    CP B                            
    JR C,DRAW_INFO_L3

    LD A,B
    CP 11
    JR NC,DRAW_INFO_L2
 
    ; - 1～10のとき
    LD (HL),$AF
    JR DRAW_INFO_L4

DRAW_INFO_L2:
    ; - 11～のとき
    LD (HL),$B0
    JR DRAW_INFO_L4

DRAW_INFO_L3:
    ; - 0のとき
    LD (HL),$20

DRAW_INFO_L4:
    DJNZ DRAW_INFO_L1

DRAW_INFO_EXIT:
    RET


; ====================================================================================================
; 情報初回描画
; オフスクリーン初期化時に描画するもの
; ====================================================================================================
DRAW_INFO_INIT:
    ; ■画面上部表示内容
    LD HL,INFO_STRING1
    CALL PRTSTR

    ; ■画面下部表示内容
    LD HL,INFO_STRING2
    CALL PRTSTR

    ; ■ハイスコア表示
    LD B,3
    LD DE,HISCORE
    LD HL,$0012
    CALL PRTBCD

    ; ■ラウンド数表示
    LD B,1
    LD DE,ROUND_BCD
    LD HL,$02F6
    CALL PRTBCD

DRAW_INFO_INIT_L1:
    ; ■残機表示
    ;   エクステンド時の処理からも呼ばれるので、この処理の後には何も処理しないこと
    LD A,(LEFT)
    OR A
    RET Z                           ; ゼロなら表示不要のため処理を抜ける

    LD HL,OFFSCREEN
    LD BC,$001B
    ADD HL,BC
    LD B,A
    CP 5
    JR C,DRAW_INFO_INIT_L2
    LD B,5                          ; 表示上は最大5機までとする

DRAW_INFO_INIT_L2:
    LD (HL),$B8
    INC HL
    DJNZ DRAW_INFO_INIT_L2
    RET

; ====================================================================================================
; モジュール
; ====================================================================================================

; ■H.TIMI割込諸理
INCLUDE "interval.asm"

; ■全体初期設定
INCLUDE "game_global_init.asm"

; ■タイトル
INCLUDE "game_title.asm"

; ■ゲーム初期化
INCLUDE "game_init.asm"

; ■ラウンドスタート
INCLUDE "game_round_start.asm"

; ■ゲームメイン
INCLUDE "game_main.asm"

; ■ラウンドクリア
INCLUDE "game_round_clear.asm"

; ■ゲームオーバー
INCLUDE "game_over.asm"

; ■オールクリア
INCLUDE "game_all_clear.asm"

; ■フィールド操作サブルーチン群
INCLUDE "game_field.asm"


; ====================================================================================================
; ゲーム共通ワークエリア
; ====================================================================================================
INCLUDE "game_global_rodata.asm"


; ====================================================================================================
; ゲーム共通定数エリア
; ====================================================================================================
INCLUDE "game_global_bss.asm"


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■画面上部表示内容
INFO_STRING1:
    DW $0000
    DB "SCORE 00000000 HI 00000000      ",0

; ■画面下部表示内容
INFO_STRING2:
    DW $02E0
    DB $B1,$B2,$B3,"                ",$B4,"R    TIME",0

; ■カラーテーブル変更データ 6,6,8,8,9,9,8,8,6,6,1
COLOR_TBL_CHG_DATA:
	DB $46, $41, $A6, $A1, $C6, $C1, $11, $E1
	DB $46, $41, $A6, $A1, $C6, $C1, $16, $E1
	DB $48, $41, $A8, $A1, $C8, $C1, $18, $E1
	DB $48, $41, $A8, $A1, $C8, $C1, $11, $E1
	DB $49, $41, $A9, $A1, $C9, $C1, $11, $E1
	DB $49, $41, $A9, $A1, $C9, $C1, $11, $E1
	DB $49, $41, $A9, $A1, $C9, $C1, $11, $E1
	DB $49, $41, $A9, $A1, $C9, $C1, $19, $E1
	DB $48, $41, $A8, $A1, $C8, $C1, $11, $E1
	DB $48, $41, $A8, $A1, $C8, $C1, $11, $E1
	DB $46, $41, $A6, $A1, $C6, $C1, $11, $E1
	DB $46, $41, $A6, $A1, $C6, $C1, $11, $E1


; ■BGMデータ
; - タイトル
INCLUDE "assets/00.asm"
; - スタート
INCLUDE "assets/01.asm"
; - BGM1
INCLUDE "assets/02.asm"
; - BGM2
INCLUDE "assets/03.asm"
; - BGM3
INCLUDE "assets/04.asm"
; - BGM4
INCLUDE "assets/05.asm"
; - MISS
INCLUDE "assets/06.asm"
; - GAME OVER
INCLUDE "assets/07.asm"
; - CLEAR
INCLUDE "assets/08.asm"


; ■SFXデータ
INCLUDE "assets/sfx_01.asm"
INCLUDE "assets/sfx_02.asm"
INCLUDE "assets/sfx_03.asm"


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■カラーテーブル変更カウンタ
COLOR_TBL_CNT:
    DEFS 1

; ■経過時間カウンタ
TICK1:
    DEFS 2                      ; 1/60のタイマー
TICK2_WK:
    DEFS 1                      ; 1/10のタイマー加算判定用
TICK2:
    DEFS 2                      ; 1/10のタイマー、TICK=6ごとにインクリメント
TICK3_WK:
    DEFS 1                      ; 1秒のタイマー加算判定用
TICK3:
    DEFS 2                      ; 1秒のタイマー、TICK1=60ごとにインクリメント

