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
    PLAYERMODE_EXPLOSION:           EQU $06

; ====================================================================================================
; プレイヤー初期化
; ====================================================================================================
INIT_PLAYER:
    ; キャラクター番号2にキャラクター番号1の内容をコピーする
    ; 現在のIXは転送先(DE)に設定
    ; キャラクター番号1のワークアドレスを転送元(HL)に設定
    ; 転送サイズは16バイト
    PUSH IX
    PUSH IX

    LD A,1
    CALL GET_SPR_WK_ADDR
    PUSH IX
    POP HL
    POP DE
    LD BC,$0010

    LDIR

    POP IX
    LD (IX),1                       ; キャラクター番号=プレイヤー
    LD (IX+5),0                     ; スプライトパターンNo
    LD (IX+6),15                    ; カラーコード

    ; ■ワークエリア初期化
    XOR A
    LD (PLAYER_CONTROL_MODE),A

INIT_PLAYER_EXIT:
    RET

INIT_PLAYER2:
    LD (IX),2                       ; キャラクター番号=プレイヤー

    LD (IX+1),0                     ; Y座標(小数部)
    LD (IX+2),88                    ; Y座標(整数部)

    LD (IX+3),0                     ; X座標(小数部)
    LD (IX+4),120                   ; X座標(整数部)

    LD (IX+5),1                     ; スプライトパターンNo
    LD (IX+6),5                     ; カラーコード

    LD (IX+7),1                     ; 移動方向
    LD (IX+8),0                     ; 移動量
    LD (IX+9),0                     ; アニメーションテーブル番号
    LD (IX+10),0                    ; アニメーションカウンタ

INIT_PLAYER2_EXIT:
    RET


; ====================================================================================================
; プレイヤー処理
; ====================================================================================================
UPDATE_PLAYER:
    ; ■プレイヤー状態取得
    LD A,(PLAYER_CONTROL_MODE)

    ; ■RET先のアドレスをスタックに入れておく
    LD HL,UPDATE_PLAYER_EXIT
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
    JP UPDATE_PLAYER_EXPLOSION      ; ミス（爆発）

UPDATE_PLAYER_EXIT:
    RET


UPDATE_PLAYER2:
    ; キャラクター番号1にキャラクター番号2の内容をコピーする
    ; 現在のIXは転送先(DE)に設定
    PUSH IX
    PUSH IX

    ; キャラクター番号1のワークアドレスを転送元(HL)に設定
    LD A,2
    CALL GET_SPR_WK_ADDR
    PUSH IX
    POP HL
    INC HL

    POP DE
    INC DE

    ; Y座標(小数部)からスプライトパターンNoまでの5バイトを転送する
    LD BC,$0005

    LDIR

    ; プレイヤーのスプライトパターン番号は、1枚目のスプライトパターン番号+4とする
    DEC DE
    LD A,(DE)
    ADD A,1
    LD (DE),A
    POP IX

UPDATE_PLAYER2_EXIT:
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
    LD (PLAYER_CNT_WK1),A           ; WK1:処理繰り返し回数
    LD A,1
    LD (PLAYER_CNT_WK2),A           ; WK2:ウェイトカウンタ
    RET

UPDATE_PLAYER_CONTROL_L1:
    CP 3
    JP NZ,UPDATE_PLAYER_CONTROL_L2

    LD A,PLAYERMODE_RIGHTTURN
    LD (PLAYER_CONTROL_MODE),A      ; プレイヤー状態を右回転に変更
    LD A,3
    LD (PLAYER_CNT_WK1),A           ; WK1:処理繰り返し回数
    LD A,1
    LD (PLAYER_CNT_WK2),A           ; WK2:ウェイトカウンタ
    RET

UPDATE_PLAYER_CONTROL_L2:
    CP 5
    JP NZ,UPDATE_PLAYER_CONTROL_EXIT

    LD A,PLAYERMODE_CHARGE
    LD (PLAYER_CONTROL_MODE),A      ; プレイヤー状態をチャージに変更
    XOR A
    LD (PLAYER_CNT_WK1),A           ; WK1:チャージカウンタ
    LD (PLAYER_CNT_WK2),A           ; WK2:未使用
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
    LD (IX+7),A                     ; 方向を設定

    DEC A                           ; (方向-1)をキャラクター番号(0～7)
    ADD A,A                         ; A=A*2
    LD (IX+5),A                     ; スプライトパターン番号を設定

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
    JP Z,UPDATE_PLAYER_MOVE_END

    ; ■チャージパワーから移動量計算
    LD A,(HL)
    CP 5
    JR NC,UPDATE_PLAYER_MOVE_L1

    ; 1〜4のときの移動量
    LD (IX+8),1
    JR UPDATE_PLAYER_MOVE_L3

UPDATE_PLAYER_MOVE_L1:
    CP 11
    JR NC,UPDATE_PLAYER_MOVE_L2

    ; 5〜10のときの移動量
    LD (IX+8),2
    JR UPDATE_PLAYER_MOVE_L3

UPDATE_PLAYER_MOVE_L2:
    ; 11〜のときの移動量
    LD (IX+8),3

UPDATE_PLAYER_MOVE_L3:
    ; ■マップチップ判定
    ; ここでアイテムがあれば取得する
    LD B,(IX+2)                     ; B <- Y座標(整数部)
    LD C,(IX+4)                     ; C <- X座標(整数部)
    CALL GET_MAPDATA_OFFSET         ; A <- マップデータオフセット
    CALL GET_MAPDATA                ; A <- マップデータ

    CP 2
    JR NZ,UPDATE_PLAYER_MOVE_L4

    ; ■アイテム取得
    CALL UPDATE_PLAYER_GETITEM

