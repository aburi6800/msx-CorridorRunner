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
    ; ■対象のキャラクター番号からスプライトキャラクターワークテーブルのアドレスを取得
    LD A,B
    CALL GET_SPR_WK_ADDR            ; IX <- 対象のスプライトキャラクターワークテーブルのアドレス

    ; ■BCレジスタをスタックに退避
    PUSH BC

    ; ■対象のキャラクター番号からキャラクターロジックテーブルのアドレスを取得
    LD A,(IX)                       ; A <- キャラクター番号
    CP $FF
    JR Z,GAME_MAIN_L3

    OR A
    JR Z,GAME_MAIN_L4               ; ゼロの場合はGAME_MAIN_L2へ
    SUB 1
    LD HL,CHARACTER_UPDATE_TABLE    ; HL <- キャラクターロジックテーブルのアドレス
    CALL TBL_JP
    JR GAME_MAIN_L4

GAME_MAIN_L3:
    CALL REMOVE_CHARACTER

GAME_MAIN_L4:
    ; ■BCレジスタをスタックから復元 
    POP BC
    DJNZ GAME_MAIN_L2

GAME_MAIN_EXIT:
    RET
