; ====================================================================================================
;
; player.asm
;
; included from sprite.asm
;
; ====================================================================================================
SECTION code_user

CHRNO_PLAYER1:                      EQU 1       ; キャラクター番号
CHRNO_PLAYER2:                      EQU 2       ; キャラクター番号

; ■プレイヤー状態の定数
PLAYERMODE_CONTROL:                 EQU $00
PLAYERMODE_LEFTTURN:                EQU $01
PLAYERMODE_RIGHTTURN:               EQU $02
PLAYERMODE_CHARGE:                  EQU $03
PLAYERMODE_MOVE:                    EQU $04
PLAYERMODE_MISS:                    EQU $05
PLAYERMODE_EXPLOSION_INIT:          EQU $06
PLAYERMODE_EXPLOSION:               EQU $07
PLAYERMODE_EXPLOSION2:              EQU $08

; ====================================================================================================
; プレイヤー初期化
; ====================================================================================================
INIT_PLAYER:
    LD (IX),CHRNO_PLAYER1           ; キャラクター番号=プレイヤー(1)

    ; キャラクター番号1にキャラクター番号2の内容をコピーする
    ; 現在のIXは転送先(DE)に設定
    ; のワークアドレスを転送元(HL)に設定
    PUSH IX
    PUSH IX

    LD A,1                          ; IX <- キャラクター番号2のワークアドレス
    CALL GET_SPR_WK_ADDR
    PUSH IX
    POP HL                          ; IX(転送元アドレス) -> HL
    POP DE                          ; DE <- 元のキャラクター番号1のワークアドレス(スタックから取得)
    LD BC,$0010                     ; 転送サイズ=16byte
    LDIR                            ; ブロック転送

    LD A,5
    CALL ADD_HL_A                   ; HL=HL+5 → PLAYER2のスプライトパターンNo1のアドレス
    LD A,(HL)                       ; A <- PLAYER2のスプライトパターンNo
    DEC A                           ; -1する

    POP IX
    LD (IX),CHRNO_PLAYER1           ; キャラクター番号=プレイヤー(1)
    LD (IX+5),A                     ; スプライトパターンNo
    LD (IX+6),1                     ; カラーコード

    ; ■ワークエリア初期化
    XOR A
    LD (PLAYER_CONTROL_MODE),A

INIT_PLAYER_EXIT:
    RET

INIT_PLAYER2:
    ; スプライト2枚目用の初期化処理
    ; ただしワークへの登録順は2枚目→1枚目の順のため、
    ; ここでプレイヤーキャラクターのワーク初期化を行う

    ; ■プレイヤー初期位置データのアドレス取得
    LD HL,PLAYER_INIT_TBL
    LD A,(ROUND)
    CALL GET_ADDR_TBL               ; DE=初期値データの取得先アドレス

    LD (IX),CHRNO_PLAYER2           ; キャラクター番号=プレイヤー(2)

    ; ■プレイヤー初期位置データ設定
    LD A,(DE)
    LD (IX+1),0                     ; Y座標(小数部)
    LD (IX+2),A                     ; Y座標(整数部)
    LD (PLAYER_POS),A               ; ワークに設定

    INC DE
    LD A,(DE)
    LD (IX+3),0                     ; X座標(小数部)
    LD (IX+4),A                     ; X座標(整数部)
    LD (PLAYER_POS+1),A             ; ワークに設定

    INC DE
    LD A,(DE)
    DEC A
    ADD A,A
    INC A
    LD (IX+5),A                     ; スプライトパターンNo
    LD (IX+6),7                     ; カラーコード

    LD A,(DE)
    LD (IX+7),A                     ; 移動方向
    LD (IX+8),0                     ; 移動量
    LD (IX+9),0                     ; アニメーションテーブルアドレス
    LD (IX+10),0                    ; アニメーションテーブルアドレス
    LD (IX+11),0                    ; アニメーションカウンタ

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
    JP UPDATE_PLAYER_EXPLOSION_INIT ; ミス（爆発初期化）
    JP UPDATE_PLAYER_EXPLOSION      ; ミス（爆発）
    JP UPDATE_PLAYER_EXPLOSION2     ; ミス（爆発2）

UPDATE_PLAYER_EXIT:
    RET

