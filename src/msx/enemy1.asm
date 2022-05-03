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
    LD (IX),CHRNO_ENEMY1            ; キャラクター番号=テキ1

    ; ■Y座標設定
    LD A,(HL)
    CP $FF
    JR NZ,INIT_ENEMY1_L1            ; $FF以外ならランダム設定しない
    CALL GET_RND_SPR_Y              ; A <- Y座標(ランダム)

INIT_ENEMY1_L1:
    LD (IX+1),0                     ; Y座標(下位)
    LD (IX+2),A                     ; Y座標(上位)

    ; ■X座標設定
    INC HL
    LD A,(HL)
    CP $FF
    JR NZ,INIT_ENEMY1_L2            ; $FF以外ならランダム設定しない
    CALL GET_RND_SPR_X              ; A <- X座標(ランダム)

INIT_ENEMY1_L2:
    LD (IX+3),0                     ; X座標(下位)
    LD (IX+4),A                     ; X座標(上位)

    LD (IX+5),3                     ; スプライトパターンNo=3(テキ1)    
    LD (IX+6),$0B                   ; カラーコード

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
    LD (IX+7),A                     ; 方向
    LD (IX+8),$FF                   ; 移動量
    LD (IX+11),0                    ; アニメーションカウンタ=0
    LD (IX+12),ENEMY_FLASHING_CNT   ; 出現中カウンタ

    ; ■キャラクタアニメーションテーブル番号設定
    ; 移動方向が1～4は右向き(ANIM_PTN_ENEMY1_R)
    ;           5～8は左向き(ANIM_PTN_ENEMY1_L)を設定する
    LD HL,ANIM_PTN_ENEMY1_R         ; 右向きの設定
    CP 5
    JR C,INIT_ENEMY1_L4             ; 5～8以外はキャリーフラグが立つのでINIT_ENEMY_L4へ    
    LD HL,ANIM_PTN_ENEMY1_L         ; 左向きの設定

INIT_ENEMY1_L4:
    LD (IX+9),L                     ; アニメーションテーブルのアドレス(L)
    LD (IX+10),H                    ; アニメーションテーブルのアドレス(H)
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
    CP X_MAX - 1
    RET C                           ; 画面右端でなければここで終了

ENEMY1_BOUND_L4:
    LD A,(IX+7)                     ; A <- 移動方向
    DEC A                           ; テーブル検索用に-1する
    CALL ADD_HL_A                   ; HL = HL + A
    LD A,(HL)
    LD (IX+7),A
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■アニメーションパターン
ANIM_PTN_ENEMY1_R:
	DB 2,2,2,2,6,6,6,6,10,10,10,10,14,14,14,14,0
ANIM_PTN_ENEMY1_L:
	DB 2,2,2,2,6,6,6,6,10,10,10,10,14,14,14,14,0

; ■バウンド方向データ
ENEMY_BOUNDDATA_VERTICAL:
    ; - DIRECTION_UPRIGHT(2)   の時：DIRECTION_DOWNRIGHT(4)
    ; - DIRECTION_UPLEFT(8)    の時：DIRECTION_DOWNLEFT(6)
    ; - DIRECTION_DOWNRIGHT(4) の時：DIRECTION_UPRIGHT(2)
    ; - DIRECTION_DOWNLEFT(6)  の時：DIRECTION_UPLEFT(8)
    DB 0,4,0,2,0,8,0,6
ENEMY_BOUNDDATA_HOLIZONAL:
    ; - DIRECTION_UPLEFT(8)    の時：DIRECTION_UPRIGHT(2)
    ; - DIRECTION_DOWNLEFT(6)  の時：DIRECTION_DOWNRIGHT(4)
    ; - DIRECTION_UPRIGHT(2)   の時：DIRECTION_UPLEFT(8)
    ; - DIRECTION_DOWNRIGHT(4) の時：DIRECTION_DOWNLEFT(6)
    DB 0,8,0,6,0,4,0,2
