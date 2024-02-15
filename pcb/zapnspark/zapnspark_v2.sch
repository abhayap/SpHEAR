EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:zapnspark_v2-cache
EELAYER 25 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L R R6
U 1 1 570D7D4E
P 6300 4300
F 0 "R6" V 6380 4300 50  0000 C CNN
F 1 "150K" V 6300 4300 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 6230 4300 30  0001 C CNN
F 3 "" H 6300 4300 30  0000 C CNN
	1    6300 4300
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 570D7DC6
P 6300 3700
F 0 "R3" V 6380 3700 50  0000 C CNN
F 1 "150K" V 6300 3700 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 6230 3700 30  0001 C CNN
F 3 "" H 6300 3700 30  0000 C CNN
	1    6300 3700
	1    0    0    -1  
$EndComp
$Comp
L BC559 Q1
U 1 1 57166EFF
P 6650 3300
F 0 "Q1" H 6850 3375 50  0000 L CNN
F 1 "BC559" H 6850 3300 50  0000 L CNN
F 2 "Transistors_TO-220:TO-220_Bipolar-BCE_Vertical" H 6850 3225 50  0001 L CIN
F 3 "" H 6650 3300 50  0000 L CNN
	1    6650 3300
	1    0    0    1   
$EndComp
$Comp
L BC559 Q2
U 1 1 57166F96
P 6650 4650
F 0 "Q2" H 6850 4725 50  0000 L CNN
F 1 "BC559" H 6850 4650 50  0000 L CNN
F 2 "Transistors_TO-220:TO-220_Bipolar-BCE_Vertical" H 6850 4575 50  0001 L CIN
F 3 "" H 6650 4650 50  0000 L CNN
	1    6650 4650
	1    0    0    -1  
$EndComp
$Comp
L ZENER D1
U 1 1 5716709C
P 7500 3300
F 0 "D1" H 7500 3400 50  0000 C CNN
F 1 "6.2V" H 7500 3200 50  0000 C CNN
F 2 "Discret:D5" H 7500 3300 60  0001 C CNN
F 3 "" H 7500 3300 60  0000 C CNN
	1    7500 3300
	0    1    1    0   
$EndComp
$Comp
L ZENER D3
U 1 1 571673BC
P 7500 4650
F 0 "D3" H 7500 4750 50  0000 C CNN
F 1 "6.2V" H 7500 4550 50  0000 C CNN
F 2 "Discret:D5" H 7500 4650 60  0001 C CNN
F 3 "" H 7500 4650 60  0000 C CNN
	1    7500 4650
	0    -1   -1   0   
$EndComp
$Comp
L CP C3
U 1 1 57167515
P 5800 4000
F 0 "C3" H 5825 4100 50  0000 L CNN
F 1 "33uF" H 5825 3900 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D8_L13_P3.8" H 5838 3850 30  0001 C CNN
F 3 "" H 5800 4000 60  0000 C CNN
	1    5800 4000
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 5716776E
P 5950 3300
F 0 "C2" H 5975 3400 50  0000 L CNN
F 1 "100nF" H 5975 3200 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Rect_L13_W4_P10" H 5988 3150 30  0001 C CNN
F 3 "" H 5950 3300 60  0000 C CNN
	1    5950 3300
	0    1    1    0   
$EndComp
$Comp
L C C4
U 1 1 571677BE
P 5950 4650
F 0 "C4" H 5975 4750 50  0000 L CNN
F 1 "100nF" H 5975 4550 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Rect_L13_W4_P10" H 5988 4500 30  0001 C CNN
F 3 "" H 5950 4650 60  0000 C CNN
	1    5950 4650
	0    1    1    0   
$EndComp
$Comp
L R R4
U 1 1 571678FC
P 5450 3750
F 0 "R4" V 5530 3750 50  0000 C CNN
F 1 "5.1K" V 5450 3750 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 5380 3750 30  0001 C CNN
F 3 "" H 5450 3750 30  0000 C CNN
	1    5450 3750
	0    1    1    0   
$EndComp
$Comp
L ZENER D2
U 1 1 5716796F
P 5050 4000
F 0 "D2" H 5050 4100 50  0000 C CNN
F 1 "10V" H 5050 3900 50  0000 C CNN
F 2 "Discret:D5" H 5050 4000 60  0001 C CNN
F 3 "" H 5050 4000 60  0000 C CNN
	1    5050 4000
	0    1    1    0   
