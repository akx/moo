DECLARE SUB pushstk (v!)
DECLARE FUNCTION popstk! (p!)
DECLARE FUNCTION getsv$ (s$)
DECLARE SUB setsv (s$, va$)
DECLARE FUNCTION getunt$ (vx!, vy!)
DECLARE FUNCTION choice! (s$, default!, tl!)
DECLARE FUNCTION getv2! (ss$)
DECLARE SUB setv (s$, va!)
DECLARE SUB dbg (s$)
DECLARE FUNCTION getv! (s$)
CLOSE

DIM SHARED x
DIM SHARED y

DIM SHARED trace AS INTEGER
trace = 0

IF COMMAND$ = "" THEN
  COLOR 15
  CLS
  PRINT "It really doesn't moo anything interesting.";
  COLOR 8
  PRINT "  [1.35] (C) AKX 2005 | www.theakx.tk"
  PRINT
  COLOR 7
  WHILE file$ = ""
    INPUT "Input file: ", file$
  WEND
  PRINT
  PRINT "Trace? (Y/N) "
  trace = choice("nyvx", 1, 5) - 1
ELSE
  file$ = COMMAND$
END IF

ON ERROR GOTO erro
RANDOMIZE TIMER


'CONST trace = 1

TYPE TPos
  x AS INTEGER
  y AS INTEGER
  x2 AS INTEGER
  y2 AS INTEGER
END TYPE

DIM SHARED script(50) AS STRING
DIM SHARED vars(25) AS SINGLE
DIM SHARED svars(25) AS STRING
DIM SHARED sreg AS STRING
DIM SHARED stack(256) AS SINGLE
DIM SHARED stacklen AS INTEGER
DIM SHARED cstack(30) AS TPos
DIM SHARED cstackl AS INTEGER
DIM SHARED reg AS SINGLE

e = 1
cstackl = 0

OPEN file$ FOR INPUT AS 1
  WHILE NOT EOF(1)
    IF e > 50 THEN
      PRINT "50 line limit reached while reading file."
      PRINT "Abort execution? (Y/N) "
      IF choice("ny", 1, 5) - 1 = 1 THEN
        CLOSE
        END
      END IF
      GOTO endred
      
    END IF

    LINE INPUT #1, script(e)
    e = e + 1
  WEND
endred:
CLOSE
nline = e

CLS


IF trace = 1 THEN
 SCREEN 12
 WIDTH 80, 60
 COLOR 13
 FOR y = 1 TO nline
  
   LOCATE y
   PRINT script(y)
 NEXT y

END IF


ox = 1
oy = 1
x = 1
y = 1
dx = 1
dy = 0
LOCATE 1
COLOR 7

