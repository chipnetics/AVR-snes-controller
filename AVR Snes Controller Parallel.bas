$regfile = "attiny2313.DAT"
$hwstack = 40
$swstack = 20
$framesize = 24
$crystal = 8000000

'DDRx - Port X Data Direction Register
'Writing 1 in the pin location makes output pin.  0 makes input pin
'Data Direction Register. 0 = Input, 1 = Output

Ddrb = &B11111111                                           ' Output for a,b,x,y,up,down,left,right
Ddrd = &B00001111                                           ' [4]Input for Serial | [3,2,1,0] Output for select,start,l,r
Ddra = &B00000011                                           ' [1]Output for clk | [0]Output for latch

'PINx - Port X Input Pins Register (READING)
'To READ the values on the pins of PortX you read the values that are on the pin
'register.

'PORTx - Port X Data Register. (OUTPUTTING)
'Stores logic values currently being OUTPUTTED on the physical pinds of PORTx
Portb = &B11111111
Portd = &B00011111                                          'Internal pullup on D.5 - set to input but outputting 1
Porta = &B00000010

Controller_latch Alias Porta.0                              'Output
Controller_clk Alias Porta.1                                'Output
Controller_serial Alias Pind.5                              'Input

Pad_a Alias Portb.0
Pad_b Alias Portb.1
Pad_x Alias Portb.2
Pad_y Alias Portb.3

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

' Reset controller states.
Portb = &B11111111
Portd = &B00001111

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
End If

ldi R17, $10                                                '
B_low_pulse_width:
dec R17
brne b_low_pulse_width
''''''''''  B BUTTON END '''''''''''''''''''''''

''''''''''  Y BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Y_clock_pulse_width:
dec R17
brne y_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_y = 0
End If
'12 uS Remainder of Low Pulse (6uS = 16x0.375us)
ldi R17, $10                                                '
Y_low_pulse_width:
dec R17
brne y_low_pulse_width
''''''''''  Y BUTTON END '''''''''''''''''''''''

''''''''''  SELECT BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Select_clock_pulse_width:
dec R17
brne select_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_select = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Select_low_pulse_width:
dec R17
brne select_low_pulse_width
''''''''''  SELECT BUTTON END '''''''''''''''''''''''

''''''''''  START BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Start_clock_pulse_width:
dec R17
brne start_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_start = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Start_low_pulse_width:
dec R17
brne start_low_pulse_width
''''''''''  START BUTTON END '''''''''''''''''''''''

''''''''''  up BUTTON up '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Up_clock_pulse_width:
dec R17
brne up_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_up = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Up_low_pulse_width:
dec R17
brne up_low_pulse_width
''''''''''  up BUTTON END '''''''''''''''''''''''

''''''''''  down BUTTON down '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Down_clock_pulse_width:
dec R17
brne down_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_down = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Down_low_pulse_width:
dec R17
brne down_low_pulse_width
''''''''''  down BUTTON END '''''''''''''''''''''''

''''''''''  left BUTTON left '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Left_clock_pulse_width:
dec R17
brne left_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_left = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Left_low_pulse_width:
dec R17
brne left_low_pulse_width
''''''''''  left BUTTON END '''''''''''''''''''''''


''''''''''  right BUTTON right '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Right_clock_pulse_width:
dec R17
brne right_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_right = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Right_low_pulse_width:
dec R17
brne right_low_pulse_width
''''''''''  right BUTTON END '''''''''''''''''''''''

''''''''''  a BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
A_clock_pulse_width:
dec R17
brne a_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_a = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
A_low_pulse_width:
dec R17
brne a_low_pulse_width
''''''''''  a BUTTON END '''''''''''''''''''''''

''''''''''  x BUTTON x '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
X_clock_pulse_width:
dec R17
brne x_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_x = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
X_low_pulse_width:
dec R17
brne x_low_pulse_width
''''''''''  x BUTTON END '''''''''''''''''''''''


''''''''''  l BUTTON l '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
L_clock_pulse_width:
dec R17
brne l_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_l = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
L_low_pulse_width:
dec R17
brne l_low_pulse_width
''''''''''  l BUTTON END '''''''''''''''''''''''

''''''''''  r BUTTON r '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
R_clock_pulse_width:
dec R17
brne r_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     Pad_r = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
R_low_pulse_width:
dec R17
brne r_low_pulse_width
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

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Unmap1_low_pulse_width:
dec R17
brne unmap1_low_pulse_width
''''''''''  unmap1 BUTTON END '''''''''''''''''''''''
''''''''''  unmap2 BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Unmap2_clock_pulse_width:
dec R17
brne unmap2_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Unmap2_low_pulse_width:
dec R17
brne unmap2_low_pulse_width
''''''''''  unmap2 BUTTON END '''''''''''''''''''''''
''''''''''  unmap3 BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Unmap3_clock_pulse_width:
dec R17
brne unmap3_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Unmap3_low_pulse_width:
dec R17
brne unmap3_low_pulse_width
''''''''''  unmap3 BUTTON END '''''''''''''''''''''''
''''''''''  unmap4 BUTTON START '''''''''''''''''''''''
Controller_clk = 1                                          'Controller latches data rising edge
ldi R17, $10                                                '
Unmap4_clock_pulse_width:
dec R17
brne unmap4_clock_pulse_width
Controller_clk = 0                                          'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If Controller_serial = 0 Then
     NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
Unmap4_low_pulse_width:
dec R17
brne unmap4_low_pulse_width
''''''''''  unmap4 BUTTON END '''''''''''''''''''''''

'NOTE::: UNCOMMENT/EDIT BELOW PART IF YOU WANT TO CHANGE RESPONSIVENESS
'HIGHER TRAILING TIME = SLOWER RESPONSE

'Trailing high...
'Waitms 16


Goto Pollcontroller