; ====================================================================================================
;
; interval.asm
;
; included from game.asm
;
; ====================================================================================================
SECTION code_user

; ====================================================================================================
; H.TIMI割り込みハンドラ初期化
; ====================================================================================================
INIT_H_TIMI_HANDLER:

    ; MEMO:
    ; - サウンドドライバでもH.TIMIのバックアップを作成して、処理後はそこに飛ばす
    ; - アプリケーションでは、H.TIMIのバックアップと書き換えは、ドライバの初期化前後のどちらでもOKとする
    ;   ドライバ初期化前の場合：
    ;     1) H.TIMIハンドラのバックアップを取る
    ;     2) H.TIMIハンドラを自前の割込処理ルーチンをCALLするように書き換える
    ;     3) サウンドドライバを初期化する（H.TIMIハンドラのバックアップが取得される）
    ;     この結果、以下の動作となる。
    ;       H.TIMIフック → サウンドドライバの処理にJP → 自前の割込処理ルーチンにJP → 元のH.TIMIの処理にJP(RET)
    ;
    ;   ドライバ初期化後の場合
    ;     1) サウンドドライバを初期化する（H.TIMIハンドラのバックアップが取得される）
    ;     2) H.TIMIハンドラのバックアップを取る（サウンドドライバへのJPが設定されている）
    ;     3) H.TIMIハンドラを自前の割込処理ルーチンをCALLするように書き換える
    ;     この結果、以下の動作となる。
    ;       H.TIMIフック → 自前の割込処理ルーチンにJP → サウンドドライバの処理にJP → 元のH.TIMIの処理にJP(RET)

    DI
    ; ■H.TIMIバックアップ
    LD HL,H_TIMI                    ; 転送元
    LD DE,H_TIMI_BACKUP             ; 転送先
    LD BC,5                         ; 転送バイト数
    LDIR

    ; ■H.TIMI書き換え
    LD A,$C3                        ; JP
    LD HL,H_TIMI_HANDLER            ; サウンドドライバのアドレス
    LD (H_TIMI+0),A
    LD (H_TIMI+1),HL
    EI

    ; ■サウンドドライバ初期化
    CALL SOUNDDRV_INIT

    RET


; ====================================================================================================
; H.TIMI割り込み処理
; ====================================================================================================
H_TIMI_HANDLER:

	; ■VSYNC_WAIT_CNTデクリメント
	;   1/60ごとに-1される
    ;   メインルーチンの最初の設定値により
    ;     1 = 60フレーム
    ;     2 = 30フレーム
    ;   の処理となる
    LD A,(VSYNC_WAIT_CNT)
    OR A
    JR Z,H_TIMI_HANDLER_L1
    DEC A
	LD (VSYNC_WAIT_CNT),A

H_TIMI_HANDLER_L1:
    ; ■バックアップ済のH.TIMIハンドラにチェーン
    ;   最後に必ず実行する
    JP H_TIMI_BACKUP


SECTION bss_user
; ====================================================================================================
; ワークエリア
; プログラム起動時にcrtでゼロでramに設定される 
; ====================================================================================================
H_TIMI_BACKUP:
    DEFS 5

; ■VSYNCウェイトカウンタ
VSYNC_WAIT_CNT:
	DEFS 1
