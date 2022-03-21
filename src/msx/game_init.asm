; ====================================================================================================
;
; game_init.asm
;
; included from game.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; ゲーム初期化
; ====================================================================================================
GAME_INIT:
    ; ■乱数初期化
    CALL INIT_RND

    ; ■各変数初期化
    ; - ラウンド数
    LD A,1
    LD (ROUND),A
    ; - スコア
    LD A,0
    LD (SCORE),A
    LD (SCORE+1),A
    LD (SCORE+2),A
    ; - 残機
    LD A,2
    LD (LEFT),A

    ; ■ゲーム状態変更
    LD A,STATE_ROUND_START          ; ゲーム状態 <- ラウンド開始
    CALL CHANGE_STATE

GAME_INIT_EXIT:
    RET