UPDATE_PLAYER2:
    ; キャラクター番号2にキャラクター番号1の内容をコピーする
    ; 現在のIXは転送先(DE)に設定
    PUSH IX
    PUSH IX

    ; スプライトキャラクターワークテーブルの2要素目のアドレスを転送元(HL)に設定
    ; (2要素目＝キャラクター番号1のデータ)
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

    ; プレイヤーのスプライトパターン番号は、1枚目のスプライトパターン番号+1とする
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

    ; ■STICK=7(左)のときの処理
    XOR A
    LD (PLAYER_CONTROL_MODE_SV),A   ; プレイヤー操作モード退避(ゼロ)
    LD A,PLAYERMODE_LEFTTURN
    JP UPDATE_PLAYER_CONTROL_L11
;    LD (PLAYER_CONTROL_MODE),A      ; プレイヤー状態を左回転に変更
;    LD A,2
;    LD (PLAYER_CNT_WK1),A           ; WK1:処理繰り返し回数
;    LD A,1
;    LD (PLAYER_CNT_WK2),A           ; WK2:ウェイトカウンタ
;    RET

UPDATE_PLAYER_CONTROL_L1:
    CP 3
    JP NZ,UPDATE_PLAYER_CONTROL_L2

    ; ■STICK=3(右)のときの処理
    XOR A
    LD (PLAYER_CONTROL_MODE_SV),A   ; プレイヤー操作モード退避(ゼロ)
    LD A,PLAYERMODE_RIGHTTURN
UPDATE_PLAYER_CONTROL_L11:
    ; ここは右、左共通
    LD (PLAYER_CONTROL_MODE),A      ; プレイヤー状態を右回転に変更
    LD A,2
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

    ; ■(方向-1)*2をスプライトパターン番号にする(0,2,4,6,8,10,12,14)
    DEC A
    ADD A,A
    LD (IX+5),A

    RET

UPDATE_PLAYER_TURN_END:
    ; ■プレイヤー操作状態をリセット
    LD A,(PLAYER_CONTROL_MODE_SV)   ; 左右ターン前の状態に戻す
    LD (PLAYER_CONTROL_MODE),A
    XOR A
    LD (PLAYER_CONTROL_MODE_SV),A   ; 退避値をゼロにリセット
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

;    CP 4
    JR NZ,UPDATE_PLAYER_CHARGE_L01
    ; ■STICK=4（右下）の場合
    LD A,(PLAYER_CONTROL_MODE)
    LD (PLAYER_CONTROL_MODE_SV),A   ; プレイヤー操作モード退避
    LD A,PLAYERMODE_RIGHTTURN
    JP UPDATE_PLAYER_CONTROL_L11

UPDATE_PLAYER_CHARGE_L01:
    CP 6
    JR NZ,UPDATE_PLAYER_CHARGE_L02
    ; ■STICK=6（左下）の場合
    LD A,(PLAYER_CONTROL_MODE)
    LD (PLAYER_CONTROL_MODE_SV),A   ; プレイヤー操作モード退避
    LD A,PLAYERMODE_LEFTTURN
    JP UPDATE_PLAYER_CONTROL_L11

UPDATE_PLAYER_CHARGE_L02:
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
    LD A,(TICK1)
    AND @00000001
    RET Z

    ; ■STICK値を取得
    LD A,(PLAYER_CNT_WK2)
    OR A
    JR Z,UPDATE_PLAYER_MOVE_L00

    LD HL,PLAYER_CNT_WK2
    DEC (HL)
    JP UPDATE_PLAYER_MOVE_L03

UPDATE_PLAYER_MOVE_L00:
    LD A,(INPUT_BUFF_STICK)
    CP 3
    JR Z,UPDATE_PLAYER_MOVE_L01
    CP 4
    JR Z,UPDATE_PLAYER_MOVE_L01
    CP 6
    JR Z,UPDATE_PLAYER_MOVE_L02
    CP 7
    JR Z,UPDATE_PLAYER_MOVE_L02
    JP UPDATE_PLAYER_MOVE_L03

UPDATE_PLAYER_MOVE_L01:
    ; ■右回転に方向変更
    LD A,(IX+7)
    INC A
    CP 9
    JR NZ,UPDATE_PLAYER_MOVE_L021
    LD A,1
    JR UPDATE_PLAYER_MOVE_L021

