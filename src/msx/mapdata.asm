; ====================================================================================================
; 定数エリア
; romに格納される
; ====================================================================================================
SECTION rodata_user

; ■ラウンド1
MAP_ROUND01:
    DB $55,$55,$55,$55
    DB $55,$57,$55,$55
    DB $00,$55,$55,$00
    DB $00,$66,$99,$00
    DB $00,$55,$55,$00
    DB $00,$66,$99,$00
    DB $00,$55,$55,$00
    DB $00,$66,$99,$00
    DB $00,$55,$55,$00
    DB $55,$55,$55,$55
    DB $55,$55,$55,$55
; ■ラウンド2
MAP_ROUND02:
    DB $01,$55,$54,$00
    DB $01,$55,$54,$00
    DB $00,$00,$1A,$40
    DB $00,$00,$1A,$40
    DB $00,$15,$94,$00
    DB $00,$19,$54,$00
    DB $01,$64,$00,$00
    DB $01,$94,$00,$00
    DB $01,$65,$97,$40
    DB $01,$55,$55,$40
    DB $00,$00,$00,$00
; ■ラウンド3
MAP_ROUND03:
    DB $00,$00,$00,$00
    DB $00,$00,$00,$00
    DB $00,$0A,$A0,$00
    DB $00,$55,$55,$00
    DB $0A,$59,$65,$A0
    DB $0A,$55,$D5,$A0
    DB $0A,$59,$65,$A0
    DB $01,$55,$55,$00
    DB $00,$0A,$A0,$00
    DB $00,$00,$00,$00
    DB $00,$00,$00,$00
; ■ラウンド4
MAP_ROUND04:
    DB $00,$00,$00,$00
    DB $16,$50,$00,$00
    DB $19,$A7,$A5,$00
    DB $16,$50,$1A,$54
    DB $01,$00,$05,$94
    DB $02,$00,$06,$64
    DB $02,$00,$05,$94
    DB $01,$00,$05,$54
    DB $15,$00,$00,$00
    DB $15,$00,$00,$00
    DB $15,$00,$00,$00
; ■ラウンド5
MAP_ROUND05:
    DB $00,$00,$00,$00
    DB $15,$01,$50,$00
    DB $1D,$01,$96,$90
    DB $15,$01,$50,$20
    DB $04,$00,$00,$54
    DB $04,$00,$00,$A8
    DB $15,$00,$00,$54
    DB $26,$00,$00,$10
    DB $19,$29,$64,$20
    DB $06,$50,$59,$A0
    DB $00,$00,$64,$00
; ■ラウンド6
MAP_ROUND06:
    DB $00,$00,$00,$00
    DB $01,$54,$00,$00
    DB $05,$99,$00,$00
    DB $16,$66,$40,$00
    DB $19,$99,$00,$00
    DB $15,$50,$0A,$14
    DB $19,$99,$0A,$1C
    DB $16,$66,$40,$00
    DB $05,$99,$00,$00
    DB $01,$54,$00,$00
    DB $00,$00,$00,$00
; ■ラウンド7
MAP_ROUND07:
    DB $00,$00,$00,$00
    DB $14,$54,$65,$94
    DB $54,$54,$55,$64
    DB $14,$64,$64,$10
    DB $00,$54,$54,$54
    DB $16,$52,$09,$64
    DB $15,$50,$04,$00
    DB $01,$61,$94,$00
    DB $19,$61,$94,$14
    DB $16,$41,$54,$1C
    DB $00,$00,$00,$00
; ■ラウンド8
MAP_ROUND08:
    DB $00,$00,$00,$00
    DB $0A,$58,$9A,$50
    DB $24,$00,$00,$24
    DB $18,$00,$00,$18
    DB $24,$00,$00,$24
    DB $0D,$69,$29,$50
    DB $24,$00,$00,$24
    DB $18,$00,$00,$18
    DB $24,$00,$00,$24
    DB $09,$A8,$A6,$90
    DB $00,$00,$00,$00
