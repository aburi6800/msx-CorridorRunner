SECTION code_user

; ■ランキングデータの１レコードサイズ
;   実際は7byteだがキリが悪いので8byteとする
SCOREBOARD_REC_SIZE:        EQU 8

; ■入力文字データ長
;   NAMEENTRY_WORDLISTの文字長 - 1を設定する
NAMEENTRY_WORDLIST_LEN:     EQU 31

; ■ウェイト
NAMEENTRY_WAIT_VALUE:       EQU 16

; ====================================================================================================
; スコアランキング表示
; ====================================================================================================
SCOREBOARD:
    ; ■初回のみの処理実行
    JR Z,SCOREBOARD_INIT

    ; ■SPACEキーが押されたらタイトルに遷移
    ; ■スペースキー or トリガが押されたか判定
    CALL GET_STRIG                  ; トリガ入力状態取得
    JR NZ,SCOREBOARD_L1             ; ゼロ以外(入力)ならゲーム状態をタイトルへ

    ; ■TICKが600カウント(=10秒)経過してなければ抜ける
    LD BC,600
    LD HL,(TICK1)    
    SBC HL,BC
    JR NZ,SCOREBOARD_EXIT

SCOREBOARD_L1:
    ; ■ゲーム状態変更
    LD A,STATE_TITLE                ; ゲーム状態をタイトルへ
    CALL CHANGE_STATE

SCOREBOARD_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; スコアランキング表示初回処理
; ----------------------------------------------------------------------------------------------------
SCOREBOARD_INIT:

    ; ■オフスクリーンリセット
    CALL RESET_OFFSCREEN

    ; ■ランキング画面作成
    LD HL,SCOREBOARD_STRING1
    CALL PRTSTR

    LD B,1
    LD HL,$00E6
    CALL DISPLAY_RANKING_RECORD

    LD B,2
    LD HL,$0126
    CALL DISPLAY_RANKING_RECORD

    LD B,3
    LD HL,$0166
    CALL DISPLAY_RANKING_RECORD

    LD B,4
    LD HL,$01A6
    CALL DISPLAY_RANKING_RECORD

    LD B,5
    LD HL,$01E6
    CALL DISPLAY_RANKING_RECORD

SCOREBOARD_INIT_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; ランキングレコード表示処理
; IN  : B  = 対象のランキング
;       HL = 表示先のオフスクリーンアドレス
; ----------------------------------------------------------------------------------------------------
DISPLAY_RANKING_RECORD:

    ; ■取得元のランキングデータのアドレス算出
    PUSH HL
    LD HL,SCOREBOARD_TBL
    LD A,B
    SUB 1                               ; A=A-1
    SLA A
    SLA A
    SLA A                               ; A=A*8
    CALL ADD_HL_A
    PUSH HL
    POP IX                              ; インデックスレジスタにランキングデータの先頭アドレスを保存
    POP HL

    ; ■ランキング表示
    ;   ランク    
    LD A,B
    ADD A,$30                           ; 文字コードを設定
    CALL PUTSTR
    INC HL                              ; 2文字右へ
    INC HL

    ;   名前
    LD B,3
DISPLAY_RANKING_RECORD_L1:
    LD A,(IX)
    CALL PUTSTR
    INC HL
    INC IX
    DJNZ DISPLAY_RANKING_RECORD_L1

    ;   スコア
    LD B,3                              ; B <- 表示するデータのバイト数
    LD C,$20                            ; C <- 表示桁を埋める文字コード
    PUSH IX
    POP DE                              ; DE <- 表示するデータのアドレス(IX)
    INC HL
    CALL PRTBCD

    XOR A
    LD A,$30
    CALL PUTSTR
    INC HL
    CALL PUTSTR

    ;   ラウンド
    INC HL
    INC HL
    LD A,$52
    PUSH HL
    CALL PUTSTR
    POP HL

    LD A,(IX+3)
    LD C,0
    INC HL
    CALL PUTBCD                         ; ゼロはないのでこのまま

DISPLAY_RANKING_RECORD_EXIT:
    RET

