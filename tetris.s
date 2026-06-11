            ORG    $7000

BEGIN       JSR    GCLS
            JSR    BORDER
            JSR    GMODE
GAME0       JSR    AWAITKEY
            JSR    PLAY
            JMP    GAME0

            ;; Locations of PIA and SAM registers:
VDGPIA      EQU    $FF22
SAMV0C      EQU    $FFC0
SAMV0S      EQU    $FFC1
SAMV1C      EQU    $FFC2
SAMV1S      EQU    $FFC3
SAMV2C      EQU    $FFC4
SAMV2S      EQU    $FFC5
SAMF0C      EQU    $FFC6
SAMF0S      EQU    $FFC7
SAMF1C      EQU    $FFC8
SAMF1S      EQU    $FFC9
SAMF2C      EQU    $FFCA
SAMF2S      EQU    $FFCB
SAMF3C      EQU    $FFCC
SAMF3S      EQU    $FFCD
SAMF4C      EQU    $FFCE
SAMF4S      EQU    $FFCF
SAMF5C      EQU    $FFD0
SAMF5S      EQU    $FFD1
SAMF6C      EQU    $FFD2
SAMF6S      EQU    $FFD3

            ;; Address of top-left of display memory:
SCRBASE     EQU    $0C00

            ;; RND8
            ;;
            ;; Return pseudo-random 8-bit value in A.
            ;;
            ;; "Almost certainly nicked from Dragon User"
            ;; https://www.6809.org.uk/dragon/asm/rnd.s
            ;;
RND8        LDA    RND8HIB
            RORA
            EORA   RND8HIB
            RORA
            RORA
            EORA   RND8HIB
            RORA
            EORA   RND8LOB
            RORA
            RORA
            ANDA   #$01
            ASL    RND8LOB
            ROL    RND8HIB
            ADDA   RND8LOB
            STA    RND8LOB
            RTS

RND8HIB     FCB    $55
RND8LOB     FCB    $33

            ;; GMODE
            ;;
            ;; Set graphics mode to PMODE 4.
            ;;
            ;; Adapted from p.169ff of "Inside the Dragon".
            ;;
GMODE       LDA    VDGPIA
            ANDA   #$07
            ORA    #$F0
            STA    VDGPIA
            STA    SAMV0C
            STA    SAMV1S
            STA    SAMV2S
            ;; SCRNBASE of $0C00 is 6 * $0200; 6 is 0000110
            STA    SAMF0C
            STA    SAMF1S
            STA    SAMF2S
            STA    SAMF3C
            STA    SAMF4C
            STA    SAMF5C
            STA    SAMF6C
            RTS

            ;; GCLS
            ;;
            ;; Clear graphics screen.
            ;;
GCLS        LDX    #SCRBASE
            LDY    #6144
GCLS0       CLR    ,X+
            LEAY   -1,Y
            BNE    GCLS0
            RTS

            ;; Global variables and equates:
BLKX        RMB    1
BLKY        RMB    1
BLKN        RMB    1
BLKR        RMB    1
NXTBLKN     RMB    1
NXTBLKR     RMB    1
MATRIX      RMB    42
SCORE       RMB    2

INCH        EQU    $8006

            ;; PUTCHR
            ;;
            ;; Print a char to screen.
            ;;
            ;; In: X-xcoord:ycoord
            ;;       (0-31) (0-23)
            ;;     A-char to be put
            ;;
PUTCHR      PSHS   X,Y,D
            STX    XCRD
            ASLA
            ASLA
            ASLA
            TFR    A,B
            LDX    #CHTABLE
            ABX
            LDA    YCRD
            LDB    XCRD
            CMPA   #$17
            BHI    OUT1
            CMPB   #$1F
            BHI    OUT1
            ADDD   #SCRBASE
            TFR    D,Y
            LDB    #$08
B0          LDA    ,X+
            STA    ,Y
            LEAY   $20,Y
            DECB
            BNE    B0
OUT1        PULS   X,Y,D
            RTS