; ■ラウンド9
MAP_ROUND09:
    DB $00,$00,$00,$00
    DB $15,$41,$55,$54
    DB $17,$41,$6A,$54
    DB $15,$41,$6A,$54
    DB $00,$01,$55,$54
    DB $00,$06,$50,$00
    DB $15,$55,$40,$00
    DB $16,$A5,$41,$54
    DB $16,$A5,$41,$54
    DB $05,$55,$41,$54
    DB $00,$00,$00,$00
; ■ラウンド10
MAP_ROUND10:
    DB $00,$00,$00,$00
    DB $00,$00,$00,$00
    DB $09,$28,$28,$60
    DB $02,$10,$04,$80
    DB $00,$00,$00,$00
    DB $01,$41,$C2,$80
    DB $00,$00,$00,$00
    DB $02,$10,$04,$80
    DB $09,$28,$28,$60
    DB $00,$00,$00,$00
    DB $00,$00,$00,$00
; ■ラウンド11
MAP_ROUND11:
    DB $00,$00,$00,$00
    DB $29,$06,$41,$58
    DB $16,$09,$00,$9C
    DB $0A,$10,$22,$18
    DB $00,$00,$50,$00
    DB $24,$25,$40,$00
    DB $0A,$05,$10,$00
    DB $08,$08,$00,$48
    DB $00,$06,$81,$28
    DB $06,$81,$84,$98
    DB $00,$00,$00,$00
; ■ラウンド12
MAP_ROUND12:
    DB $00,$00,$00,$00
    DB $24,$28,$28,$18
    DB $08,$10,$04,$20
    DB $00,$00,$00,$00
    DB $01,$00,$00,$80
    DB $05,$41,$C2,$60
    DB $01,$00,$00,$80
    DB $00,$00,$00,$00
    DB $08,$10,$04,$20
    DB $24,$28,$28,$18
    DB $00,$00,$00,$00
; ■ラウンド13
MAP_ROUND13:
    DB $00,$00,$00,$00
    DB $00,$55,$55,$00
    DB $05,$99,$66,$50
    DB $16,$55,$55,$94
    DB $15,$41,$41,$54
    DB $19,$03,$40,$64
    DB $15,$41,$41,$54
    DB $16,$55,$55,$94
    DB $05,$99,$66,$50
    DB $00,$55,$55,$00
    DB $00,$00,$00,$00
; ■ラウンド14
MAP_ROUND14:
    DB $00,$00,$00,$00
    DB $05,$40,$15,$00
    DB $07,$45,$19,$00
    DB $05,$45,$16,$00
    DB $00,$00,$00,$00
    DB $00,$00,$02,$80
    DB $00,$00,$02,$80
    DB $05,$4A,$00,$00
    DB $06,$4A,$18,$00
    DB $05,$40,$24,$80
    DB $00,$00,$00,$00
; ■ラウンド15
MAP_ROUND15:
    DB $00,$00,$00,$00
    DB $34,$00,$01,$50
    DB $00,$01,$49,$94
    DB $05,$42,$85,$54
    DB $16,$62,$86,$64
    DB $15,$52,$81,$50
    DB $19,$91,$40,$00
    DB $05,$40,$00,$24
    DB $00,$00,$00,$00
    DB $14,$00,$00,$00
    DB $00,$00,$00,$00
; ■ラウンド16
MAP_ROUND16:
    DB $00,$00,$00,$00
    DB $15,$40,$29,$48
    DB $01,$40,$10,$28
    DB $01,$40,$20,$04
    DB $01,$55,$6C,$08
    DB $00,$01,$00,$00
    DB $00,$00,$00,$04
    DB $10,$00,$00,$98
    DB $18,$00,$00,$48
    DB $05,$92,$4A,$40
    DB $00,$00,$00,$00