$EndComp
$Comp
L Earth #PWR01
U 1 1 57167A20
P 5800 4250
F 0 "#PWR01" H 5800 4000 50  0001 C CNN
F 1 "Earth" H 5800 4100 50  0001 C CNN
F 2 "" H 5800 4250 60  0000 C CNN
F 3 "" H 5800 4250 60  0000 C CNN
	1    5800 4250
	1    0    0    -1  
$EndComp
$Comp
L Earth #PWR02
U 1 1 57167A3F
P 5050 4300
F 0 "#PWR02" H 5050 4050 50  0001 C CNN
F 1 "Earth" H 5050 4150 50  0001 C CNN
F 2 "" H 5050 4300 60  0000 C CNN
F 3 "" H 5050 4300 60  0000 C CNN
	1    5050 4300
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 57167AE5
P 4500 4900
F 0 "R5" V 4580 4900 50  0000 C CNN
F 1 "2.21K" V 4500 4900 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 4430 4900 30  0001 C CNN
F 3 "" H 4500 4900 30  0000 C CNN
	1    4500 4900
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 571680A3
P 4500 3050
F 0 "R2" V 4580 3050 50  0000 C CNN
F 1 "2.21K" V 4500 3050 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 4430 3050 30  0001 C CNN
F 3 "" H 4500 3050 30  0000 C CNN
	1    4500 3050
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 57168127
P 4750 2800
F 0 "R1" V 4830 2800 50  0000 C CNN
F 1 "470" V 4750 2800 50  0000 C CNN
F 2 "Resistors_ThroughHole:Resistor_Horizontal_RM10mm" V 4680 2800 30  0001 C CNN
F 3 "" H 4750 2800 30  0000 C CNN
	1    4750 2800
	0    1    1    0   
$EndComp
$Comp
L CP C1
U 1 1 5716818E
P 4150 3050
F 0 "C1" H 4175 3150 50  0000 L CNN
F 1 "47uF" H 4175 2950 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D8_L13_P3.8" H 4188 2900 30  0001 C CNN
F 3 "" H 4150 3050 60  0000 C CNN
	1    4150 3050
	1    0    0    -1  
$EndComp
$Comp
L Earth #PWR03
U 1 1 5716857A
P 4150 3300
F 0 "#PWR03" H 4150 3050 50  0001 C CNN
F 1 "Earth" H 4150 3150 50  0001 C CNN
F 2 "" H 4150 3300 60  0000 C CNN
F 3 "" H 4150 3300 60  0000 C CNN
	1    4150 3300
	1    0    0    -1  
$EndComp
$Comp
L Earth #PWR04
U 1 1 57168822
P 4500 5100
F 0 "#PWR04" H 4500 4850 50  0001 C CNN
F 1 "Earth" H 4500 4950 50  0001 C CNN
F 2 "" H 4500 5100 60  0000 C CNN
F 3 "" H 4500 5100 60  0000 C CNN
	1    4500 5100
	1    0    0    -1  
$EndComp
$Comp
L Earth #PWR05
U 1 1 57168E5A
P 8250 4550
F 0 "#PWR05" H 8250 4300 50  0001 C CNN
F 1 "Earth" H 8250 4400 50  0001 C CNN
F 2 "" H 8250 4550 60  0000 C CNN
F 3 "" H 8250 4550 60  0000 C CNN
	1    8250 4550
	1    0    0    -1  
$EndComp
$Comp
L Earth #PWR06
U 1 1 57168E7D
P 3800 4500
F 0 "#PWR06" H 3800 4250 50  0001 C CNN
F 1 "Earth" H 3800 4350 50  0001 C CNN
F 2 "" H 3800 4500 60  0000 C CNN
F 3 "" H 3800 4500 60  0000 C CNN
	1    3800 4500
	1    0    0    -1  
$EndComp
Text GLabel 8600 2900 2    60   Input ~ 0
XLR3
Text GLabel 8800 4400 2    60   Input ~ 0
XLR1
Text GLabel 8600 5100 2    60   Input ~ 0
XLR2
Text GLabel 3550 3550 0    60   Input ~ 0
CDRN
Text GLabel 3550 3900 0    60   Input ~ 0
CGND
Text GLabel 3550 4300 0    60   Input ~ 0
CSRC
$Comp
L CONN_01X03 P2
U 1 1 57168A6B
P 8450 4000
F 0 "P2" H 8450 4200 50  0000 C CNN
F 1 "CONN_01X03" V 8550 4000 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x03" H 8450 4000 60  0001 C CNN
F 3 "" H 8450 4000 60  0000 C CNN
	1    8450 4000
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X03 P1
U 1 1 57168EF3
P 4200 3950
F 0 "P1" H 4200 4150 50  0000 C CNN
F 1 "CONN_01X03" V 4300 3950 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x03" H 4200 3950 60  0001 C CNN
F 3 "" H 4200 3950 60  0000 C CNN
	1    4200 3950
	-1   0    0    1   