XCRD        RMB    1
YCRD        RMB    1

            ;; Display coordinates of "next block", (18, 5):
NXDPY       EQU    $1205

            ;; Table of character graphics.  Each character takes 8
            ;; bytes, so one line of source code.
            ;;
            ;; Char 0: blank (full black)
CHTABLE     FDB    $0000,$0000,$0000,$0000 ; full black

            ;; Chars 1 to 19 (incl): white with different combinations
            ;; of edges and corners having black stripe one pixel in
            ;; from edge.
            FDB    $BDBD,$BDBD,$BDBD,$BDBD
            FDB    $FF00,$FFFF,$FFFF,$00FF
            FDB    $BFBF,$BFBF,$BFBF,$80FF
            FDB    $FDFD,$FDFD,$FDFD,$01FF
            FDB    $FF01,$FDFD,$FDFD,$FDFD
            FDB    $FF80,$BFBF,$BFBF,$BFBF
            FDB    $BDBC,$BFBF,$BFBF,$80FF
            FDB    $BD3D,$FDFD,$FDFD,$01FF
            FDB    $FF01,$FDFD,$FDFD,$3DBD
            FDB    $FF80,$BFBF,$BFBF,$BCBD
            FDB    $FF81,$BDBD,$BDBD,$BDBD
            FDB    $BDBD,$BDBD,$BDBD,$81FF
            FDB    $FF80,$BFBF,$BFBF,$80FF
            FDB    $FF01,$FDFD,$FDFD,$01FF
            FDB    $BD3C,$FFFF,$FFFF,$00FF
            FDB    $FF00,$FFFF,$FFFF,$3CBD
            FDB    $BDBC,$BFBF,$BFBF,$BCBD
            FDB    $BD3D,$FDFD,$FDFD,$3DBD
            FDB    $FFFF,$FFFF,$FFFF,$FFFF

            ;; Char 20: block once set in position.
            FDB    $FF81,$BDBD,$BDBD,$81FF

            ;; Chars 21 to 30 (incl): decimal digits 0 to 9
            FDB    $0018,$2424,$2424,$2418
            FDB    $0008,$1808,$0808,$081C
            FDB    $001C,$2202,$1C20,$203E
            FDB    $001C,$2202,$0C02,$221C
            FDB    $000C,$1424,$3E04,$0404
            FDB    $003E,$203C,$0202,$221C
            FDB    $001C,$2220,$3C22,$221C
            FDB    $003E,$0204,$0810,$2020
            FDB    $0038,$4444,$3844,$4438
            FDB    $0038,$4444,$3C04,$4438

            ;; PRSCOR
            ;;
            ;; Print a decimal number to the screen.
            ;;
            ;; In: X-xcoord:ycoord
            ;;       (0-28) (0-23)
            ;;     D-number in BCD
            ;;
PRSCOR      PSHS   X,Y,D
            STD    TMP1
            LSRA
            LSRA
            LSRA
            LSRA
            ADDA   #$15
            JSR    PUTCHR
            LEAX   $0100,X
            LDA    TMP1
            ANDA   #$0F
            ADDA   #$15
            JSR    PUTCHR
            LEAX   $0100,X
            LDA    TMP1+1
            LSRA
            LSRA
            LSRA
            LSRA
            ADDA   #$15
            JSR    PUTCHR
            LEAX   $0100,X
            LDA    TMP1+1
            ANDA   #$0F
            ADDA   #$15
            JSR    PUTCHR
            PULS   X,Y,D
            RTS

TMP1        RMB    2

            ;; PUTBLK
            ;;
            ;; Put a block to screen.
            ;;
            ;; In: X-xcoord:ycoord
            ;;       (0-31) (0-23)
            ;;     A-block to put (0-6)
            ;;     B-rotation (0-3)
            ;;
PUTBLK      PSHS   X,Y,D
            STD    TMP1
            STX    TMP2
            LDB    #$04
            STB    COUNT
            LDB    #$30
            MUL
            TFR    D,Y
            LDA    TMP1+1
            LDB    #$0C
            MUL
            ADDD   #BLKTBL
            LEAY   D,Y      ; Start of data now in Y
