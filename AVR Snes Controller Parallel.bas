$regfile = "attiny2313.DAT"
$hwstack = 40
$swstack = 20
$framesize = 24
$crystal = 8000000

'DDRx - Port X Data Direction Register
'Writing 1 in the pin location makes output pin.  0 makes input pin
'Data Direction Register. 0 = Input, 1 = Output

Ddrb = &B11111111 ' Output for a,b,x,y,up,down,left,right
Ddrd = &B00001111 ' [4]Input for Serial | [3,2,1,0] Output for select,start,l,r
Ddra = &B00000011 ' [1]Output for clk | [0]Output for latch

'PINx - Port X Input Pins Register (READING)
'To READ the values on the pins of PortX you read the values that are on the pin
'register.

'PORTx - Port X Data Register. (OUTPUTTING)
'Stores logic values currently being OUTPUTTED on the physical pinds of PORTx
Portb = &B11111111
Portd = &B00011111           'Internal pullup on D.5 - set to input but outputting 1
Porta = &B00000010

controller_latch          Alias PORTa.0        'Output
controller_clk            Alias PORTa.1        'Output
controller_serial         Alias PIND.5         'Input

pad_a                     Alias PORTb.0
pad_b                     Alias PORTb.1
pad_x                     Alias PORTb.2
pad_y                     Alias PORTb.3

pad_up                    Alias PORTb.4
pad_down                  Alias PORTb.5
pad_left                  Alias PORTb.6
pad_right                 Alias PORTb.7

pad_select                Alias PORTd.0
pad_start                 Alias PORTd.1

pad_l                     Alias PORTd.2
pad_r                     Alias PORTd.3


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

PollController:

'Controller clock normally high
controller_clk = 1

' Reset controller states.
portb = &B11111111
portd = &B00001111

'12uS wide data latch pulse
'At 8MHz each loop is 0.375uS
controller_latch = 1
ldi R17, $21                                                '
data_latch_pulse_width:
dec R17
brne data_latch_pulse_width
controller_latch = 0


''''''''''  B BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
b_clock_pulse_width:
dec R17
brne b_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_b = 0
End If

ldi R17, $10                                                '
b_low_pulse_width:
dec R17
brne b_low_pulse_width
''''''''''  B BUTTON END '''''''''''''''''''''''

''''''''''  Y BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
y_clock_pulse_width:
dec R17
brne y_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_y = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
y_low_pulse_width:
dec R17
brne y_low_pulse_width
''''''''''  Y BUTTON END '''''''''''''''''''''''

''''''''''  SELECT BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
select_clock_pulse_width:
dec R17
brne select_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_select = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
select_low_pulse_width:
dec R17
brne select_low_pulse_width
''''''''''  SELECT BUTTON END '''''''''''''''''''''''

''''''''''  START BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
start_clock_pulse_width:
dec R17
brne start_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_start = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
start_low_pulse_width:
dec R17
brne start_low_pulse_width
''''''''''  START BUTTON END '''''''''''''''''''''''

''''''''''  up BUTTON up '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
up_clock_pulse_width:
dec R17
brne up_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_up = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
up_low_pulse_width:
dec R17
brne up_low_pulse_width
''''''''''  up BUTTON END '''''''''''''''''''''''

''''''''''  down BUTTON down '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
down_clock_pulse_width:
dec R17
brne down_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_down = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
down_low_pulse_width:
dec R17
brne down_low_pulse_width
''''''''''  down BUTTON END '''''''''''''''''''''''

''''''''''  left BUTTON left '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
left_clock_pulse_width:
dec R17
brne left_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_left = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
left_low_pulse_width:
dec R17
brne left_low_pulse_width
''''''''''  left BUTTON END '''''''''''''''''''''''


''''''''''  right BUTTON right '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
right_clock_pulse_width:
dec R17
brne right_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_right = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
right_low_pulse_width:
dec R17
brne right_low_pulse_width
''''''''''  right BUTTON END '''''''''''''''''''''''

''''''''''  a BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
a_clock_pulse_width:
dec R17
brne a_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_a = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
a_low_pulse_width:
dec R17
brne a_low_pulse_width
''''''''''  a BUTTON END '''''''''''''''''''''''

''''''''''  x BUTTON x '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
x_clock_pulse_width:
dec R17
brne x_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_x = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
x_low_pulse_width:
dec R17
brne x_low_pulse_width
''''''''''  x BUTTON END '''''''''''''''''''''''


''''''''''  l BUTTON l '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
l_clock_pulse_width:
dec R17
brne l_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_l = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
l_low_pulse_width:
dec R17
brne l_low_pulse_width
''''''''''  l BUTTON END '''''''''''''''''''''''

''''''''''  r BUTTON r '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
r_clock_pulse_width:
dec R17
brne r_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     pad_r = 0
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
r_low_pulse_width:
dec R17
brne r_low_pulse_width
''''''''''  r BUTTON END '''''''''''''''''''''''

''''''''''''''''''''''''''
''' UNMAPPED BUTTONS '''''
''''''''''''''''''''''''''

''''''''''  unmap1 BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
unmap1_clock_pulse_width:
dec R17
brne unmap1_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
unmap1_low_pulse_width:
dec R17
brne unmap1_low_pulse_width
''''''''''  unmap1 BUTTON END '''''''''''''''''''''''
''''''''''  unmap2 BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
unmap2_clock_pulse_width:
dec R17
brne unmap2_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
unmap2_low_pulse_width:
dec R17
brne unmap2_low_pulse_width
''''''''''  unmap2 BUTTON END '''''''''''''''''''''''
''''''''''  unmap3 BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
unmap3_clock_pulse_width:
dec R17
brne unmap3_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
unmap3_low_pulse_width:
dec R17
brne unmap3_low_pulse_width
''''''''''  unmap3 BUTTON END '''''''''''''''''''''''
''''''''''  unmap4 BUTTON START '''''''''''''''''''''''
controller_clk = 1                'Controller latches data rising edge
ldi R17, $10                                                '
unmap4_clock_pulse_width:
dec R17
brne unmap4_clock_pulse_width
controller_clk = 0                'CPU fetches falling edge

' First sample is on the falling edge. (for B Button)
If controller_serial = 0 Then
     NOP
End If
'12 uS Remainder of Low Pulse
ldi R17, $10                                                '
unmap4_low_pulse_width:
dec R17
brne unmap4_low_pulse_width
''''''''''  unmap4 BUTTON END '''''''''''''''''''''''

'Trailing high...
Waitms 16

'ldi R17, $FF                                                '
'trailing_pulse_width:
'dec R17
'brne trailing_pulse_width

Goto PollController