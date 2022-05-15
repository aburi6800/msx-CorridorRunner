; ====================================================================================================
;
; game_global_rodata.asm
;
; included from game.asm
;
; ====================================================================================================

SECTION rodata_user
; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================

; ■マップデータ
include "mapdata.asm"

; ■ラウンドデータ
include "rounddata.asm"

; ■マップデータテーブル
MAP_TBL:
    DW MAP_ROUND01
    DW MAP_ROUND02
    DW MAP_ROUND03
    DW MAP_ROUND04
    DW MAP_ROUND05
    DW MAP_ROUND06
    DW MAP_ROUND07
    DW MAP_ROUND08
    DW MAP_ROUND09
    DW MAP_ROUND10
    DW MAP_ROUND11
    DW MAP_ROUND12
    DW MAP_ROUND13
    DW MAP_ROUND14
    DW MAP_ROUND15
    DW MAP_ROUND16

; ■プレイヤー初期位置テーブル
PLAYER_INIT_TBL:
    DW PLAYER_INIT_ROUND01
    DW PLAYER_INIT_ROUND02
    DW PLAYER_INIT_ROUND03
    DW PLAYER_INIT_ROUND04
    DW PLAYER_INIT_ROUND05
    DW PLAYER_INIT_ROUND06
    DW PLAYER_INIT_ROUND07
    DW PLAYER_INIT_ROUND08
    DW PLAYER_INIT_ROUND09
    DW PLAYER_INIT_ROUND10
    DW PLAYER_INIT_ROUND11
    DW PLAYER_INIT_ROUND12
    DW PLAYER_INIT_ROUND13
    DW PLAYER_INIT_ROUND14
    DW PLAYER_INIT_ROUND15
    DW PLAYER_INIT_ROUND16

; ■敵出現パターンテーブル
;   敵出現パターンデータは以下構造：
;   2byte : 出現カウント ($0000 = ラウンド開始時に出現, $FFFF = 終端)
;   1byte : 敵の種類（キャラクター番号）
;   1byte : 敵のY座標 (整数値, $FF=ランダムに設定)
;   1byte : 敵のX座標 (整数値, $FF=ランダムに設定)
;   1byte : 移動方向 ($01〜$08、$00=移動しない、$FF=ランダムに設定)
;   2byte : 予備
ENEMY_PTN_TBL:
    DW ENEMY_PTN_ROUND01
    DW ENEMY_PTN_ROUND02
    DW ENEMY_PTN_ROUND03
    DW ENEMY_PTN_ROUND04
    DW ENEMY_PTN_ROUND05
    DW ENEMY_PTN_ROUND06
    DW ENEMY_PTN_ROUND07
    DW ENEMY_PTN_ROUND08
    DW ENEMY_PTN_ROUND09
    DW ENEMY_PTN_ROUND10
    DW ENEMY_PTN_ROUND11
    DW ENEMY_PTN_ROUND12
    DW ENEMY_PTN_ROUND13
    DW ENEMY_PTN_ROUND14
    DW ENEMY_PTN_ROUND15
    DW ENEMY_PTN_ROUND16

; ■チップセットテーブル
CHIPSET_TBL:
    DW CHIPSET_1
    DW CHIPSET_2
    DW CHIPSET_3
    DW CHIPSET_4

; ■チップセットデータ
CHIPSET_1:
    DB $20, $20, $20, $20
    DB $60, $61, $62, $63
    DB $64, $65, $66, $67
    DB $69, $6A, $6B, $6C
    DB $68, $68, $00, $00

CHIPSET_2:
    DB $20, $20, $20, $20
    DB $70, $71, $72, $73
    DB $74, $75, $76, $77
    DB $79, $7A, $7B, $7C
    DB $78, $78, $00, $00

CHIPSET_3:
    DB $20, $20, $20, $20
    DB $80, $81, $82, $83
    DB $84, $85, $86, $87
    DB $89, $8A, $8B, $8C
    DB $88, $88, $00, $00

CHIPSET_4:
    DB $20, $20, $20, $20
    DB $90, $91, $92, $93
    DB $94, $95, $96, $97
    DB $99, $9A, $9B, $9C
    DB $98, $98, $00, $00


; ■BGMテーブル
BGM_TBL:
    DW _02
    DW _03
    DW _04
    DW _05
