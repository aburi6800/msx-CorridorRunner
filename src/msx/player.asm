; ====================================================================================================
;
; player.asm
;
; included from sprite.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; プレイヤー初期化
; ====================================================================================================
INIT_PLAYER:
    LD (IX),1                       ; キャラクター番号=プレイヤー

    LD (IX+1),0                     ; Y座標(小数部)
    LD (IX+2),88                    ; Y座標(整数部)

    LD (IX+3),0                     ; X座標(小数部)
    LD (IX+4),120                   ; X座標(整数部)

    LD (IX+5),0                     ; スプライトパターンNo
    LD (IX+6),15                    ; カラーコード
    LD (IX+7),0                     ; 移動方向

    LD (IX+8),0                     ; アニメーションテーブル番号
    LD (IX+9),0                     ; アニメーションカウンタ

INIT_PLAYER_EXIT:
    RET


; ====================================================================================================
; プレイヤー処理サブルーチン
; ====================================================================================================
UPDATE_PLAYER:
    ; ■プレイヤー操作不可カウント判定
    ; - プレイヤー操作不可カウント<>0の場合は、操作を受け付けずに終了する
    LD A,(PLAYER_MISS_CNT)          ; A <- プレイヤーミスカウント
    OR A
    JR Z,UPDATE_PLAYER_L1           ; ゼロの時だけプレイヤー操作処理へ

    ; ■プレイヤーを操作不可にする
    DEC A                           ; A=A-1
    LD (PLAYER_MISS_CNT),A          ; A -> プレイヤーミスカウント

;    LD HL,STRING4                   ; 'OUT !!'表示
;    CALL PRTSTR

    JR UPDATE_PLAYER_EXIT

UPDATE_PLAYER_L1:
;    LD HL,STRING3
;    CALL PRTSTR

    ; ■プレイヤー操作
    ; @ToDo:なぜか下方向だけ、一定量ごとに右に1ドット移動してしまう
    CALL PLAYER_CONTROL             ; プレイヤー操作処理
    CALL SPRITE_MOVE                ; スプライトキャラクター移動処理

    ; ■移動先座標のマップ判定
    LD B,(IX+2)                     ; B <- Y座標(整数部)
    LD C,(IX+4)                     ; C <- X座標(整数部)
    CALL GET_MAPDATA_NO             ; マップデータ番号取得
    CALL GET_MAPDATA                ; マップデータ取得

    LD C,A                          ; A=A*3
    ADD A,A
    ADD A,C
    LD B,0                          ; BC <- A
    LD C,A

    LD HL,UPDATE_PLAYER_L2          ; HL <- ジャンプテーブルの先頭アドレス
    ADD HL,BC
    JP (HL)

UPDATE_PLAYER_L2:
    JP UPDATE_PLAYER_L3             ; マップデータ=0
    JP UPDATE_PLAYER_L4             ; マップデータ=1
    JP UPDATE_PLAYER_L5             ; マップデータ=2
    JP UPDATE_PLAYER_L6             ; マップデータ=3

UPDATE_PLAYER_L3:
;    LD HL,STRING5                   ; テスト：'MISS !!'表示 
;    CALL PRTSTR
    JP UPDATE_PLAYER_EXIT

UPDATE_PLAYER_L4:
    JP UPDATE_PLAYER_EXIT

UPDATE_PLAYER_L5:
    ; ■アイテムを取った処理
    ;   自分の座標からマップデータ番号を求める
;    PUSH AF
    LD B,(IX+2)                     ; B <- Y座標(整数部)
    LD C,(IX+4)                     ; C <- X座標(整数部)
    CALL GET_MAPDATA_NO             ; A <- マップデータ番号
;    POP AF

    ;   マップデータを1(床)に更新
    LD HL,MAP_WK
    LD B,0
    LD C,A
    ADD HL,BC
    LD (HL),1

    ;   マップデータ番号から左上のアドレスを取得
    LD B,A
    CALL DRAW_MAPCHIP               ; 床を描画

    ; SFX再生
;    LD HL,SFX_01
;    CALL SOUNDDRV_SFXPLAY

    JP UPDATE_PLAYER_EXIT


UPDATE_PLAYER_L6:
    JP UPDATE_PLAYER_EXIT

UPDATE_PLAYER_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤー操作サブルーチン
; ----------------------------------------------------------------------------------------------------
PLAYER_CONTROL:
    ; ■A <- 操作入力データ（方向）
    LD A,(INPUT_BUFF_STICK)

    ; DEBUG
    LD HL,30+32
    CALL PRTHEX
    ; DEBUGここまで

    ; ■入力データをスプライトキャラクターワークテーブルに保存
    LD (IX+7),A
    OR A
    RET Z

    ; ■スプライトパターン番号更新
    CALL SPRITE_ANIM

PLAYER_CTRL_EXIT:
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■アニメーションパターン
ANIM_PTN_PLAYER:
	DB 1,1,1,2,2,2,3,3,3,2,2,2,0


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

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

; ■プレイヤーミスカウント
PLAYER_MISS_CNT:
    DEFS 1

