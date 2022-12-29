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

    ; ■メッセージ待ち時間チェック
    LD A,(ALL_CLEAR_MSG_WAITCNT)
    CP $FF
    JR Z,ALL_CLEAR_L1           ; 待ち時間が$FF(=メッセージを最後まで表示)ならスペースキー判定へ


    LD A,(TICK3_WK)
    OR A
    RET NZ                      ; TICK3_WKがゼロ以外（=1秒経過していない）なら、そのまま終了

    LD HL,ALL_CLEAR_MSG_WAITCNT
    DEC (HL)                    ; ウェイトカウンタ減算
    RET NZ                      ; ゼロでない場合は終了

    CALL MESSAGE_PRINT          ; メッセージ表示処理
    RET


ALL_CLEAR_L1:
    ; ■スペースキー or トリガが押されたか判定
    LD A,(INPUT_BUFF_STRIG)     ; A <- トリガボタンの入力値
    OR A                        ; ゼロ(未入力)なら抜ける
    RET Z

    ; ■状態をゲームオーバーへ変更
    LD A,STATE_GAME_OVER        ; ゲーム状態 <- ゲームオーバー
    CALL CHANGE_STATE

    RET


; ----------------------------------------------------------------------------------------------------
; オールクリアー時の初回処理
; ----------------------------------------------------------------------------------------------------
ALL_CLEAR_INIT:

    ; ■オフスクリーンリセット
    CALL RESET_OFFSCREEN

    ; ■メッセージタイムテーブルアドレスの初期値設定
    LD HL,ALL_CLEAR_MSG_TIMETBL
    LD (ALL_CLEAR_MSG_TIMETBL_ADDR),HL

    ; ■メッセージ表示
    CALL MESSAGE_PRINT

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

    ; ■クリアボーナス加算
    LD DE,$5000
    CALL ADDSCORE

    ; ■オールクリアフラグ設定
    LD A,1
    LD (ALLCLEAR_FLG),A

    ; ■BGM再生
    LD HL,_09
    CALL SOUNDDRV_BGMPLAY

ALL_CLEAR_INIT_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; メッセージ表示
; ----------------------------------------------------------------------------------------------------
MESSAGE_PRINT:

    ; ■事前処理
    CALL MESSAGE_AREA_CLEAR             ; メッセージエリア消去
    LD HL,(ALL_CLEAR_MSG_TIMETBL_ADDR)  ; メッセージタイムテーブルのアドレスを取得

MESSAGE_PRINT_L1:
    LD E,(HL)
    INC HL
    LD D,(HL)

    EX DE,HL
    CALL PRTSTR
    EX DE,HL

    INC HL
    LD A,(HL)
    OR A
    INC HL
    JR Z,MESSAGE_PRINT_L1               ; 待ち時間がゼロなら次のメッセージの処理へ    


    LD (ALL_CLEAR_MSG_TIMETBL_ADDR),HL  ; メッセージタイムテーブルのアドレスを保存
    LD (ALL_CLEAR_MSG_WAITCNT),A    ; 待ち時間を設定
    RET

; ----------------------------------------------------------------------------------------------------
; メッセージエリア消去
; ----------------------------------------------------------------------------------------------------
MESSAGE_AREA_CLEAR:
    LD HL,$0080
    LD BC,32*9
    
MESSAGE_AREA_CLEAR_L1:
    DEC BC
    LD A,B
    OR C
    JR NZ,MESSAGE_AREA_CLEAR_L2

    RET

MESSAGE_AREA_CLEAR_L2:
    LD A,$20
    CALL PUTSTR
    INC HL
    JR MESSAGE_AREA_CLEAR_L1

; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================
SECTION rodata_user

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

; ■オールクリアメッセージ
ALL_CLEAR_MSG_00:
    DW $0080
    DB " ",0
ALL_CLEAR_MSG_01:
    DW $0088
    DB "CONGRATULATIONS!",0
ALL_CLEAR_MSG_02:
    DW $00E4
    DB "SHE RAN THROUGH SEVERAL",0
ALL_CLEAR_MSG_03:
    DW $0104
    DB "CORRIDORS AND REACHED THE", 0
ALL_CLEAR_MSG_04:
    DW $0124
    DB "GROUND.",0
ALL_CLEAR_MSG_05:
    DW $0164
    DB "THE BEAUTIFUL MOONLIGHT",0
ALL_CLEAR_MSG_06:
    DW $0184
    DB "SURROUNDED HER.",0
ALL_CLEAR_MSG_07:
    DW $0131
    DB "ABURI#$%%",0
ALL_CLEAR_MSG_08:
    DW $00E6
    DB "PROGRAM BY",0
ALL_CLEAR_MSG_09:
    DW $00E6
    DB "GRAPHIC BY",0
ALL_CLEAR_MSG_10:
    DW $00E6
    DB "CHARACTER DESIGN BY",0
ALL_CLEAR_MSG_11:
    DW $00E6
    DB "SOUND AND MUSIC BY",0
ALL_CLEAR_MSG_12:
    DW $00E6
    DB "GAME DESIGN BY",0
ALL_CLEAR_MSG_13:
    DW $00E6
    DB "STORY BY",0
ALL_CLEAR_MSG_14:
    DW $00E6
    DB "DIRECTED BY",0
ALL_CLEAR_MSG_15:
    DW $00E6
    DB "PRESENTED BY",0
ALL_CLEAR_MSG_16:
    DW $012A
    DB "ABURI GAMES 2022",0

; ■メッセージタイムテーブル
;   2byte メッセージデータアドレス
;   1byte 待ち時間(sec), $FFは終了
ALL_CLEAR_MSG_TIMETBL:
    DW ALL_CLEAR_MSG_01
    DB 0
    DW ALL_CLEAR_MSG_02
    DB 0
    DW ALL_CLEAR_MSG_03
    DB 0
    DW ALL_CLEAR_MSG_04
    DB 0
    DW ALL_CLEAR_MSG_05
    DB 0
    DW ALL_CLEAR_MSG_06
    DB 19
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_07
    DB 0
    DW ALL_CLEAR_MSG_08
    DB 5
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_07
    DB 0
    DW ALL_CLEAR_MSG_09
    DB 5
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_07
    DB 0
    DW ALL_CLEAR_MSG_09
    DB 5
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_07
    DB 0
    DW ALL_CLEAR_MSG_10
    DB 5
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_07
    DB 0
    DW ALL_CLEAR_MSG_11
    DB 5
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_07
    DB 0
    DW ALL_CLEAR_MSG_12
    DB 5
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_07
    DB 0
    DW ALL_CLEAR_MSG_13
    DB 5
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_07
    DB 0
    DW ALL_CLEAR_MSG_14
    DB 5
    DW ALL_CLEAR_MSG_00
    DB 1
    DW ALL_CLEAR_MSG_15
    DB 0    
    DW ALL_CLEAR_MSG_16
    DB $FF

; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================
SECTION bss_user

; ■メッセージテーブルアドレス
ALL_CLEAR_MSG_TIMETBL_ADDR:
    DEFS 2

; ■ウェイトカウント
;   メッセージ表示が終わっていたら$FF
ALL_CLEAR_MSG_WAITCNT:
    DEFS 1
