; ====================================================================================================
;
; enemy.asm
;
; included from sprite.asm
;
; ====================================================================================================
INCLUDE "enemy1.asm"
INCLUDE "enemy2.asm"

SECTION code_user

; ====================================================================================================
; テキ出現制御初期処理
; ラウンド初期処理で設定されるワークエリア ROUNDの値を参照する
; ====================================================================================================
ENEMY_APPEARANCE_INIT:

    ; ■ROUNDに対応するテキ出現パターンデータのアドレスをENEMY_PTN_TBLから取得し、ENEMY_PTN_ADDRに設定
    LD A,(ROUND)
    SUB A
    LD HL,ENEMY_PTN_TBL
    CALL GET_ADDR_TBL
    LD (ENEMY_PTN_ADDR),DE

    ; ■ テキ出現制御処理
    CALL ENEMY_APPEARANCE_CTRL


ENEMY_APPEARANCE_INIT_EXIT:
    RET


; ====================================================================================================
; テキ出現制御処理
; 事前にENEMY_APPEARANCE_INITを実行しておくこと。
; HL,DEレジスタを破壊します
; ====================================================================================================
ENEMY_APPEARANCE_CTRL:

    ; 1) ENEMY_PTN_ADDRから出現カウントを取得(2byte)
    LD HL,(ENEMY_PTN_ADDR)          ; HL <- テキ出現パターンデータの参照先アドレス
    LD E,(HL)                       ; DE <- 出現カウント(16bit)
    INC HL                          ; ENEMY_PTN_ADDR + 1
    LD D,(HL)

    ; 出現カウント=$FFFFだったら抜ける
    LD A,D
    XOR $FF                         ; A=$FFの場合、ここでゼロフラグが立つ
    JR NZ,ENEMY_APPEARANCE_CTRL_L1  ; ゼロフラグが降りている場合は$FFではないので後続の処理へ
    LD A,E
    XOR $FF                         ; A=$FFの場合、ここでゼロフラグが立つ
    JR NZ,ENEMY_APPEARANCE_CTRL_L1  ; ゼロフラグが降りている場合は$FFではないので後続の処理へ

    RET                             ; ここに到達する=$FFFFなので、抜ける

ENEMY_APPEARANCE_CTRL_L1:
;    PUSH HL
    PUSH DE                         ; 出現カウント(DE) -> HL
    POP HL

    LD DE,$0000                     ; 初期値 = $0000 とする

    LD A,(GAME_STATE)
    SUB STATE_ROUND_START
    JR Z,ENEMY_APPEARANCE_CTRL_L3   ; ゲーム状態 = ラウンドスタートの場合はL3へ

    ; 2) tickを取得
    LD DE,(TICK1)

ENEMY_APPEARANCE_CTRL_L3:
    ; 3) 出現カウント - DE != ZERO なら抜ける
    SBC HL,DE
;    POP HL
    RET NZ

    ; テキキャラクター登録
    CALL ADD_ENEMY

    JP ENEMY_APPEARANCE_CTRL


; ====================================================================================================
; テキキャラクター登録処理
; IN  : HL = テキ出現パターンデータのアドレス
; ====================================================================================================
ADD_ENEMY:
    ; 4) (ENEMY_PTN_ADDR+1)して、キャラクター番号を取得
    LD HL,(ENEMY_PTN_ADDR)          ; HL <- テキ出現パターンデータの参照先アドレス
    INC HL                          ; ENEMY_PTN_ADDR + 2 = キャラクター番号
    INC HL                          ;
    LD A,(HL)                       ; A <- キャラクター番号

    ; 5) パラメタ取得開始アドレスをスタックに積む
    INC HL                          ; ENEMY_PTN_ADDR + 3 = キャラクターY座標
;    PUSH HL                         ; パラメタ取得開始アドレスを各初期化処理から参照できるようにスタックに積む
    LD (ENEMY_PARAM_ADDR),HL        ; パラメタ取得開始アドレスをワークに設定

    ; 次の処理用にアドレスを計算してワークに格納しておく
    LD DE,$0005
    ADD HL,DE
    LD (ENEMY_PTN_ADDR),HL

    ; 6) キャラクター番号に対応するキャラクターを登録
    ;    スタックにパラメタの取得開始アドレスをpushしてあるので、
    ;    テキの取得処理では必ずpopすること
    CALL ADD_CHARACTER

    ; 7) 1) へ
    RET


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■テキ出現パターンデータの参照先アドレス
ENEMY_PTN_ADDR:
    DEFS 2

; ■テキ初期値データの参照先アドレス
ENEMY_PARAM_ADDR:
    DEFS 2