UPDATE_PLAYER_MOVE_L02:
    ; ■左回転に方向変更
    LD A,(IX+7)
    DEC A
    JR NZ,UPDATE_PLAYER_MOVE_L021
    LD A,8
UPDATE_PLAYER_MOVE_L021:
    LD (IX+7),A                     ; 方向を設定
    DEC A                           ; (方向-1)*2をスプライトパターン番号にする(0,2,4,6,8,10,12,14)
    ADD A,A
    LD (IX+5),A
    LD A,2
    LD (PLAYER_CNT_WK2),A

UPDATE_PLAYER_MOVE_L03:
    ; ■チャージパワー減算
    LD HL,PLAYER_CHARGE_POWER
    DEC (HL)
    JP Z,UPDATE_PLAYER_MOVE_END

    ; ■チャージパワーから移動量計算
    LD A,(HL)
    CP 5
    JR NC,UPDATE_PLAYER_MOVE_L1

    ; 1〜4のときの移動量
    LD (IX+8),2
    JR UPDATE_PLAYER_MOVE_L3

UPDATE_PLAYER_MOVE_L1:
    CP 11
    JR NC,UPDATE_PLAYER_MOVE_L2

    ; 5〜10のときの移動量
    LD (IX+8),4
    JR UPDATE_PLAYER_MOVE_L3

UPDATE_PLAYER_MOVE_L2:
    ; 11〜のときの移動量
    LD (IX+8),6

UPDATE_PLAYER_MOVE_L3:
    ; ■マップチップ判定
    ; ここでターゲットがあれば取得する
    CALL UPDATE_PLAYER_MOVE_GET_MAPDATA ; A <- マップデータ
    CP 2
    JR NZ,UPDATE_PLAYER_MOVE_L4

    ; ■ターゲット取得
    CALL UPDATE_PLAYER_GETTARGET

UPDATE_PLAYER_MOVE_L4:
    ; ■スプライトキャラクター移動
    CALL SPRITE_MOVE

    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤー移動終了サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_MOVE_END:
    ; ■スコア倍率のリセット判定
    ;   移動中にターゲットを取得していない場合、スコアのキャラクター番号を0に、スコア倍率を1にリセットする
    LD A,(TARGET_GET_FLG)
    OR A
    JR NZ,UPDATE_PLAYER_MOVE_END_L1

    XOR A
    LD (SCORE_CHRNO),A
    INC A
    LD (SCORE_ADDVALUE_BCD),A

UPDATE_PLAYER_MOVE_END_L1:
    XOR A                           ; ターゲット取得フラグをOFF
    LD (TARGET_GET_FLG),A

    ; ■停止地点のマップチップ判定
    CALL UPDATE_PLAYER_MOVE_GET_MAPDATA ; A <- マップデータ
    CP 3
    JR Z,UPDATE_PLAYER_MOVE_END_L2  ; マップデータが3(出口)の場合、ゲーム状態をラウンドクリアに変更

    OR A
    JR NZ,UPDATE_PLAYER_MOVE_END_L3 ; マップデータがゼロでなければ、プレイヤー操作に状態遷移

    ; ■ミス時の初期設定
    ; - パターンテーブルのインデックス
    XOR A
    LD (PLAYER_MISS_PTN_CNT),A

    ; - 時間経過カウントをリセット
    ;   最初に必ずDECするので、1を設定しておく
    INC A
    LD (PLAYER_MISS_TIME_CNT),A

    ; - ミスの全体の時間
    LD A,$60
    LD (PLAYER_CNT_WK1),A

    ; ■ミスの状態に遷移
    LD A,PLAYERMODE_MISS
    LD (PLAYER_CONTROL_MODE),A

    ; ■BGM再生
    LD HL,_06
    CALL SOUNDDRV_BGMPLAY
    RET

UPDATE_PLAYER_MOVE_END_L2:
    ; ■ターゲット残数チェック
    LD A,(TARGET_LEFT)
    OR A
    JR NZ,UPDATE_PLAYER_MOVE_END_L3 ; ターゲット残数がゼロでなければ、状態遷移のみ実施

    ; ■ゲーム状態をラウンドクリアに変更
    LD A,STATE_ROUND_CLEAR
    CALL CHANGE_STATE
    
