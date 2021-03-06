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
    ;   - ラウンド数
    XOR A
    LD (ROUND),A
    ;   - スコア
    LD (SCORE),A
    LD (SCORE+1),A
    LD (SCORE+2),A
    ;   - 残機
    LD A,2
    LD (LEFT),A
    ;   - 次回エクステンドスコア
    LD A,$00
    LD (NEXT_EXTEND_SCORE),A
    LD A,$02
    LD (NEXT_EXTEND_SCORE+1),A
    LD A,$00
    LD (NEXT_EXTEND_SCORE+2),A

    ; ■ゲーム状態変更
    LD A,STATE_ROUND_START          ; ゲーム状態 <- ラウンド開始
    CALL CHANGE_STATE


GAME_INIT_EXIT:
    RET