B1          LDD    TMP2
            ADDA   ,Y+
            ADDB   ,Y+
            TFR    D,X
            LDA    ,Y+
            JSR    PUTCHR
            DEC    COUNT
            BNE    B1
            PULS   X,Y,D
            RTS

TMP2        RMB    2
COUNT       RMB    1

            ;; Block data is organised firstly by piece type.  Within
            ;; each piece type, there are four chunks of data, one per
            ;; rotation.  Within each piece-with-rotation chunk, there
            ;; are four records, one per cell making up the piece, of
            ;; three bytes: (x offset, y offset, character).
            ;;
            ;; Block 0:
BLKTBL      FDB    $0000,$0500,$0104,$FF00,$06FF,$0103
            FDB    $0000,$0500,$0104,$FF00,$06FF,$0103
            FDB    $0000,$0500,$0104,$FF00,$06FF,$0103
            FDB    $0000,$0500,$0104,$FF00,$06FF,$0103
            ;; Block 1:
            FDB    $0000,$0701,$0002,$0200,$0E00,$FF0B
            FDB    $0000,$08FF,$000D,$00FF,$0100,$FE0B
            FDB    $0000,$09FF,$0002,$FE00,$0D00,$010C
            FDB    $0000,$0A01,$000E,$0001,$0100,$020C
            ;; Block 2:
            FDB    $0000,$0A01,$0002,$0200,$0E00,$010C
            FDB    $0000,$0701,$000E,$00FF,$0100,$FE0B
            FDB    $0000,$08FF,$0002,$FE00,$0D00,$FF0B
            FDB    $0000,$0900,$0101,$0002,$0CFF,$000D
            ;; Block 3:
            FDB    $0000,$0800,$FF0A,$01FF,$0EFF,$000D
            FDB    $0000,$0900,$010C,$FF00,$07FF,$FF0B
            FDB    $0000,$0800,$FF0A,$01FF,$0EFF,$000D
            FDB    $0000,$0900,$010C,$FF00,$07FF,$FF0B
            ;; Blocm 4:
            FDB    $0000,$09FF,$000D,$0001,$0701,$010E
            FDB    $0000,$0A01,$0008,$01FF,$0B00,$010C
            FDB    $0000,$09FF,$000D,$0001,$0701,$010E
            FDB    $0000,$0A01,$0008,$01FF,$0B00,$010C
            ;; Block 5:
            FDB    $0000,$0F00,$FF0B,$0100,$0EFF,$000D
            FDB    $0000,$1200,$FF0B,$0001,$0CFF,$000D
            FDB    $0000,$1000,$010C,$0100,$0EFF,$000D
            FDB    $0000,$1100,$010C,$00FF,$0B01,$000E
            ;; Block 6:
            FDB    $0000,$0201,$0002,$0200,$0EFF,$000D
            FDB    $0000,$0100,$0101,$0002,$0C00,$FF0B
            FDB    $0000,$0201,$0002,$0200,$0EFF,$000D
            FDB    $0000,$0100,$0101,$0002,$0C00,$FF0B

            ;; CLRBLK
            ;;
            ;; Blank a block from the screen.
            ;;
            ;; In: X-xcoord:ycoord
            ;;       (0-31) (0-23)
            ;;     A-block
            ;;     B-rotation
            ;;
CLRBLK      PSHS   X,Y,D
            STD    TMP1
            STX    TMP2
            LDB    #$04
            STB    COUNT
            LDB    #$30
            MUL
            TFR    D,Y
            LDA    TMP1+1
            LDB    #$0C
            MUL
            ADDD   #BLKTBL
            LEAY   D,Y
B2          LDA    TMP2
            ADDA   ,Y+
            LDB    TMP2+1
            ADDB   ,Y++
            TFR    D,X
            CLRA
            JSR    PUTCHR
            DEC    COUNT
            BNE    B2
            PULS   X,Y,D
            RTS

            ;; MOVBLK
            ;;
            ;; Move the current block one char position.
            ;;
            ;; In: A-direction
            ;;       0-down,  1-right
            ;;               FF-left
            ;;
