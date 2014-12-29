﻿'' =================================================================================================
''
''   File....... dc22_badge_human.spin
'' 
''   Authors.... Jon "JonnyMac" McPhalen and Ryan "1o57" Clarke
''               MIT License
''               -- see below for terms of use
''
''   E-mail..... jon@jonmcphalen.com
''               1o57@10000100001.org 
''
'' =================================================================================================

{{

  Welcome to Defcon 22. This year we would like to invite you to experiment more fully with your
  badge -- feel free to play around with code.

  You can load directly to RAM [F10] if you don't want to blast your firmware, but even if you do,
  we are giving you the source from the start. The source provides a nice badge template with extra
  objects so that you can experiment with LEDs, buttons, IR (in and out), timing, speed changes, etc.

  Completing the challenge will at some point require you to 'update' your badge -- but for now, how
  about changing your LED pattern? It's easier than you think! If you need help, feel free to stop
  by the Hardware Hacking Village, or simply ask someone who has a different pattern than yours.
  Create a new pattern -- have fun!

}}


con { timing }

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000                                          ' use 5MHz crystal

  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq               ' system freq as a constant
  MS_001   = CLK_FREQ / 1_000                                   ' ticks in 1ms
  US_001   = CLK_FREQ / 1_000_000                               ' ticks in 1us


  ' speed settings for power control/reduction
  ' -- use with clkset() instruction

  XT1_P16  = %0_1_1_01_111                                      ' 16x crystal (5MHz) = 80MHz
  XT1_PL8  = %0_1_1_01_110 
  XT1_PL4  = %0_1_1_01_101                                      
  XT1_PL2  = %0_1_1_01_100
  XT1_PL1  = %0_1_1_01_011
  RC_SLOW  = %0_0_0_00_001                                      ' 20kHz


  ' program speed and terminal baud
  
  B_SPEED  = 20     { MHz }
  T_BAUD   = 57_600 { for terminal io }


  IR_FREQ  = 36_000 { matches receiver on DC22 badge }
  IR_BAUD  = 2400   { max supported using IR connection }
  IR_BLAST = $DC22
  IR_1337  = $1337

con { io pins }

  RX1    = 31                                                   ' programming / terminal
  TX1    = 30
  
  SDA    = 29                                                   ' eeprom / i2c
  SCL    = 28

  PAD3   = 27                                                   ' touch pads
  PAD2   = 26
  PAD1   = 25
  PAD0   = 24
  
  LED7   = 23                                                   ' leds
  LED6   = 22
  LED5   = 21
  LED4   = 20
  LED3   = 19
  LED2   = 18
  LED1   = 17
  LED0   = 16

  IR_IN  = 15                                                   ' ir input
  IR_OUT = 14                                                   ' ir output
                                                                
   
                                             


con { io configuration }

  IS_OFF    =  0                                                ' all bits off   
  IS_ON     = -1                                                ' all bits on    

  IS_LOW    =  0                                                
  IS_HIGH   = -1                                                

  IS_INPUT  =  0
  IS_OUTPUT = -1
  

con { pst formatting }

  #1, HOME, GOTOXY, #8, BKSP, TAB, LF, CLREOL, CLRDN, CR
  #14, GOTOX, GOTOY, CLS


obj

  term : "cryptofullduplexserial64"                             ' serial io for terminal
  irtx : "jm_sircs_tx"                                          ' SIRCS output
  irrx : "jm_sircs_rx"                                          ' SIRCS input
  prng : "jm_prng"                                              ' random #s
  tmr1 : "jm_eztimer"                                           ' asynchronous timer
  ee   : "jm_24xx512"                                           ' eeprom access
  pwm  : "jm_pwm8"                                              ' pwm for LEDs
 

var

  long  ms001                                                   ' system ticks per millisecond
  long  us001                                                   ' system ticks per microsecond
  long  lives

  