; ====================================================================================================
; スコアランキング判定・ソート処理
; チェック結果は SCOREBOARD_INRANK を参照、ゼロ以外ならランキング入りしている
; ====================================================================================================
CHECK_RANKING_REGIST:

    ; ■ランキング順位初期化
    XOR A
    LD (SCOREBOARD_INRANK),A

    ; ■プレイヤースコアとラウンドをランキングワークにコピー
    LD HL,SCORE                                  ; コピー元（プレイヤースコア(BCD値)）のアドレス
    LD DE,SCOREBOARD_TBL+SCOREBOARD_REC_SIZE*5+3 ; コピー先（6位のレコード）のアドレス
    LD BC,4                                      ; データサイズ(スコア3バイト+ラウンド数1バイト)
    LDIR

    ; ■名前初期化
    LD A,$20
    LD (SCOREBOARD_TBL+SCOREBOARD_REC_SIZE*5),A
    LD (SCOREBOARD_TBL+SCOREBOARD_REC_SIZE*5+1),A
    LD (SCOREBOARD_TBL+SCOREBOARD_REC_SIZE*5+2),A

    ; ■ランキングワークをチェック
    LD B,6                                      ; 6位（=プレイヤーのスコア)から処理する
    LD DE,SCOREBOARD_TBL+SCOREBOARD_REC_SIZE*4  ; 5位のレコードのアドレス
    LD HL,SCOREBOARD_TBL+SCOREBOARD_REC_SIZE*5  ; 6位のレコードのアドレス

CHECK_RANKING_REGIST_L1:
    PUSH BC
    PUSH DE
    PUSH HL

    INC DE
    INC DE                          ; スコアのアドレス

    INC HL                          ; スコアのアドレス
    INC HL

    LD B,3                          ; ループ回数(桁数)
CHECK_RANKING_REGIST_CHK_L2:
    INC HL                          ; 次の桁へ
    INC DE                          ; 次の桁へ

    OR A                            ; フラグクリア
    LD A,(DE)                       ; １つ上位のスコア
    SUB (HL)                        ; 現在の位のスコアを減算
    JR C,CHECK_RANKING_REGIST_L3    ; １つ上位のスコア < 現在の位のスコアの時は入れ替える
    JR NZ,CHECK_RANKING_REGIST_L22  ; １つ上位のスコア > 現在の位のスコアの時はここでチェック終了

CHECK_RANKING_REGIST_L21:
    DJNZ CHECK_RANKING_REGIST_CHK_L2

CHECK_RANKING_REGIST_L22:
    POP HL
    POP DE
    POP BC

    RET

CHECK_RANKING_REGIST_L3:
    ; ■ランキング入れ替え
    POP HL
    POP DE
    POP BC
    LD (SCOREBOARD_REGIST_ADDR),DE  ; 入れ替え先の順位のデータのアドレスを登録先として保存
    CALL RANKING_SWAP               ; ランキング入れ替え
    LD A,B
    DEC A
    LD (SCOREBOARD_INRANK),A        ; ランキング順
    ; ■HLを-8して一つ上の順位のレコードのアドレスを設定
    LD A,L
    SUB 8
    LD L,A
    JR NC,CHECK_RANKING_REGIST_L31
    DEC H

CHECK_RANKING_REGIST_L31:
    ; ■DEを-8して一つ上の順位のレコードのアドレスを設定
    LD A,E
    SUB 8
    LD E,A
    JR NC,CHECK_RANKING_REGIST_L32
    DEC D

CHECK_RANKING_REGIST_L32:
    DJNZ CHECK_RANKING_REGIST_L1            

    RET

; ----------------------------------------------------------------------------------------------------
; スコアランキング入れ替え処理
; IN : HL = 入れ替え元レコードのアドレス
;      DE = 入れ替え先レコードのアドレス
; ----------------------------------------------------------------------------------------------------
RANKING_SWAP:
    PUSH BC
    PUSH DE
    PUSH HL

    ; ■入れ替え先レコードの内容をワークにコピー
    PUSH DE
    PUSH HL
    LD HL,DE                        ; コピー元アドレス
    LD DE,SCOREBOARD_SWAP_WK        ; コピー先アドレス
    LD BC,8                         ; データサイズ
    LDIR
    POP HL
    POP DE

    ; ■入れ替え元レコードの内容を入れ替え先レコードにコピー
    PUSH DE
    PUSH HL
    LD BC,8                         ; データサイズ
    LDIR
    POP HL
    POP DE

    ; ■ワークの内容を入れ替え元レコードにコピー
    LD DE,HL                        ; コピー元アドレス
    LD HL,SCOREBOARD_SWAP_WK        ; コピー先アドレス
    LD BC,8                         ; データサイズ
    LDIR

RANKING_SWAP_EXIT:
    POP HL
    POP DE
    POP BC
    RET