MOVBLK      PSHS   X,B
            PSHS   A        ; Save dir
            LDX    BLKX
            LDD    BLKN
            JSR    CLRBLK
            PULS   A        ; Get dir back
            TSTA
            BEQ    DWN
            ADDA   BLKX
            STA    BLKX
            BRA    PUT
DWN         INC    BLKY
PUT         LDX    BLKX
            LDD    BLKN
            JSR    PUTBLK
            PULS   X,B
            RTS

            ;; ROTBLK
            ;;
            ;; Twist current block one step anti-clockwise.
            ;;
ROTBLK      PSHS   X,D
            LDX    BLKX
            LDD    BLKN
            JSR    CLRBLK
            LDB    BLKR
            INCB
            ANDB   #$03
            STB    BLKR
            JSR    PUTBLK
            PULS   X,D
            RTS

            ;; BORDER
            ;;
            ;; Draw border round play area.
            ;;
BORDER      PSHS   X,Y,D
            LDX    #SCRBASE
            LEAX   $0101,X
            LDY    #BDTOP
            JSR    PUTBDR
            LEAX   12,X
            JSR    PUTBDR
            LDX    #SCRBASE
            LEAX   $0301,X
            LDY    #BDVRT
            LDA    #$09
B3          JSR    PUTBDR
            LEAX   12,X
            JSR    PUTBDR
            LEAX   512-12,X
            DECA
            BNE    B3
            LDY    #BDLC
            JSR    PUTBDR
            LEAX   12,X
            LDY    #BDRC
            JSR    PUTBDR
            LEAX   -10,X
            LDY    #BDHRZ
            LDA    #$05
B4          JSR    PUTBDR
            LEAX   2,X
            DECA
            BNE    B4
            PULS   X,Y,D
            RTS

            ;; PUTBDR
            ;;
            ;; Put a border block to the screen.
            ;;
            ;; In: X-destination address
            ;;     Y-source address
            ;;
PUTBDR      PSHS   X,Y,D
            LDA    #$10
            STA    COUNT
B5          LDD    ,Y++
            STD    ,X
            LEAX   $20,X
            DEC    COUNT
            BNE    B5
            PULS   X,Y,D
            RTS

BDTOP       FDB    $0000,$73CE,$67E6,$4E72,$0C30,$0C30,$4E72,$6726
            FDB    $338C,$31CC,$64E6,$4E72,$1C38,$381C,$718E,$73CE

BDVRT       FDB    $73CE,$738E,$399C,$381C,$1C38,$4E72,$6726,$338C
            FDB    $31CC,$64E6,$4E72,$1C38,$381C,$399C,$71CE,$73CE

BDLC        FDB    $73CE,$718F,$3807,$3803,$1C60,$1C70,$0E71,$0E03
            FDB    $0E03,$2EC1,$6EF0,$6EFC,$7E3F,$7C0F,$3803,$0000

BDRC        FDB    $73CE,$F18E,$E01C,$C01C,$0638,$0E38,$8E70,$C070
            FDB    $C000,$83F8,$0FFC,$3FFE,$FC0E,$F07E,$C03C,$0000

BDHRZ       FDB    $0000,$C663,$F3CF,$F99F,$3C3C,$0E70,$84E3,$E1C7
            FDB    $E387,$C721,$0E70,$3C3C,$F99F,$F3CF,$C663,$0000

            ;; RDMTRX
            ;;
            ;; Read one bit from play area matrix.
            ;;
            ;; In: X-xcoord:ycoord
            ;;
            ;; Out: CC zero bit
            ;;      0-mtrx bit set
            ;;      1-mtrx bit clear
            ;;
