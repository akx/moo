# Moo – a two-dimensional programming language

```
THello World!\]!
```

The Moo language, this documentation and example programs © AKX 2005


## Syntax

### Commands

A command is the basic block in Moo. Commands contain one or more
characters. Commands are traversed (the execution pointer moved) in
either of two methods: from left to right or from up to down. Their
parameters are always read from left to right. The direction can be
changed programmatically and certain commands change it as well.

The default direction (the direction commands are traversed when a Moo
program begins execution) is from left to right. Execution begins at the
top left corner of the program (coordinates (1,1)).

All space characters (ASCII 32) and characters after EOL are considered
noop, and they simply move the execution pointer into the current
direction (down or right).

### Variables

Moo has 26 programmer-usable floating-point single-precision variables.
They are addressed by the letters A to Z inclusive and the dollar sign
(\$). All variables are initialized zero. The dollar sign denotes a
special variable called the work register. All mathematical operations
are done in the work register. Mathematical operations are executed with
the \$ command. The work register can be copied back and forth into any
variable and some other meta-variables with the commands ( (opening
parentheses) and ) (closing parentheses).

### Metavariables

The programmer can use some metavariables in addition to the standard
variables:

  ---------- -------------------------------- -------- ----------------------
  Variable   Description                      Access   Range

  x          The horizontal position of the   RW       1..65535 inclusive
             execution pointer                         

  y          The vertical position of the     RW       1..50 inclusive
             execution pointer                         

  \<         The horizontal position of the   RW       1..80 inclusive
             screen cursor                             

  \^         The vertical position of the     RW       1..25 inclusive or
             screen cursor                             1..50 inclusive

  r          A random number                  R        0..1

  k          An ASCII code for the last key   R        -255..0..255 inclusive
             pressed, or a negative number             
             for a scancode. 0 if nothing is           
             pressed.                                  

  f          The VGA color number for the     W        0..31 inclusive
             text foreground color.                    

  b          The VGA color number for the     W        0..7 inclusive
             text background color                     

  \%         The length of the call stack     RW       0..25 inclusive
             (used by subprograms).                    

  t          Timer. Seconds elapsed since     R (1.2)  0..24\*60\*60
             midnight.                                 inclusive

  t          Timer. Write amount of           W (1.2)  0..65535 inclusive
             milliseconds (1/1000 second) to           
             make the program wait for that            
             time.                                     

  \^         The length of the variable       RW (1.2) 0..64 inclusive
             stack.                                    

  \[         Equal to \[ (pop stack)          R        
  ---------- -------------------------------- -------- ----------------------

### Branching

Branching is done by using the + command. In Moo, branch operations
quite literally branch; for false results the execution pointer is
turned into the opposite direction. The + command is further explained
in the Commands section.

### Strings (1.2)

Strings are a new feature in Moo 1.2. They are referenced by alphabets
just like numeric variables and they have their own work register,
referenced by \$. Strings can be used to store text, numerics can be
converted and stored into strings or they can be used as byte arrays.
The maximum length of a single string (there are 26 available -- limited
by your conventional memory (!)) is 65535 characters in the original
BASIC interpreter.

### Stack (1.3)

The stack is a new feature in Moo 1.3. The stack is a further variable
storage space with easy functionality to push and pop data. (Using all
of the 256-item stack and 5 full strings in addition to normal variables
allows 164122 variables, so you're not really running out there.)

## Commands

Parameters marked with an asterisk (\*) must be terminated with a
bracket \]. Unbracketed strings are continued until 500 characters,
beyond which a warning is issued on screen. Other parameters are
single-character unless otherwise noted.

### Variable Commands

#### ( -- Read Work Register From Variable

Parameters: variable

The ( command loads a variable into the work register. It takes one
parameter, the variable from which the value is loaded from. Variable
can also be 0 to 9 inclusive, for loading a number into the work
register.

#### ) -- Write Work Register To Variable

Parameters: variable

) writes the current value of the work register into a variable. One
parameter is taken, the variable to receive the current value of the
work register.

#### \] -- Push Work Register To Stack

Writes the current value of the work register to the global stack,
incrementing stack length by one.

#### \[ - Pop Stack To Work Register

Writes the last-written stack value to the register and decrements stack
length by one.

#### { - Advanced Pop Stack To Work Register

Parameters: variable\*

When N \> 0: Reads the n\'th value from the stack to the work register,
n being variable, 1-based.

When N=0: The last pushed value is read and stack length decremented by
one.

When N \< 0: Reads the n\'th last value.

#### \$ - Work Register Arithmetic

Parameters: operator, operand\*

\$ is the Moo workhorse -- it is the basic arithmetic command. Operand
may be empty, any readable variable or a floating point number. Operator
may be one of the following:

  ---------- -------------- -------------------------------------------------
  Operator   Unary/Binary   Description

  \+         B              Adds operand to \$.

  \-         B              Subtracts operand from \$.

  \*         B              Multiplies \$ by operand.

  /          B              Divides \$ by operand.

  \%         B              Returns the division remainder (modulo) of
                            \$/operand.

  \|         B              Returns the bitwise OR between \$ and operand.

  &          B              Returns the bitwise AND between \$ and operand.

  \^         B              Returns \$operand.

  !          U              Returns the bitwise NOT of \$.

  s          U              Returns the sine of \$ (expressed in radians).

  c          U              Returns the cosine of \$.

  t          U              Returns the tangent of \$.

  i          U              Returns the integer part of \$.

  f          U              Returns the fractional part of \$.
  ---------- -------------- -------------------------------------------------

Unary operators do not require an operand. `\$i\]`

### Input/Output commands

#### = - Print variable

Parameters: variable\*

= prints a variable or a number on the screen.

#### T -- Print text

Parameters: string\*

This command prints a string of text on the screen at the current
location.

#### & - Print newline

This command outputs a newline character.

#### ? -- Input Variable

This command inputs a numeric variable from the user to the work
register.

### String commands

**NB: All string commands are subcommands of the S command. Example:**

```
S=TEST\]ST\$\]
```

#### = - Push literal to string register

Parameters: string\*

The literal string parameter is pushed into the string register.

#### ? -- Input string

A string (until newline) is input from the user and pushed into the
string register.

#### T -- Print string

Parameters: stringvar

The string variable is printed, just like the = command.

#### ) -- Push register into string variable

Parameters: stringvar

The current string register contents are pushed into the specified
string variable.

#### ( - Pop register from string variable

Parameters: stringvar

The contents of the string register are overwritten with the contents
from the specified string variable.

#### \# - Get Length

Parameters: stringvar

The number of characters in the specified string variable is put into
the numeric register.

#### \[ - Get Character

Parameters: index\*

The ASCII value of the character in the string register at the specified
index position (either number literal or variable) is put into the
numeric register.

#### \] -- Set Character

Parameters: index\*, value\*

The character at index\'th position of the string register is changed to
the ASCII character *value*.

#### \> - Set Character, ASCII literal

Parameters: index\*, character

The character at index\'th position of the string register is changed to
*character*.

#### + - Append String

Parameters: stringvar\*

The string variable (or literal) is appended to the work register.

#### F -- Fill String with ASCII Literal

Parameters: length\*, character

The string register is set to be length characters of the character
*character*.

#### W -- Write string to file

Parameters: filename\*

The string in the work register is written to the specified file.
Spacebars in front of the name are trimmed out. You\'ll figure out why.

#### R -- Read string from file

Parameters: filename\*

The file is read into the string register. If the file does not exist,
the program will probably crash.

#### } -- Write numeric to string

Parameters: variable, stringvar, position\*

The numeric variable is written into the specified position in the
string. Each variable takes 4 characters. If position is 0, the variable
is appended to the string.

#### { -- Read numeric from string

Parameters: string, position\*

A number is read from the specified position in the string and written
into the work register. 4 characters are read, so be careful with the
alignment ;-).

### Flow control commands

#### \> - Turn right

Turns the program flow rightwards.

#### v -- Turn down

Turns the program flow downwards.

#### + - Branch

Parameters: operand1, operator, operand2\*

As discussed before, the + command branches program execution. Operand1
is any one-character variable, operator may be any one of the operators
listed in the table below and operand2 may be a number, a variable or
any other valid character.

For false results the execution pointer is turned into the opposite
direction (downward flow turned rightward and vice versa). For true
results execution is continued in the current direction.

Valid operators are

  ------------------- ---------------------------------------------------
  Operator            Description

  =                   Equality

  !                   Inequality

  \<                  Lesser than

  \>                  Greater than

  {                   Lesser or equal than

  }                   Greater or equal than

  &                   Bitwise AND ineq 0

  \|                  Bitwise OR ineq 0

  \^                  Bitwise XOR ineq 0

  \#                  Bitwise EQV ineq 0

  \%                  Bitwise IMP ineq 0
  ------------------- ---------------------------------------------------

#### x -- Inverted branch

x is the same as + except that true results turn the pointer.

#### ! -- Exit

The ! command stops the program. Without a proper ! the program will fly
out to the distance.

### Jumping

There are multiple ways of jumping in Moo. You can use coordinate
jumping to make your programs look obscenely obfuscated (and look like a
true programmer in the process) or use much easier label jumps.

#### Coordinate jumping

The commands for coordinate jumping are:

  ----------------------- ------------------------ -----------------------
  \`                      \^                       ´

  \<                                               }

  ,                       V                        .
  ----------------------- ------------------------ -----------------------

The corner commands jump diagonally and thus take two single-character
parameters while the commands marked in primary directions in the graph
take only one parameter. The primary jump commands may also take their
identity as parameter (for example \<\<) to go to the ultimate position
in the specified direction. For example \<\< would jump to the start of
the current line.

#### Label jumping

Labels are defined with the @ command, and jumped into with \#.
Subprogram calls can also be made using the % command. Returning from
such subprograms is done with the / (slash) command.

### Label jumping commands

#### @ - Label

Parameters: label name

The @ command defines a label. A label is considered noop in execution.

#### \# - Jump to label

Parameters: label name

The \# command finds a label in the program and jumps to it. If the
specified label is not found the program will terminate with an error.

#### % - Subprogram to label

Parameters: label name

The % command performs otherwise as \#, but the next statement
(according to the current direction) is pushed to a special call stack
to allow returning there. % is also a fast way to do loops (more on this
later). If the label name given to % is a period (.) the execution
pointer is not moved there, but the next command is pushed onto the call
stack.

#### / - Return from subprogram

The / command is used to return from a subprogram to the next statement
as defined when the gosub was made. The callstack is popped so that the
next / statement will move the execution pointer to the last next
statement instead of keeping the position / returns to as the last one,
as \\ would do.

#### \\ - Return from subprogram, don\'t pop stack

\\ performs as /, but the stack isn\'t popped but peeked instead. This
means consecutive \\ will move the execution pointer always to the same
position if no % operations are done. The callstack length can be
modified with (%\$-1\])% or similar code (see Metavariables). This
operation makes label-based looping faster than repeated gotos.

Example programs
----------------

### First test

This was the first ever Moo program.

It prints the numbers 12345102040807570656055 and so on until zero.

```
+A>4]&+$>50]&v
(A    $*2]   <3
$+1]  =$] $-5]
=$]   >`13=$]
)A.32     +$>0](0$+20],$0
>`15      ^3
     !
