; ====================================================================================================
;
; game_all_clear.asm
;
; include from game.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; オールクリアー
; ====================================================================================================
ALL_CLEAR:
    ; ■初回のみの処理実行
    JR Z,ALL_CLEAR_INIT

ALL_CLEAR_EXIT:
    RET


; ----------------------------------------------------------------------------------------------------
; オールクリアー時の初回処理
; ----------------------------------------------------------------------------------------------------
ALL_CLEAR_INIT:

    ; ■オフスクリーンリセット
    CALL RESET_OFFSCREEN

    ; ■メッセージ表示
    LD HL,ALL_CLEAR_MESSAGE1
    CALL PRTSTR

    LD HL,ALL_CLEAR_MESSAGE2
    CALL PRTSTR

    LD HL,ALL_CLEAR_MESSAGE3
    CALL PRTSTR

    LD HL,ALL_CLEAR_MESSAGE4
    CALL PRTSTR

    LD HL,ALL_CLEAR_MESSAGE5
    CALL PRTSTR

    ; ■BGM再生
    LD HL,_00
    CALL SOUNDDRV_BGMPLAY


ALL_CLEAR_INIT_EXIT:
    RET

SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■暫定のメッセージ
ALL_CLEAR_MESSAGE1:
    DW $00A7
    DB "THANKS FOR PLAYING.",0
ALL_CLEAR_MESSAGE2:
    DW $0123
    DB "THE FULL VERSION",0
ALL_CLEAR_MESSAGE3:
    DW $0164
    DB "WILL BE RELEASED IN THE", 0
ALL_CLEAR_MESSAGE4:
    DW $01AE
    DB "SUMMER OF 2022.",0
ALL_CLEAR_MESSAGE5:
    DW $022A
    DB "COMMING SOON!",0