pub main | idx, last, button, code
           
  setup                                                         ' setup badge io and objects

   
  pause(800)
  term.tx(CR)
  term.str(string("Never gonna give you up"))                            
  term.tx(CR)
  term.str(string("Never gonna let you down")) 
  term.tx(CR)
  term.str(string("Never gonna run around and desert you"))
  term.tx(CR)
  term.str(string("Never gonna make you cry"))
  term.tx(CR)
  term.str(string("Never gonna say goodbye"))  
  term.tx(CR)
  term.str(string("Never gonna tell a lie and hurt you"))
  term.tx(CR)
  term.tx(CR)
  term.str(string("Thank you for loading my binary. #Defcon22 - @joshcano @mrisher"))
  start_animation(@Chaser, 0)
  
    
  repeat 
    repeat
      irrx.enable
      button := read_pads
      code := irrx.rxcheck
      if (code > -1)
        if (code == IR_BLAST)
          start_animation(@InOut, 0)
          'term.str(string("goon"))
          'term.tx(CR)
          start_animation(@Cylon, 0) 
        elseif (code == IR_1337)  
          'term.str(string("1337"))
          'term.tx(CR)
          if(lives == $0)
            set_leds($0)
            stop_animation
            pause(5000)
            reboot
          else
            start_animation(@IsHit, 0)
            pause(5000)
            lives >>= 1
            start_animation(@Chaser, 0)
            irrx.enable
        else
          'term.str(string("no match"))
        irrx.enable
          
  
      case button
        %1000:
          'term.str(string("goonBlast"))
          'term.tx(CR)
          irtx.tx(IR_BLAST,16,3)       
          pause(250) 
        %0100:
          irtx.tx(IR_1337,16,3)
          'term.str(string("1337"))       
          'term.tx(CR)  
          pause(250)
        %0010:
          irtx.tx(IR_1337,16,3)
          'term.str(string("1337"))       
          'term.tx(CR)
          pause(250)        
        %0001: 
          irtx.tx(IR_1337,16,3)  
          'term.str(string("1337"))       
          'term.tx(CR)
          pause(250)
  
          
  
'   repeat until(read_pads <> %0000) ' SENDS PAYLOAD DD22
'   
'     irtx.tx(IR_BLAST,16, 3)
'     start_animation(@Cylon, 0) 
'     pause(1000)                                  ' END SENDING PAYLOAD
     
     
  'repeat until (read_pads <> %0000)
  ' irrx.enable
  ' term.hex(irrx.rx, 4)
  ' term.tx(CR)
  ' start_animation(@Cylon, 0)                
  ' pause(250)
   
   'repeat
   ''  repeat
   '    term.hex(irrx.rx, 4)
   '    button := irrx.rx
   '  until((button <> IR_BLAST) and (button <> last))
   '  last := button
     
   '  case button
   '    IR_BLAST:
   '      start_animation(@Police, 0)
   '      term.caesar(@Diver)
   '      pause(250)
   
   'irrx.enable
   'case irrx.rx
    
    '%IR_BLAST
   'pause(250)
 
 ' repeat                                                        
  '  repeat
   '   button := read_pads                                       ' wait for input
    'until ((button <> %0000) and (button <> last))              ' must be new
    'last := button                                              ' save for next check
    
  ' repeat                                                        
  '  repeat
  '    button := read_pads                                       ' wait for input
  '  until ((button <> %0000) and (button <> last))              ' must be new
  '  last := button                                              ' save for next check
    
  '  case button
  '    %0001:
  '      start_animation(@Cylon, 0)
  '      irtx.tx(IR_BLAST, 16, 3)                              ' start animation
  '      term.caesar(@Detective)                                 ' display crypto string
  '      pause(250)    

pub setup

'' Setup badge IO and objects
'' -- set speed before starting other objects

  set_speed(B_SPEED)                                            ' set badge speed (MHz)
  
  set_leds(%00000000)                                           ' LEDs off

  term.start(RX1, TX1, %0000, T_BAUD)                           ' start terminal

  prng.seed(cnt << 2, cnt, $1057, -cnt, cnt ~> 2)               ' seed prng (random #s)
  irtx.start(IR_OUT, IR_FREQ)
  irrx.start(IR_IN)
  lives := 255
 