$EndComp
Wire Wire Line
	6300 3550 6300 3300
Wire Wire Line
	6100 3300 6450 3300
Wire Wire Line
	6300 3850 6300 4150
Wire Wire Line
	6750 3500 6750 4450
Wire Wire Line
	7500 3500 7500 4450
Connection ~ 6300 3300
Wire Wire Line
	6100 4650 6450 4650
Wire Wire Line
	6300 4450 6300 4650
Connection ~ 6300 4650
Wire Wire Line
	6050 4000 7500 4000
Connection ~ 6750 4000
Connection ~ 6300 4000
Connection ~ 7500 4000
Wire Wire Line
	4500 3300 5800 3300
Wire Wire Line
	4500 4650 5800 4650
Wire Wire Line
	4150 2800 4600 2800
Wire Wire Line
	4500 2900 4500 2800
Connection ~ 4500 2800
Wire Wire Line
	4150 2900 4150 2800
Wire Wire Line
	4150 3300 4150 3200
Wire Wire Line
	4900 2800 5050 2800
Wire Wire Line
	5050 2800 5050 3800
Wire Wire Line
	5300 3750 5050 3750
Connection ~ 5050 3750
Wire Wire Line
	5600 3750 6050 3750
Wire Wire Line
	5800 3750 5800 3850
Wire Wire Line
	6050 3750 6050 4000
Connection ~ 5800 3750
Wire Wire Line
	5050 4300 5050 4200
Wire Wire Line
	5800 4250 5800 4150
Wire Wire Line
	4500 5100 4500 5050
Wire Wire Line
	6750 3100 6750 2900
Wire Wire Line
	6750 2900 8600 2900
Wire Wire Line
	6750 4850 6750 5100
Wire Wire Line
	6750 5100 8600 5100
Wire Wire Line
	7500 3100 7500 2900
Connection ~ 7500 2900
Wire Wire Line
	7500 4850 7500 5100
Connection ~ 7500 5100
Wire Wire Line
	4500 3550 3550 3550
Connection ~ 4500 3300
Wire Wire Line
	3550 4300 4500 4300
Connection ~ 4500 4650
Wire Wire Line
	8250 4400 8800 4400
Wire Wire Line
	3800 3900 3800 4500
Wire Wire Line
	3550 3900 3800 3900
Connection ~ 8050 2900
Wire Wire Line
	8050 4000 8250 4000
Connection ~ 8050 5100
Connection ~ 4500 3550
Connection ~ 4500 4300
Wire Wire Line
	4500 3850 4400 3850
Wire Wire Line
	4500 3200 4500 3850
Wire Wire Line
	3800 4200 4600 4200
Connection ~ 3800 4200
Wire Wire Line
	8050 2900 8050 3900
Wire Wire Line
	8050 3900 8250 3900
Connection ~ 8250 4400
Wire Wire Line
	8250 4100 8250 4550
Wire Wire Line
	8050 4000 8050 5100
Wire Wire Line
	4500 4050 4500 4750
Wire Wire Line
	4500 4050 4400 4050
Wire Wire Line
	4400 3950 4600 3950
Wire Wire Line
	4600 3950 4600 4200
$Comp
L CP C5
U 1 1 5AC19F11
P 6050 4150
F 0 "C5" H 6075 4250 50  0000 L CNN
F 1 "33uF" H 6075 4050 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D8_L13_P3.8" H 6088 4000 30  0001 C CNN
F 3 "" H 6050 4150 60  0000 C CNN
	1    6050 4150
	1    0    0    -1  
$EndComp
$Comp
L Earth #PWR07
U 1 1 5AC1A195
P 6050 4300
F 0 "#PWR07" H 6050 4050 50  0001 C CNN
F 1 "Earth" H 6050 4150 50  0001 C CNN
F 2 "" H 6050 4300 50  0000 C CNN
F 3 "" H 6050 4300 50  0000 C CNN
	1    6050 4300
	1    0    0    -1  
$EndComp
Connection ~ 6050 4000
$EndSCHEMATC
