; ====================================================================================================
;
; enemy3.asm
;
; included from enemy.asm
;
; ====================================================================================================
SECTION code_user

CHRNO_ENEMY3:           EQU 7       ; キャラクター番号

; ====================================================================================================
; テキ3初期化
; パラメタはなし
; ====================================================================================================
INIT_ENEMY3:
    CALL INIT_ENEMY1                ; まずはテキ１と同じ初期化を行う

    ; ■テキ１の設定からオーバーライドする
    LD (IX),CHRNO_ENEMY3            ; キャラクター番号
    LD (IX+5),41                    ; スプライトパターンNo
    LD (IX+6),13                    ; カラーコード
    LD (IX+8),2                     ; 移動量

    LD HL,(ENEMY_PARAM_ADDR)        ; HL <- パラメータのアドレス
    INC HL                          ; Y座標読み飛ばし
    INC HL                          ; X座標読み飛ばし
    LD A,(HL)                       ; 方向
    CP $FF
    JR NZ,INIT_ENEMY3_L1            ; $FF以外ならランダム設定しない
    CALL GET_RND                    ; 乱数取得(0〜255)
    AND @00000111                   ; 取得した乱数から0〜7の値を取得する
    ADD A,2                         ; A=A+2
    AND @00001110                   ; 下位1ビットを0にする(=2,4,6,8の値にする)
    DEC A                           ; A=A-1(=1,3,5,7の値にする)
INIT_ENEMY3_L1:
    LD (IX+7),A                     ; 移動方向(1=上、3=右、5=下、7=左)

    LD BC,ANIM_PTN_ENEMY3
    LD (IX+9),C                     ; アニメーションテーブルアドレス
    LD (IX+10),B

    ; ■テキ3の独自のプロパティ
    LD (IX+13),128                  ; 方向変更するまでのカウンタ
    LD (IX+14),0                    ; 追尾する方向(0=上下、1=左右)

    RET


; ====================================================================================================
; テキ3処理サブルーチン
; ====================================================================================================
UPDATE_ENEMY3:

    CALL SPRITE_MOVE                ; スプライトキャラクター移動処理

    LD A,(IX+12)                    ; A <- 出現中カウンタ
    OR A
    RET NZ                          ; 出現中の場合は以降の処理はせず抜ける

    DEC (IX+13)                     ; 移動カウンタ -1
    LD A,(IX+13)                    ; 移動量の設定を判定するためカウンタを取得
    CP 96
    JP Z,UPDATE_ENEMY3_L5           ; 96なら移動量1に設定
    CP 80
    JP Z,UPDATE_ENEMY3_L6           ; 64なら移動量$FFに設定
    CP 64
    JP Z,UPDATE_ENEMY3_L7           ; 48なら移動量ゼロに設定
    OR A
    JP NZ,UPDATE_ENEMY3_L8          ; ゼロでなければ衝突判定処理へ

    ; ■移動カウンタゼロの時の処理
    ;  - 移動カウンタ、移動量をリセット
    ;  - 追尾方向からテキとプレイヤーの座標を比較、次の移動方向を決定
    ;  - 追尾方向は縦方向/横方向を交互に切り替える

    LD (IX+13),128                  ; 移動カウンタリセット
    LD (IX+8),2                     ; 移動量リセット

    PUSH IX
    XOR A                           ; A <- 衝突判定用の相手キャラクター（プレイヤー）
    CALL GET_SPR_WK_ADDR
    PUSH IX                         ; IX -> HL
    POP HL
    POP IX                          ; 元のIXを復元
                                    ; この時点で以下が設定されている
                                    ;   HL -> プレイヤーのワークエリアの先頭アドレス
                                    ;   IX -> テキのワークエリアの先頭アドレス

    LD A,(IX+7)
    AND @010
    JP NZ,UPDATE_ENEMY3_L3

    ; ■左右方向の追尾設定
    LD A,(IX+4)                     ; テキのX座標(整数値)
    INC HL
    INC HL
    INC HL
    INC HL
    LD B,(HL)                       ; プレイヤーのX座標(整数値)
    SUB A,B                         ; A=A-B
    JP C,UPDATE_ENEMY3_L2
    ;   テキのX座標 > プレイヤーのX座標
    LD (IX+7),DIRECTION_LEFT        ; 次の移動方向を左にする
    JP UPDATE_ENEMY3_L8
UPDATE_ENEMY3_L2:
    ;   テキのX座標 < プレイヤーのX座標
    LD (IX+7),DIRECTION_RIGHT       ; 次の移動方向を右にする
    JP UPDATE_ENEMY3_L8

UPDATE_ENEMY3_L3:
    ; ■上下方向の追尾設定
    LD A,(IX+2)                     ; テキのY座標(整数値)
    INC HL
    INC HL
    LD B,(HL)                       ; プレイヤーのY座標(整数値)
    SUB A,B                         ; A=A-B
    JP C,UPDATE_ENEMY3_L4
    ;   テキのY座標 > プレイヤーのY座標
    LD (IX+7),DIRECTION_UP          ; 次の移動方向を上にする
    JP UPDATE_ENEMY3_L8

UPDATE_ENEMY3_L4:
    ;   テキのY座標 < プレイヤーのY座標
    LD (IX+7),DIRECTION_DOWN        ; 次の移動方向を下にする
    JP UPDATE_ENEMY3_L8

UPDATE_ENEMY3_L5:
    LD (IX+8),1                     ; 移動量
    JP UPDATE_ENEMY3_L8

UPDATE_ENEMY3_L6:
    LD (IX+8),$FF                   ; 移動量
    JP UPDATE_ENEMY3_L8

UPDATE_ENEMY3_L7:
    LD (IX+8),0                     ; 移動量

UPDATE_ENEMY3_L8:
    CALL ENEMY1_BOUND               ; バウンド処理（テキ１と共通）
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
ANIM_PTN_ENEMY3:
	DB 41,41,41,41,41,41,41,41,42,42,42,42,42,42,42,42,$FF
