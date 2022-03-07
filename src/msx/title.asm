; ====================================================================================================
;
; title.asm
;
; included from main.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; タイトル
; ====================================================================================================
TITLE:
    ; ■初回のみ初期化を実行
    JR Z,TITLE_INIT

    ; ■スペースキーが押されたら状態変更
    LD A,(INPUT_BUFF_STRIG)     ; A <- トリガボタンの入力値

    OR A                        ; ゼロ(未入力)なら抜ける
    JR Z,TITLE_EXIT

    LD A,STATE_GAME_INIT        ; ゲーム状態 <- ゲーム開始
    CALL CHANGE_STATE

TITLE_EXIT:
    RET

TITLE_INIT:
    ; ■各変数初期化
    LD A,0
    LD (ROUND),A                    ; ラウンド数 <- 0

    ; ■タイトル画面作成
;    CALL COPY_MAP_DATA
;    CALL DRAW_MAP                   ; フィールド描画

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

    ; ■BGM再生
    LD HL,_00
    CALL SOUNDDRV_BGMPLAY

TITLE_INIT_EXIT:
    RET


; ====================================================================================================
; ゲーム初期化
; ToDo : ゲーム初期化もソースをわける
; ====================================================================================================
GAME_INIT:
    ; ■乱数初期化
    CALL INIT_RND

    ; ■各変数初期化
    LD A,1
    LD (ROUND),A                    ; ラウンド数 <- 1
    LD A,0
    LD (SCORE),A                    ; スコア <- 0
    LD A,3
    LD (LEFT),A                     ; 残機 <- 3

    ; ToDo : ここで固定表示される文字列もオフスクリーンに設定しておく？

    ; ■ゲーム状態変更
    LD A,STATE_ROUND_START          ; ゲーム状態 <- ラウンド開始
    CALL CHANGE_STATE

GAME_INIT_EXIT:
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
    DW $00A4
    DB $a0,$a2,$a1,$a1,$a1,$a1,$ab,$a1,$a4,$a1,$a1,$a1,$a0,$a2,$a1,$a1,$a1,$a1,$a1,$a1,$a1,$a1,$a1,$a2,0
TITLE2:
    DW $00C4
	DB $a3,$20,$a0,$a2,$a0,$a0,$a8,$a0,$a4,$a0,$a2,$a0,$a3,$a7,$a3,$a4,$a0,$a2,$a0,$a2,$a9,$aa,$a0,$a4,0
TITLE3:
    DW $00E4
	DB $a3,$20,$a5,$a7,$a3,$a3,$a8,$a5,$a7,$a5,$a7,$a3,$a3,$a2,$a5,$a7,$a3,$a4,$a3,$a4,$a5,$a6,$a3,$a4,0
TITLE4:
    DW $0104
	DB $a5,$a7,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a3,$ac,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a6,$a7,0
TITLE5:
    DW $0205
	DB "PUSH SPACE OR TRIGGER.",0
TITLE6:
    DW $0282
	DB "PROGRAMMED BY ABURI6800 2022",0