```

### One To Ten

Counts from 1 to 10 each on a new line. Demonstrates goto looping.

```
@1$+1]=$]&+$>9]&TDone!]!
          >#1
```

### Jumping gosubs

This program demonstrates jumping and gosubs.

```
v v
%P#P
@P^2
$+1]
=$]
&
+$=10]\
TDone]
!
```

### Ornate, documented Moo

There\'s the program information and a fancy ASCII art border in the
program.

```
v

 @!T   Moo Demo Program #4                      ]#A
 @AT   (C) AKX 2005                             ]#B
 @BT   ------------------------------------     ]#C
 @CT   Demonstrates dice. Yes. Dice. ;-)        ]#D
 @D!   ------------------------------------     ]#E <-- LOL.

>T     You can press Space to quit this demo.   ]&&&v

>         v                                         <<

  +-----+   +--------+
  |                  |
  |       @          |
  |       (r         |
  |       $*6]       |
  |       $+1]       |
  |       $i]        |
  |       =$]        |
  |       T  ]       |
  |       (k         |
  |       +$!32]#!   |
  |                  |
  +-----+   +--------+
        | # |
        +---+
```

### A Moo Game

A simple reaction test game.

```
TInstructions: Press any key when you're told to.]&&#P
@P+k=0]#K                       Wait for keypresses to go out.
  >@P
