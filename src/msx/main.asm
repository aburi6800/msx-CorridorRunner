; ====================================================================================================
;
; main.asm
;
; ====================================================================================================
SECTION code_user
EXTERN SOUNDDRV_INIT
EXTERN SOUNDDRV_EXEC
EXTERN SOUNDDRV_BGMPLAY
EXTERN SOUNDDRV_SFXPLAY
EXTERN SOUNDDRV_STOP

PUBLIC _main

_main:

STATE_INIT:             EQU 0       ; ゲーム状態：初期処理
STATE_TITLE:            EQU 1       ; ゲーム状態：タイトル
STATE_GAME_INIT:        EQU 2       ; ゲーム状態：ゲーム初期化
STATE_ROUND_START:      EQU 3       ; ゲーム状態：ラウンド開始
STATE_GAME_MAIN:        EQU 4       ; ゲーム状態：ゲームメイン
STATE_PLAYER_MISS:      EQU 5       ; ゲーム状態：プレイヤーミス
STATE_OVER:             EQU 6       ; ゲーム状態：ゲームオーバー
STATE_ROUND_CLEAR:      EQU 7       ; ゲーム状態：ラウンドクリアー


; ====================================================================================================
; メインループ
; ====================================================================================================
MAINLOOP:
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
    LD HL,MAINLOOP_RET              ; 各ルーチンからのRET先のアドレスをスタックに積む
    PUSH HL
    LD HL,MAINLOOP_L1               ; HL <- ジャンプテーブルのアドレス
    ADD HL,BC                       ; HL=HL+BC（ゼロフラグは変化しない）
    JP (HL)

MAINLOOP_L1:
    JP INIT                         ; ゲーム状態：初期処理
    JP TITLE                        ; ゲーム状態：タイトル
    JP GAME_INIT                    ; ゲーム状態：ゲーム初期化
    JP ROUND_START                  ; ゲーム状態：ラウンド開始
    JP GAME_MAIN                    ; ゲーム状態：ゲームメイン
    JP PLAYER_MISS                  ; ゲーム状態：プレイヤーミス
    JP OVER                         ; ゲーム状態：ゲームオーバー
    JP ROUND_CLEAR                  ; ゲーム状態：ラウンドクリアー

MAINLOOP_RET:
VSYNC:
	; ■垂直帰線待ち
	HALT

    ; ■キー入力値取得
    CALL GET_CONTROL

    ; ■画面更新
    CALL DRAW

	JP MAINLOOP


; ====================================================================================================
; ゲーム状態変更
; IN A  : 変更するゲーム状態の値
; ====================================================================================================
CHANGE_STATE:
    LD (GAME_STATE),A
    CALL TICK_RESET

CHANGE_STATE_EXIT:
    RET


; ====================================================================================================
; 経過時間リセット
; ====================================================================================================
TICK_RESET:
    LD A,0                          ; A <- 0
    LD (TICK1+0),A
    LD (TICK1+1),A

TICK_RESET_EXIT:
    RET


; ====================================================================================================
; 経過時間カウント
; ====================================================================================================
TICK_COUNT:
    ; DEBUG
    LD HL,28
    LD A,(TICK1+1)
    CALL PRTHEX

    LD HL,30
    LD A,(TICK1)
    CALL PRTHEX
    ; DEBUGここまで

    LD HL,(TICK1)                   ; HL <- TICKの値

    LD A,H                          ; HL=0の場合、ゼロフラグが立つ
    OR L

    INC HL                          ; TICKをカウントアップ(フラグは変化しない)
    JR Z,TICK_COUNT_L1              ; ゼロフラグが立っていたら次の処理へ

    LD A,H                          ; ゼロでなければ次の処理へ
    OR L
    JR NZ,TICK_COUNT_L1

    LD L,1                          ; 1にリセット
    LD H,0

TICK_COUNT_L1:
    LD (TICK1),HL

TICK_COUNT_EXIT:
    RET


; ====================================================================================================
; 画面更新
; ====================================================================================================
DRAW:
    ; ■スプライト設定
    CALL SET_SPR_ATR_WK             ; スプライトキャラクターワークテーブルからスプライトアトリビュートワークテーブルを設定
    CALL SET_SPR_ATTR_AREA          ; スプライトアトリビュートエリア設定

    ; ■パターンネームテーブル設定
;    CALL DRAW_MAP                   ; マップデータ描画
    CALL DRAW_INFO                  ; 情報描画

DRAW_EXIT:
    RET

; -----------------------------------------------------------------------------------------------------
; 情報描画
; -----------------------------------------------------------------------------------------------------
DRAW_INFO:

    LD HL,INFO_STRING1
    CALL PRTSTR

    LD HL,INFO_STRING2
    CALL PRTSTR

    ;ToDo:スコアやハイスコアの表示も入れる

DRAW_INFO_EXIT:
    RET


; ■初期設定
INCLUDE "init.asm"

; ■タイトル
INCLUDE "title.asm"

; ■ゲームメイン
INCLUDE "game.asm"

; ■スプライト操作サブルーチン群
INCLUDE "sprite.asm"

; ■フィールド操作サブルーチン群
INCLUDE "field.asm"

; ■ユーティリティーサブルーチン群
INCLUDE "utils.asm"

; ■BIOSアドレス定義
INCLUDE "include/msxbios.inc"

; ■システムワークエリアアドレス定義
INCLUDE "include/msxsyswk.inc"

; ■VRAMワークエリアアドレス定義
INCLUDE "include/msxvrmwk.inc"

; ■BGMデータ
INCLUDE "assets/00.asm"
INCLUDE "assets/01.asm"
INCLUDE "assets/02.asm"
INCLUDE "assets/03.asm"
INCLUDE "assets/04.asm"
INCLUDE "assets/05.asm"
INCLUDE "assets/06.asm"
INCLUDE "assets/07.asm"
INCLUDE "assets/08.asm"

; ■SFXデータ
INCLUDE "assets/sfx_01.asm"
INCLUDE "assets/sfx_02.asm"

SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■画面上部表示内容
INFO_STRING1:
    DW $0000
    DB "SCORE 000000 TOP 000000      ",$B8,$B8,$B8,0

; ■画面下部表示内容
INFO_STRING2:
    DW $02E0
    DB $B1,$B2,$B3,"                ",$B4,"    ROUND 00",0


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■経過時間カウンタ
TICK1:
    DEFS 2                      ; 1/60のタイマー
TICK2:
    DEFS 2                      ; 1/10のタイマー、TICK=6ごとにインクリメント
TICK3:
    DEFS 2                      ; 1秒のタイマー、TICK1=60ごとにインクリメント

; ■ゲーム状態
GAME_STATE:
    DEFS 1

; ■ラウンド
ROUND:
    DEFS 1

; ■スコア
SCORE:
    DEFS 3

; ■タイム
TIME:
    DEFS 2

; ■残機
LEFT:
    DEFS 2
