; ====================================================================================================
;
; player.asm
;
; included from sprite.asm
;
; ====================================================================================================
SECTION code_user

    PLAYERMODE_CONTROL:             EQU $00
    PLAYERMODE_LEFTTURN:            EQU $01
    PLAYERMODE_RIGHTTURN:           EQU $02
    PLAYERMODE_CHARGE:              EQU $03
    PLAYERMODE_MOVE:                EQU $04
    PLAYERMODE_MISS:                EQU $05

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

    LD (IX+7),1                     ; 移動方向
    LD (IX+8),0                     ; 移動量
    LD (IX+9),0                     ; アニメーションテーブル番号
    LD (IX+10),0                    ; アニメーションカウンタ

    ; ■ワークエリア初期化
    XOR A
    LD (PLAYER_CONTROL_MODE),A

INIT_PLAYER_EXIT:
    RET


; ====================================================================================================
; プレイヤー処理
; ====================================================================================================
UPDATE_PLAYER:
    ; ■プレイヤー状態取得
    LD A,(PLAYER_CONTROL_MODE)

    ; ■RET先のアドレスをスタックに入れておく
    LD HL,UPDATE_PLAYER_L2
    PUSH HL

    ; ■ジャンプテーブルのアドレス設定
    LD C,A                          ; A=A*3
    ADD A,A
    ADD A,C
    LD B,0                          ; BC <- A
    LD C,A

    LD HL,UPDATE_PLAYER_L1          ; HL <- ジャンプテーブルの先頭アドレス
    ADD HL,BC
    JP (HL)

UPDATE_PLAYER_L1:
    ; ■ジャンプテーブル
    JP UPDATE_PLAYER_CONTROL        ; 操作
    JP UPDATE_PLAYER_TURN           ; 左回転/右回転
    JP UPDATE_PLAYER_TURN           ; 左回転/右回転
    JP UPDATE_PLAYER_CHARGE         ; チャージ
    JP UPDATE_PLAYER_MOVE           ; 移動
    JP UPDATE_PLAYER_MISS           ; ミス

UPDATE_PLAYER_L2:
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤー操作サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_CONTROL:

    LD A,(INPUT_BUFF_STICK)
    OR A
    RET Z                           ; STICK値がゼロ(＝未入力)なら抜ける

    CP 7
    JP NZ,UPDATE_PLAYER_CONTROL_L1

    LD A,PLAYERMODE_LEFTTURN
    LD (PLAYER_CONTROL_MODE),A      ; プレイヤー状態を左回転に変更
    LD A,3
    LD (PLAYER_CNT_WK1),A           ; WK1：処理繰り返し回数
    LD A,1
    LD (PLAYER_CNT_WK2),A           ; WK2：ウェイトカウンタ
    RET

UPDATE_PLAYER_CONTROL_L1:
    CP 3
    JP NZ,UPDATE_PLAYER_CONTROL_L2

    LD A,PLAYERMODE_RIGHTTURN
    LD (PLAYER_CONTROL_MODE),A      ; プレイヤー状態を右回転に変更
    LD A,3
    LD (PLAYER_CNT_WK1),A           ; WK1：処理繰り返し回数
    LD A,1
    LD (PLAYER_CNT_WK2),A           ; WK2：ウェイトカウンタ
    RET

UPDATE_PLAYER_CONTROL_L2:
    CP 5
    JP NZ,UPDATE_PLAYER_CONTROL_EXIT

    LD A,PLAYERMODE_CHARGE
    LD (PLAYER_CONTROL_MODE),A      ; プレイヤー状態をチャージに変更
    XOR A
    LD (PLAYER_CNT_WK1),A           ; WK1：チャージカウンタ
    LD (PLAYER_CNT_WK2),A           ; WK2：未使用
    LD (PLAYER_CHARGE_POWER),A      ; チャージパワー値をリセット
    RET

