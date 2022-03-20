SECTION rodata_user

; ■PCGパターンデータ
; &H0308〜
PCG_PTN_DATA:
    ; MAPCHIP 1
	DB $60, $ff, $df, $9f, $ff, $ff, $ff, $ff, $ff
	DB $61, $ff, $fb, $f9, $ff, $ff, $ff, $ff, $ff
	DB $62, $ff, $ff, $ff, $ff, $ff, $9f, $df, $ff
	DB $63, $ff, $ff, $ff, $ff, $ff, $f9, $fb, $ff
	DB $64, $ff, $df, $9f, $ff, $fc, $f8, $f0, $f0
	DB $65, $ff, $fb, $f9, $ff, $3f, $1f, $0f, $2f
	DB $66, $f0, $f0, $f9, $fc, $ff, $9f, $df, $ff
	DB $67, $4f, $af, $5f, $3f, $ff, $f9, $fb, $ff
	DB $68, $00, $ab, $92, $ee, $a2, $b3, $20, $20
	DB $69, $ff, $80, $9f, $80, $80, $ba, $a2, $b9
	DB $6A, $ff, $01, $f9, $01, $01, $af, $a5, $25
	DB $6B, $a2, $ba, $80, $87, $80, $9f, $80, $ff
	DB $6C, $a5, $a5, $01, $e1, $01, $f9, $01, $ff

    ; MAPCHIP 2
	DB $70, $7f, $ff, $f4, $ff, $f7, $f7, $f7, $f7
	DB $71, $fe, $ff, $2f, $ff, $ef, $ef, $ef, $ef
	DB $72, $f7, $f7, $f7, $f7, $ff, $f4, $ff, $7f
	DB $73, $ef, $ef, $ef, $ef, $ff, $2f, $ff, $fe
	DB $74, $7f, $ff, $f4, $ff, $f7, $f7, $f7, $f7
	DB $75, $fe, $ff, $2f, $ff, $ef, $ef, $ef, $ef
	DB $76, $f7, $f7, $f7, $f7, $ff, $f4, $ff, $7f
	DB $77, $ef, $ef, $ef, $ef, $ff, $2f, $ff, $fe
	DB $78, $00, $89, $d3, $4a, $10, $4a, $10, $00
	DB $79, $ff, $80, $9f, $80, $80, $ba, $a2, $b9
	DB $7A, $ff, $01, $f9, $01, $01, $af, $a5, $25
	DB $7B, $a2, $ba, $80, $87, $80, $9f, $80, $ff
	DB $7C, $a5, $a5, $01, $e1, $01, $f9, $01, $ff

    ; MAPCHIP 3
	DB $80, $f7, $f7, $f7, $17, $e8, $ef, $ef, $ef
	DB $81, $ef, $ef, $ef, $e8, $17, $f7, $f7, $f7
	DB $82, $ef, $ef, $ef, $e8, $17, $f7, $f7, $f7
	DB $83, $f7, $f7, $f7, $17, $e8, $ef, $ef, $ef
	DB $84, $f7, $f7, $f7, $17, $e8, $ef, $ef, $ef
	DB $85, $ef, $ef, $ef, $e8, $17, $f7, $f7, $f7
	DB $86, $ef, $ef, $ef, $e8, $17, $f7, $f7, $f7
	DB $87, $f7, $f7, $f7, $17, $e8, $ef, $ef, $ef
	DB $88, $00, $ee, $bb, $55, $aa, $00, $00, $00
	DB $89, $ff, $80, $9f, $80, $80, $ba, $a2, $b9
	DB $8A, $ff, $01, $f9, $01, $01, $af, $a5, $25
	DB $8B, $a2, $ba, $80, $87, $80, $9f, $80, $ff
	DB $8C, $a5, $a5, $01, $e1, $01, $f9, $01, $ff

    ; MAPCHIP 4
	DB $90, $ff, $ff, $ff, $ff, $f7, $fe, $ff, $fb
	DB $91, $ff, $ff, $ff, $ff, $ef, $7f, $ff, $df
	DB $92, $fb, $ff, $fe, $f7, $ff, $ff, $ff, $ff
	DB $93, $df, $ff, $7f, $ef, $ff, $ff, $ff, $ff
	DB $94, $ff, $ff, $ff, $ff, $f7, $fe, $ff, $fb
	DB $95, $ff, $ff, $ff, $ff, $ef, $7f, $ff, $df
	DB $96, $fb, $ff, $fe, $f7, $ff, $ff, $ff, $ff
	DB $97, $df, $ff, $7f, $ef, $ff, $ff, $ff, $ff
	DB $98, $00, $00, $c3, $00, $18, $00, $42, $00
	DB $99, $ff, $80, $9f, $80, $80, $ba, $a2, $b9
	DB $9A, $ff, $01, $f9, $01, $01, $af, $a5, $25
	DB $9B, $a2, $ba, $80, $87, $80, $9f, $80, $ff
	DB $9C, $a5, $a5, $01, $e1, $01, $f9, $01, $ff

    ; POWER GUAGE
	DB $AF, $00, $fe, $fe, $fe, $fe, $fe, $fe, $00
	DB $B0, $00, $fe, $fe, $fe, $fe, $fe, $fe, $00
	DB $B1, $00, $c4, $aa, $aa, $ca, $8a, $84, $00
	DB $B2, $00, $ae, $a8, $ae, $e8, $e8, $ae, $00
	DB $B3, $01, $c3, $a2, $a2, $c2, $a2, $a3, $01
	DB $B4, $80, $c0, $40, $40, $40, $40, $c0, $80

    ; PLAYER-LEFT
	DB $88, $24, $24, $66, $5a, $5a, $66, $24, $00

    ; TITLE PARTS
	DB $A0, $0f, $3e, $7c, $78, $f8, $f8, $f8, $f8
	DB $A1, $ff, $00, $00, $00, $00, $00, $00, $00
	DB $A2, $e0, $38, $1c, $0c, $0e, $0e, $0e, $0e
	DB $A3, $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f8
	DB $A4, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	DB $A5, $f8, $f8, $f8, $f8, $78, $7c, $3e, $0f
	DB $A6, $00, $00, $00, $00, $00, $00, $00, $ff
	DB $A7, $0e, $0e, $0e, $0e, $0c, $1c, $38, $e0
	DB $A8, $3c, $3c, $3c, $3c, $3c, $3c, $3c, $3c
	DB $A9, $0f, $3e, $7c, $78, $f8, $f8, $f8, $ff
	DB $AA, $e0, $38, $1c, $0c, $0e, $0e, $0e, $fe
	DB $AB, $ff, $00, $18, $3c, $3c, $18, $00, $00
	DB $AC, $0e, $0e, $0e, $0e, $0e, $06, $07, $03

    DB 0


; ■PCGカラーデータ
; &H2000〜、32byte
PCG_COLOR_DATA:
    DB $00, $00, $00, $00
    DB $F1, $F1, $F1, $F1
    DB $F1, $F1, $F1, $F1
    DB $41, $41, $D1, $D1
    DB $C1, $C1, $1E, $1E
    DB $31, $31, $91, $71
    DB $F1, $F1, $F1, $F1
    DB $F1, $F1, $F1, $F1
