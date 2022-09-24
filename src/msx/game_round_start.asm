; ====================================================================================================
;
; game_round_start.asm
;
; include from game.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; ラウンド開始
; ====================================================================================================
ROUND_START:
    ; ■初回のみの処理実行
    JR Z,ROUND_START_INIT

    ; ■TICKが240カウント(=4秒)経過してなければ抜ける
    LD BC,240
    LD HL,(TICK1)    
    SBC HL,BC
    JR NZ,ROUND_START_EXIT

    ; ■フィールド初期化処理
    CALL INIT_FIELD

    ; ■スプライトキャラクターワークテーブル初期化
    CALL INIT_SPR_CHR_WK_TBL

    ; ■プレイヤー初期化
    ; ゲームメインではdjnzでループするため、先に処理したいキャラクタを後に登録する
    LD A,CHRNO_PLAYER2
    CALL ADD_CHARACTER
    LD A,CHRNO_PLAYER1
    CALL ADD_CHARACTER

    ; ■テキ初期化
    CALL ENEMY_APPEARANCE_INIT

    ; ■ワーク初期化
    XOR A
    LD (SCORE_CHRNO),A
    INC A
    LD (SCORE_ADDVALUE_BCD),A

    ; ■ゲーム状態変更
    LD A,STATE_GAME_MAIN            ; ゲーム状態をゲームメインへ
    CALL CHANGE_STATE

    ; ■BGM再生
    LD HL,(BGM_WK)
    CALL SOUNDDRV_BGMPLAY

ROUND_START_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; ラウンド開始時の初回処理
; ----------------------------------------------------------------------------------------------------
ROUND_START_INIT:

    ; ■ワーク初期化
    ; - タイム
    LD A,$60
    DAA
    LD (TIME_BCD),A

    ; - タイムアウト時のテキ出現カウンタ
    XOR A
    LD (TIMEOUTENEMY_APPEARANCE_CNT),A

    ; - コンティニューラウンド設定
    ;   4面ごとに設定する
    LD A,(ROUND)
    AND %11111100
    LD (CONTINUE_ROUND),A

    ; - ラウンド数をBCD変換してワークに設定
    ;   ワーク(ROUND)の値は0〜なので、表示用に+1する
    LD A,(ROUND)
    INC A                           
    DAA
    LD (ROUND_BCD),A

    ; - ターゲット取得フラグ
    ;   最初は$FF、取得したら$01とする
    LD A,$FF
    LD (TARGET_GET_FLG),A

    ; - パーフェクト判定フラグ
    ;   初期値は$01、移動時に空振りした際、ターゲット取得フラグが$01の場合に$00を設定する
    LD A,1
    LD (PERFECT_FLG),A

    ; - 一時停止フラグ
    XOR A
    LD (GAME_IS_PAUSE),A

    ; - テキ出現カウンタ
    LD (ENEMY_PTN_CNT),A
    LD (ENEMY_PTN_CNT+1),A


    ; ■スプライトキャラクターワークテーブル初期化
    CALL INIT_SPR_CHR_WK_TBL

    ; ■オフスクリーンリセット
    CALL RESET_OFFSCREEN

    ; ■ラウンド開始メッセージ表示
    LD HL,STRING_ROUND_START
    CALL PRTSTR

    ; ■ラウンド数表示
    LD B,1
    LD C,$20
    LD DE,ROUND_BCD
    LD HL,$0115
    CALL PRTBCD

    ; ■BGM再生
    LD HL,_01
    CALL SOUNDDRV_BGMPLAY

    RET

SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

STRING_ROUND_START:
    DW $0109
	DB "READY ROUND",0
