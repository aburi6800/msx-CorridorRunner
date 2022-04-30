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

GAME_MAIN_EXIT:
    RET