RDMTRX      PSHS   X,Y,D
            STX    XCRD
            LDA    YCRD
            ASLA
            STA    TMP1
            LDA    XCRD
            SUBA   #$03
            LSRA
            LSRA
            LSRA
            ADDA   TMP1
            LDX    #MATRIX
            LEAX   A,X      ; X now holds address with bit in
            LDA    XCRD
            SUBA   #$03
            ANDA   #$07
            LDY    #MASKP
            LDB    A,Y
            PSHS   B
            LDA    ,X
            ANDA   ,S+      ; Set/clear zero bit as needed
            PULS   X,Y,D    ; Does not affect zero bit
            RTS

MASKP       FDB    $8040,$2010,$0804,$0201

            ;; WRMTRX
            ;;
            ;; Write one bit to play area matrix.
            ;;
            ;; In: X-xcoord:ycoord
            ;;     A-bit to write (0/1)
            ;;
WRMTRX      PSHS   X,Y,D
            STX    XCRD
            STA    TMP1
            LDA    XCRD
            SUBA   #$03
            STA    XCRD
            LDA    YCRD
            ASLA
            STA    TMP2
            LDA    XCRD
            LSRA
            LSRA
            LSRA
            ADDA   TMP2
            LDX    #MATRIX
            LEAX   A,X      ; X now holds address
            TST    TMP1
            BNE    SETIT
            LDA    XCRD
            ANDA   #$07
            LDY    #MASKN
            LDA    A,Y
            LDB    ,X
            PSHS   B
            ANDA   ,S+
            STA    ,X
            PULS   X,Y,D
            RTS
SETIT       LDA    XCRD
            ANDA   #$07
            LDY    #MASKP
            LDA    A,Y
            LDB    ,X
            PSHS   B
            ORA    ,S+
            STA    ,X
            PULS   X,Y,D
            RTS

MASKN       FDB    $7FBF,$DFEF,$F7FB,$FDFE

            ;; CHKCLR
            ;;
            ;; Check to see if a block detailed would impinge on a
            ;; previous block.
            ;;
            ;; In: X-xcoord:ycoord
            ;;     A-block number
            ;;     B-rotation
            ;;
            ;; Out: CC zero bit
            ;;      0-would impinge
            ;;      1-would not impinge
            ;;
CHKCLR      PSHS   X,Y,D
            STD    TMP1
            STX    TMP2
            LDB    #$04
            STB    COUNT
            LDB    #$30
            MUL
            TFR    D,Y
            LDA    TMP1+1
            LDB    #$0C
            MUL
            ADDD   #BLKTBL
            LEAY   D,Y      ; Start of data now in Y
B6          LDA    TMP2
            ADDA   ,Y+
            LDB    TMP2+1
            ADDB   ,Y++     ; Skip over char data byte
            TFR    D,X
            JSR    RDMTRX
            BNE    OUT2     ; Return with Z clear if impingement
            DEC    COUNT
            BNE    B6       ; Fails "BNE" if zero set, and this
OUT2        PULS   X,Y,D    ; is also what is wanted for no
            RTS             ; impingement

            ;; CHKIN
            ;;
            ;; Check to see if a block detailed is all inside the
            ;; playing area.
            ;;
            ;; In: X-xcoord:ycoord
            ;;     A-block number
            ;;     B-rotation
            ;;
            ;; Out: CC zero bit
            ;;      0-some protrudes
            ;;      1-all inside area
            ;;
CHKIN       PSHS   X,Y,D
            STD    TMP1
            STX    TMP2
            LDB    #$04
            STB    COUNT
            LDB    #$30
            MUL
            TFR    D,Y
            LDA    TMP1+1
            LDB    #$0C
            MUL
            ADDD   #BLKTBL
            LEAY   D,Y      ; Start of data now in Y
B7          LDA    TMP2
            ADDA   ,Y+
            LDB    TMP2+1
            ADDB   ,Y++     ; Skip over char data byte
            CMPA   #$03
            BLO    PROUT
            CMPA   #$0C
            BHI    PROUT
            CMPB   #$14
            BHI    PROUT
            DEC    COUNT
            BNE    B7
            PULS   X,Y,D    ; Gets here if all inside, and the
            RTS             ; "DEC" instruction will have set Z
