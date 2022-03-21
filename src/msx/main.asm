; ====================================================================================================
;
; main.asm
;
; ====================================================================================================
SECTION code_user

; ■BGMドライバのAPI定義
EXTERN SOUNDDRV_INIT
EXTERN SOUNDDRV_EXEC
EXTERN SOUNDDRV_BGMPLAY
EXTERN SOUNDDRV_SFXPLAY
EXTERN SOUNDDRV_STOP

PUBLIC _main

_main:
; ====================================================================================================
; メインループ
; ====================================================================================================
MAINLOOP:
    ; ■ゲーム処理呼び出し
    CALL GAME

VSYNC:
	; ■垂直帰線待ち
	HALT

	JP MAINLOOP


; ■ゲーム本体
INCLUDE "game.asm"

; ■スプライト操作サブルーチン群
INCLUDE "sprite.asm"

; ■共通サブルーチン群
INCLUDE "common.asm"

; ■BIOSアドレス定義
INCLUDE "include/msxbios.inc"

; ■システムワークエリアアドレス定義
INCLUDE "include/msxsyswk.inc"

; ■VRAMワークエリアアドレス定義
INCLUDE "include/msxvrmwk.inc"