con

  { ----------------------------- }
  {  B A D G E   F E A T U R E S  }
  { ----------------------------- }


pub set_speed(mhz)

'' Sets badge clock speed
'' -- sets timing variables ms001 and us001
'' -- note: objects may require restart after speed change

  case mhz
     0: clkset(RC_SLOW,     20_000)                             ' super low power -- sleep mode only!
     5: clkset(XT1_PL1,  5_000_000)
    10: clkset(XT1_PL2, 10_000_000)
    20: clkset(XT1_PL4, 20_000_000)
    40: clkset(XT1_PL8, 40_000_000) 
    80: clkset(XT1_P16, 80_000_000)

  waitcnt(cnt + (clkfreq / 100))                                ' wait ~10ms

  ms001 := clkfreq / 1_000                                      ' set ticks per millisecond for waitcnt
  us001 := clkfreq / 1_000_000                                  ' set ticks per microsecond for waitcnt

  
pub set_leds(pattern)

'' Sets LED pins to output and writes pattern to them
'' -- swaps LSB/MSB for correct binary output

  outa[LED0..LED7] := pattern                                   ' write pattern to LEDs
  dira[LED0..LED7] := IS_HIGH                                   ' make LED pins outputs

  
pub read_pads

'' Reads and returns state of touch pad inputs
'' -- swaps LSB/MSB for correct binary input

  outa[PAD3..PAD0] := IS_HIGH                                   ' charge pads (all output high)   
  dira[PAD3..PAD0] := IS_OUTPUT
    
  dira[PAD3..PAD0] := IS_INPUT                                  ' float pads   
  pause(50)                                                     ' -- allow touch to discharge

  return (!ina[PAD3..PAD0] & $0F) >< 4                          ' return "1" for touched pads


con

  { --------------- }
  {  L E D   F U N  }
  { --------------- }


var

  long  anicog                                                  ' cog running animation
  long  anistack[32]                                            ' stack space for Spin cog
  

pri start_animation(p_table, cycles)

'' Start animation in background cog
'' -- allows LED animation while doing other processes
'' -- p_table is pointer (address of) animation table
'' -- set cycles to 0 to run without stopping

  stop_animation
  
  anicog := cognew(run_animation(p_table, cycles), @anistack) + 1  

  return anicog                                                 ' return cog used


pri stop_animation

'' Stop animation if currently running

  if (anicog)                                                   ' if running
    cogstop(anicog - 1)                                         ' stop the cog
    anicog := 0                                                 ' mark stopped 


pri run_animation(p_table, cycles) | p_leds

'' Run animation
'' -- p_table is pointer (address of) animation table
'' -- cycles is number of iterations to run
''    * 0 cycles runs "forever"
'' -- usually called with start_animation()

  if (cycles =< 0)
    cycles := POSX                                              ' run "forever"

  if  (p_table == @IsHit)
    repeat cycles
      set_leds($FF)
      pause(64)
      set_leds(lives >> 1)
      pause(64)
  else
  
   repeat cycles
     p_leds := p_table                                           ' point to table
     repeat byte[p_leds++]        
                                  ' repeat for steps in table
       set_leds(byte[p_leds++])                                  ' update leds
       pause(byte[p_leds++])                                     ' hold
      
  anicog := 0                                                   ' mark stopped
  cogstop(cogid)                                                ' stop this cog
    

