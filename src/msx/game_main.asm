; ====================================================================================================
;
; game_main.asm
;
; include from game.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; ゲームメイン
; ====================================================================================================
GAME_MAIN:
    ; ■一時停止判定
    LD A,(GAME_IS_PAUSE)
    OR A
    JR NZ,GAME_MAIN_L0              ; 一時停止フラグが1の場合は一時停止中処理へ

    LD A,(KEYBUFF+5)
    OR A
    JR Z,GAME_MAIN_L1               ; [F1]キーが押されていなければ後続の処理へ

    LD A,1
    LD (GAME_IS_PAUSE),A            ; 一時停止フラグをON

    CALL SOUNDDRV_PAUSE             ; サウンドドライバの一時停止
    RET

GAME_MAIN_L0:
    ; ■一時停止中処理
    ; - キーマトリクス入力値取得
    LD A,(KEYBUFF+5)
    OR A
    RET Z                           ; [F1]キーが押されていなければ抜ける

    XOR A
    LD (GAME_IS_PAUSE),A            ; 一時停止フラグをOFF
    CALL SOUNDDRV_RESUME            ; サウンドドライバの一時停止解除

    ; ■テキ出現制御処理を呼び出す
    CALL IS_PLAYER_MISS
    JR NC,GAME_MAIN_L1
    CALL ENEMY_APPEARANCE_CTRL

GAME_MAIN_L1:
    ; ■スプライトキャラクターワークテーブルの全ての要素に対して繰り返し
    LD B,MAX_CHR_CNT

GAME_MAIN_L2:
    ; ■BCレジスタをスタックに退避
    PUSH BC

    ; ■対象のキャラクター番号からスプライトキャラクターワークテーブルのアドレスを取得
    LD A,B
    CALL GET_SPR_WK_ADDR            ; IX <- 対象のスプライトキャラクターワークテーブルのアドレス

    LD B,(IX)                       ; B <- キャラクター番号
    LD A,B
    CP $FF
    JR Z,GAME_MAIN_L4               ; $FFの場合はキャラクタ除去へ
    OR A
    JR Z,GAME_MAIN_L5               ; ゼロの場合はGAME_MAIN_L4へ

    CP 5                            ; 5未満(=プレイヤー・バクハツの場合)ならキャリーが立つ
    JR C,GAME_MAIN_L3

    ; ■テキの場合はプレイヤーの状態を判断する
    LD A,(PLAYER_CONTROL_MODE)      ; プレイヤーの状態、5以降はミスとなる
    CP 6                            ; 6未満ならキャリーが立つ
    JR NC,GAME_MAIN_L5

GAME_MAIN_L3:
    ; ■対象のキャラクター番号からキャラクターロジックテーブルのアドレスにジャンプ
    LD A,B
    SUB 1
    LD HL,CHARACTER_UPDATE_TABLE    ; HL <- キャラクターロジックテーブルのアドレス
    CALL TBL_JP
    JR GAME_MAIN_L5

GAME_MAIN_L4:
    ; ■キャラクタ除去
    CALL REMOVE_CHARACTER

GAME_MAIN_L5:
    ; ■BCレジスタをスタックから復元 
    POP BC
    DJNZ GAME_MAIN_L2

    ; ■タイム減算
    LD A,(TICK3_WK)
    OR A
    RET NZ

    LD A,(TIME_BCD)
    OR A
    JR Z,GAME_MAIN_TIMEOUT          ; タイムがゼロならタイムアウト処理へ

    DEC A
    DAA
    LD (TIME_BCD),A

GAME_MAIN_EXIT:
    RET


; -----------------------------------------------------------------------------------------------------
; タイムアウト処理
; -----------------------------------------------------------------------------------------------------
GAME_MAIN_TIMEOUT:

    LD HL,TIMEOUTENEMY_APPEARANCE_CNT
    LD A,(HL)
    OR A    
    JR NZ,GAME_MAIN_TIMEOUT_L1

    LD A,10                         ; 次に出現するまで10秒
    LD (HL), A
    CALL ADD_ENEMY_TIMEOUT
    RET

GAME_MAIN_TIMEOUT_L1:
    DEC (HL)
    RET
