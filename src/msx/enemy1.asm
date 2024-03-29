; ====================================================================================================
;
; enemy1.asm
;
; included from enemy.asm
; requirement player.asm
;
; ====================================================================================================
SECTION code_user

CHRNO_ENEMY1:           EQU 5       ; キャラクター番号

; ====================================================================================================
; テキ1初期化
; ====================================================================================================
INIT_ENEMY1:
    LD HL,(ENEMY_PARAM_ADDR)        ; HL <- パラメータのアドレス
    PUSH IX
    POP DE
    LD A,CHRNO_ENEMY1
    LD (DE),A                       ; キャラクター番号=テキ1

    ; ■Y座標設定
    INC DE                          ; +1
    XOR A
    LD (DE),A                       ; Y座標(小数部)
    LD A,(HL)
    CP $FF
    JR NZ,INIT_ENEMY1_L1            ; $FF以外ならランダム設定しない
    CALL GET_RND_SPR_Y              ; A <- Y座標(ランダム)

INIT_ENEMY1_L1:
    INC DE                          ; +2
    LD (DE),A                       ; Y座標(整数部)

    ; ■X座標設定
    INC DE                          ; +3
    XOR A
    LD (DE),A                       ; X座標(小数部)
    INC HL
    LD A,(HL)
    CP $FF
    JR NZ,INIT_ENEMY1_L2            ; $FF以外ならランダム設定しない
    CALL GET_RND_SPR_X              ; A <- X座標(ランダム)

INIT_ENEMY1_L2:
    INC DE                          ; +4
    LD (DE),A                       ; X座標(整数部)

    INC DE                          ; +5
    LD A,33
    LD (DE),A                       ; スプライトパターンNo    
    INC DE                          ; +6
    LD A,7
    LD (DE),A                       ; カラーコード

    ; ■方向設定
    INC HL
    LD A,(HL)
    CP $FF
    JR NZ,INIT_ENEMY1_L3            ; $FF以外ならランダム設定しない
    CALL GET_RND                    ; 乱数取得(0〜255)
    AND @00000111                   ; 取得した乱数から0〜7の値を取得する
    ADD A,2                         ; A=A+2
    AND @00001110                   ; 下位1ビットを0にする(=2,4,6,8の値にする)

INIT_ENEMY1_L3:
    INC DE                          ; +7
    LD (DE),A                       ; 方向
    INC DE                          ; +8
    LD A,$FF
    LD (DE),A                       ; 移動量
    LD HL,ANIM_PTN_ENEMY1           ; キャラクタアニメーションテーブルアドレス
    INC DE                          ; +9
    LD A,L
    LD (DE),A                       ; アニメーションテーブルのアドレス(L)
    INC DE                          ; +10
    LD A,H
    LD (DE),A                       ; アニメーションテーブルのアドレス(H)
    INC DE                          ; +11
    XOR A
    LD (DE),A                       ; アニメーションカウンタ=0
    INC DE                          ; +12
    LD A,ENEMY_FLASHING_CNT
    LD (DE),A                       ; 出現中カウンタ

 	RET


; ====================================================================================================
; テキ1処理サブルーチン
; ====================================================================================================
UPDATE_ENEMY1:

    CALL SPRITE_MOVE                ; スプライトキャラクター移動処理
    CALL ENEMY1_BOUND               ; テキバウンド処理
    CALL HIT_CHECK_FROM_ENEMY       ; 衝突判定
    JR NC,UPDATE_ENEMY1_L1          ; ヒットしてなかったら終了

    CALL SET_PLAYER_MISS_EXPLOSION  ; プレイヤーミス状態（爆発）に設定

UPDATE_ENEMY1_L1:
    RET 

; ----------------------------------------------------------------------------------------------------
; テキバウンド処理
; ----------------------------------------------------------------------------------------------------
ENEMY1_BOUND:

    LD A,(TICK1)
    AND @00000001
    RET Z

    ; ■出現中か
    LD A,(IX+12)
    OR A
    RET NZ                          ; 出現中カウンタ > 0 の場合、終了する

    ; ■画面上端か
    LD HL,ENEMY_BOUNDDATA_VERTICAL  ; 参照先デーブルデータのアドレス
    LD A,(IX+2)                     ; A <- Y座標(整数部)
    CP Y_MIN+1
    JR C,ENEMY1_BOUND_L4            ; バウンド処理

ENEMY1_BOUND_L1:
    ; ■画面下端か
    CP Y_MAX-1
    JR NC,ENEMY1_BOUND_L4            ; バウンド処理

ENEMY1_BOUND_L2:
    ; ■画面左端か
    LD HL,ENEMY_BOUNDDATA_HOLIZONAL ; 参照先デーブルデータのアドレス
    LD A,(IX+4)                     ; A <- X座標(整数部)
    OR A
    JR Z,ENEMY1_BOUND_L4            ; バウンド処理

ENEMY1_BOUND_L3:
    ; ■画面右端か
    CP X_MAX
    RET C                           ; 画面右端でなければここで終了

ENEMY1_BOUND_L4:
    LD A,(IX+7)                     ; A <- 移動方向
    DEC A                           ; テーブル検索用に-1する
    CALL ADD_HL_A                   ; HL = HL + A
    LD A,(HL)
    LD (IX+7),A
    RET


; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================
SECTION rodata_user

; ■アニメーションパターン
ANIM_PTN_ENEMY1:
	DB 33,33,33,33,34,34,34,34,35,35,35,35,36,36,36,36,35,35,35,35,34,34,34,34,$FF

; ■バウンド方向データ
ENEMY_BOUNDDATA_VERTICAL:
    ; - DIRECTION_UP(1)        の時：DIRECTION_DOWN(5)
    ; - DIRECTION_UPRIGHT(2)   の時：DIRECTION_DOWNRIGHT(4)
    ; - DIRECTION_DOWNRIGHT(4) の時：DIRECTION_UPRIGHT(2)
    ; - DIRECTION_DOWN(5)      の時：DIRECTION_UP(1)
    ; - DIRECTION_DOWNLEFT(6)  の時：DIRECTION_UPLEFT(8)
    ; - DIRECTION_UPLEFT(8)    の時：DIRECTION_DOWNLEFT(6)
    DB 5,4,0,2,1,8,0,6
ENEMY_BOUNDDATA_HOLIZONAL:
    ; - DIRECTION_UPRIGHT(2)   の時：DIRECTION_UPLEFT(8)
    ; - DIRECTION_RIGHT(3)     の時：DIRECTION_LEFT(7)
    ; - DIRECTION_DOWNRIGHT(4) の時：DIRECTION_DOWNLEFT(6)
    ; - DIRECTION_DOWNLEFT(6)  の時：DIRECTION_DOWNRIGHT(4)
    ; - DIRECTION_LEFT(7)      の時：DIRECTION_RIGHT(3)
    ; - DIRECTION_UPLEFT(8)    の時：DIRECTION_UPRIGHT(2)
    DB 0,8,7,6,0,4,3,2