dat

  ' Animation tables for LEDs
  ' -- 1st byte is number of steps in animation sequence
  ' -- each step holds pattern and hold time (ms)
  ' -- for delays > 255, duplicate pattern + delay

  Boom      byte   (@Boom_X - @Boom) / 2 + 1
                 byte      %11111111, 125
                 byte      %00000000, 125
  Boom_X
  
  Cylon        byte      (@Cylon_X - @Cylon) / 2 + 1 
                   byte      %10000000, 125
                   byte      %01000000, 125
                   byte      %00100000, 125 
                   byte      %00010000, 125
                   byte      %00001000, 125  
                   byte      %00000100, 125  
                   byte      %00000010, 125  
                   byte      %00000001, 125
                   byte      %00000010, 125
                   byte      %00000100, 125
                   byte      %00001000, 125  
                   byte      %00010000, 125  
                   byte      %00100000, 125    
  Cylon_X     byte      %01000000, 125

                    
  Chaser       byte      (@Chaser_X - @Chaser) / 2 + 1      
                    byte      %10010010,  75
                    byte      %00100100,  75
  Chaser_X    byte      %01001001,  75

                     
  InOut         byte      (@InOut_X - @InOut) / 2 + 1  
                   byte      %10000001, 100
                   byte      %01000010, 100
                   byte      %00100100, 100
                   byte      %00011000, 100
                   byte      %00100100, 100
  InOut_X     byte      %01000010, 100

          
  Police       byte      (@Police_X - @Police) / 2 + 1 
                  byte      %11001100,  75
                  byte      %11110000,  75
                  byte      %11001100,  75
                  byte      %11110000,  75         
                  byte      %00001111,  75
                  byte      %00110011,  75
                  byte      %00001111,  75
  Police_X    byte      %00110011,  75
  
  
  Sudo byte (@Sudo_x - @Sudo) / 2 + 1
           byte      %00011000, 75
           byte      %00100100, 75
           byte      %01000010, 75
           byte      %10000001, 75
           byte      %01000010, 75
           byte      %00100100, 75
           byte      %00011000, 75
  Sudo_X
  
  IsHit    byte    %0
          
  
con   

  { ------------- }
  {  B A S I C S  }
  { ------------- }


pub pause(ms) | t