UPDATE_PLAYER_MOVE_END_L3:
    ; ■プレイヤー操作に状態遷移
    LD A,PLAYERMODE_CONTROL
    LD (PLAYER_CONTROL_MODE),A
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤー移動時のマップデータ取得サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_MOVE_GET_MAPDATA:

    CALL GET_MAPDATA_OFFSET         ; A <- マップデータオフセット
    CALL GET_MAPDATA                ; A <- マップデータ
    RET

; ----------------------------------------------------------------------------------------------------
; ターゲット取得サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_GETTARGET:

    ; ■ターゲット残数デクリメント
    LD A,(TARGET_LEFT)
    OR A
    JR Z,UPDATE_PLAYER_GETITEM_L1   ; ゼロなら何もしない

    DEC A
    LD (TARGET_LEFT),A
    OR A
    JR NZ,UPDATE_PLAYER_GETITEM_L1  ; ゼロ以外なら次の処理へ

    ; ■ターゲット残数がゼロなら出口を表示する
    LD A,(MAPWK_EXIT_OFFSET)
    LD B,A
    CALL DRAW_MAPCHIP

UPDATE_PLAYER_GETITEM_L1:
    ; ■マップデータオフセット取得
    CALL GET_MAPDATA_OFFSET         ; A <- マップデータオフセット
    LD B,A

    ; ■マップデータ更新
    LD HL,MAP_WK
    CALL ADD_HL_A
    LD (HL),1    

    ; ■仮想画面更新
    ; マップデータのオフセットに該当するマップチップを書き換える
    CALL DRAW_MAPCHIP

    ; ■ターゲット取得フラグON
    LD A,1
    LD (TARGET_GET_FLG),A

    ; ■効果音再生
    LD HL,SFX_01
    CALL SOUNDDRV_SFXPLAY

    ; ■スコア加算
    LD A,(SCORE_ADDVALUE_BCD)       ; スコア倍率
    LD D,0                          ; DE <- 加算スコア
    LD E,A
    CALL ADDSCORE                   ; スコア加算

    ; ■スコアのキャラクター表示
    LD A,CHRNO_SCORE                ; スコアのキャラクターを追加する
    CALL ADD_CHARACTER

    LD A,(SCORE_ADDVALUE_BCD)       ; スコア倍率
    CP $16
    RET Z                           ; 既に16倍なら抜ける

    ; ■次の表示に向けた準備
    ADD A,A                         ; スコア倍率を２倍
    DAA
    LD (SCORE_ADDVALUE_BCD),A

    LD A,(SCORE_CHRNO)              ; 得点のキャラクター番号を設定
    INC A
    LD (SCORE_CHRNO),A

UPDATE_PLAYER_GETITEM_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤーミス（落下）サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_MISS:
    ; ■ミスの処理時間カウントダウン
    LD HL,PLAYER_CNT_WK1
    DEC (HL)
    JP Z,PLAYER_MISS_CHANGE_GAME_STATE

    ; ■ミスカウント減算
    LD HL,PLAYER_MISS_TIME_CNT
    DEC (HL)
    RET NZ
    
    ; ■カウントゼロ時の処理
    ; - スプライトパターン番号を取得する
    ; - ゼロの場合はスプライト表示消去
    LD HL,PLAYER_MISS_PTN_CNT
    LD B,0
    LD C,(HL)
    LD HL,PLAYER_MISS_PTN1
    ADD HL,BC

    LD A,(HL)
    OR A
    JP Z,UPDATE_PLAYER_MISS_L1

    ; - スプライトパターン番号を更新する
    LD (IX+5),A
    ; - ミスカウントリセット
    LD A,7
    LD (PLAYER_MISS_TIME_CNT),A
    ; - パターンカウントを+1
    LD HL,PLAYER_MISS_PTN_CNT
    INC (HL)
    RET

UPDATE_PLAYER_MISS_L1:
    LD (IX+2),-16
    LD (IX+4),-16
    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤーミス（爆発初期化）サブルーチン
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_EXPLOSION_INIT:
    ; ■BGM停止
    CALL SOUNDDRV_STOP

    ; ■ミスカウント初期化
    LD A,30
    LD (PLAYER_MISS_TIME_CNT),A

    ; ■プレイヤー状態を爆発に変更
    LD A,PLAYERMODE_EXPLOSION
    LD (PLAYER_CONTROL_MODE),A

    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤーミス（爆発）サブルーチン
