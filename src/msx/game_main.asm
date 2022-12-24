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
    JR NZ,GAME_MAIN_PAUSE           ; 一時停止フラグが1の場合は一時停止中処理へ

    LD A,(KEYBUFF)
    CP KEY_F1
    JR NZ,GAME_MAIN_L1              ; [F1]キーが押されていなければ後続の処理へ

    ; ■一時停止
    LD A,1
    LD (GAME_IS_PAUSE),A            ; 一時停止フラグをON
    LD HL,SFX_01
    CALL SOUNDDRV_SFXPLAY
    CALL SOUNDDRV_PAUSE             ; サウンドドライバの一時停止
    RET


GAME_MAIN_L1:
    ; ■テキ出現制御処理を呼び出す
    CALL ENEMY_APPEARANCE_CTRL

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

    CALL IS_PLAYER_MISS             ; プレイヤーミス状態を判定
;    JR NC,GAME_MAIN_EXIT            ; プレイヤーミス状態ならタイム減算はせずに終了
    RET NC

    ; ■1秒タイマー更新判定
    LD A,(TICK3_WK)
    OR A
    RET NZ

    ; ■内部ランク加算判定
    CALL CHECK_INTERNAL_RANK_CNT

    ; ■タイム減算
GAME_MAIN_L6:
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


; -----------------------------------------------------------------------------------------------------
; ポーズ中処理
; -----------------------------------------------------------------------------------------------------
GAME_MAIN_PAUSE:
    LD A,(KEYBUFF)                  ; キーバッファ取得
    OR A
    RET Z                           ; 未入力なら抜ける

    ; ■キー入力があった場合はバッファに溜める
    PUSH AF
    LD HL,SECRET_COMMAND_BUFF+6
    LD DE,SECRET_COMMAND_BUFF+7
    LD BC,$0007
    LDDR                            ; 入力中コマンドバッファを全体的に右にシフト
    POP AF
    LD HL,SECRET_COMMAND_BUFF
    LD (HL),A                       ; バッファの先頭に入力値を保存

    ; ■コマンドチェック
    LD C,0                          ; C : コマンド番号
GAME_MAIN_PAUSE_L01:
    LD A,C                          ; A <- C(コマンド番号)
    INC C                           ; コマンド番号+1しておく
    ADD A,A
    ADD A,A
    ADD A,A                         ; *8する
    LD HL,SECRET_COMMAND            ; HL <- コマンド
    CALL ADD_HL_A                   ; コマンドの先頭アドレスを求める

    LD A,(HL)                       ; コマンド文字数
    OR A
    JR Z,GAME_MAIN_PAUSE_L3         ; コマンド文字数＝ゼロならL03へ

    LD B,A                          ; B <- コマンド文字数(ループ回数)
    INC HL                          ; HL <- コマンドの先頭へ
    LD DE,SECRET_COMMAND_BUFF       ; DE <- 入力中コマンドバッファ
GAME_MAIN_PAUSE_L2:
    LD A,(DE)                       ; A <- 入力コマンド
    CP (HL)                         ; コマンドの文字と比較
    JR NZ,GAME_MAIN_PAUSE_L01       ; 同じでなければ次のコマンドのチェックへ

    INC HL                          ; 次のコマンドの文字へ
    INC DE                          ; 次の入力中コマンドバッファの文字へ
    DJNZ GAME_MAIN_PAUSE_L2

    ; ■コマンド入力完了
    LD A,C                          ; C <- コマンド番号(この時点で1〜になっている)
    CP 3
    JR Z,GAME_MAIN_PAUSE_L22        ; コマンド３
    CP 2
    JR Z,GAME_MAIN_PAUSE_L21        ; コマンド２

    ; ■コマンド１：強制ラウンドクリア
    LD A,STATE_ROUND_CLEAR
    CALL CHANGE_STATE
    JR GAME_MAIN_PAUSE_L4

GAME_MAIN_PAUSE_L21:
    ; ■コマンド２：無敵
    LD A,1
    LD (INVINCIBLE_FLG),A
    RET

GAME_MAIN_PAUSE_L22:
    ; ■コマンド３：内部ランク表示
    LD A,1
    LD (INTERNAL_RANK_DISP),A
    RET

GAME_MAIN_PAUSE_L3:
    LD A,(KEYBUFF)                  ; キーバッファ取得
    CP KEY_F1                       ; [F1]キーか
    RET NZ                          ; [F1]キーが押されていなければ抜ける

GAME_MAIN_PAUSE_L4:
    XOR A
    LD (GAME_IS_PAUSE),A            ; 一時停止フラグをOFF
    CALL SOUNDDRV_RESUME            ; サウンドドライバの一時停止解除

GAME_MAIN_PAUSE_EXIT:
    RET


; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================
SECTION rodata_user

; ■コマンド
SECRET_COMMAND:
    DB 5,KEY_A,KEY_K,KEY_U,KEY_S,KEY_A,$00,$00
    DB 5,KEY_I,KEY_K,KEY_U,KEY_U,KEY_Y,$00,$00
    DB 4,KEY_A,KEY_Y,KEY_A,KEY_S,$00,$00,$00
    DB $00

; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================
SECTION bss_user

; ■入力中コマンドバッファ
SECRET_COMMAND_BUFF:
    DB $00,$00,$00,$00,$00,$00,$00,$00