'' Delay program in milliseconds
'' -- ensure set_speed() used before calling

  t := cnt                                                      ' sync to system counter
  repeat (ms #>= 0)                                             ' delay > 0
    waitcnt(t += ms001)                                         ' hold 1ms


pub high(pin)

'' Makes pin output and high

  outa[pin] := IS_HIGH
  dira[pin] := IS_OUTPUT


pub low(pin)

'' Makes pin output and low

  outa[pin] := IS_LOW
  dira[pin] := IS_OUTPUT


pub toggle(pin)

'' Toggles pin state

  !outa[pin]
  dira[pin] := IS_OUTPUT


pub input(pin)

'' Makes pin input and returns current state

  dira[pin] := IS_INPUT

  return ina[pin]


pub pulse_out(pin, us) | state

'' Generate pulse on pin for us microseconds
'' -- ensure set_speed() used before calling
'' -- makes pin output
'' -- pulse out is opposite of pin's input state
'' -- blocks until pulse is finished (to clear counter)

  us *= us001                                                   ' convert us to system ticks
  state := ina[pin]                                             ' read incoming state of pin

  if (ctra == 0)                                                ' ctra available?
    if (state == 0)                                             ' low-high-low
      low(pin)                                                  ' set to output
      frqa := 1 
      phsa := -us                                               ' set timing
      ctra := (%00100 << 26) | pin                              ' start the pulse
      repeat
      until (phsa => 0)                                         ' let pulse finish
                          
    else                                                        ' high-low-high
      high(pin)
      frqa := -1
      phsa := us
      ctra := (%00100 << 26) | pin
      repeat
      until (phsa < 0) 

    ctra := IS_OFF                                              ' release counter
    return true

  elseif (ctrb == 0)               
    if (state == 0)                
      low(pin)                     
      frqb := 1 
      phsb := -us               
      ctrb := (%00100 << 26) | pin 
      repeat
      until (phsb => 0)            
                          
    else                           
      high(pin)
      frqb := -1
      phsb := us
      ctrb := (%00100 << 26) | pin
      repeat
      until (phsb < 0) 

    ctrb := IS_OFF                     
    return true
  
  else
    return false                                                ' alert user of error
  

pub set_freq(ctrx, px, fx)

'' Sets ctrx to frequency fx on pin px (NCO/SE mode)
'' -- fx in hz
'' -- use fx of 0 to stop counter that is running

  if (fx > 0)                             
    fx := ($8000_0000 / (clkfreq / fx)) << 1                    ' convert freq for NCO mode    
    case ctrx                                                    
      "a", "A":                                                  
        ctra := ((%00100) << 26) | px                           ' configure ctra for NCO on pin
        frqa := fx                                              ' set frequency
        dira[px] := IS_OUTPUT                                    
                                                                 
      "b", "B":                                                  
        ctrb := ((%00100) << 26) | px                            
        frqb := fx                                               
        dira[px] := IS_OUTPUT                                    
                                                                 
  else                                                           
    case ctrx                                                    
      "a", "A":                                                  
        ctra := IS_OFF                                          ' disable counter
        outa[px] := IS_OFF                                      ' clear pin/driver 
        dira[px] := IS_INPUT                                  
     
      "b", "B":                         
        ctrb := IS_OFF  
        outa[px] := IS_OFF  
        dira[px] := IS_INPUT 


dat
 
  RayNelson   byte      "IAIHG TPJNU QU CZR GALWXK DC MHR LANK FOTLA OTN LOYOC HPMPB PX HKICW",0
  Test4       byte      "DID YOU REALLY THINK THAT IT WOULD BE SO EASY? Really?  Just running strings?",0
  Greets      byte      16,77,85,66,83,69,67,85,32,74,69,32,84,85,86,83,69,68,32,74,77,85,68,74,79,32,74,77,69,13,0
  Detective   byte      13,74,85,82,69,82,32,71,66,32,79,82,84,86,65,32,86,32,88,65,66,74,32,83,86,65,81,32,85,78,69,66,89,81,13,0
  Scientist   byte      76,81,84,89,86,70,32,82,75,66,32,83,78,90,32,83,81,87,83,85,32,87,82,65,32,73,77,82,66,32,67,70,72,82,32,90,65,65,65,65,32,73,89,77,87,90,32,80,32,69,65,74,81,86,68,32,89,79,84,80,32,76,71,65,87,32,89,75,90,76,13,0
  Diver       byte      10,"DBI DRO PSBCD RKVP YP RSC ZRYXO XEWLOB PYVVYGON LI RSC VKCD XKWO DROX DRO COMYXN RKVP YP RSC XEWLOB",CR,0
  Driver      byte      "SOMETIMES WE HAVE ANSWERS AND DONT EVEN KNOW IT SO ENJOY THE VIEW JUST BE HAPPY",0
  Politician  byte      83,83,80,87,76,77,32,84,72,67,65,80,32,81,80,32,74,84,32,73,87,69,32,87,68,88,70,90,32,89,85,90,88,32,85,77,86,72,88,72,32,90,65,32,67,66,32,80,65,69,32,88,82,79,76,32,70,65,89,32,73,80,89,75,13,0
  Test3       byte      "ZGJG MTM LLPN C NTER MPMH TW",CR,0
  Football    byte      "IT MIGHT BE HELPFUL LATER IF YOU KNOW HOW TO GET TO EDEN OR AT LEAST THE WAY",0
  Mystery     byte      "OH A MYSTERY STRING I SHOULD HANG ON TO THIS FOR LATER I WONDER WHAT ITS FOR OR WHAT IT DECODES TO?",0

  
dat

  Cmd00       byte      $4e, $65, $76, $65, $72, $20, $67, $6f, $6e, $6e, $61, $20, $67, $69
                    byte      $76, $65, $20, $79, $6f, $75, $20, $75, $70
 
  Commands    word      @Cmd00
        
  

dat

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}  
