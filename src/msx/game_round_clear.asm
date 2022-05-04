; ====================================================================================================
;
; game_round_clear.asm
;
; include from game.asm
;
; ====================================================================================================
SECTION code_user

; ■ラウンドクリア処理状態
ROUND_CLEAR_STS_WIPE:               EQU 0   ; 画面消去
ROUND_CLEAR_STS_MESSAGE1:           EQU 1   ; メッセージ表示１
ROUND_CLEAR_STS_ADDBONUS:           EQU 2   ; ボーナス加算
ROUND_CLEAR_STS_MESSAGE2:           EQU 3   ; メッセージ表示2

; ====================================================================================================
; ラウンドクリアー
; ====================================================================================================
ROUND_CLEAR:

    ; ■初回のみの処理実行
    JR Z,ROUND_CLEAR_INIT

    ; ■ラウンドクリア処理状態の値からジャンプテーブルアドレスのオフセット値を求める
    LD A,(ROUND_CLEAR_STS)          ; A <- ラウンドクリア処理状態
    LD C,A                          ; A=A*3
    ADD A,A
    ADD A,C

    LD B,0                          ; BC <- ジャンプテーブルのオフセット値
    LD C,A

    ; ■ジャンプテーブルの該当ステップにジャンプ
    LD HL,ROUND_CLEAR_RET           ; 各ルーチンからのRET先のアドレスをスタックに積む
    PUSH HL
    LD HL,ROUND_CLEAR_L1            ; HL <- ジャンプテーブルのアドレス
    ADD HL,BC                       ; HL=HL+BC（ゼロフラグは変化しない）
    JP (HL)

ROUND_CLEAR_L1:
    JP ROUND_CLEAR_WIPE             ; ラウンドクリア:画面ワイプ
    JP ROUND_CLEAR_MESSAGE1         ; ラウンドクリア:メッセージ１
    JP ROUND_CLEAR_ADDBONUS         ; ラウンドクリア:ボーナス加算
    JP ROUND_CLEAR_MESSAGE2         ; ラウンドクリア:メッセージ２

ROUND_CLEAR_RET:
    RET

; ----------------------------------------------------------------------------------------------------
; ラウンドクリアー時の初回処理
; ----------------------------------------------------------------------------------------------------
ROUND_CLEAR_INIT:

    ; ■プレイヤー以外のスプライトを消す
    LD A,MAX_CHR_CNT

ROUND_CLEAR_INIT_L1:
    CALL GET_SPR_WK_ADDR            ; IX <- スプライトキャラクターワークテーブルのアドレス
    CALL DEL_CHARACTER              ; スプライトキャラクター削除
    DEC A
    CP 3
    JR NC,ROUND_CLEAR_INIT_L1       ; カウンタが3未満(=1,2:プレイヤー)なら抜ける

    ; ■画面ワイプの初期化
    LD HL,OFFSCREEN+$0020           ; 左側のオフスクリーン初期アドレス
    LD (ROUND_CLEAR_WIPE_START_POS_L),HL
    LD HL,OFFSCREEN+$005F           ; 右側のオフスクリーン初期アドレス
    LD (ROUND_CLEAR_WIPE_START_POS_R),HL
    LD A,32                         ; カウンタ設定
    LD (ROUND_CLEAR_CNT),A

    ; ■ラウンドクリア処理状態を進める
    LD A,ROUND_CLEAR_STS_WIPE
    LD (ROUND_CLEAR_STS),A

ROUND_CLEAR_INIT_EXIT:
    RET


; ====================================================================================================
; ラウンドクリアー画面ワイプ
; ====================================================================================================
ROUND_CLEAR_WIPE:

    ; ■左端の処理
    LD B,11                         ; ループ回数
    LD HL,(ROUND_CLEAR_WIPE_START_POS_L)

ROUND_CLEAR_WIPE_L1:
    LD (HL),$20
    LD A,64
    CALL ADD_HL_A
    DJNZ ROUND_CLEAR_WIPE_L1

    ; ■右端の処理
    LD B,11                         ; ループ回数
    LD HL,(ROUND_CLEAR_WIPE_START_POS_R)

