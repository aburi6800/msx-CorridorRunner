; ====================================================================================================
;
; game_title.asm
;
; included from game.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; タイトル
; ====================================================================================================
GAME_TITLE:
    ; ■初回のみ初期化を実行
    JR Z,GAME_TITLE_INIT

    ; ■10秒経過したらランキング表示に切り替える
    LD BC,600
    LD HL,(TICK1)    
    SBC HL,BC
    JR NZ,GAME_TITLE_L1

    LD A,STATE_SCOREBOARD       ; ゲーム状態→ランキング表示
    CALL CHANGE_STATE
    RET

GAME_TITLE_L1:
    ; ■スペースキー or トリガが押されたか判定
    CALL GET_STRIG               ; トリガ入力状態判定
    JR Z,GAME_TITLE_EXIT        ; ゼロ(未入力)なら抜ける

    ; ■状態をゲーム初期化へ変更
    LD A,STATE_GAME_INIT        ; ゲーム状態 <- ゲーム開始
    CALL CHANGE_STATE

GAME_TITLE_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; タイトル初回処理
; ----------------------------------------------------------------------------------------------------
GAME_TITLE_INIT:
    ; ■コンティニューラウンド初期化
    ;   GAME_INITはコンティニュー時の初期化でも呼ばれるため、ここで実施する
    XOR A
    LD (CONTINUE_ROUND),A

    ; ■スプライトキャラクターワークテーブル初期化
    CALL INIT_SPR_CHR_WK_TBL

    ; ■オフスクリーンリセット
    CALL RESET_OFFSCREEN

    ; ■タイトル画面作成
    LD HL,TITLE1
    CALL PRTSTR
    LD HL,TITLE2
    CALL PRTSTR
    LD HL,TITLE3
    CALL PRTSTR
    LD HL,TITLE4
    CALL PRTSTR
    LD HL,TITLE5
    CALL PRTSTR
    LD HL,TITLE6
    CALL PRTSTR
    LD HL,TITLE7
    CALL PRTSTR

    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■表示文字列データ
; dw : 表示先のVRAMアドレスのオフセット値    
; db : 表示文字列、最後に0を設定すること
TITLE1:
    DW $0084
    DB $a0,$a2,$a1,$a1,$a1,$a1,$ab,$a1,$a4,$a1,$a1,$a1,$a0,$a2,$a1,$a1,$a1,$a1,$a1,$a1,$a1,$a1,$a1,$a2,0
TITLE2:
    DW $00A4
	DB $a3,$20,$a0,$a2,$a0,$a0,$a8,$a0,$a4,$a0,$a2,$a0,$a3,$a7,$a3,$a4,$a0,$a2,$a0,$a2,$a9,$aa,$a0,$a4,0
TITLE3:
    DW $00C4
	DB $a3,$20,$a5,$a7,$a3,$a3,$a8,$a5,$a7,$a5,$a7,$a3,$a3,$a2,$a5,$a7,$a3,$a4,$a3,$a4,$a5,$a6,$a3,$a4,0
TITLE4:
    DW $00E4
	DB $a5,$a7,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a3,$ac,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a7,0
TITLE5:
    DW $01C5
	DB "PUSH SPACE OR TRIGGER.",0
TITLE6:
    DW $0267
	DB $5F,"ABURI GAMES 2022",0
TITLE7:
    DW $02A6
	DB "ALL RIGHTS RESERVED.",0