; 30flame経過まで待つ。
; 30flame経過後は、スプライトキャラクターワークを初期化してバクハツを生成する
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_EXPLOSION:
    ; ■ミスカウント減算
    LD HL,PLAYER_MISS_TIME_CNT
    DEC (HL)
    RET NZ

    ; ■プレイヤーの座標を画面外に設定
    ;   バクハツ完了後の状態遷移までを行う必要があるため、
    ;   プレイヤーは非表示で生かしておく
    LD (IX+2),-16
    LD (IX+4),-16

    ; ■プレイヤー以外のスプライトキャラクターを除去
    ;   ここ以降はプレイヤーのワークアドレス(IX)は参照できなくなるので注意
    ;   1,2はプレイヤー固定なので対象外、3以降に対して除去していく
    LD B,MAX_CHR_CNT
UPDATE_PLAYER_EXPLOSION_L1:
    LD A,B
    CALL GET_SPR_WK_ADDR            ; IX <- 対象インデックスのスプライトキャラクターワークテーブルアドレス
    LD A,(IX)                       ; キャラクター番号
    SUB 3                           ; キャラクター番号 - 3
    JR C,UPDATE_PLAYER_EXPLOSION_L11
    CALL DEL_CHARACTER              ; スプライトキャラクターワークテーブルから除去
UPDATE_PLAYER_EXPLOSION_L11:
    DJNZ UPDATE_PLAYER_EXPLOSION_L1; 次が0になるまで繰り返し処理

    ; ■バクハツのキャラクターを生成
    LD B,4
UPDATE_PLAYER_EXPLOSION_L2:
    LD A,B
    ADD A,A
    LD (INIT_EXPLOSION_DIRECTION),A
    LD A,CHRNO_EXPLOSION
    CALL ADD_CHARACTER
    DJNZ UPDATE_PLAYER_EXPLOSION_L2

    ; ■SFX再生
    LD HL,SFX_03
    CALL SOUNDDRV_BGMPLAY

    ; ■ミスカウント初期化
    LD A,64
    LD (PLAYER_MISS_TIME_CNT),A

    ; ■プレイヤー状態を爆発2に変更
    LD A,PLAYERMODE_EXPLOSION2
    LD (PLAYER_CONTROL_MODE),A

    RET

; ----------------------------------------------------------------------------------------------------
; プレイヤーミス（爆発2）サブルーチン
; 64flame経過まで待つ。
; 64flame経過後は、次のゲーム状態に遷移する。
; ----------------------------------------------------------------------------------------------------
UPDATE_PLAYER_EXPLOSION2:
    ; ■ミスカウント減算
    LD HL,PLAYER_MISS_TIME_CNT
    DEC (HL)
    LD A,(HL)
    OR A
    RET NZ


; ====================================================================================================
; プレイヤーミス後のゲーム状態変更処理
; ====================================================================================================
PLAYER_MISS_CHANGE_GAME_STATE:
    ; ■プレイヤーチャージパワーをゼロに設定
    LD A,0
    LD (PLAYER_CHARGE_POWER),A

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
; 呼び出し元では、CALL後にキャリーフラグを判定でも可(ON=ミス状態ではない、OFF=ミス状態)
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
    LD A,PLAYERMODE_EXPLOSION_INIT  ; プレイヤー操作状態を爆発初期化に変更
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
; 0=CONTROL,1=TURN LEFT,2=TURN RIGHT,3=CHARGE,4=MOVE,5〜=MISS
PLAYER_CONTROL_MODE:
    DEFS 1

; ■プレイヤー操作モード退避用
PLAYER_CONTROL_MODE_SV:
    DEFS 1

; ■チャージパワー
PLAYER_CHARGE_POWER:
    DEFS 1

; ■プレイヤー座標(Y,X)
PLAYER_POS:
    DEFS 2

; ■汎用カウンタワーク
PLAYER_CNT_WK1:
    DEFS 1
PLAYER_CNT_WK2:
    DEFS 1

; ■プレイヤーミス時の時間カウント
PLAYER_MISS_TIME_CNT:
    DEFS 1

; ■プレイヤーミス時のスプライトパターンカウント
PLAYER_MISS_PTN_CNT:
    DEFS 1

; ■ターゲット取得フラグ
TARGET_GET_FLG:
    DEFS 1
