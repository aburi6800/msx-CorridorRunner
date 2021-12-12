; ====================================================================================================
; asm06.asm
; ====================================================================================================
SECTION code_user
EXTERN SOUNDDRV_INIT
EXTERN SOUNDDRV_EXEC
EXTERN SOUNDDRV_BGMPLAY
EXTERN SOUNDDRV_SFXPLAY
EXTERN SOUNDDRV_STOP

PUBLIC _main

_main:
; ====================================================================================================
; 初期処理
; ====================================================================================================
    CALL INIT                       ; 初期設定

    ; ■ゲーム状態をタイトル初期化に変更
    LD A,STATE_TITLE
    CALL CHANGE_STATE

    ; ■テスト：固定で表示
    LD HL,STRING_HEADER1
    CALL PRTSTR
    LD HL,STRING_HEADER2
    CALL PRTSTR
















    ; 32文字×22行=704byte
    ; VRAMの$4000〜に書き込む
;    DB "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
;    DB "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
;    DB "                                "
;    DB "                                "
;    DB "aaaaaa                    aaaaaa"
;    DB "aaaaaa                    aaaaaa"
;    DB "aaaaaaaaaa            aaaaaaaaaa"
;    DB "aaaaaaaaaa            aaaaaaaaaa"
;    DB "aaaaaaaaaaaa        aaaaaaaaaaaa"
;    DB "aaaaaaaaaaaa        aaaaaaaaaaaa"
;    DB "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
;    DB "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
;    DB "aaaaaaaaaaaa        aaaaaaaaaaaa"
;    DB "aaaaaaaaaaaa        aaaaaaaaaaaa"
;    DB "aaaaaaaaaa            aaaaaaaaaa"
;    DB "aaaaaaaaaa            aaaaaaaaaa"
;    DB "aaaaaa                    aaaaaa"
;    DB "aaaaaa                    aaaaaa"
;    DB "                                "
;    DB "                                "
;    DB "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
;    DB "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"


    ; 2byte x 11 = 22byte
;    DW $FFFF,$0000,$E007,$F81F,$FC3F
;    DW $FFFF,$FC3F,$F81F,$E007,$0000
;    DW $FFFF

STRING_HEADER1:
    DW $0000
    DB "SCORE       HI-SCORE    RD  LEFT"
STRING_HEADER2:
    DW $2000
    DB "       0       76500     0     0"
STRING3:
    DW $0D00
	DB "      ",0
STRING4:
    DW $0D00
	DB "HIT !!",0
STRING5:
    DW $0D00
	DB "OUT !!",0

; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================
SECTION bss_user

; ■VRAMアドレスワーク
VRAM_ADDR_WK:
    DEFS 2




; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでramに値が設定される 
; ====================================================================================================
SECTION data_user