WHILE ex = 0
  s = s + 1
  cop$ = MID$(script(y), x, 1)
  dbg "pos(" + STR$(x) + "," + STR$(y) + ") dlt(" + STR$(dx) + "," + STR$(dy) + ")"
  ox = x
  oy = y

  SELECT CASE cop$
    CASE "+", "x"' branch
      dbg "Branch:"

      op1 = getv(MID$(script(y), x + 1, 1))
      dbg "  Op 1 value: " + STR$(op1)
      operand$ = MID$(script(y), x + 2, 1)
      dbg "  Operand: " + operand$
     
      t = x + 3
      op2$ = getunt(x + 3, y)
     
      IF getv(op2$) = -666 THEN
        op2e = VAL(op2$)
      ELSE
        op2e = getv(op2$)
      END IF
      dbg "  Op 2: " + op2$ + " ( =" + STR$(op2e) + ")"
      th = 0

      SELECT CASE operand$
        CASE ">"
          IF op1 > op2e THEN th = 1
        CASE "<"
          IF op1 < op2e THEN th = 1
        CASE "="
          IF op1 = op2e THEN th = 1
        CASE "!"
          IF op1 <> op2e THEN th = 1
        CASE "{"
          IF op1 <= op2e THEN th = 1
        CASE "}"
          IF op1 >= op2e THEN th = 1
        CASE "&"
          IF (op1 AND op2e) THEN th = 1
        CASE "|"
          IF (op1 OR op2e) THEN th = 1
        CASE "^"
          IF (op1 XOR op2e) THEN th = 1
        CASE "#"
          IF (op1 EQV op2e) THEN th = 1
        CASE "%"
          IF (op1 IMP op2e) THEN th = 1
      END SELECT

      IF (cop$ = "+" AND th = 1) OR (cop$ = "x" AND th = 0) THEN
        dbg "   ** TRUE"
        IF dx = 1 THEN x = x + 4 + LEN(op2$)
        IF dy = 1 THEN y = y + 1
      ELSE
        dbg "   ** FALSE"
        IF dx = 1 THEN
          dbg "    Turning down"
          y = y + 1
          dx = 0
          dy = 1
        ELSEIF dy = 1 THEN
          dbg "    Turning left"
          x = x + 4 + LEN(op2$)
          dx = 1
          dy = 0
        END IF
      END IF
   
    CASE "(" '' pop to reg
      v = getv2(MID$(script(y), x + 1, 1))
      dbg "READ MEMORY:" + STR$(v)

      reg = v
      IF dx = 1 THEN x = x + 2
      IF dy = 1 THEN y = y + 1
   
    CASE ")" '' push to mem
      setv MID$(script(y), x + 1, 1), reg
      dbg "MEMORIZE:" + STR$(v)
    
      IF dx = 1 THEN x = x + 2
      IF dy = 1 THEN y = y + 1



    CASE "$" '' reg op
      dbg "REG OP"
      operator$ = MID$(script(y), x + 1, 1)
      dbg "  Operator: " + operator$
     
      op2$ = getunt(x + 2, y)
      op2e = getv2(op2$)
      dbg "  Operand: " + op2$ + " ( =" + STR$(op2e) + ")"
      dbg "  Reg before: " + STR$(reg)
      SELECT CASE operator$
        CASE "+"
          reg = reg + op2e
        CASE "-"
          reg = reg - op2e
        CASE "*"
          reg = reg * op2e
        CASE "/"
          reg = reg / op2e
        CASE "%"
          reg = reg MOD op2e
        CASE "|"
          reg = reg OR op2e
        CASE "&"
          reg = reg AND op2e
        CASE "^"
          reg = reg ^ op2e
        CASE "!"
          reg = NOT reg
        CASE "s"
          reg = SIN(reg)
        CASE "c"
          reg = COS(reg)
        CASE "t"
          reg = TAN(reg)
        CASE "i"
          reg = INT(reg)
        CASE "f"
          reg = reg - INT(reg)
        CASE "="
          reg = op2e

        
      END SELECT
      dbg "  Reg after: " + STR$(reg)
      IF dx = 1 THEN x = x + 3 + LEN(op2$)
      IF dy = 1 THEN y = y + 1


    CASE "{"
      dbg "ADVPOP"
      op$ = getunt$(x + 1, y)
      
      ope = getv2(op$)
      reg = popstk(ope)
      IF dx = 1 THEN x = x + 2 + LEN(op2$)
      IF dy = 1 THEN y = y + 1

    CASE "["
      dbg "STACK: POP"
      reg = popstk(0)
      IF dx = 1 THEN x = x + 1
      IF dy = 1 THEN y = y + 1


    CASE "]"
      dbg "STACK: PUSH"
      pushstk reg
      IF dx = 1 THEN x = x + 1
      IF dy = 1 THEN y = y + 1

    CASE "="
      dbg "PRINT"
      op2$ = getunt$(x + 1, y)
      op2e = getv(op2$)
      PRINT LTRIM$(STR$(op2e));

      IF dx = 1 THEN x = x + 2 + LEN(op2$)
      IF dy = 1 THEN y = y + 1


    CASE "T"
      dbg "PRINT TEXT"
      op2$ = getunt(x + 1, y)
      PRINT op2$;

      IF dx = 1 THEN x = x + 2 + LEN(op2$)
      IF dy = 1 THEN y = y + 1
      'INPUT "g", ff
    CASE "?"
      dbg "INPUT"
      INPUT ; "", reg


    CASE "G"
      dbg "GFXOP"
      sc$ = MID$(script(y), x + 1, 1)
      SELECT CASE sc$
        CASE "G"
                SCREEN 12
                WIDTH 80, 60
                IF dx = 1 THEN x = x + 2
                IF dy = 1 THEN y = y + 1

        CASE "T"
                SCREEN 0
                IF dx = 1 THEN x = x + 2
                IF dy = 1 THEN y = y + 1


        CASE ">"
                gx = getv2(MID$(script(y), x + 2, 1))
                gy = getv2(MID$(script(y), x + 3, 1))
                gc = getv2(MID$(script(y), x + 4, 1))
                PSET (gx, gy), gc
                IF dx = 1 THEN x = x + 5
                IF dy = 1 THEN y = y + 1
        CASE "<"
                gx = getv2(MID$(script(y), x + 2, 1))
                gy = getv2(MID$(script(y), x + 3, 1))
                reg = POINT(gx, gy)
                IF dx = 1 THEN x = x + 4
                IF dy = 1 THEN y = y + 1

        CASE "t"
                trace = 3
                y = y + 1
      END SELECT
   
    CASE "S"
      dbg "STRING OP"
      sc$ = MID$(script(y), x + 1, 1)
      SELECT CASE sc$

        CASE "="
                dbg "PUSH STRING TO REG"
                sreg = getunt(x + 2, y)
                IF dx = 1 THEN x = x + 3 + LEN(sreg)
                IF dy = 1 THEN y = y + 1

        CASE "?"
                dbg "INPUT STRING"
                INPUT ; "", sreg
                IF dx = 1 THEN x = x + 2
                IF dy = 1 THEN y = y + 1
        CASE "T"
                dbg "PRINT STRING"
                op2d$ = getunt(x + 2, y)
                op2$ = getsv$(op2d$)
                PRINT op2$;
                IF dx = 1 THEN x = x + 3 + LEN(op2d$)
                IF dy = 1 THEN y = y + 1

        CASE ")"
                dbg "PUSH"
                setsv MID$(script(y), x + 2, 1), sreg
                IF dx = 1 THEN x = x + 3
                IF dy = 1 THEN y = y + 1
        CASE "("
                dbg "POP"
                sreg = getsv$(MID$(script(y), x + 2, 1))
                IF dx = 1 THEN x = x + 3
                IF dy = 1 THEN y = y + 1
        CASE "#"
                dbg "GETLEN"
                reg = LEN(getsv$(MID$(script(y), x + 2, 1)))
                IF dx = 1 THEN x = x + 2
                IF dy = 1 THEN y = y + 1

        CASE "["
                dbg "GETCHAR"
                ns$ = getunt$(x + 2, y)
                n = getv2(ns$)
                IF n > LEN(sreg) OR n < 1 THEN
                  reg = 0
                ELSE
                  reg = ASC(MID$(sreg, n, 1))
                END IF
                IF dx = 1 THEN x = x + 3 + LEN(ns$)
                IF dy = 1 THEN y = y + 1

        CASE "]"
                dbg "SETCHAR"

                ps$ = getunt$(x + 2, y)
                dbg "PS: " + ps$
                p = getv2(ps$)
                dbg "P:  " + STR$(p)
                ns$ = getunt$(x + 3 + LEN(ps$), y)
                dbg "NS: " + ns$
                n = getv2(ns$)
                dbg "N:  " + STR$(n)

                IF p >= 1 AND p <= LEN(sreg) THEN
                  IF n > 0 AND n < 256 THEN MID$(sreg, p, 1) = CHR$(n)
                ELSE
                  dbg "Illegal"
                  dbg "P: " + STR$(p)
                  dbg "L: " + STR$(LEN(sreg))

                END IF
                IF dx = 1 THEN x = x + 4 + LEN(ns$) + LEN(ps$)
                IF dy = 1 THEN y = y + 1
        CASE ">"
                dbg "SETCHAR LITERAL"

                ps$ = getunt$(x + 2, y)
                p = getv2(ps$)
                ns$ = MID$(script(y), x + 3 + LEN(ps$), 1)
                
                IF p >= 1 AND p <= LEN(sreg) THEN
                  MID$(sreg, p, 1) = ns$
                ELSE
                  dbg "Illegal"
                END IF
                IF dx = 1 THEN x = x + 4 + LEN(ps$)
                IF dy = 1 THEN y = y + 1

        CASE "+"
                dbg "APPEND"
                ns$ = getunt$(x + 2, y)
                sreg = sreg + getsv(ns$)
                IF dx = 1 THEN x = x + 3 + LEN(ns$)
                IF dy = 1 THEN y = y + 1

        CASE "F"
                dbg "FILL LITERAL"

                ps$ = getunt$(x + 2, y)
                p = getv2(ps$)
                ns$ = MID$(script(y), x + 3 + LEN(ps$), 1)
               
                sreg = STRING$(p, ns$)
                IF dx = 1 THEN x = x + 4 + LEN(ps$)
                IF dy = 1 THEN y = y + 1
        CASE "W"
                dbg "Write file"
                fi$ = getunt$(x + 2, y)
                fib$ = LTRIM$(getsv$(fi$))
                OPEN fib$ FOR BINARY AS 1
                PUT #1, , sreg
                CLOSE 1
                IF dx = 1 THEN x = x + 3 + LEN(sreg)
                IF dy = 1 THEN y = y + 1
        CASE "R"
                dbg "Read file"
                fi$ = getunt$(x + 2, y)
                fib$ = LTRIM$(getsv$(fi$))
                OPEN fib$ FOR BINARY AS 1
                sreg = INPUT$(LOF(1), #1)
                CLOSE 1
                IF dx = 1 THEN x = x + 3 + LEN(sreg)
                IF dy = 1 THEN y = y + 1
        CASE "{"
                dbg "Read numeric"
                vi$ = getsv$(MID$(script(y), x + 2, 1))
                fi$ = getunt$(x + 3, y)
                fv = getv2(fi$)
                
                IF fv > 0 AND fv <= LEN(vi$) - 3 THEN
                  reg = CVS(MID$(vi$, fv, 4))
                  dbg "  " + vi$ + ":" + fi$ + "=" + STR$(reg)
                ELSE
                  reg = -.2
                  dbg "Can not read numeric: " + STR$(fv) + STR$(LEN(vi$))
                END IF
                
                IF dx = 1 THEN x = x + 4 + LEN(fi$)
                IF dy = 1 THEN y = y + 1

        CASE "}"
                dbg "Write numeric"
                va = getv(MID$(script(y), x + 2, 1))
                vi$ = getsv$(MID$(script(y), x + 3, 1))
                fi$ = getunt$(x + 4, y)
                fv = VAL(fi$)
                IF fv > 0 AND fv < LEN(vi$) - 4 THEN
                  MID$(vi$, fv, 4) = MKS$(va)
                  setsv MID$(script(y), x + 3, 1), vi$
                ELSEIF fv = 0 THEN
                  dbg "  * Append num: " + STR$(va)
                  setsv MID$(script(y), x + 3, 1), vi$ + MKS$(va)
                ELSE
                  dbg "error writ"
                END IF

                IF dx = 1 THEN x = x + 5 + LEN(fi$)
                IF dy = 1 THEN y = y + 1




        CASE ELSE
                IF dx = 1 THEN x = x + 2
                IF dy = 1 THEN y = y + 1

       END SELECT


    CASE "&"
      dbg "NEWLINE"
      
      PRINT
      
      x = x + dx
      y = y + dy

    CASE ">" '' go right
      dbg "Turn right"
      dx = 1
      dy = 0
      x = x + 1

    CASE "v" '' go down
      dbg "Turn down"
      dy = 1
      dx = 0
      y = y + 1


    CASE "^" '' go up, keep direction
      dbg "Go up keep"
      ch$ = MID$(script(y), x + 1, 1)
      IF ch$ = "^" THEN
        y = 1
      ELSE
        y = y - getv2(ch$)
      END IF


    CASE "<" '' go left, keep direction
     
      dbg "Go left keep"
      ch$ = MID$(script(y), x + 1, 1)
      IF ch$ = "<" THEN
        x = 1
      ELSE
        x = x - getv2(ch$)
      END IF
    
    CASE "}" '' go right, keep direction
      dbg "Go right keep"
      ch$ = MID$(script(y), x + 1, 1)
      IF ch$ = ">" THEN
        x = LEN(script(y)) - 1
      ELSE
        x = x + getv2(ch$)
      END IF
     

    CASE "V" '' go down, keep direction
      dbg "Go down keep"
      ch$ = MID$(script(y), x + 1, 1)
      IF ch$ = "V" THEN
        y = nline
      ELSE
        y = y + getv2(ch$)
      END IF
    



    CASE "`" '' go up-left, keep direction
      dbg "Go upleft keep"
      dbg "  Params: " + MID$(script(y), x + 1, 2)

      xm = getv2(MID$(script(y), x + 1, 1))
      ym = getv2(MID$(script(y), x + 2, 1))

      x = x - xm
      y = y - ym

    CASE "," '' go down-left, keep direction
      dbg "Go dnleft keep"
      dbg "  Params: " + MID$(script(y), x + 1, 2)

      xm = getv2(MID$(script(y), x + 1, 1))
      ym = getv2(MID$(script(y), x + 2, 1))

      x = x - xm
      y = y + ym

    CASE "ï" '' go up-right, keep direction
      dbg "Go upright keep"
      dbg "  Params: " + MID$(script(y), x + 1, 2)

      xm = getv2(MID$(script(y), x + 1, 1))
      ym = getv2(MID$(script(y), x + 2, 1))

      x = x + xm
      y = y - ym

    CASE "." '' go down-right, keep direction
      dbg "Go downright keep"
      dbg "  Params: " + MID$(script(y), x + 1, 2)

      xm = getv2(MID$(script(y), x + 1, 1))
      ym = getv2(MID$(script(y), x + 2, 1))

      x = x + xm
      y = y + ym

    CASE "#" '' goto
      dbg "Goto"
      lb$ = "@" + MID$(script(y), x + 1, 1)
      ff = 0
      FOR vy = 1 TO nline
        g = INSTR(script(vy), lb$)
        IF g > 0 THEN
          y = vy
          x = g
          dbg "  FOUND!"
          ff = 1
          vy = 2000
        END IF
      NEXT vy
      IF ff = 0 THEN
        PRINT "Label not found: "; lb$
        END
      END IF

    CASE "%" '' gosub
      dbg "Gosub"
      dbg "  Callstack length: " + STR$(cstacklen)
      IF cstacklen < 30 THEN
        IF dx = 1 THEN
          cstack(cstacklen).x = x + 2
          cstack(cstacklen).y = y
        ELSEIF dy = 1 THEN
          cstack(cstacklen).x = x
          cstack(cstacklen).y = y + 1

        END IF
        cstacklen = cstacklen + 1
      ELSE
        PRINT "Callstack overflow!"
        END
      END IF
      IF MID$(script(y), x + 1, 1) = "." THEN
        dbg "  ** Noop gosub"
        IF dx = 1 THEN
          x = x + 2
        ELSE
          y = y + 1
        END IF
      ELSE
        lb$ = "@" + MID$(script(y), x + 1, 1)
        ff = 0
        FOR vy = 1 TO nline
          g = INSTR(script(vy), lb$)
          IF g > 0 THEN
            y = vy
            x = g
            dbg "  FOUND!"
            ff = 1
            vy = 2000
          END IF
        NEXT vy
        IF ff = 0 THEN
          PRINT "Label not found: "; lb$
          END
        END IF
      END IF

    CASE "/" '' return
      dbg "Return"
      dbg "  Callstack length: " + STR$(cstacklen)
      IF cstacklen > 0 THEN
        x = cstack(cstacklen - 1).x
        y = cstack(cstacklen - 1).y
        cstacklen = cstacklen - 1
      ELSE
        PRINT "Callstack underflow!"
        END
      END IF

    CASE "\" '' return, don't remove cstack
      dbg "Return norem"
      dbg "  Callstack length: " + STR$(cstacklen)

      IF cstacklen > 0 THEN
        x = cstack(cstacklen - 1).x
        y = cstack(cstacklen - 1).y
      ELSE
        PRINT "Callstack underflow!"
        END
      END IF


    CASE "@" '' label (noop)
      dbg "Label"
      IF dx = 1 THEN x = x + 2
      y = y + dy
    
    CASE " ", ""  '' noop
      'INPUT swss$
      dbg "Noop"
      x = x + dx
      y = y + dy

    CASE "!" '' exit
      dbg "Exit"
      ex = 1

    CASE ELSE
      PRINT "Unknown command '" + cop$ + "', bailing out"
      PRINT "Position: "; x; ","; y
      END
  END SELECT
  'PRINT "AFTER:  ("; x; ","; y; ") delta ("; dx; ","; dy; ")"
  'PRINT
  IF trace >= 1 AND trace < 3 THEN
    sx = 4
    sy = 4
    mux = 8
    muy = 8

    LINE (sx + (ox - 1) * mux, sy + (oy - 1) * muy)-(sx + (x - 1) * mux, sy + (y - 1) * muy), 9 + s MOD 5
    LINE (sx + (x - 1) * mux - 2, sy + (y - 1) * muy - 2)-(sx + (x - 1) * mux + 2, sy + (y - 1) * muy + 2), 9 + (5 - s MOD 5), BF
    LINE (sx + (x - 1) * mux - 3, sy + (y - 1) * muy - 3)-(sx + (x - 1) * mux + 3, sy + (y - 1) * muy + 3), 0, B

    tt = TIMER


    FOR i = 0 TO 25
      LOCATE i + 1, 60
      PRINT CHR$(65 + i) + ": "; vars(i)
      LOCATE i + 1, 55
      PRINT LEN(svars(i))

    NEXT i
    LOCATE 27, 60
    PRINT "$:  "; reg
    LOCATE 28, 60
    PRINT "SL/CSL: "; stacklen; cstacklen

    

    WHILE TIMER - tt < .1: WEND

  END IF

WEND

END





erro:
PRINT
ec = ERR
IF ec = 53 THEN
  PRINT "FILE NOT FOUND"
  END
END IF

COLOR 31, 4
PRINT USING "Internal error ### &"; ERR; STRING$(61, " ")
PRINT
COLOR 7, 0
PRINT "Most internal errors are irrecoverable. You can try to continue"
PRINT "execution anyway by pressing C."
PRINT "Exiting automatically in 5 seconds."
PRINT
PRINT "[C]ontinue / [E]xit? ";
COLOR 7
IF choice("ce", 2, 5) = 1 THEN RESUME NEXT
PRINT
PRINT
PRINT "Exiting."
END

FUNCTION choice (s$, default, tl)
  ss = 0
  s$ = LCASE$(s$)
  st = TIMER
  qt = TIMER
  cx = POS(0)
  cy = CSRLIN
  

  WHILE ss = 0
    IF TIMER - qt > .1 THEN t = t + 1: qt = TIMER
    LOCATE cy, cx
    PRINT MID$("|/-\", t MOD 4 + 1, 1);

    IF tl > 0 AND TIMER - st > tl THEN ss = default
    g$ = INKEY$
    IF g$ <> "" THEN
      ss = INSTR(s$, g$)
    END IF

  WEND
  LOCATE cy, cx
  PRINT " ";
  LOCATE cy, cx
  choice = ss
END FUNCTION

SUB dbg (s$)
  IF trace > 1 THEN
    PRINT "Debug: "; s$
    t = TIMER
    WHILE TIMER - t < .1: WEND
  END IF

END SUB

FUNCTION getsv$ (s$)
  gg = ASC(s$)
  
  SELECT CASE gg
    CASE 36
      getsv$ = sreg
    CASE 65 TO 90
      getsv$ = svars(gg - 65)
    CASE ELSE
      getsv$ = s$
  END SELECT
END FUNCTION

FUNCTION getunt$ (vx, vy)
      svx = vx
      svy = vy
      op2$ = " "
      l = 0
      WHILE RIGHT$(op2$, 1) <> "]"
        op2$ = op2$ + MID$(script(vy), vx, 1)
        vx = vx + 1
        l = l + 1
        IF l > 500 THEN
          getunt$ = MID$(op2$, 2, 1)
          COLOR 4
          PRINT "Warning! Unfinished bracket string near ("; svx; ","; svy; ")"
          COLOR 7
          EXIT FUNCTION

        END IF
      WEND
      op2$ = MID$(op2$, 2)
      op2$ = LEFT$(op2$, LEN(op2$) - 1)
      getunt$ = op2$
END FUNCTION

FUNCTION getv (s$)
  IF s$ = "" THEN
    getv = -666
    EXIT FUNCTION

  END IF
  gg = ASC(s$)
  SELECT CASE gg
    CASE 36
      getv = reg
    CASE 65 TO 90
      getv = vars(gg - 65)
    CASE 37 '' callstack
      getv = cstacklen
    CASE 114 '"r"
      getv = RND
    CASE 107 '"k"
      d$ = INKEY$
      IF d$ <> "" THEN
        IF LEN(d$) = 2 THEN
          getv = -ASC(MID$(d$, 2, 1))
        ELSE
          getv = ASC(d$)
        END IF
      ELSE
        getv = 0
      END IF
    CASE 120 '' x
      getv = x
    CASE 121 '' y
      getv = y
    CASE 94 '' ^
      getv = CSRLIN
    CASE 60 '' <
      getv = POS(0)
    CASE 116 '' t
      getv = TIMER
    CASE 94 '' ^ (stack length)
      getv = stacklen
    CASE 91 '' [ (pop stack)
      getv = popstk(0)
    CASE ELSE
      getv = -666
  END SELECT

END FUNCTION

FUNCTION getv2 (s$)
  vb = getv(s$)
  IF vb = -666 THEN vb = VAL(s$)
  getv2 = vb
END FUNCTION

FUNCTION popstk (p)
  dbg "Doing stack pop, arg: " + STR$(p)
  IF p = 0 THEN

    IF stacklen = 0 THEN
      PRINT "Stack underflow (0)!"
      END
    END IF
    v = stack(stacklen - 1)
    stacklen = stacklen - 1
    popstk = v

    EXIT FUNCTION
  END IF

  IF p > 0 THEN
    pt = stacklen - p
    IF pt < 0 THEN
      PRINT "Stack underflow (argument: "; p; "-> "; pt; ")"
      END
    END IF
    v = stack(pt)
    popstk = v
    EXIT FUNCTION
  END IF

  IF p < 0 THEN
    pt = ABS(p)
    IF pt > stacklen THEN
      PRINT "Stack underflow (argument: "; p; "-> "; pt; ")"
      END
    END IF
    v = stack(pt)
    popstk = v

  END IF

END FUNCTION

SUB pushstk (v)
  IF stacklen > 256 THEN
    PRINT "Stack overflow"
  END IF
  dbg "Pushing onto stack: " + STR$(v)

  stack(stacklen) = v
  stacklen = stacklen + 1
END SUB

SUB setsv (s$, va$)
  gg = ASC(s$)
  SELECT CASE gg
    CASE 36
      sreg = va$
    CASE 65 TO 90
      svars(gg - 65) = va$
  END SELECT
END SUB

SUB setv (s$, va)
  dbg " : SETVA call " + s$ + " = " + STR$(va)
  gg = ASC(s$)
  SELECT CASE gg
    CASE 36
      reg = va
    CASE 65 TO 90
      vars(gg - 65) = va
    CASE 37 '' callstack
      cstacklen = va
    CASE 120 '' x
      x = va
    CASE 121 '' y
      y = va
    CASE 94 '' ^
      LOCATE va, POS(0)
    CASE 60 '' <
      LOCATE CSRLIN, va
    CASE 102 '' f
      COLOR va MOD 32
    CASE 98 '' b
      COLOR , va MOD 8

    CASE 94 '' ^ (stack)
      stacklen = va

    CASE 116 '' t
      st = TIMER
      hgz = TIMER + va / 1000
      WHILE TIMER < gz: WEND

  END SELECT


END SUB

