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

    ; ■スペースキー or トリガが押されたか判定
    LD A,(INPUT_BUFF_STRIG)     ; A <- トリガボタンの入力値
    OR A                        ; ゼロ(未入力)なら抜ける
;    JR Z,ALL_CLEAR_EXIT
    RET Z

    ; ■状態をゲーム初期化へ変更
    LD A,STATE_GAME_OVER        ; ゲーム状態 <- ゲームオーバー
    CALL CHANGE_STATE

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
    LD HL,ALL_CLEAR_MESSAGE6
    CALL PRTSTR

    ; ■グラフィック表示
    LD HL,ALL_CLEAR_PIC1
    CALL PRTSTR
    LD HL,ALL_CLEAR_PIC2
    CALL PRTSTR
    LD HL,ALL_CLEAR_PIC3
    CALL PRTSTR
    LD HL,ALL_CLEAR_PIC4
    CALL PRTSTR
    LD HL,ALL_CLEAR_PIC5
    CALL PRTSTR

    ; ■スプライトキャラクターワークテーブル設定
    ;   4キャラクター、固定で定義する
    CALL INIT_SPR_CHR_WK_TBL            ; スプライトキャラクターワークテーブル初期化
    LD HL,ALL_CLEAR_SPRITE              ; HL = 転送元アドレス
    LD DE,SPR_CHR_WK_TBL                ; DE = 転送先アドレス
    LD BC,16*4                          ; BC = 転送サイズ
    LDIR

    ; ■BGM再生
    LD HL,_09
    CALL SOUNDDRV_BGMPLAY

    ; ■クリアボーナス加算
    LD DE,$5000
    CALL ADDSCORE


ALL_CLEAR_INIT_EXIT:
    RET

SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■オールクリアメッセージ
ALL_CLEAR_MESSAGE1:
;    DW $00A7
;    DB "THANKS FOR PLAYING.",0
    DW $0088
    DB "CONGRATULATIONS!",0
ALL_CLEAR_MESSAGE2:
;    DW $0123
;    DB "THE FULL VERSION",0
    DW $00E4
    DB "SHE RAN THROUGH SEVERAL",0
ALL_CLEAR_MESSAGE3:
;    DW $0164
;    DB "WILL BE RELEASED IN THE", 0
    DW $0104
    DB "CORRIDORS AND REACHED THE", 0
ALL_CLEAR_MESSAGE4:
;    DW $01AE
;    DB "SUMMER OF 2022.",0
    DW $0124
    DB "GROUND.",0
ALL_CLEAR_MESSAGE5:
;    DW $022A
;    DB "COMMING SOON!",0
    DW $0164
    DB "THE BEAUTIFUL MOONLIGHT",0
ALL_CLEAR_MESSAGE6:
    DW $0184
    DB "SURROUNDED HER.",0

ALL_CLEAR_PIC1:
    DW $01EC
	DB 192,193,194,195,224, 32,225, 32,  0
ALL_CLEAR_PIC2:
    DW $020C
	DB 196,197,198,199,226,227,228,229,  0
ALL_CLEAR_PIC3:
    DW $022C
	DB 200,201,202,203,227, 32, 32,227,  0
ALL_CLEAR_PIC4:
    DW $024C
	DB 204,205,206,207, 32, 32, 32, 32,  0
ALL_CLEAR_PIC5:
    DW $026C
	DB 208,209,210,211,212,213,214,215,  0

ALL_CLEAR_SPRITE:
    DB 0,   0, 119,   0,  96,  46,  11,   0,   0,   0,   0,   0,   0,   0,   0,   0 
    DB 1,   0, 119,   0, 112,  47,  11,   0,   0,   0,   0,   0,   0,   0,   0,   0
    DB 2,   0, 135,   0,  96,  48,  11,   0,   0,   0,   0,   0,   0,   0,   0,   0
    DB 3,   0, 135,   0, 112,  49,  11,   0,   0,   0,   0,   0,   0,   0,   0,   0