UPDATE_PLAYER_CONTROL_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤー左回転／右回転サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_TURN:
    ; ■動作ウェイト判定
    ;   WK2をデクリメントし、ゼロでない場合はなにもせずに終了する
    LD HL,PLAYER_CNT_WK2
    DEC (HL)
    RET NZ

    ;■WK2(動作ウェイト値)をリセット
    LD A,10
    LD (HL),A

    ; ■方向変更カウンタ判定
    ;   WK1をデクリメントし、ゼロの場合はプレイヤー操作状態をリセットする
    LD HL,PLAYER_CNT_WK1
    DEC (HL)
    JP Z,UPDATE_PLAYER_TURN_END

    ; ■方向変更の方向判定
    LD A,(PLAYER_CONTROL_MODE)
    CP PLAYERMODE_RIGHTTURN
    JP Z,UPDATE_PLAYER_TURN_RIGHT

    ; ■左回転
    LD A,(IX+7)
    DEC A
    JP NZ,UPDATE_PLAYER_TURN_EXIT
    LD A,8
    JR UPDATE_PLAYER_TURN_EXIT

UPDATE_PLAYER_TURN_RIGHT:
    ; ■右回転
    LD A,(IX+7)
    INC A
    CP 9
    JP NZ,UPDATE_PLAYER_TURN_EXIT
    LD A,1

UPDATE_PLAYER_TURN_EXIT:
    LD (IX+7),A

    DEC A                           ; (方向-1)をパターン番号として設定
    LD (IX+5),A

    RET

UPDATE_PLAYER_TURN_END:
    ; ■プレイヤー操作状態をリセット
    LD A,PLAYERMODE_CONTROL
    LD (PLAYER_CONTROL_MODE),A
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤーチャージサブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_CHARGE:
    ; ■STICK値を判定し、4〜6(右下〜左下)以外の場合は次の状態に遷移させる
    LD A,(INPUT_BUFF_STICK)
    CP 7
    JP NC,UPDATE_PLAYER_CHARGE_END  ; STICKの値が7〜8の場合はキャリーが立たないので、次の状態に遷移させる
    CP 4
    JP C,UPDATE_PLAYER_CHARGE_END   ; STICKの値が1〜3の場合はキャリーが立つので、次の状態に遷移させる

    ; ■上記以外の時はチャージ
    ;   カウンタ＝０の時は、チャージパワーを+1してパワー値に対応したカウンタを取得
    ;   ただしチャージパワーが16の時は加算しない
    LD A,(PLAYER_CNT_WK1)
    OR A
    JP NZ,UPDATE_PLAYER_CHARGE_L1   ; カウンタがゼロ以外の時は次の処理へ

    LD HL,PLAYER_CHARGE_POWER

    INC (HL)                        ; チャージパワー+1
    LD C,(HL)
    LD B,$00
    LD HL,CHARGE_WAIT_VALUE

    ADD HL,BC
    LD A,(HL)
    LD (PLAYER_CNT_WK1),A

UPDATE_PLAYER_CHARGE_L1:
    LD A,(PLAYER_CHARGE_POWER)
    CP 16
    RET Z                           ; チャージパワーが16の場合は終了

    LD HL,PLAYER_CNT_WK1
    DEC (HL)
    RET

UPDATE_PLAYER_CHARGE_END:
    ; ■プレイヤー移動に遷移
    LD A,PLAYERMODE_MOVE
    LD (PLAYER_CONTROL_MODE),A

    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤー移動サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_MOVE:
    ; ■チャージパワー減算
    LD HL,PLAYER_CHARGE_POWER
    DEC (HL)
    JR Z,UPDATE_PLAYER_MOVE_END

    ; ■チャージパワーから移動量計算
    LD A,(HL)
    CP 7
    JR C,UPDATE_PLAYER_MOVE_L1
    LD (IX+8),%00000011
    JR UPDATE_PLAYER_MOVE_L3

UPDATE_PLAYER_MOVE_L1:
    CP 4
    JR C,UPDATE_PLAYER_MOVE_L2
    LD (IX+8),%00000010
    JR UPDATE_PLAYER_MOVE_L3

UPDATE_PLAYER_MOVE_L2:
    LD (IX+8),%00000001

UPDATE_PLAYER_MOVE_L3:
    CALL SPRITE_MOVE
    RET

UPDATE_PLAYER_MOVE_END:
    ; ■プレイヤー操作に遷移
    LD A,PLAYERMODE_CONTROL
    LD (PLAYER_CONTROL_MODE),A

    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤーミスサブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_MISS:

    RET


    ; ■プレイヤー操作不可カウント判定
    ; - プレイヤー操作不可カウント<>0の場合は、操作を受け付けずに終了する