UPDATE_PLAYER_MOVE_L4:
    ; ■スプライトキャラクター移動
    CALL SPRITE_MOVE

    RET

UPDATE_PLAYER_MOVE_END:
    ; ■マップチップ判定
    ; ここで床がなければミスにする
    LD B,(IX+2)                     ; B <- Y座標(整数部)
    LD C,(IX+4)                     ; C <- X座標(整数部)
    CALL GET_MAPDATA_OFFSET         ; A <- マップデータオフセット
    CALL GET_MAPDATA                ; A <- マップデータ
    OR A
    JR NZ,UPDATE_PLAYER_MOVE_END_L2 ; マップデータがゼロでなければ、プレイヤー操作に状態遷移

    ; ■ミス時の初期設定
    ; - 時間経過カウントをリセット
    LD A,1
    LD (PLAYER_MISS_TIME_CNT),A
    ; - パターンテーブルのインデックス
    LD A,0
    LD (PLAYER_MISS_PTN_CNT),A

    ; ■ミスの状態に遷移
    LD A,PLAYERMODE_MISS
    LD (PLAYER_CONTROL_MODE),A

    ; ■BGM再生
    LD HL,_06
    CALL SOUNDDRV_BGMPLAY
    RET

UPDATE_PLAYER_MOVE_END_L2:
    ; ■プレイヤー操作に状態遷移
    LD A,PLAYERMODE_CONTROL
    LD (PLAYER_CONTROL_MODE),A
    RET

; ----------------------------------------------------------------------------------------------------
; アイテム取得サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_GETITEM:

    ; ■マップデータオフセット取得
    LD B,(IX+2)                     ; B <- Y座標(整数部)
    LD C,(IX+4)                     ; C <- X座標(整数部)
    CALL GET_MAPDATA_OFFSET         ; A <- マップデータオフセット

    ; ■マップデータ更新
    LD H,0
    LD L,A
    LD DE,MAP_WK
    ADD HL,DE
    LD (HL),1    

    ; ■仮想画面更新
    ; マップデータのオフセットに該当するマップチップを書き換える
    LD B,A
    CALL DRAW_MAPCHIP

UPDATE_PLAYER_GETITEM_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤーミスサブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_MISS:
    ; ■ミスカウント減算
    LD HL,PLAYER_MISS_TIME_CNT
    DEC (HL)
    RET NZ
    
    ; ■カウントゼロ時の処理
    ; - スプライトパターン番号を取得する
    ; - ゼロの場合はゲーム状態変更処理へ
    LD HL,PLAYER_MISS_PTN_CNT
    LD B,0
    LD C,(HL)
    LD HL,PLAYER_MISS_PTN1
    ADD HL,BC
    LD A,(HL)
    OR A
    JP Z,PLAYER_MISS_CHANGE_GAME_STATE

    ; - スプライトパターン番号を更新する
    LD (IX+5),A
    ; - ミスカウントリセット
    LD A,7
    LD (PLAYER_MISS_TIME_CNT),A
    ; - パターンカウントを+1
    LD HL,PLAYER_MISS_PTN_CNT
    INC (HL)
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤーミス（爆発）サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_EXPLOSION:

    RET

; ====================================================================================================
; プレイヤーミス後のゲーム状態変更処理
; ====================================================================================================
PLAYER_MISS_CHANGE_GAME_STATE:
    ; ■残機判定
    ; - ゼロならゲーム状態をゲームオーバーへ
    LD A,(LEFT)
    OR A
    JR Z,PLAYER_MISS_CHANGE_GAME_STATE_L1

    ; ■残機ゼロ以外の時の処理
    ; - 残機を１減らす
    LD HL,LEFT
    DEC (HL)
    ; - ゲーム状態をラウンドスタートに戻す
    LD A,STATE_ROUND_START
    CALL CHANGE_STATE

    RET

PLAYER_MISS_CHANGE_GAME_STATE_L1:
    ; ■ゲームの状態をゲームオーバーへ変更
    LD A,STATE_GAME_OVER
    CALL CHANGE_STATE

    RET


; ====================================================================================================
; プレイヤーミス状態かを判定して返却する
; IN  : NONE
; OUT : A 0=ミス状態でない、1=ミス状態である
; ====================================================================================================
IS_PLAYER_MISS:
    LD A,(PLAYER_CONTROL_MODE)      ; プレイヤー操作状態を取得
    SUB PLAYERMODE_MISS
    LD A,0
    RET C                           ; PLAYERMODE_MISS未満の状態のときはキャリーが立っているのでA=ゼロでRET
    LD A,1
    RET


; ====================================================================================================
; プレイヤーミス状態（爆発）に設定する
; IN  : NONE
; OUT : NONE
; ====================================================================================================
SET_PLAYER_MISS_EXPLOSION:
    LD A,PLAYERMODE_EXPLOSION       ; プレイヤー操作状態を爆発に変更
    LD (PLAYER_CONTROL_MODE),A
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■チャージウェイト値
CHARGE_WAIT_VALUE:
    DB $02,$02,$02,$02,$04,$04,$04,$04,$06,$06,$08,$08,$0A,$0A,$0C,$0C,$FF

; ■ミス時のキャラクターパターンデータ
;   ここでは１枚目のスプライトパターン番号のみ設定する
;   ２枚目のスプライトパターンは+1されたパターンが設定される
PLAYER_MISS_PTN1:
    DB 16,18,20,22,0

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

; ■プレイヤーミス時の時間カウント
PLAYER_MISS_TIME_CNT:
    DEFS 1
; ■プレイヤーミス時のスプライトパターン
PLAYER_MISS_PTN_CNT:
    DEFS 1
