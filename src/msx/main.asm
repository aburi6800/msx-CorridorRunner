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
EXTERN SOUNDDRV_PAUSE
EXTERN SOUNDDRV_RESUME
EXTERN SOUNDDRV_STATE

PUBLIC _main

_main:
; ====================================================================================================
; メインループ
; ====================================================================================================
MAINLOOP:
	; ■VSYNC_WAIT_FLGの初期化
	;   この値は以下の制御を行うために使用する：
	;   - メインロジック開始時に 0 に設定
	;   - H.TIMI割り込み処理の中でデクリメント (1/60秒ごとに呼び出し)
	;   - メインロジックの最後に、キャリーがONになるまで待機
	LD A,1
	LD (VSYNC_WAIT_CNT),A

    ; ■ゲーム処理呼び出し
    CALL GAME

VSYNC_WAIT:
	; ■垂直帰線待ち
	LD A,(VSYNC_WAIT_CNT)
	OR A
	JP NZ,VSYNC_WAIT

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