; ====================================================================================================
; ネームエントリー
; ====================================================================================================
NAMEENTRY:
    ; ■初回のみ初期化を実行
    JR Z,NAMEENTRY_INIT

    ; ■入力文字表示
    LD A,(TICK2)
    AND %00000001
    LD A,$20                        ; 表示文字をスペースとする
    JR Z,NAMEENTRY_L1

    LD A,(NAMEENTRY_WORD)           ; 表示文字を選択文字とする

NAMEENTRY_L1:
    LD HL,(NAMEENTRY_WORD_DISP_ADDR)
    CALL PUTSTR

    ; ■トリガ入力判定
    CALL GET_STRIG                  ; トリガ入力状態取得
    JR Z,NAMEENTRY_L2               ; 未入力なら次の処理へ

    ;   名前に文字を追加
    LD A,(NAMEENTRY_WORD)           ; A <- 選択文字
    LD HL,(SCOREBOARD_REGIST_ADDR)  ; HL <- ランキング登録先アドレス
    LD (HL),A                       ; ランキング登録先アドレスに選択文字を保存
    INC HL                          ; ランキング登録先アドレスを+1
    LD (SCOREBOARD_REGIST_ADDR),HL

    LD HL,(NAMEENTRY_WORD_DISP_ADDR) ; HL <- 選択文字の表示先アドレス
    CALL PUTSTR                     ; 表示しておく
    INC HL                          ; 選択文字の表示先アドレスを+1
    LD (NAMEENTRY_WORD_DISP_ADDR),HL

    LD HL,NAMEENTRY_WORD_CNT        ; HL <- 入力文字数格納先アドレス
    INC (HL)                        ; 入力文字数を+1
    LD A,(HL)
    CP 3
    JR Z,NAMEENTRY_END              ; 3文字目を入力したらネームエントリー終了

NAMEENTRY_L2:
    ; ■ウェイト処理
    LD A,(NAMEENTRY_WAIT_CNT)       ; A <- ウェイトカウンタ
    DEC A                           ; ウェイトカウンタ -1
    JR Z,NAMEENTRY_L21              ; ゼロならL21へ
    ;   ウェイトカウンタリセット
    LD (NAMEENTRY_WAIT_CNT),A       ; メモリに保存
    RET
NAMEENTRY_L21:
    LD A,NAMEENTRY_WAIT_VALUE       ; ゼロならカウンタをリセット
    LD (NAMEENTRY_WAIT_CNT),A       ; メモリに保存

NAMEENTRY_L3:
    ; ■STICK入力判定
    LD A,(INPUT_BUFF_STICK)
    OR A
    RET Z                           ; STICK値がゼロ(＝未入力)なら抜ける

    CP DIRECTION_RIGHT
    JR NZ,NAMEENTRY_L4              ; 右以外なら次の処理へ

    LD HL,NAMEENTRY_WORD_IDX
    INC (HL)
NAMEENTRY_L31:
    CALL NAMEENTRY_SETWORD          ; 入力中文字設定
                                    ; Aレジスタに選択中の文字が入っている
    OR A
    JR NZ,NAMEENTRY_EXIT            ; ゼロ(両端)でなければ終了

    LD A,NAMEENTRY_WORDLIST_LEN - 1
    LD (NAMEENTRY_WORD_IDX),A       ; 入力中文字インデックスを先頭に設定
                                    ; 戻った時にインクリメントするのでゼロにする
    JR NAMEENTRY_L31                ; 再度入力中文字を設定

NAMEENTRY_L4:
    CP DIRECTION_LEFT
    JR NZ,NAMEENTRY_EXIT            ; 左以外なら次の処理へ

    LD HL,NAMEENTRY_WORD_IDX
    DEC (HL)
NAMEENTRY_L41:
    CALL NAMEENTRY_SETWORD          ; 入力中文字設定
                                    ; Aレジスタに選択中の文字が入っている
    OR A
    JR NZ,NAMEENTRY_EXIT            ; ゼロ(両端)でなければ終了

    LD A,1
    LD (NAMEENTRY_WORD_IDX),A       ; 入力中文字インデックスを末端に設定
                                    ; 戻った時にデクリメントするので最大値にする
    JR NAMEENTRY_L41                ; 再度入力中文字を設定

NAMEENTRY_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; ネームエントリー終了処理
; ----------------------------------------------------------------------------------------------------
NAMEENTRY_END:
    CALL SOUNDDRV_STOP              ; BGM演奏STOP
    LD A,STATE_TITLE                ; ゲーム状態をタイトルへ
    CALL CHANGE_STATE

NAMEENTRY_END_EXIT:
    RET