PROUT       ANDCC  #$FB     ; Clear Z to indicate protrusion
            PULS   X,Y,D
            RTS

            ;; CLMTRX
            ;;
            ;; Clear entire play matrix.
            ;;
CLMTRX      PSHS   X
            LDX    #MATRIX
B8          CLR    ,X+
            CMPX   #MATRIX+42
            BNE    B8
            PULS   X
            RTS

            ;; LEFT
            ;;
            ;; Check if OK to move the current block left one place,
            ;; then does so if possible.
            ;;
            ;; Out: CC zero bit
            ;;      0-could not move
            ;;      1-moved OK
            ;;
LEFT        PSHS   X,Y,D
            LDD    BLKX
            DECA
            TFR    D,X      ; Coords to test in X
            LDD    BLKN
            JSR    CHKIN
            BNE    OUT3
            JSR    CHKCLR
            BNE    OUT3
            LDA    #$FF
            JSR    MOVBLK
            CLR    TMP1     ; Sets Z
OUT3        PULS   X,Y,D
            RTS

            ;; RIGHT
            ;;
            ;; As for `LEFT` but move right not left.
            ;;
            ;; Out: CC zero bit
            ;;      0-could not move
            ;;      1-moved OK
            ;;
RIGHT       PSHS   X,Y,D
            LDD    BLKX
            INCA
            TFR    D,X      ; Coords to test
            LDD    BLKN
            JSR    CHKIN
            BNE    OUT4
            JSR    CHKCLR
            BNE    OUT4
            LDA    #$01
            JSR    MOVBLK
            CLR    TMP1     ; Sets Z
OUT4        PULS   X,Y,D
            RTS

            ;; DOWN
            ;;
            ;; As for `RIGHT` and `LEFT`, except move down.
            ;;
            ;; Out: CC zero bit
            ;;      0-could not move
            ;;      1-moved OK
            ;;
DOWN        PSHS   X,Y,D
            LDD    BLKX
            INCB
            TFR    D,X
            LDD    BLKN
            JSR    CHKIN
            BNE    OUT5
            JSR    CHKCLR
            BNE    OUT5
            CLRA
            JSR    MOVBLK
            CLR    TMP1
OUT5        PULS   X,Y,D
            RTS

            ;; TWIST
            ;;
            ;; Twist block one step if possible.
            ;;
            ;; Out: CC zero bit
            ;;      0-could not twist
            ;;      1-twisted OK
            ;;
TWIST       PSHS   X,Y,D
            LDX    BLKX
            LDD    BLKN
            INCB
            ANDB   #$03
            JSR    CHKIN
            BNE    OUT6
            JSR    CHKCLR
            BNE    OUT6
            JSR    ROTBLK
            CLR    TMP1
OUT6        PULS   X,Y,D
            RTS

            ;; LDMTRX
            ;;
            ;; Load current block data into play area matrix.
            ;;
LDMTRX      PSHS   X,Y,D
            LDA    BLKN
            LDB    #$30
            MUL
            TFR    D,Y
            LDA    BLKR
            LDB    #$0C
            MUL
            ADDD   #BLKTBL
            LEAY   D,Y      ; Start of data now in Y
            LDA    #$04
            STA    COUNT
B9          LDA    BLKX
            ADDA   ,Y+
            LDB    BLKY
            ADDB   ,Y++     ; Skip char data byte
            TFR    D,X
            LDA    #$01
            JSR    WRMTRX
            DEC    COUNT
            BNE    B9
            PULS   X,Y,D
            RTS

            ;; DROP
            ;;
            ;; Drop current block as far as it will go and alter
            ;; matrix accordingly.
            ;;
DROP        PSHS   X,Y,D
B10         JSR    DELAY
            JSR    DOWN
            BEQ    B10
            JSR    LDMTRX
            PULS   X,Y,D
            RTS

            ;; DELAY
            ;;
            ;; Provide a short delay.
            ;;