ROUND_CLEAR_WIPE_L2:
    LD (HL),$20
    LD A,64
    CALL ADD_HL_A                   ; HL=HL+A(32)
    DJNZ ROUND_CLEAR_WIPE_L2

    ; ■次の処理用に開始位置を設定
    LD HL,(ROUND_CLEAR_WIPE_START_POS_L)
    INC HL
    LD (ROUND_CLEAR_WIPE_START_POS_L),HL
    LD HL,(ROUND_CLEAR_WIPE_START_POS_R)
    DEC HL
    LD (ROUND_CLEAR_WIPE_START_POS_R),HL
    LD HL,ROUND_CLEAR_CNT
    DEC (HL)

    RET NZ

    ; ■スプライトキャラクター削除
    XOR A
    INC A
    CALL GET_SPR_WK_ADDR 
    CALL DEL_CHARACTER
    INC A
    CALL GET_SPR_WK_ADDR 
    CALL DEL_CHARACTER

    ; ■カウンタ設定
    XOR A
    LD (ROUND_CLEAR_CNT),A

    ; ■BGM再生
    LD HL,_08
    CALL SOUNDDRV_BGMPLAY

    ; ■ラウンドクリア処理状態を進める
    LD A,ROUND_CLEAR_STS_MESSAGE1
    LD (ROUND_CLEAR_STS),A

ROUND_CLEAR_WIPE_EXIT:
    RET


; ====================================================================================================
; ラウンドクリアーメッセージ表示１
; ====================================================================================================
ROUND_CLEAR_MESSAGE1:

    ; ■カウンタ加算
    LD HL,ROUND_CLEAR_CNT
    INC (HL)

    ; ■カウンタ判定
    LD A,(ROUND_CLEAR_CNT)
    CP $10
    JR Z,ROUND_CLEAR_MESSAGE1_L1
    CP $20
    JR Z,ROUND_CLEAR_MESSAGE1_L2
    CP $30
    JR Z,ROUND_CLEAR_MESSAGE1_L3
    CP $40
    JR Z,ROUND_CLEAR_MESSAGE1_L4
    CP $66
    JR Z,ROUND_CLEAR_MESSAGE1_L5
    CP $C0
    JR Z,ROUND_CLEAR_MESSAGE1_L7
    CP $FF
    JR Z,ROUND_CLEAR_MESSAGE1_L8

    RET

ROUND_CLEAR_MESSAGE1_L1:
    LD HL,STRING_ROUND_CLEAR_MSG1
    JR ROUND_CLEAR_MESSAGE1_L6

ROUND_CLEAR_MESSAGE1_L2:
    LD HL,STRING_ROUND_CLEAR_MSG2
    JR ROUND_CLEAR_MESSAGE1_L6

ROUND_CLEAR_MESSAGE1_L3:
    LD HL,STRING_ROUND_CLEAR_MSG3
    JR ROUND_CLEAR_MESSAGE1_L6

ROUND_CLEAR_MESSAGE1_L4:
    LD HL,STRING_ROUND_CLEAR_MSG4
    JR ROUND_CLEAR_MESSAGE1_L6

ROUND_CLEAR_MESSAGE1_L5:
    LD B,1
    LD DE,ROUND_BCD
    LD HL,$0112
    CALL PRTBCD

    LD HL,STRING_ROUND_CLEAR_MSG5

ROUND_CLEAR_MESSAGE1_L6:
    CALL PRTSTR
    RET

ROUND_CLEAR_MESSAGE1_L7:
    ; ■ボーナス点計算
    ;   基点(500)にラウンド数*500を加算
    LD A,(ROUND)
    INC A
    LD B,A                          ; ループ回数として設定
    LD A,5                          ; 500pts
ROUND_CLEAR_MESSAGE1_L71:
    ADD A,5                         ; 500pts
    DAA                             ; BCD値変換
    DJNZ ROUND_CLEAR_MESSAGE1_L71
    LD (ROUND_CLEAR_BONUS_BCD),A

    LD HL,STRING_ROUND_CLEAR_MSG6
    CALL ROUND_CLEAR_MESSAGE1_L6
    CALL ROUND_CLEAR_PRTBONUS
    RET

