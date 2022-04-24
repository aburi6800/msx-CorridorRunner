; ====================================================================================================
;
; enemy2.asm
;
; included from enemy.asm
;
; ====================================================================================================
SECTION code_user

CHRNO_ENEMY2:           EQU 4       ; キャラクター番号

; ====================================================================================================
; テキ2初期化
; ====================================================================================================
INIT_ENEMY2:
    CALL INIT_ENEMY1                ; まずはテキ１と同じ初期化を行う

    LD (IX),CHRNO_ENEMY2            ; キャラクター番号=テキ2
    LD (IX+5),7
    LD (IX+8),3                     ; アニメーションテーブル番号=3(ANIM_PTN_ENEMY2)
    LD (IX+9),0                     ; アニメーションカウンタ=0

    ; テキ2の独自のプロパティ
    LD (IX+10),20                   ; カウンタ(20フレーム)

    RET


; ====================================================================================================
; テキ2処理サブルーチン
; ====================================================================================================
UPDATE_ENEMY2:
    ; ■移動
    CALL SPRITE_MOVE                ; スプライトキャラクター移動処理
    CALL SPRITE_ANIM                ; スプライトパターン番号更新

    ; ■カウンタ減算
    LD A,(IX+10)                    ; A <- カウンタ
    DEC A                           ; A=A-1
    OR A                            ; ゼロかどうか判定(ゼロならZフラグがONになる)
    JR NZ,UPDATE_ENEMY2_L2          ; ゼロでなければL2へ

    ; ■カウンタリセット
    LD (IX+10),20

    ; ■移動方向を変更する
    LD A,(IX+7)                     ; A <- 方向
    DEC A                           ; A=A-1
    OR A                            ; ゼロかどうか判定(ゼロならZフラグがONになる)
    JR NZ,UPDATE_ENEMY2_L1
    LD A,8                          ; 移動方向を8に設定

UPDATE_ENEMY2_L1:
    LD (IX+7),A                     ; A -> 方向
    RET

UPDATE_ENEMY2_L2:
    LD (IX+10),A
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■アニメーションパターン
ANIM_PTN_ENEMY2:
	DB 8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,0
