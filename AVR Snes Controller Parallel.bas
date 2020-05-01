'The MIT License (MIT)

'Copyright (c) 2019 Jeffrey Paranich (jeff<at>chipnetics.com)

'Permission is hereby granted, free of charge, to any person obtaining a copy of
'this software and associated documentation files (the "Software"), to deal in
'the Software without restriction, including without limitation the rights to
'use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
'the Software, and to permit persons to whom the Software is furnished to do so,
'subject to the following conditions:

'The above copyright notice and this permission notice shall be included in all
'copies or substantial portions of the Software.

'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
'FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
'COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
'IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
'CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


$regfile = "attiny2313.DAT"
$hwstack = 40
$swstack = 20
$framesize = 24
$crystal = 8000000

'DDRx - Port X Data Direction Register
'Writing 1 in the pin location makes output pin.  0 makes input pin
'Data Direction Register. 0 = Input, 1 = Output

Ddrb = &B11111111                                           ' Output for a,b,x,y,up,down,left,right
Ddrd = &B00001111                                           ' [5]Input for Serial | [3,2,1,0] Output for select,start,l,r
Ddra = &B00000011                                           ' [1]Output for clk | [0]Output for latch

'PINx - Port X Input Pins Register (READING)
'To READ the values on the pins of PortX you read the values that are on the pin
'register.

'PORTx - Port X Data Register. (OUTPUTTING)
'Stores logic values currently being OUTPUTTED on the physical pinds of PORTx
Portb = &B11111111
Portd = &B00101111                                          'Internal pullup on D.5 - set to input but outputting 1
Porta = &B00000010

Controller_latch Alias Porta.0                              'Output
Controller_clk Alias Porta.1                                'Output
Controller_serial Alias Pind.5                              'Input

Pad_y Alias Portb.0                                         'Neo Geo A
Pad_b Alias Portb.1                                         'Neo Geo B
Pad_x Alias Portb.2                                         'Neo Geo C
Pad_a Alias Portb.3                                         'Neo Geo D

Pad_up Alias Portb.4
Pad_down Alias Portb.5
Pad_left Alias Portb.6
Pad_right Alias Portb.7

Pad_select Alias Portd.0
Pad_start Alias Portd.1

Pad_l Alias Portd.2
Pad_r Alias Portd.3


'--------------------------------------------------------------------------------
' Every 16.67ms (60hz), SNES sends out 12us wide +ve data latch pulse pin 3
' 6us after fall of latch:
' 16 data clock pulses output on pin 2, 50% duty cycle at 12uS per cycle (6 low, 6 high)
' Controller serially shift latch button states on pin 4 every rising edge of clk
' CPU samples on every falling edge.
' Logic high on samples mean the button is NOT depressed.
' At  end of 16 cycle sequence, serial data line driven low until next data latch pulse
' Clk cycle:
' 1 B | 2 Y | 3 Select | 4 Start | 5 Up | 6 Down | 7 Left | 8 Right | 9 A
' 10 X | 11 L | 12 R | 13->16 None (always High)
'
' Serial data train takes (6uS high + 6uS low) X 16 = 192uS
' SNES is sampling at 16.67mS -> 16667uS which means it is wayyy undersampling data.
'
' Here we sample fast as possible, much more above what the SNES CPU would which will
' Achieve a much more parallel-like output to the NEO GEO.
'
' Neo Geo CPU probably does not poll this fast (60hz?) so when it does sample everything
' will be setup high/low and will appear as parallel data.
'--------------------------------------------------------------------------------
Pollcontroller:

'Controller clock normally high
Controller_clk = 1


'12uS wide data latch pulse
'At 8MHz each loop is 0.375uS
Controller_latch = 1
ldi R17, $21                                                '
Data_latch_pulse_width:
dec R17
brne data_latch_pulse_width
Controller_latch = 0


''''''''''  B BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
B_clock_pulse_width:
dec R17
brne b_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
      Pad_b = 0
Else
      Pad_b = 1
End If

ldi R17, $F                                                 '
B_low_pulse_width:
dec R17
brne b_low_pulse_width
NOP
''''''''''  B BUTTON END '''''''''''''''''''''''

''''''''''  Y BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Y_clock_pulse_width:
dec R17
brne y_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for Y Button)
If Controller_serial = 0 Then
      Pad_y = 0
Else
      Pad_y = 1
End If
'12 uS Remainder of Low Pulse (6uS = 16x0.375us)
ldi R17, $F                                                 '
Y_low_pulse_width:
dec R17
brne y_low_pulse_width
NOP
''''''''''  Y BUTTON END '''''''''''''''''''''''

''''''''''  SELECT BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Select_clock_pulse_width:
dec R17
brne select_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for Select Button)
If Controller_serial = 0 Then
      Pad_select = 0
Else
      Pad_select = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Select_low_pulse_width:
dec R17
brne select_low_pulse_width
NOP
''''''''''  SELECT BUTTON END '''''''''''''''''''''''

''''''''''  START BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Start_clock_pulse_width:
dec R17
brne start_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for Start Button)
If Controller_serial = 0 Then
      Pad_start = 0
