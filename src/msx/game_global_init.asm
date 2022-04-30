; ====================================================================================================
;
; game_global_init.asm
;
; included from game.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; ゲーム全体初期化処理
; ====================================================================================================
GAME_GLOBAL_INIT:
    ; ■画面初期化
    CALL SCREEN_INIT

    ; ■フォントパターン定義
    CALL SET_FONT_PATTERN

    ; ■PCGパターン定義
    CALL SET_PCG_PATTERN

    ; ■カラーテーブル定義
    CALL SET_COLOR_TABLE

    ; ■スプライトパターン定義
    CALL SET_SPRITE_PATTERN

    ; ■スプライトキャラクターワークテーブル初期化
    CALL INIT_SPR_CHR_WK_TBL

    ; ■サウンドドライバ初期化
    CALL SOUNDDRV_INIT

    ; ■ゲーム状態をタイトルに変更
    LD A,STATE_TITLE
    CALL CHANGE_STATE

    RET


; ====================================================================================================
; 画面初期化
; ====================================================================================================
SCREEN_INIT:
    ; ■COLOR 15,1,1
    LD A,15                         ; Aレジスタに文字色をロード 
    LD (FORCLR),A                   ; Aレジスタの値をワークエリアに格納
    LD A,1                          ; Aレジスタに全景色をロード
    LD (BAKCLR),A                   ; Aレジスタの値をワークエリアに格納
;    LD A,1                         ; Aレジスタに背景色をロード
    LD (BDRCLR),A                   ; Aレジスタの値をワークエリアに格納

    ; ■SCREEN 1,2,0
    LD A,(REG1SAV)                  ; AレジスタにVDPコントロールレジスタ1の値をロード
    OR 2                            ; ビット2を立てる(=スプライトモードを16x16に設定)
    LD (REG1SAV),A                  ; Aレジスタの値をVDPコントロールレジスタ1のワークエリアに格納
    LD A,1                          ; Aレジスタにスクリーンモードの値を設定
    CALL CHGMOD                     ; BIOS スクリーンモード変更
    LD A,0                          ; Aレジスタにキークリックスイッチの値(0=OFF)をロード
    LD (CLIKSW),A                   ; Aレジスタの値をワークエリアに格納

    ; ■WIDTH 32
    LD A,32                         ; AレジスタにWIDTHの値を設定
    LD (LINL32),A                   ; Aレジスタの値をワークエリアに格納

    ; ■KEY OFF
    CALL ERAFNC                     ; BIOS ファンクションキー非表示

    RET


; ====================================================================================================
; フォントパターン定義
; ====================================================================================================
SET_FONT_PATTERN:
	LD HL,FONT_PTN_DATA			    ; HLレジスタに転送元データの先頭アドレスを設定
    LD DE,PTN_GEN_ADDR+32*8         ; DEレジスタに転送先アドレスを設定
	LD BC,8*64					    ; BCレジスタにデータサイズを指定
    CALL LDIRVM					    ; BIOS VRAMブロック転送

    RET


; ====================================================================================================
; PCGパターン定義
; ====================================================================================================
SET_PCG_PATTERN:
    LD HL,PCG_PTN_DATA              ; HL <- PCGデータの先頭アドレス

SET_PCG_PATTERN_L1:
    LD A,(HL)                       ; A <- PCGデータのキャラクターコード
    OR A                            ; A=ゼロなら抜ける
    JR Z,SET_PCG_PATTERN_EXIT

    ; DEレジスタにコピー先のアドレスを設定
    ; $0000+キャラクターコード*8
    PUSH HL                         ; HLを退避
    LD H,0                          ; HL <- A
    LD L,A
    ADD HL,HL                       ; HL=HL*8
    ADD HL,HL
    ADD HL,HL
    LD D,H                          ; DE <- HL
    LD E,L    
    POP HL

    ; HLレジスタにコピー元のアドレスを設定
    INC HL                          ; HL=HL+1
    
    ; BCレジスタに転送バイト数を設定
    LD BC,8                         ; 8バイトを転送
    PUSH BC
    PUSH HL
    CALL LDIRVM                     ; BIOS VRAMブロック転送
    POP HL
    POP BC
    
    ADD HL,BC                       ; HL <- 次のPCGデータのアドレス(+8)
    JR SET_PCG_PATTERN_L1

SET_PCG_PATTERN_EXIT:
    RET


; ====================================================================================================
; カラーテーブル定義
; ====================================================================================================
SET_COLOR_TABLE:
    LD HL,PCG_COLOR_DATA            ; HL <- PCGカラーデータの先頭アドレス
    LD DE,COLOR_TABLE_ADDR          ; DE <- カラーテーブルの先頭アドレス
    LD BC,32                        ; BC <- 転送バイト数
    CALL LDIRVM                     ; BIOS VRAMブロック転送

    RET


; ====================================================================================================
; スプライトパターン定義
; ====================================================================================================
SET_SPRITE_PATTERN:
	LD HL,SPR_PTN_DATA			    ; HLレジスタにスプライトデータの先頭アドレスを設定
    LD DE,SPR_PTN_ADDR			    ; DEレジスタにスプライトパターンジェネレータの先頭アドレスを設定
	LD BC,32*28-1				    ; BCレジスタにスプライトデータのサイズを指定
    CALL LDIRVM				 	    ; BIOS VRAMブロック転送

    RET


SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■フォントパターンデータ
INCLUDE "assets/font.asm"

; ■PCGパターン／カラーテーブルデータ
INCLUDE "assets/pcgptn.asm"

; ■スプライトパターンデータ
INCLUDE "assets/spriteptn.asm"