@K(r$*3000]$+1000]$i])A(0#!     Prepare random timer.
@!v                             Hacky.
(B#!                            Pop time.
$+1]                            Add to time.
)B                              Push time.
xB=A]TPUSH IT NOW!]v            Output help for player.
@1                 #1           Just some gotos.
xB>A](C$+1])Cv                  Increase score.
@2           #2                 Just some gotos, again.
xk>0]v                          Check for keypress.
#! @3#3                         Goto endgame if key pressed.
@4!&
!  xC=0]TJ00 xkiitter! There was only ](A$-B]=$]T left!]#4
   TYour score (lower better): ]
   =C]
   &
   TThis means that you]
   xC>300]T suck a lot!]#4
   xC>250]T suck!]#4
   xC>200]T suck a bit.]#4
   xC>150]T don't suck a lot.]#4
   xC>100]T're quite OK.]#4
   xC>40]T're very OK.]#4
   T are actually quite amazing.]
   #4

(C) AKX 2005
```

### A Moo Game, Obfuscated

This does almost exactly what the previous example does, but it\'s quite
a lot more obscene to look at, don\'t you think?

```
%I+k=0](r$*1000]$+0500]$i])A(0#!
  >`11 @!>(B$+1])BxB=A],52
  +k>0],52        >%J,31
  >´42            xB>A]@Z(0$+30]`$1
  &##             >(C$+1])C#Z
e@#+C=0]%K(A$-B]=$]%L#$@$!
   >%M=C]&%Nv
   xC>300]#O<9@0
   #0@1       xC>250]#P
     xC>200]#Q#1@2
     #2@3       xC>150]#R
       xC>100]#S#3
       xC>40]#T
       >>>>>>#U<<<<<<
