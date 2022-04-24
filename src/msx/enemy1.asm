; ====================================================================================================
;
; enemy1.asm
;
; included from enemy.asm
; requirement player.asm
;
; ====================================================================================================
SECTION code_user

CHRNO_ENEMY1:           EQU 3       ; キャラクター番号

; ====================================================================================================
; テキ1初期化
; ====================================================================================================
INIT_ENEMY1:
    LD HL,(ENEMY_PARAM_ADDR)        ; HL <- パラメータのアドレス
    LD (IX),CHRNO_ENEMY1            ; キャラクター番号=テキ1

    ; ■Y座標設定
    LD A,(HL)
    CP $FF
    JR Z,INIT_ENEMY1_L1             ; $FFならランダム設定とする
    JP INIT_ENEMY1_L2

INIT_ENEMY1_L1:
    CALL GET_RND_SPR_Y              ; A <- Y座標(ランダム)
INIT_ENEMY1_L2:
    LD (IX+1),0                     ; Y座標(下位)
    LD (IX+2),A                     ; Y座標(上位)

    ; ■X座標設定
    INC HL
    LD A,(HL)
    CP $FF
    JR Z,INIT_ENEMY1_L3
    JP INIT_ENEMY1_L4

INIT_ENEMY1_L3:
    CALL GET_RND_SPR_X              ; A <- X座標(ランダム)
INIT_ENEMY1_L4:
    LD (IX+3),0                     ; X座標(下位)
    LD (IX+4),A                     ; X座標(上位)

    ; ■パターンNo設定
    LD (IX+5),3                     ; パターンNo=3(テキ1)
    
INIT_ENEMY1_L5:
    ; ■カラーコード設定
    LD (IX+6),$B                     ; カラーコード

    ; ■方向設定
    INC HL
    LD A,(HL)
    CP $FF
    JR Z,INIT_ENEMY1_L6
    JP INIT_ENEMY1_L7

INIT_ENEMY1_L6:
    CALL GET_RND                    ; 乱数取得(0〜255)
    AND @00000111                   ; 取得した乱数から0〜7の値を取得する
    ADD A,2                         ; A=A+2
    AND @00001110                   ; 下位1ビットを0にする(=2,4,6,8の値にする)
INIT_ENEMY1_L7:
    LD (IX+7),A                     ; 方向

    ; ■キャラクタアニメーションテーブル番号設定
    ; 移動方向が1～4は右向き(ANIM_PTN_ENEMY1)
    ;           5～8は左向き(ANIM_PTN_ENEMY2)を設定する
    CP 5
    JR NC,INIT_ENEMY1_L8            ; 5～8はキャリーフラグが立たないのでENEMY_BOUND_L5へ

    ; 右向きの設定
    LD (IX+8),1                     ; アニメーションテーブル番号=1(ANIM_PTN_ENEMY1_R)
    LD (IX+9),0                     ; アニメーションカウンタ=0
    RET

INIT_ENEMY1_L8:
    ; 左向きの設定
    LD (IX+8),2                     ; アニメーションテーブル番号=2(ANIM_PTN_ENEMY1_L)
    LD (IX+9),0                     ; アニメーションカウンタ=0

INIT_ENEMY1_EXIT:
	RET


; ====================================================================================================
; テキ1処理サブルーチン
; ====================================================================================================
UPDATE_ENEMY1:
    ; ■移動
    CALL SPRITE_MOVE                ; スプライトキャラクター移動処理
    CALL ENEMY_BOUND                ; テキバウンド処理
    CALL SPRITE_ANIM                ; スプライトパターン番号更新

    ; ■ヒット判定
    CALL IS_PLAYER_MISS
    OR A
    JR NZ,UPDATE_ENEMY1_L1          ; プレイヤーミス状態なら衝突判定せずに終了

    LD C,0                          ; C <- 衝突判定用の相手キャラクター番号
                                    ;      0 = プレイヤー
    CALL HIT_CHECK                  ; 衝突判定
    JR NC,UPDATE_ENEMY1_L1          ; ヒットしてなかったら終了

    CALL SET_PLAYER_MISS_EXPLOSION  ; プレイヤーミス状態（爆発）に設定

    ; ■SFX再生
;    LD HL,SFX_02
;    CALL SOUNDDRV_SFXPLAY

UPDATE_ENEMY1_L1:
    RET 

; ----------------------------------------------------------------------------------------------------
; テキバウンド処理
; ----------------------------------------------------------------------------------------------------
ENEMY_BOUND:
    ; ■移動方向のアドレスをHLレジスタに設定
    PUSH IX                         ; IX -> HL
    POP HL
    LD DE,7                         ; HL=HL+7
    ADD HL,DE                       ; HL=移動方向のアドレス

    ; ■テキバウンド処理（垂直方向）
    CALL ENEMY_BOUND_VERTICAL

    ; ■テキバウンド処理（水平方向）
    CALL ENEMY_BOUND_HOLIZONTAL

