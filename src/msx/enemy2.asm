; ====================================================================================================
;
; enemy2.asm
;
; included from enemy.asm
;
; ====================================================================================================
SECTION code_user

CHRNO_ENEMY2:           EQU 6       ; キャラクター番号

; ====================================================================================================
; テキ2初期化
; パラメタ1：回転方向(0=右回り、1=左回り)
; ====================================================================================================
INIT_ENEMY2:
    CALL INIT_ENEMY1                ; まずはテキ１と同じ初期化を行う

    LD (IX),CHRNO_ENEMY2            ; キャラクター番号=テキ2
    LD (IX+5),33                    ; スプライトパターンNo=33(テキ1)
    LD (IX+6),6                     ; カラーコード
    LD (IX+8),$FF                   ; 移動量
    LD BC,ANIM_PTN_ENEMY2
    LD (IX+9),C                     ; アニメーションテーブルアドレス
    LD (IX+10),B

    ; ■テキ2の独自のプロパティ
    LD (IX+13),32                   ; 方向変更するまでのカウンタ

    LD HL,(ENEMY_PARAM_ADDR)        ; HL <- パラメータのアドレス
    INC HL
    INC HL
    INC HL
    LD A,(HL)
    OR A
    JR Z,INIT_ENEMY2_L2
    LD A,1

INIT_ENEMY2_L2:
    LD (IX+14),A                    ; 方向 0=右回り(方向+1)、1=左回り(方向-1)

    RET


; ====================================================================================================
; テキ2処理サブルーチン
; ====================================================================================================
UPDATE_ENEMY2:

    CALL SPRITE_MOVE                ; スプライトキャラクター移動処理

    ; ■方向変換カウンタ
    DEC (IX+13)                     ; カウンタ -1
    RET NZ                          ; ゼロでなければ終了
    LD (IX+13),32                   ; カウンタリセット
    LD A,(IX+14)                    ; 方向
    OR A
    JR NZ,UPDATE_ENEMY2_L1          ; ゼロでなければ左回り

    ;   右回り
    LD A,(IX+7)                     ; A <- 方向
    INC A                           ; A=A+1
    CP 9                            ; 結果が9か
    JR NZ,UPDATE_ENEMY2_L2
    LD A,1                          ; 移動方向を1に設定
    JP UPDATE_ENEMY2_L2

UPDATE_ENEMY2_L1:
    ;   左回り
    LD A,(IX+7)                     ; A <- 方向
    DEC A                           ; A=A-1
    OR A                            ; ゼロかどうか判定(ゼロならZフラグがONになる)
    JR NZ,UPDATE_ENEMY2_L2
    LD A,8                          ; 移動方向を8に設定

UPDATE_ENEMY2_L2:
    LD (IX+7),A                     ; A -> 方向

    CALL HIT_CHECK_FROM_ENEMY       ; 衝突判定
    RET NC                          ; ヒットしてなかったら終了
    CALL SET_PLAYER_MISS_EXPLOSION  ; プレイヤーミス状態（爆発）に設定
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■アニメーションパターン
ANIM_PTN_ENEMY2:
	DB 33,33,33,33,34,34,34,34,35,35,35,35,36,36,36,36,35,35,35,35,34,34,34,34,$FF