----------#$-----#$---------#$--#$-#$---#$----------#$
@ITInstructions: Press any key when you're told to.]&&(0$+5]$-1]+$>0]<9
@JTPUSH IT NOW!]#Z@KTJ00 xkiitter! There was only ]/            >/
@LT left!]/@MTYour score (lower better): ]/@Zv
@NTThis means that you]/@OT suck a lot!]^4   /
@PT suck!]^5@QT suck a bit.]^5@RT don't suck a lot.]^4
@ST're quite OK.]^6@TT're very OK.]^6
@UT are actually quite amazing.]^7
```


### String manipulation and stack example (1.3+)

I particularly like the **S\]\$\]\[\]\[** part.

```
v       @R
SF70]   ]
$=5]    >$=r]$*96]$+32]]$=r]$*70]S]$][][v
@1      @@                              /
$-1]    %.
%R      >ST$]&$=r]$*3]v $-1]<6
+$=0]v                %R
#@   #1               +$<0]`32
                      \
                      
```

Enlightened thoughts about Moo.
-------------------------------

-   Breakage occurs. Don\'t hack.

-   Hacking occurs. Causes breakage.

-   You can\'t go back to your old creations. Trust me.

-   Concentrate.

-   You should fill all empty space with filler characters. It\'s more
    fun to read then.

-   For labels, prioritize your character usage: special characters,
    especially those synonymous with Moo commands, should be used first.
    @@.

Revision History
----------------

-   1.1 (11 April 2005)

  -   First public release

-   1.2 (1 May 2005)

  -   Added strings

  -   Added timer

  -   Added file i/o (yes, you read that right)

  -   Added numeric \<-\> string conversion (combined with file io this is
    persistent variables)

-   1.3 (5 May 2005)

  -   Added stack (yes, this means that function calls are coming.)