DELAY       PSHS   X
            LDX    #$0800
B11         LEAX   -1,X
            BNE    B11
            PULS   X
            RTS

            ;; GOBLK
            ;;
            ;; Take control of current block and complete its play.
            ;;
GOBLK       PSHS   X,Y,D
SET         LDY    FALLDY
B12         LEAY   -1,Y
            BEQ    FALL
            JSR    INCH
            BEQ    B12
            CMPA   #$09
            BNE    N1
            JSR    RIGHT
            BRA    B12
N1          CMPA   #$08
            BNE    N2
            JSR    LEFT
            BRA    B12
N2          CMPA   #$0A
            BNE    N3
            JSR    DROP
            BRA    OUT7
N3          CMPA   #$20
            BNE    B12
            JSR    TWIST
            BRA    B12
FALL        JSR    DOWN
            BEQ    SET
            JSR    LDMTRX
OUT7        JSR    FIXBLK
            PULS   X,Y,D
            RTS

FALLDY      FDB    $3000

            ;; FIXBLK
            ;;
            ;; Convert the current block into a display with all
            ;; "fixed" cells.
            ;;
FIXBLK      PSHS   X,Y,D
            LDB    #$04
            STB    COUNT
            LDA    BLKN
            LDB    #$30
            MUL
            TFR    D,Y
            LDA    BLKR
            LDB    #$0C
            MUL
            ADDD   #BLKTBL
            LEAY   D,Y      ; Start of data now in Y
FB1         LDA    BLKX
            ADDA   ,Y+
            LDB    BLKY
            ADDB   ,Y++
            TFR    D,X
            LDA    #20
            JSR    PUTCHR
            DEC    COUNT
            BNE    FB1
            PULS   X,Y,D
            RTS

            ;; CHSNEXT
            ;;
            ;; Choose the "next block".
            ;;
CHSNEXT     PSHS   A
            JSR    RND8
CN1         CMPA   #$06
            BLS    CN2
            SUBA   #$07
            BRA    CN1
CN2         STA    NXTBLKN
            JSR    RND8
            ANDA   #$03
            STA    NXTBLKR
            PULS   A,PC

            ;; ONEBLK
            ;;
            ;; Bring the "next block" into play, choose a random new
            ;; "next block", and play the now-current block.
            ;;
ONEBLK      PSHS   X,Y,D
            LDX    #NXDPY
            LDD    NXTBLKN
            JSR    CLRBLK
            STD    BLKN
            JSR    CHSNEXT
            LDD    NXTBLKN
            JSR    PUTBLK
            LDX    #$0702
            STX    BLKX
            LDD    BLKN
            JSR    CHKCLR
            BNE    GOHOME
            JSR    PUTBLK
            JSR    GOBLK
            PULS   X,Y,D
            RTS
GOHOME      LDX    #NXDPY
            LDD    NXTBLKN
            JSR    CLRBLK
            PULS   X,Y,D
            LEAS   2,S      ; If new block is over an old one,
            RTS             ; skip one PC and return

            ;; CLRALL
            ;;
            ;; Clear the play area display.
            ;;
CLRALL      PSHS   D,X
            LDX    #SCRBASE
            LEAX   3,X
            LDA    #(21 * 8)
CA0         LDB    #10
CA1         CLR    ,X+
            DECB
            BNE    CA1
            LEAX   22,X
            DECA
            BNE    CA0
            PULS   D,X
            RTS

            ;; CLRLIN
            ;;
            ;; Clear a line of the play area from the screen.
            ;;
            ;; In: A-line to clear
            ;;
CLRLIN      PSHS   X,Y,D
            LDB    #$03
            ADDD   #SCRBASE
            TFR    D,X
            STX    TMP1
            LDA    #$08
            STA    COUNT
B14         LDX    TMP1
            LDA    #$08