;    LD A,(PLAYER_MISS_CNT)          ; A <- プレイヤーミスカウント
;    OR A
;    JR Z,UPDATE_PLAYER_L1           ; ゼロの時だけプレイヤー操作処理へ

    ; ■プレイヤーを操作不可にする
;    DEC A                           ; A=A-1
;    LD (PLAYER_MISS_CNT),A          ; A -> プレイヤーミスカウント

;    LD HL,STRING4                   ; 'OUT !!'表示
;    CALL PRTSTR

;    JR UPDATE_PLAYER_EXIT

;UPDATE_PLAYER_L1:
;    LD HL,STRING3
;    CALL PRTSTR

    ; ■プレイヤー操作
    ; @ToDo:なぜか下方向だけ、一定量ごとに右に1ドット移動してしまう
;    CALL PLAYER_CONTROL             ; プレイヤー操作処理
;    CALL SPRITE_MOVE                ; スプライトキャラクター移動処理

    ; ■移動先座標のマップ判定
;    LD B,(IX+2)                     ; B <- Y座標(整数部)
;    LD C,(IX+4)                     ; C <- X座標(整数部)
;    CALL GET_MAPDATA_NO             ; マップデータ番号取得
;    CALL GET_MAPDATA                ; マップデータ取得


;UPDATE_PLAYER_L2:
;    JP UPDATE_PLAYER_L3             ; マップデータ=0
;    JP UPDATE_PLAYER_L4             ; マップデータ=1
;    JP UPDATE_PLAYER_L5             ; マップデータ=2
;    JP UPDATE_PLAYER_L6             ; マップデータ=3

;UPDATE_PLAYER_L3:
;    LD HL,STRING5                   ; テスト：'MISS !!'表示 
;    CALL PRTSTR
;    JP UPDATE_PLAYER_EXIT

;UPDATE_PLAYER_L4:
;    JP UPDATE_PLAYER_EXIT

;UPDATE_PLAYER_L5:
    ; ■アイテムを取った処理
    ;   自分の座標からマップデータ番号を求める
;    PUSH AF
;    LD B,(IX+2)                     ; B <- Y座標(整数部)
;    LD C,(IX+4)                     ; C <- X座標(整数部)
;    CALL GET_MAPDATA_NO             ; A <- マップデータ番号
;    POP AF

    ;   マップデータを1(床)に更新
;    LD HL,MAP_WK
;    LD B,0
;    LD C,A
;    ADD HL,BC
;    LD (HL),1

    ;   マップデータ番号から左上のアドレスを取得
;    LD B,A
;    CALL DRAW_MAPCHIP               ; 床を描画

    ; SFX再生
;    LD HL,SFX_01
;    CALL SOUNDDRV_SFXPLAY

;    JP UPDATE_PLAYER_EXIT


;UPDATE_PLAYER_L6:
;    JP UPDATE_PLAYER_EXIT

;UPDATE_PLAYER_EXIT:
;    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤー操作サブルーチン
; ----------------------------------------------------------------------------------------------------
;PLAYER_CONTROL:
    ; ■A <- 操作入力データ（方向）
;    LD A,(INPUT_BUFF_STICK)

    ; DEBUG
;    LD HL,30+32
;    CALL PRTHEX
    ; DEBUGここまで

    ; ■入力データをスプライトキャラクターワークテーブルに保存
;    LD (IX+7),A
;    OR A
;    RET Z

    ; ■スプライトパターン番号更新
;    CALL SPRITE_ANIM

;PLAYER_CTRL_EXIT:
;    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■チャージウェイト値
CHARGE_WAIT_VALUE:
    DB $00,$02,$02,$04,$04,$04,$08,$08,$08,$08,$0C,$0C,$0C,$0C,$0F,$0F,$FF

SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■プレイヤー操作モード
; 0=CONTROL,1=TURN LEFT,2=TURN RIGHT,3=CHARGE,4=MOVE,5=MISS
PLAYER_CONTROL_MODE:
    DEFS 1

; ■チャージパワー
PLAYER_CHARGE_POWER:
    DEFS 1

; ■カウントワーク
PLAYER_CNT_WK1:
    DEFS 1
PLAYER_CNT_WK2:
    DEFS 1

; ■プレイヤーミスカウント
PLAYER_MISS_CNT:
    DEFS 1