; ----------------------------------------------------------------------------------------------------
; ネームエントリー初期処理
; ----------------------------------------------------------------------------------------------------
NAMEENTRY_INIT:
    ; ■オフスクリーン初期化・ランキング表示
    CALL SCOREBOARD_INIT

    ; ■ネームエントリー時のメッセージ
    LD HL,SCOREBOARD_STRING2
    CALL PRTSTR

    ; ■ワーク設定
    ;   ウェイト
    LD A,NAMEENTRY_WAIT_VALUE
    LD (NAMEENTRY_WAIT_CNT),A
    ;   選択文字インデックス
    ;   先頭は$00のため、1を初期値とする
    LD A,1
    LD (NAMEENTRY_WORD_IDX),A
    ;   選択文字
    CALL NAMEENTRY_SETWORD
    ;   入力文字数
    ;   ゼロとする
    XOR A
    LD (NAMEENTRY_WORD_CNT),A
    ;   文字入力位置
    LD HL,$00E8                     ; HL <- 名前の表示開始アドレス(1位)
    LD DE,32+32                     ; DE <- 名前の表示開始アドレス加算量
    LD A,(SCOREBOARD_INRANK)        ; A <- ランキング順位
    DEC A
    JR Z,NAMEENTRY_INIT_L2
    LD B,A
NAMEENTRY_INIT_L1:
    ADD HL,DE                       ; 次の順位の表示開始アドレス
    DJNZ NAMEENTRY_INIT_L1
NAMEENTRY_INIT_L2:
    LD (NAMEENTRY_WORD_DISP_ADDR),HL

    ; ■BGM再生
    LD HL,_10
    CALL SOUNDDRV_BGMPLAY

NAMEENTRY_INIT_EXIT:
    RET


; ----------------------------------------------------------------------------------------------------
; 入力中文字設定処理
; ----------------------------------------------------------------------------------------------------
NAMEENTRY_SETWORD:
    LD HL,NAMEENTRY_WORDLIST       ; HL <- 入力文字データのアドレス
    LD A,(NAMEENTRY_WORD_IDX)      ; A <- 入力中文字インデックス
    CALL ADD_HL_A
    LD A,(HL)                      ; A <- 選択中の文字
    LD (NAMEENTRY_WORD),A          ; ワークに格納

NAMEENTRY_SETWORD_EXIT:
    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■スコアランキング初期データ
SCOREBOARD_INITDATA:
    DB "AAA"    
    DB $00,$10,$00
    DB $05,$00
    DB "BBB"    
    DB $00,$08,$00
    DB $04,$00
    DB "CCC"    
    DB $00,$06,$00
    DB $03,$00
    DB "DDD"    
    DB $00,$04,$00
    DB $02,$00
    DB "EEE"    
    DB $00,$02,$00
    DB $01,$00
    DB "   "
    DB $00,$00,$00
    DB $00,$00

; ■スコアランキング表示文字列
SCOREBOARD_STRING1:
    DW $008A
    DB "TOP PLAYERS",0

; ■ネームエントリー表示文字列
SCOREBOARD_STRING2:
    DW $0088
    DB "ENTER YOUR NAME!",0

; ■入力文字データ
;   32byte
NAMEENTRY_WORDLIST:
    DB 0,"ABCDEFGHIJKLMNOPQRSTUVWXYZ.!? ",0


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================

; ■ランキングデータ
;   以下をソート時のワーク含めて6レコード分確保
;   1位からの昇順で格納される
;   3byte : 名前
;   3byte : スコア(BCD値)
;   1byte : ラウンド数(BCD値)
;   1byte : 予備
SCOREBOARD_TBL:
    DEFS SCOREBOARD_REC_SIZE * 6

; ■ランキングデータ入れ替え用ワーク
SCOREBOARD_SWAP_WK:
    DEFS SCOREBOARD_REC_SIZE

; ■ランキング順位
SCOREBOARD_INRANK:
    DEFS 1

; ■ランキング登録先アドレス
SCOREBOARD_REGIST_ADDR:
    DEFS 2

; ■選択文字インデックス
NAMEENTRY_WORD_IDX:
    DEFS 1

; ■選択文字
NAMEENTRY_WORD:
    DEFS 1

; ■入力文字数
NAMEENTRY_WORD_CNT:
    DEFS 1

; ■選択文字の表示先アドレス
NAMEENTRY_WORD_DISP_ADDR:
    DEFS 2

; ■ウェイトカウンタ
NAMEENTRY_WAIT_CNT:
    DEFS 1
