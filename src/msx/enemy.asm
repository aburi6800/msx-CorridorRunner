; ====================================================================================================
;
; enemy.asm
;
; included from sprite.asm
;
; ====================================================================================================
INCLUDE "enemy1.asm"
INCLUDE "enemy2.asm"
INCLUDE "enemy3.asm"
INCLUDE "enemy4.asm"

SECTION code_user

; ■テキ出現時の点滅時間
ENEMY_FLASHING_CNT:                 EQU $40

; ====================================================================================================
; テキ出現制御初期処理
; ラウンド初期処理で設定されるワークエリア ROUNDの値を参照する
; ====================================================================================================
ENEMY_APPEARANCE_INIT:

    ; ■ROUNDに対応するテキ出現パターンデータのアドレスをENEMY_PTN_TBLから取得し、ENEMY_PTN_ADDRに設定
    LD A,(ROUND)
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

    ; ■ENEMY_PTN_ADDRから出現カウントを取得(2byte)
    LD HL,(ENEMY_PTN_ADDR)          ; HL <- テキ出現パターンデータの参照先アドレス
    LD E,(HL)                       ; DE <- 出現カウント(16bit)
    INC HL                          ; ENEMY_PTN_ADDR + 1
    LD D,(HL)

    ; ■出現カウント=$FFFFだったら抜ける
    LD A,D
    CP $FF
    JR NZ,ENEMY_APPEARANCE_CTRL_L1  ; $FFでない場合は後続の処理へ
    LD A,E
    CP $FF
    JR NZ,ENEMY_APPEARANCE_CTRL_L1  ; $FFでない場合は後続の処理へ

    RET                             ; ここに到達する=$FFFFなので、抜ける

ENEMY_APPEARANCE_CTRL_L1:
    LD H,D                          ; 出現カウント(DE) -> HL
    LD L,E
    
    LD A,(GAME_STATE)
    SUB STATE_ROUND_START
    JR NZ,ENEMY_APPEARANCE_CTRL_L2  ; ゲーム状態 = ラウンドスタート以外の場合はL2へ

;    LD DE,$0000                     ; 初期値 = $0000 とする
    LD HL,$0000                     ; 初期値 = $0000 とする
    JP ENEMY_APPEARANCE_CTRL_L3

ENEMY_APPEARANCE_CTRL_L2:
;    LD DE,(ENEMY_PTN_CNT)           ; テキ出現カウンタ取得
    LD HL,(ENEMY_PTN_CNT)           ; テキ出現カウンタ取得

ENEMY_APPEARANCE_CTRL_L3:
    SBC HL,DE                       ; 出現カウント - テキ出現カウンタ != ZERO なら抜ける
    JR NZ,ENEMY_APPEARANCE_CTRL_L4

    ; テキキャラクター登録
    CALL ADD_ENEMY
    JP ENEMY_APPEARANCE_CTRL

ENEMY_APPEARANCE_CTRL_L4:

    LD HL,(ENEMY_PTN_CNT)           ; テキ出現カウンタ取得
    INC HL                          ; メモリのテキ出現カウンタカウントアップ
    LD (ENEMY_PTN_CNT),HL

    RET


; ====================================================================================================
; テキキャラクター登録処理
; ====================================================================================================
ADD_ENEMY:

    ; ■内部ランク判定
    LD HL,INTERNAL_RANK_SV          ; HL <- 内部ランク退避値のアドレス
    LD A,(HL)                       ; A <- 内部ランク値
    LD HL,(ENEMY_PTN_ADDR)          ; HL <- テキ出現パターンデータの参照先アドレス
    INC HL
    INC HL
    SUB (HL)                        ; A <- 内部ランク値 - 出現ランク値

    LD DE,$0007
    JR C,ADD_ENEMY_L1               ; < 0 なら出現させずに次の処理へ

    ; ■キャラクター番号取得
    INC HL
    LD A,(HL)                       ; A <- キャラクター番号

    ; ■パラメタ取得開始アドレスをワークに設定
    INC HL                          ; ENEMY_PTN_ADDR + 4 = キャラクター座標の開始アドレス
    LD (ENEMY_PARAM_ADDR),HL        ; パラメタ取得開始アドレスをワークに設定

    ; ■キャラクター番号に対応するキャラクターをスプライトキャラクターワークテーブルに登録
    CALL ADD_CHARACTER

    ; ■ENEMY_APPEARANCE_CTRLの次の処理用にアドレスを計算してワークに格納しておく
    LD DE,$0005
ADD_ENEMY_L1:
    ADD HL,DE
    LD (ENEMY_PTN_ADDR),HL

    RET


; ====================================================================================================
; タイムアウト時のテキキャラクター登録処理
; ====================================================================================================
ADD_ENEMY_TIMEOUT:

    LD HL,ENEMY_TIMEOUT             ; HL <- テキ出現パターンデータの参照先アドレス

    ; ■(ENEMY_PTN_ADDR+2)からキャラクター番号を取得
    INC HL                          ; ENEMY_PTN_ADDR + 3 = キャラクター番号
    INC HL                          ;
    INC HL                          ;
    LD A,(HL)                       ; A <- キャラクター番号

    ; ■パラメタ取得開始アドレスをワークに設定
    INC HL                          ; ENEMY_PTN_ADDR + 3 = キャラクター座標の開始アドレス
    LD (ENEMY_PARAM_ADDR),HL        ; パラメタ取得開始アドレスをワークに設定

    ; ■キャラクター番号に対応するキャラクターをスプライトキャラクターワークテーブルに登録
    CALL ADD_CHARACTER

    RET


; ====================================================================================================
; プレイヤーとの衝突判定処理
; 衝突している場合、キャリーフラグ＝ONで返す
; テキが出現中、プレイヤーがミス状態ならキャリーフラグ＝OFFで終了する
; ====================================================================================================
HIT_CHECK_FROM_ENEMY:

    ; ■出現中か
    LD A,(IX+12)
    OR A
    RET NZ                          ; 出現中カウンタ > 0 の場合、終了する

    ; ■プレイヤー状態判定
    CALL IS_PLAYER_MISS
    OR A
    RET NZ                          ; プレイヤーミス状態なら衝突判定せずに終了

    LD A,(INVINCIBLE_FLG)           ; 無敵フラグチェック
    CP 1
    RET Z                           ; フラグONなら判定しない

    XOR A                           ; A <- 衝突判定用の相手キャラクター（プレイヤー）
                                    ;      0の場合スプライトキャラクターワークテーブルの先頭を参照するが
                                    ;      1〜2要素目はプレイヤー固定なのとアドレス算出が若干高速化されるので
                                    ;      このままとする
    CALL HIT_CHECK                  ; 衝突判定
    RET


; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================
SECTION bss_user

; ■テキ出現カウンタ
;   テキの出現タイミングをtick1で行うとポーズ時に狂うため、別カウンタを設ける
ENEMY_PTN_CNT:
    DEFS 2

; ■テキ出現パターンデータの参照先アドレス
ENEMY_PTN_ADDR:
    DEFS 2

; ■テキ初期値データの参照先アドレス
ENEMY_PARAM_ADDR:
    DEFS 2
