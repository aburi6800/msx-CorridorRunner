; ====================================================================================================
;
; game_over.asm
;
; include from game.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; ゲームオーバー
; ====================================================================================================
GAME_OVER:
    ; ■初回のみの処理実行
    JR Z,GAME_OVER_INIT

    LD A,(MAX_ROUND)                    ; 最終ラウンド
    LD HL,ROUND
    CP (HL)
    JR C,GAME_OVER_L1                   ; 最終ラウンドクリアしていたらコンティニュー不可

    ; ■コンティニュー
    ; - キーマトリクス入力値取得
    LD A,(KEYBUFF+9)
    OR A
    JP NZ,GAME_CONTINUE

GAME_OVER_L1:
    ; ■TICKが300カウント(=5秒)経過してなければ抜ける
    LD BC,300
    LD HL,(TICK1)    
    SBC HL,BC
    JR NZ,GAME_OVER_EXIT

    ; ■ゲーム状態変更
    CALL CHECK_RANKING_REGIST       ; スコアランキング判定・ソート

    LD A,(SCOREBOARD_INRANK)        ; ランキング取得
    OR A
    JR Z,GAME_OVER_L2

    ;   ランキングに入った場合
    LD A,STATE_NAME_ENTRY           ; ゲーム状態をネームエントリーへ
    CALL CHANGE_STATE
    RET

GAME_OVER_L2:
    ;   ランキングに入らなかった場合
    LD A,STATE_SCOREBOARD           ; ゲーム状態をランキング表示へ
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
    CALL RESET_OFFSCREEN

    ; ■ゲームオーバーメッセージ表示
    LD HL,STRING_GAME_OVER
    CALL PRTSTR

    LD A,(MAX_ROUND)                    ; 最終ラウンド
    LD HL,ROUND
    CP (HL)
    JR C,GAME_OVER_INIT_L1              ; エンディングまで迎えるとMAX_ROUND+1がROUNDに設定されるため、
                                        ; ここでキャリーが立つ

    LD HL,STRING_CONTINUE
    CALL PRTSTR

    ; ■キーバッファクリア
    CALL KILBUF

GAME_OVER_INIT_L1:
    ; ■BGM再生
    LD HL,_07
    CALL SOUNDDRV_BGMPLAY

GAME_OVER_INIT_EXIT:
    RET

; ---------------------------------------------------------------------------------------------------
; コンティニュー処理
; ---------------------------------------------------------------------------------------------------
GAME_CONTINUE:

    ; ■ゲーム初期化
    CALL GAME_INIT

    ; ■コンティニュー時の開始ラウンドを設定
    LD A,(CONTINUE_ROUND)           ; コンティニュー開始ラウンドを取得して設定
    LD (ROUND),A

GAME_CONTINUE_EXIT:
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

STRING_GAME_OVER:
    DW $012B
	DB "GAME OVER",0
STRING_CONTINUE:
    DW $0209
	DB "CONTINUE  [F^]",0