Else
      Pad_start = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Start_low_pulse_width:
dec R17
brne start_low_pulse_width
NOP
''''''''''  START BUTTON END '''''''''''''''''''''''

''''''''''  up BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Up_clock_pulse_width:
dec R17
brne up_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for Up Button)
If Controller_serial = 0 Then
     Pad_up = 0
Else
     Pad_up = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Up_low_pulse_width:
dec R17
brne up_low_pulse_width
NOP
''''''''''  up BUTTON END '''''''''''''''''''''''

''''''''''  down BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Down_clock_pulse_width:
dec R17
brne down_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for Down Button)
If Controller_serial = 0 Then
      Pad_down = 0
Else
      Pad_down = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Down_low_pulse_width:
dec R17
brne down_low_pulse_width
NOP
''''''''''  down BUTTON END '''''''''''''''''''''''

''''''''''  left BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Left_clock_pulse_width:
dec R17
brne left_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for Left Button)
If Controller_serial = 0 Then
      Pad_left = 0
Else
      Pad_left = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Left_low_pulse_width:
dec R17
brne left_low_pulse_width
NOP
''''''''''  left BUTTON END '''''''''''''''''''''''


''''''''''  right BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Right_clock_pulse_width:
dec R17
brne right_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for Right Button)
If Controller_serial = 0 Then
      Pad_right = 0
Else
      Pad_right = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Right_low_pulse_width:
dec R17
brne right_low_pulse_width
NOP
''''''''''  right BUTTON END '''''''''''''''''''''''

''''''''''  a BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
A_clock_pulse_width:
dec R17
brne a_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for A Button)
If Controller_serial = 0 Then
      Pad_a = 0
Else
      Pad_a = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
A_low_pulse_width:
dec R17
brne a_low_pulse_width
NOP
''''''''''  a BUTTON END '''''''''''''''''''''''

''''''''''  x BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
X_clock_pulse_width:
dec R17
brne x_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for X Button)
If Controller_serial = 0 Then
      Pad_x = 0
Else
      Pad_x = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
X_low_pulse_width:
dec R17
brne x_low_pulse_width
NOP
''''''''''  x BUTTON END '''''''''''''''''''''''


''''''''''  l BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
L_clock_pulse_width:
dec R17
brne l_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for l Button)
If Controller_serial = 0 Then
      Pad_l = 0
Else
      Pad_l = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
L_low_pulse_width:
dec R17
brne l_low_pulse_width
NOP
''''''''''  l BUTTON END '''''''''''''''''''''''

''''''''''  r BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
R_clock_pulse_width:
dec R17
brne r_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for r Button)
If Controller_serial = 0 Then
      Pad_r = 0
Else
      Pad_r = 1
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
R_low_pulse_width:
dec R17
brne r_low_pulse_width
NOP
''''''''''  r BUTTON END '''''''''''''''''''''''

''''''''''''''''''''''''''
''' UNMAPPED BUTTONS '''''
''''''''''''''''''''''''''

''''''''''  unmap1 BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Unmap1_clock_pulse_width:
dec R17
brne unmap1_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge.
If Controller_serial = 0 Then
      NOP
Else
      NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Unmap1_low_pulse_width:
dec R17
brne unmap1_low_pulse_width
NOP
''''''''''  unmap1 BUTTON END '''''''''''''''''''''''
''''''''''  unmap2 BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Unmap2_clock_pulse_width:
dec R17
brne unmap2_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge.
If Controller_serial = 0 Then
      NOP
Else
      NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Unmap2_low_pulse_width:
dec R17
brne unmap2_low_pulse_width
NOP
''''''''''  unmap2 BUTTON END '''''''''''''''''''''''
''''''''''  unmap3 BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Unmap3_clock_pulse_width:
dec R17
brne unmap3_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge.
If Controller_serial = 0 Then
      NOP
Else
      NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Unmap3_low_pulse_width:
dec R17
brne unmap3_low_pulse_width
NOP
''''''''''  unmap3 BUTTON END '''''''''''''''''''''''
''''''''''  unmap4 BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Unmap4_clock_pulse_width:
dec R17
brne unmap4_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge.
If Controller_serial = 0 Then
      NOP
Else
      NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $F                                                 '
Unmap4_low_pulse_width:
dec R17
brne unmap4_low_pulse_width
NOP
''''''''''  unmap4 BUTTON END '''''''''''''''''''''''

'NOTE::: UNCOMMENT/EDIT BELOW PART IF YOU WANT TO CHANGE RESPONSIVENESS
'HIGHER TRAILING TIME = SLOWER RESPONSE

'Trailing high...
'Waitms 16


Goto Pollcontroller