B15         LDB    #$0A
B16         LSL    ,X+
            DECB
            BNE    B16
            LEAX   22,X
            DECA
            BNE    B15
            JSR    DELAY
            JSR    DELAY
            JSR    DELAY
            DEC    COUNT
            BNE    B14
            PULS   X,Y,D
            RTS

            ;; LINDWN
            ;;
            ;; Move the play area down one line on screen.
            ;;
            ;; In: A-line which will be overwritten by the moving-down
            ;;       process
            ;;
LINDWN      PSHS   X,Y,D
            CMPA   #$01
            BEQ    OUT8
            LDB    #$E3
            ADDD   #SCRBASE
            STD    TMP2
            LDD    #SCRBASE
            ADDD   #$01E3
            STD    TMP1
            LDA    #$08
            PSHS   A
B17A        LDX    TMP2
B17         LDA    #$08
B18         LDB    #$05
B19         LDY    -32,X
            STY    ,X++
            DECB
            BNE    B19
            LEAX   -42,X
            DECA
            BNE    B18
            CMPX   TMP1
            BNE    B17
            JSR    DELAY
            DEC    ,S
            BNE    B17A
            LEAS   1,S      ; Discard counter
OUT8        PULS   X,Y,D
            RTS

            ;; CHKLIN
            ;;
            ;; Check play area for complete lines, and take
            ;; appropriate action if necessary.
            ;;
CHKLIN      PSHS   X,Y,D
            LDA    #$01
B20         LDX    #MATRIX
            LEAX   A,X
            LDX    A,X      ; Two data bytes in X
            CMPX   #$FFC0   ; Full line
            BEQ    FULL
N5          INCA
            CMPA   #$15
            BNE    B20
            PULS   X,Y,D
            RTS
FULL        JSR    CLRLIN
            JSR    LINDWN
            JSR    MTXDWN
            PSHS   A
            LDA    SCORE+1
            ADDA   #1
            DAA
            STA    SCORE+1
            LDA    SCORE
            ADCA   #0
            DAA
            STA    SCORE
            LDD    SCORE
            LDX    #$1001
            JSR    PRSCOR
            PULS   A
            BRA    N5

            ;; MTXDWN
            ;;
            ;; Move matrix down one line and clears top.
            ;;
            ;; In: A-line to move down to
            ;;
MTXDWN      PSHS   X,Y,D
            CMPA   #$01
            BEQ    OUT9
            LDX    #MATRIX
            ASLA
            LEAX   A,X
B21         LDD    ,--X
            STD    2,X
            CMPX   #MATRIX
            BNE    B21
            CLR    MATRIX
            CLR    MATRIX+1
OUT9        PULS   X,Y,D
            RTS

            ;; PLAY
            ;;
            ;; Play a complete game.
            ;;
PLAY        JSR    CLMTRX
            JSR    CLRALL
            LDD    #0
            STD    SCORE
            LDX    #$1001
            JSR    PRSCOR
            JSR    CHSNEXT
            LDX    #NXDPY
            LDD    NXTBLKN
            JSR    PUTBLK
BACK        JSR    ONEBLK
            JSR    CHKLIN
            BRA    BACK

            ;; AWAITKEY
            ;;
            ;; While waiting for a keypress, spin a "T" piece and
            ;; update the random number state.  When a keypress does
            ;; occur, erase the piece and return.
            ;;
AWAITKEY    LDX    #$1410
            LDA    #5
            LDB    AKROTN
            JSR    CLRBLK
            INCB
            ANDB   #$03
            STB    AKROTN
            JSR    PUTBLK
AK0         INC    RND8LOB
            BNE    AK1
            INC    RND8HIB
AK1         JSR    INCH
            BNE    AK2
            LDX    AKPHASE
            LEAX   -1,X
            STX    AKPHASE
            BNE    AK0
            LDX    #$1000
            STX    AKPHASE
            JMP    AWAITKEY
            ;; Ensure random state is not zero:
AK2         TST    RND8LOB
            BNE    AK3
            INC    RND8LOB
AK3         LDX    #$1410
            LDA    #5
            LDB    AKROTN
            JMP    CLRBLK

AKPHASE     FDB    $1000
AKROTN      FCB    $00
