; # ラウンドデータ
; ## PLAYER_INIT
;    DB [Y座標], [X座標], [方向]
; ## ENEMY_PTN
;    DW [出現する時間、$0000=スタート時に出現]
;    DB [テキのキャラクター番号], [Y座標], [X座標], [方向], [パラメタ1], [パラメタ2]
;    パラメタについては各テキのソース参照

; ■ラウンド1
PLAYER_INIT_ROUND01:
    DB 160,120,DIRECTION_UP
ENEMY_PTN_ROUND01:
    DW $FFFF

; ■ラウンド2
PLAYER_INIT_ROUND02:
    DB 144, 24,DIRECTION_UP
ENEMY_PTN_ROUND02:
    DW $FFFF

; ■ラウンド3
PLAYER_INIT_ROUND03:
    DB 144, 32,DIRECTION_RIGHT
ENEMY_PTN_ROUND03:
    DW $0000
    DB CHRNO_ENEMY2, 136, 200, DIRECTION_RIGHT, $00, $00
    DW $0000
    DB CHRNO_ENEMY2,  72,  40,  DIRECTION_LEFT, $01, $00
    DW $FFFF

; ■ラウンド4
PLAYER_INIT_ROUND04:
    DB 104,112,DIRECTION_UP
ENEMY_PTN_ROUND04:
    DW $0000
    DB CHRNO_ENEMY2, 152,  56, DIRECTION_RIGHT, $00, $00
    DW $0000
    DB CHRNO_ENEMY2,  56, 184,  DIRECTION_LEFT, $01, $00
    DW $0200
    DB CHRNO_ENEMY2,  56,  56, DIRECTION_RIGHT, $00, $00
    DW $0200
    DB CHRNO_ENEMY2, 152, 184,  DIRECTION_LEFT, $01, $00
    DW $FFFF

; ■ラウンド5
PLAYER_INIT_ROUND05:
    DB $A0,$78,$01
ENEMY_PTN_ROUND05:
    DW $FFFF

; ■ラウンド6
PLAYER_INIT_ROUND06:
    DB $A0,$78,$01
ENEMY_PTN_ROUND06:
    DW $FFFF

; ■ラウンド7
PLAYER_INIT_ROUND07:
    DB $A0,$78,$01
ENEMY_PTN_ROUND07:
    DW $FFFF

; ■ラウンド8
PLAYER_INIT_ROUND08:
    DB $A0,$78,$01
ENEMY_PTN_ROUND08:
    DW $FFFF

; ■ラウンド9
PLAYER_INIT_ROUND09:
    DB $A0,$78,$01
ENEMY_PTN_ROUND09:
    DW $FFFF

; ■ラウンド10
PLAYER_INIT_ROUND10:
    DB $A0,$78,$01
ENEMY_PTN_ROUND10:
    DW $FFFF

; ■ラウンド11
PLAYER_INIT_ROUND11:
    DB $A0,$78,$01
ENEMY_PTN_ROUND11:
    DW $FFFF

; ■ラウンド12
PLAYER_INIT_ROUND12:
    DB $A0,$78,$01
ENEMY_PTN_ROUND12:
    DW $FFFF

; ■ラウンド13
PLAYER_INIT_ROUND13:
    DB $A0,$78,$01
ENEMY_PTN_ROUND13:
    DW $FFFF

; ■ラウンド14
PLAYER_INIT_ROUND14:
    DB $A0,$78,$01
ENEMY_PTN_ROUND14:
    DW $FFFF

; ■ラウンド15
PLAYER_INIT_ROUND15:
    DB $A0,$78,$01
ENEMY_PTN_ROUND15:
    DW $FFFF

; ■ラウンド16
PLAYER_INIT_ROUND16:
    DB $A0,$78,$01
ENEMY_PTN_ROUND16:
    DW $FFFF

; ■タイムアウト時のテキ
ENEMY_TIMEOUT:
    DW $0000                        ; ダミー
    DB CHRNO_ENEMY1, $FF, $FF, $FF, $00, $00
