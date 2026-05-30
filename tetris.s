BEGIN       JSR    BORDER
            LDX    #$0702
            LDD    #$0200
            STX    BLKX
            STD    BLKN
            JSR    PUTBLK
SET         LDY    #$4000
BACK        LEAY   -1,Y
            BEQ    FALL
            JSR    INCH
            BEQ    BACK
            CMPA   #$09
            BNE    N1
            LDA    #$01
            JSR    MOVBLK
            BRA    BACK
N1          CMPA   #$08
            BNE    N2
            LDA    #$FF
            JSR    MOVBLK
            BRA    BACK
N2          CMPA   #$20
            BNE    N3
            JSR    ROTBLK
            BRA    BACK
N3          CMPA   #$03
            BEQ    HOME
            BRA    BACK
FALL        CLRA
            JSR    MOVBLK
            BRA    SET
HOME        RTS

            ;; GLOBAL VARIABLES
            ;; AND EQUATES
            ;;
BLKX        RMB    1
BLKY        RMB    1
BLKN        RMB    1
BLKR        RMB    1

INCH        EQU    $8006

            ;; PUTCHR
            ;;
            ;; PRINT A CHAR TO SCREEN
            ;; IN: X-XCOORD:YCOORD
            ;;       (0-31) (0-23)
            ;;     A-CHAR TO BE PUT
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
            ADDD   SCRBASE
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

SCRBASE     FDB    $0C00

CHTABLE     FDB    $0000,$0000,$0000,$0000
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
            FDB    $003C,$2424,$2424,$243C
            FDB    $0004,$0404,$0404,$0404
            FDB    $003C,$0404,$3C20,$203C
            FDB    $003C,$0404,$3C04,$043C
            FDB    $0024,$2424,$3C04,$0404
            FDB    $003C,$2020,$3C04,$043C
            FDB    $003C,$2020,$3C24,$243C
            FDB    $003C,$2424,$2404,$0404
            FDB    $003C,$2424,$3C24,$243C
            FDB    $003C,$2424,$3C04,$043C

            ;; PRSCOR
            ;;
            ;; PRINT A NUMBER TO SCREEN
            ;; IN: X-XCOORD:YCOORD
            ;;       (0-28) (0-23)
            ;;     D-NUMBER IN BCD
            ;;
PRSCOR      PSHS   X,Y,D
            STD    TMP1
            LSRA
            LSRA
            LSRA
            LSRA
            ADDA   #$14
            JSR    PUTCHR
            LEAX   $0100,X
            LDA    TMP1
            ANDA   #$0F
            ADDA   #$14
            JSR    PUTCHR
            LEAX   $0100,X
            LDA    TMP1+1
            LSRA
            LSRA
            LSRA
            LSRA
            ADDA   #$14
            JSR    PUTCHR
            LEAX   $0100,X
            LDA    TMP1+1
            ANDA   #$0F
            ADDA   #$14
            JSR    PUTCHR
            PULS   X,Y,D
            RTS

TMP1        RMB    2

            ;; PUTBLK
            ;;
            ;; PUT A BLOCK TO SCREEN
            ;; IN: X-XCOORD:YCOORD
            ;;       (0-31) (0-23)
            ;;     A-BLOCK TO PUT (0-6)
            ;;     B-ROTATION (0-3)
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
            LEAY   D,Y      ; START OF DATA NOW IN Y
B1          LDA    TMP2
            ADDA   ,Y+
            LDB    TMP2+1
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

BLKTBL      FDB    $0000,$0500,$0104,$FF00,$06FF,$0103
            FDB    $0000,$0500,$0104,$FF00,$06FF,$0103
            FDB    $0000,$0500,$0104,$FF00,$06FF,$0103
            FDB    $0000,$0500,$0104,$FF00,$06FF,$0103
            FDB    $0000,$0701,$0002,$0200,$0E00,$FF0B
            FDB    $0000,$08FF,$000D,$00FF,$0100,$FE0B
            FDB    $0000,$09FF,$0002,$FE00,$0D00,$010C
            FDB    $0000,$0A01,$000E,$0001,$0100,$020C
            FDB    $0000,$0A01,$0002,$0200,$0E00,$010C
            FDB    $0000,$0701,$000E,$00FF,$0100,$FE0B
            FDB    $0000,$08FF,$0002,$FE00,$0D00,$FF0B
            FDB    $0000,$0900,$0101,$0002,$0CFF,$000D
            FDB    $0000,$0800,$FF0A,$01FF,$0EFF,$000D
            FDB    $0000,$0900,$010C,$FF00,$07FF,$FF0B
            FDB    $0000,$0800,$FF0A,$01FF,$0EFF,$000D
            FDB    $0000,$0900,$010C,$FF00,$07FF,$FF0B
            FDB    $0000,$09FF,$000D,$0001,$0701,$010E
            FDB    $0000,$0A01,$0008,$01FF,$0B00,$010C
            FDB    $0000,$09FF,$000D,$0001,$0701,$010E
            FDB    $0000,$0A01,$0008,$01FF,$0B00,$010C
            FDB    $0000,$0F00,$FF0B,$0100,$0EFF,$000D
            FDB    $0000,$1200,$FF0B,$0001,$0CFF,$000D
            FDB    $0000,$1000,$010C,$0100,$0EFF,$000D
            FDB    $0000,$1100,$010C,$00FF,$0B01,$000E
            FDB    $0000,$0201,$0002,$0200,$0EFF,$000D
            FDB    $0000,$0100,$0101,$0002,$0C00,$FF0B
            FDB    $0000,$0201,$0002,$0200,$0EFF,$000D
            FDB    $0000,$0100,$0101,$0002,$0C00,$FF0B

            ;; CLRBLK
            ;;
            ;; BLANK A BLOCK FROM SCREEN
            ;; IN: X-XCOORD:YCOORD
            ;;       (0-31) (0-23)
            ;;     A-BLOCK
            ;;     B-ROTATION
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
            ;; MOVE THE CURRENT BLOCK
            ;; ONE CHAR POSITION
            ;; IN: A-DIRECTION
            ;;       0-DOWN,  1-RIGHT
            ;;               FF-LEFT
            ;;
MOVBLK      PSHS   X,B
            PSHS   A        ; SAVE DIR
            LDX    BLKX
            LDD    BLKN
            JSR    CLRBLK
            PULS   A        ; GET DIR BACK
            TSTA
            BEQ    DOWN
            ADDA   BLKX
            STA    BLKX
            BRA    PUT
DOWN        INC    BLKY
PUT         LDX    BLKX
            LDD    BLKN
            JSR    PUTBLK
            PULS   X,B
            RTS

            ;; ROTBLK
            ;;
            ;; TWIST CURRENT BLOCK ONE
            ;; STEP ANTI-CLOCKWISE
            ;; IN: NONE
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
            ;; DRAW BORDER ROUND AREA
            ;; IN: NONE
            ;;
BORDER      PSHS   X,Y,D
            LDX    SCRBASE
            LEAX   $0101,X
            LDY    #BDTOP
            JSR    PUTBDR
            LEAX   12,X
            JSR    PUTBDR
            LDX    SCRBASE
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
            ;; PUT A BORDER BLOCK TO THE
            ;; SCREEN
            ;; IN: X-DESTINATION ADDRESS
            ;;     Y-SOURCE ADDRESS
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
