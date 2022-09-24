; # ラウンドデータ
; ## PLAYER_INIT
;    DB [Y座標], [X座標], [方向]
; ## ENEMY_PTN
;    DW [出現する時間、$0000=スタート時に出現]
;    DB [テキのキャラクター番号], [Y座標], [X座標], [方向], [パラメタ1], [パラメタ2]
;    パラメタについては各テキのソース参照

; ■ラウンド1
PLAYER_INIT_ROUND01:
    DB 160, 120, DIRECTION_UP
ENEMY_PTN_ROUND01:
    DW $FFFF

; ■ラウンド2
PLAYER_INIT_ROUND02:
    DB  16,  48, DIRECTION_RIGHT
ENEMY_PTN_ROUND02:
    DW $FFFF

; ■ラウンド3
PLAYER_INIT_ROUND03:
    DB  88, 112, DIRECTION_UP
ENEMY_PTN_ROUND03:
    DW $0000
    DB CHRNO_ENEMY4,  40, 120, DIRECTION_UP, $00, $00
    DW $FFFF

; ■ラウンド4
PLAYER_INIT_ROUND04:
    DB 152, 48, DIRECTION_UP
ENEMY_PTN_ROUND04:
    DW $0000
    DB CHRNO_ENEMY4,  40,  48, DIRECTION_UP, $00, $00
    DW $0000
    DB CHRNO_ENEMY4,  40, 128, DIRECTION_RIGHT, $00, $00
    DW $FFFF

; ■ラウンド5
PLAYER_INIT_ROUND05:
    DB  40, 32, DIRECTION_DOWN
ENEMY_PTN_ROUND05:
    DW 60*10
    DB CHRNO_ENEMY4,  80,  80, DIRECTION_DOWN, $00, $00
    DW 60*20
    DB CHRNO_ENEMY4,  80, 176, DIRECTION_DOWN, $00, $00
    DW $FFFF

; ■ラウンド6
PLAYER_INIT_ROUND06:
    DB 104,  80, DIRECTION_UP
ENEMY_PTN_ROUND06:
    DW $0000
    DB CHRNO_ENEMY4,  56, 168, DIRECTION_RIGHT, $00, $00
    DW $0000
    DB CHRNO_ENEMY4, 120, 168, DIRECTION_LEFT, $00, $00
    DW $FFFF

; ■ラウンド7
PLAYER_INIT_ROUND07:
    DB 120,  48, DIRECTION_UP
ENEMY_PTN_ROUND07:
    DW $0258
    DB CHRNO_ENEMY1,  48,  56, DIRECTION_DOWNRIGHT, $00, $00
    DW $04B0
    DB CHRNO_ENEMY1, 120, 192, DIRECTION_UPLEFT, $00, $00
    DW $FFFF

; ■ラウンド8
PLAYER_INIT_ROUND08:
    DB  88, 208, DIRECTION_LEFT
ENEMY_PTN_ROUND08:
    DW $0000
    DB CHRNO_ENEMY2,   8, 132, DIRECTION_RIGHT, $00, $00
    DW $0258
    DB CHRNO_ENEMY2,  80, 112, DIRECTION_LEFT, $01, $00
    DW $04B0
    DB CHRNO_ENEMY2, 136, 132, DIRECTION_RIGHT, $00, $00
    DW $FFFF

; ■ラウンド9
PLAYER_INIT_ROUND09:
    DB  88, 128, DIRECTION_DOWN
ENEMY_PTN_ROUND09:
    DW $0708
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $00, $00
    DW $0960
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $01, $00
    DW $0BB8
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $00, $00

; ■ラウンド10
PLAYER_INIT_ROUND10:
    DB  88,  48, DIRECTION_UP
ENEMY_PTN_ROUND10:
    DW $0960
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $00, $00
    DW $0A14
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $01, $00
    DW $0ACB
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $00, $00
    DW $0B7C
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $01, $00
    DW $0C30
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $00, $00
    DW $0CE4
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $01, $00

; ■ラウンド11
PLAYER_INIT_ROUND11:
    DB  88, 128, DIRECTION_UP
ENEMY_PTN_ROUND11:
    DW $0960
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $01, $00
    DW $0BB8
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $00, $00
    DW $0D20
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $01, $00

; ■ラウンド12
PLAYER_INIT_ROUND12:
    DB  88,  16, DIRECTION_RIGHT
ENEMY_PTN_ROUND12:
    DW $0708
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $00, $00
    DW $0708
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $01, $00
    DW $0708
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $00, $00
    DW $0708
    DB CHRNO_ENEMY2, $FF, $FF, DIRECTION_RANDOM, $01, $00

; ■ラウンド13
PLAYER_INIT_ROUND13:
    DB  80, 120, DIRECTION_UP
ENEMY_PTN_ROUND13:
    DW $04B0
    DB CHRNO_ENEMY3, 80, 120, DIRECTION_UP, $00, $00

; ■ラウンド14
PLAYER_INIT_ROUND14:
    DB  40,  48, DIRECTION_RIGHT
ENEMY_PTN_ROUND14:
    DW $0258
    DB CHRNO_ENEMY3, 40, 32, DIRECTION_RIGHT, $00, $00
    DW $04B0
    DB CHRNO_ENEMY3, 40, 32, DIRECTION_LEFT, $00, $00

; ■ラウンド15
PLAYER_INIT_ROUND15:
    DB  24,  48, DIRECTION_RIGHT
ENEMY_PTN_ROUND15:
    DW $04B0
    DB CHRNO_ENEMY3, $FF, $FF, DIRECTION_RANDOM, $00, $00

; ■ラウンド16
PLAYER_INIT_ROUND16:
    DB 160,  24, DIRECTION_UP
ENEMY_PTN_ROUND16:
    DW $FFFF

; ■タイムアウト時のテキ
ENEMY_TIMEOUT:
    DW $0000                        ; ダミー
    DB CHRNO_ENEMY3, $FF, $FF, $FF, $00, $00