ROUND_CLEAR_MESSAGE1_L8:
    ; ■カウンタ設定
    LD A,$80
    LD (ROUND_CLEAR_CNT),A

    ; ■ラウンドクリア処理状態を進める
    LD A,ROUND_CLEAR_STS_ADDBONUS
    LD (ROUND_CLEAR_STS),A
    RET

; ----------------------------------------------------------------------------------------------------
; ラウンドクリアーボーナス表示
; ----------------------------------------------------------------------------------------------------
ROUND_CLEAR_PRTBONUS:
    LD B,1
    LD DE,ROUND_CLEAR_BONUS_BCD
    LD HL,$0192
    CALL PRTBCD
    RET


; ====================================================================================================
; ラウンドクリアーボーナス加算
; ====================================================================================================
ROUND_CLEAR_ADDBONUS:

    LD A,(ROUND_CLEAR_BONUS_BCD)
    OR A
    JR Z,ROUND_CLEAR_ADDBONUS_L1    ; ボーナスがゼロなら一定時間まって状態を進める

    DEC A
    DAA
    LD (ROUND_CLEAR_BONUS_BCD),A
    CALL ROUND_CLEAR_PRTBONUS

    LD DE,$0001
    CALL ADDSCORE
    RET

ROUND_CLEAR_ADDBONUS_L1:
    ; ■カウンタ減算
    LD HL,ROUND_CLEAR_CNT
    DEC (HL)
    RET NZ

    ; ■カウンタ設定
    LD A,$80
    LD (ROUND_CLEAR_CNT),A

    ; ■ラウンドクリア処理状態を進める
    LD A,ROUND_CLEAR_STS_MESSAGE2
    LD (ROUND_CLEAR_STS),A

    RET


; ====================================================================================================
; ラウンドクリアーメッセージ表示２
; ====================================================================================================
ROUND_CLEAR_MESSAGE2:

    LD HL,STRING_ROUND_CLEAR_MSG7
    CALL PRTSTR

    ; ■カウンタ減算
    LD HL,ROUND_CLEAR_CNT
    DEC (HL)
    RET NZ

    ; ■次のラウンドに進める
    LD HL,ROUND
    INC (HL)                       ; データがないので一旦保留

    ; ■ゲーム状態を変更
    LD A,(HL)
    CP 17
    LD A,STATE_ROUND_START          ; ゲーム状態 <- ラウンド開始
    JP NZ,ROUND_CLEAR_MESSAGE2_L2
    LD A,STATE_ALL_CLEAR            ; ゲーム状態 <- オールクリア

ROUND_CLEAR_MESSAGE2_L2:
    CALL CHANGE_STATE
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

STRING_ROUND_CLEAR_MSG1:
    DW $00C6
	DB "YOU",0
STRING_ROUND_CLEAR_MSG2:
    DW $00CA
	DB "MADE",0
STRING_ROUND_CLEAR_MSG3:
    DW $00CF
	DB "IT",0
STRING_ROUND_CLEAR_MSG4:
    DW $00D2
	DB "THROUGH",0
STRING_ROUND_CLEAR_MSG5:
    DW $010C
    DB "ROUND",0
STRING_ROUND_CLEAR_MSG6:
    DW $018A
    DB "BONUS     00",0
STRING_ROUND_CLEAR_MSG7:
    DW $0202
    DB "GOOD LUCK IN THE NEXT ROUND!",0


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■ラウンドクリア処理の状態
ROUND_CLEAR_STS:
    DEFS 1

; ■画面消去のアドレス
ROUND_CLEAR_WIPE_START_POS_L:
    DEFS 2
ROUND_CLEAR_WIPE_START_POS_R:
    DEFS 2

; ■各処理用のカウンタ
ROUND_CLEAR_CNT:
    DEFS 1

; ■ボーナス点
ROUND_CLEAR_BONUS_BCD:
    DEFS 1
