; ====================================================================================================
;
; game_over.asm
;
; include from main.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; ゲームオーバー
; ====================================================================================================
GAME_OVER:
    ; ■初回のみの処理実行
    JR Z,GAME_OVER_INIT

    ; ■TICKが300カウント(=5秒)経過してなければ抜ける
    LD BC,300
    LD HL,(TICK1)    
    SBC HL,BC
    JR NZ,GAME_OVER_EXIT

    ; ■ゲーム状態変更
    LD A,STATE_TITLE                ; ゲーム状態をタイトルへ
    CALL CHANGE_STATE

GAME_OVER_EXIT:
    RET

; ---------------------------------------------------------------------------------------------------
; ゲームオーバー初回処理
; ---------------------------------------------------------------------------------------------------
GAME_OVER_INIT:
    ; ■スプライトキャラクターワークテーブル初期化
    CALL INIT_SPR_CHR_WK_TBL

    ; ■オフスクリーン初期化
    CALL CLEAR_OFFSCREEN

    ; ■ハイスコア更新判定
    CALL CHECK_HIGHSCORE_UPDATE

    ; ■ゲームオーバーメッセージ表示
    LD HL,STRING_GAME_OVER
    CALL PRTSTR

    ; ■BGM再生
    LD HL,_07
    CALL SOUNDDRV_BGMPLAY

GAME_OVER_INIT_EXIT:
    RET

; ---------------------------------------------------------------------------------------------------
; ハイスコア更新判定処理
; ---------------------------------------------------------------------------------------------------
CHECK_HIGHSCORE_UPDATE:
    ; ■ハイスコア更新判定
    LD HL,SCORE
    LD DE,HISCORE
    LD B,3

CHECK_HIGHSCORE_UPDATE_L1:
    OR A
    LD A,(DE)                           ; A <- ハイスコア(DEアドレスの値)
    INC DE                              ; DE=DE+1

    SUB (HL)                            ; A=A-HL(スコアの値)
    INC HL                              ; HL=HL+1

    ; マイナスだったらハイスコア更新
    JP M,CHECK_HIGHSCORE_UPDATE_L2

    ; 同じだったら次の桁をチェック
    JP Z,CHECK_HIGHSCORE_UPDATE_L3

    ; プラスだったら更新不要なのでループを抜ける
    JR CHECK_HIGHSCORE_UPDATE_EXIT

CHECK_HIGHSCORE_UPDATE_L2:
    ; ■ハイスコア更新
    ; -スコアの値(3byte)でハイスコアの値を置き換える
    LD HL,SCORE
    LD DE,HISCORE
    LD BC,3
    LDIR                            ; HL(SCORE)→DE(HISCORE)へ転送
    RET

CHECK_HIGHSCORE_UPDATE_L3:
    DJNZ CHECK_HIGHSCORE_UPDATE_L1

CHECK_HIGHSCORE_UPDATE_EXIT:
    RET

SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

STRING_GAME_OVER:
    DW $012B
	DB "GAME OVER",0