;ENEMY_BOUND_L5:
;    ; ■キャラクタアニメーションテーブル番号設定
;    ; 移動方向が1～4は右向き(ANIM_PTN_ENEMY1)
;    ;          5～8は左向き(ANIM_PTN_ENEMY2)を設定する
;    LD A,(HL)                       ; A <- 移動方法
;    CP 5
;    JR NC,ENEMY_BOUND_L6            ; 5～8はキャリーフラグが立たないのでENEMY_BOUND_L4へ
;
;    INC HL
;    LD (HL),1                       ; アニメーションテーブル番号=1(ANIM_PTN_ENEMY1)
;    INC HL
;    LD (HL),0                       ; アニメーションカウンタ=0
;    JR ENEMY_BOUND_EXIT
;
;ENEMY_BOUND_L6:
;    INC HL
;    LD (HL),2                       ; アニメーションテーブル番号=2(ANIM_PTN_ENEMY2)
;    INC HL
;    LD (HL),0                       ; アニメーションカウンタ=0
;
ENEMY_BOUND_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; 敵バウンド処理（垂直方向）
; IN  : IX = 対象キャラクターのスプライトキャラクターワークテーブルの先頭アドレス
;       HL = 移動方向のアドレス
; ----------------------------------------------------------------------------------------------------
ENEMY_BOUND_VERTICAL:
    ; ■Y座標をDレジスタに取得
    LD D,(IX+2)                     ; D <- Y座標(整数部)

    ; ■画面上端チェック
    LD A,D
    CP 8+1                          ; Y座標が8以下だと、ここでキャリーが立つ
    JR NC,ENEMY_BOUND_VERTICAL_L1   ; 画面上端でなければ画面下端チェックへ

    ; ■Y座標が上端の場合の跳ね返りの方向決定
    ; - V=DIRECTION_UPRIGHT の時：V = DIRECTION_DOWNRIGHT
    ; - V=DIRECTION_UPLEFT の時 ：V = DIRECTION_DOWNLEFT
    LD A,(HL)                       ; A <- 現在の移動方向
    LD (HL),DIRECTION_DOWNRIGHT     ; まずは次の移動方向をDIRECTION_DOWNRIGHTとする
    CP DIRECTION_UPRIGHT
    RET Z

    LD (HL),DIRECTION_DOWNLEFT      ; 次の移動方向をDIRECTION_DOWNLEFTにする
    RET

ENEMY_BOUND_VERTICAL_L1:
    ; ■画面下端チェック
    LD A,D
    CP 192-8-16-1
    RET C                           ; 画面下端でなければ終了

    ; ■Y座標が下端の場合の跳ね返りの方向決定
    ; - V=DIRECTION_DOWNRIGHT の時：V = DIRECTION_UPRIGHT
    ; - V=DIRECTION_DOWNLEFT の時 ：V = DIRECTION_UPLEFT
    LD A,(HL)                       ; A <- 現在の移動方向
    LD (HL),DIRECTION_UPRIGHT       ; まずは次の移動方向をDIRECTION_UPRIGHTとする
    CP DIRECTION_DOWNRIGHT
    RET Z                           ; 移動方向=DIRECTION_DOWNRIGHTの場合はこのままでいいので、終了

    LD (HL),DIRECTION_UPLEFT        ; 次の移動方向をDIRECTION_UPLEFTにする
    RET

; ----------------------------------------------------------------------------------------------------
; 敵バウンド処理（水平方向）
; IN  : IX = 対象キャラクターのスプライトキャラクターワークテーブルの先頭アドレス
;       HL = 移動方向のアドレス
; ----------------------------------------------------------------------------------------------------
ENEMY_BOUND_HOLIZONTAL:
    ; ■X座標をDレジスタに取得
    LD D,(IX+4)                     ; D <- X座標(整数部)

    ; ■X座標が画面左端か調べる
    LD A,D
    CP 0+1
    JR NC,ENEMY_BOUND_HOLIZONTAL_L1 ; 画面左端でなければ画面右端チェックへ

    ; ■跳ね返りの方向決定
    ; - V=DIRECTION_UPLEFT の時  ：V = DIRECTION_UPRIGHT
    ; - V=DIRECTION_DOWNLEFT の時：V = DIRECTION_DOWNRIGHT
    LD A,(HL)                       ; A <- 現在の移動方向
    LD (HL),DIRECTION_UPRIGHT       ; まずは次の移動方向をDIRECTION_UPRIGHTとする
    CP DIRECTION_UPLEFT
    RET Z

    LD (HL),DIRECTION_DOWNRIGHT     ; 次の移動方向をDIRECTION_DOWNRIGHTにする
    RET

ENEMY_BOUND_HOLIZONTAL_L1:
    ; ■X座標が右端か調べる
    LD A,D
    CP 256-16-1
    RET C                           ; 画面右端でなければ終了

    ; ■跳ね返りの方向決定
    ; - V = DIRECTION_UPRIGHT の時  ：V = DIRECTION_UPLEFT
    ; - V = DIRECTION_DOWNRIGHT の時：V = DIRECTION_DOWNLEFT
    LD A,(HL)                       ; A <- 現在の移動方向
    LD (HL),DIRECTION_UPLEFT        ; まずは次の移動方向をDIRECTION_UPLEFTとする
    CP DIRECTION_UPRIGHT
    RET Z

    LD (HL),DIRECTION_DOWNLEFT      ; 次の移動方向をDIRECTION_DOWNLEFTにする
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
