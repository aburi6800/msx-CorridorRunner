; ====================================================================================================
;
; game_global_bss.asm
;
; included from game.asm
;
; ====================================================================================================

; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================
SECTION bss_user

; ■ゲーム状態
GAME_STATE:
    DEFS 1

; ■ラウンド
ROUND:
    DEFS 1

; ■コンティニューラウンド
CONTINUE_ROUND:
    DEFS 1

; ■スコア(BCD値)
SCORE:
    DEFS 3

; ■ラウンド数(BCD値)
ROUND_BCD:
    DEFS 1

; ■オールクリアフラグ
ALLCLEAR_FLG:
    DEFS 1

; ■スコア加算値(BCD値)
SCORE_ADDVALUE_BCD:
    DEFS 1

; ■次回エクステンドスコア(BCD値)
NEXT_EXTEND_SCORE:
    DEFS 3

; ■残機
LEFT:
    DEFS 1

; ■タイム(BCD)
TIME_BCD:
    DEFS 1

; ■タイムアウト時のテキ出現カウンタ
TIMEOUTENEMY_APPEARANCE_CNT:
    DEFS 1

; ■パーフェクト判定フラグ
PERFECT_FLG:
    DEFS 1

; ■一時停止フラグ
GAME_IS_PAUSE:
    DEFS 1

; ■無敵フラグ
INVINCIBLE_FLG:
    DEFS 1

