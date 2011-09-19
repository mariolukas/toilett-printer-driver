#include <SPI.h>
#include <Ethernet.h>
#include <Wire.h>
#include <TwigMotor.h>
#include <Servo.h>


#define DOWN 1
#define UP 0
#define TOP_STEPPER 0x30
#define FRONT_STEPPER 0x28
#define STEPS 48
#define MAXLENGTH 32

TwigMotor stepper(STEPS);
Servo servo_pen;


/* Font Declaration c64 8x8 */
unsigned char font[2048] =
{
	0x00, 0x00, 0x00, 0x00, 0x00, 0x66, 0x66, 0x3C,	// Char 096 (`)
	0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0,	// Char 097 (a)
	0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 098 (b)
	0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	// Char 099 (c)
	0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00,	// Char 100 (d)
	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0,	// Char 101 (e)
	0xCC, 0xCC, 0x33, 0x33, 0xCC, 0xCC, 0x33, 0x33,	// Char 102 (f)
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,	// Char 103 (g)
	0x00, 0x00, 0x00, 0x00, 0xCC, 0xCC, 0x33, 0x33,	// Char 104 (h)
	0xFF, 0xFE, 0xFC, 0xF8, 0xF0, 0xE0, 0xC0, 0x80,	// Char 105 (i)
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03,	// Char 106 (j)
	0x18, 0x18, 0x18, 0x1F, 0x1F, 0x18, 0x18, 0x18,	// Char 107 (k)
	0x00, 0x00, 0x00, 0x00, 0x0F, 0x0F, 0x0F, 0x0F,	// Char 108 (l)
	0x18, 0x18, 0x18, 0x1F, 0x1F, 0x00, 0x00, 0x00,	// Char 109 (m)
	0x00, 0x00, 0x00, 0xF8, 0xF8, 0x18, 0x18, 0x18,	// Char 110 (n)
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF,	// Char 111 (o)
	0x00, 0x00, 0x00, 0x1F, 0x1F, 0x18, 0x18, 0x18,	// Char 112 (p)
	0x18, 0x18, 0x18, 0xFF, 0xFF, 0x00, 0x00, 0x00,	// Char 113 (q)
	0x00, 0x00, 0x00, 0xFF, 0xFF, 0x18, 0x18, 0x18,	// Char 114 (r)
	0x18, 0x18, 0x18, 0xF8, 0xF8, 0x18, 0x18, 0x18,	// Char 115 (s)
	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0,	// Char 116 (t)
	0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0,	// Char 117 (u)
	0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07,	// Char 118 (v)
	0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	// Char 119 (w)
	0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00,	// Char 120 (x)
	0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF,	// Char 121 (y)
	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0xFF, 0xFF,	// Char 122 (z)
	0x00, 0x00, 0x00, 0x00, 0xF0, 0xF0, 0xF0, 0xF0,	// Char 123 ({)
	0x0F, 0x0F, 0x0F, 0x0F, 0x00, 0x00, 0x00, 0x00,	// Char 124 (|)
	0x18, 0x18, 0x18, 0xF8, 0xF8, 0x00, 0x00, 0x00,	// Char 125 (})
	0xF0, 0xF0, 0xF0, 0xF0, 0x00, 0x00, 0x00, 0x00,	// Char 126 (~)
	0xF0, 0xF0, 0xF0, 0xF0, 0x0F, 0x0F, 0x0F, 0x0F,	// Char 127 (.)

	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	// Char 032 ( )
	0x18, 0x18, 0x18, 0x18, 0x00, 0x00, 0x18, 0x00,	// Char 033 (!)
	0x66, 0x66, 0x66, 0x00, 0x00, 0x00, 0x00, 0x00,	// Char 034 (")
	0x3C, 0x60, 0x38, 0x6C, 0x38, 0x0C, 0x78, 0x00,	// Char 035 (#)
	0x18, 0x3E, 0x60, 0x3C, 0x06, 0x7C, 0x18, 0x00,	// Char 036 ($)
	0x62, 0x66, 0x0C, 0x18, 0x30, 0x66, 0x46, 0x00,	// Char 037 (%)
	0x3C, 0x66, 0x3C, 0x38, 0x67, 0x66, 0x3F, 0x00,	// Char 038 (&)
	0x00, 0x03, 0x06, 0x0C, 0x18, 0x30, 0x60, 0x00,	// Char 039 (')
	0x0C, 0x18, 0x30, 0x30, 0x30, 0x18, 0x0C, 0x00,	// Char 040 (()
	0x30, 0x18, 0x0C, 0x0C, 0x0C, 0x18, 0x30, 0x00,	// Char 041 ())
	0x00, 0x66, 0x3C, 0xFF, 0x3C, 0x66, 0x00, 0x00,	// Char 042 (*)
	0x3C, 0x66, 0x66, 0x6C, 0x66, 0x66, 0x7C, 0x60,	// Char 043 (+)
	0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x30,	// Char 044 (,)
	0x00, 0x00, 0x00, 0x7E, 0x00, 0x00, 0x00, 0x00,	// Char 045 (-)
	0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x18, 0x00,	// Char 046 (.)
	0x00, 0x00, 0x00, 0x7E, 0x00, 0x00, 0x00, 0x00,	// Char 047 (/)
	0x3C, 0x66, 0x6E, 0x76, 0x66, 0x66, 0x3C, 0x00,	// Char 048 (0)
	0x18, 0x18, 0x38, 0x18, 0x18, 0x18, 0x7E, 0x00,	// Char 049 (1)
	0x3C, 0x66, 0x06, 0x0C, 0x30, 0x60, 0x7E, 0x00,	// Char 050 (2)
	0x3C, 0x66, 0x06, 0x1C, 0x06, 0x66, 0x3C, 0x00,	// Char 051 (3)
	0x06, 0x0E, 0x1E, 0x66, 0x7F, 0x06, 0x06, 0x00,	// Char 052 (4)
	0x7E, 0x60, 0x7C, 0x06, 0x06, 0x66, 0x3C, 0x00,	// Char 053 (5)
	0x3C, 0x66, 0x60, 0x7C, 0x66, 0x66, 0x3C, 0x00,	// Char 054 (6)
	0x7E, 0x66, 0x0C, 0x18, 0x18, 0x18, 0x18, 0x00,	// Char 055 (7)
	0x3C, 0x66, 0x66, 0x3C, 0x66, 0x66, 0x3C, 0x00,	// Char 056 (8)
	0x3C, 0x66, 0x66, 0x3E, 0x06, 0x66, 0x3C, 0x00,	// Char 057 (9)
	0x66, 0x00, 0x3C, 0x66, 0x66, 0x66, 0x3C, 0x00,	// Char 058 (:)
	0x36, 0x00, 0x3C, 0x06, 0x3E, 0x66, 0x3E, 0x00,	// Char 059 (;)
	0x00, 0x00, 0x18, 0x00, 0x00, 0x18, 0x18, 0x30,	// Char 060 (<)
	0x00, 0x00, 0x7E, 0x00, 0x7E, 0x00, 0x00, 0x00,	// Char 061 (=)
	0x00, 0x00, 0x18, 0x00, 0x00, 0x18, 0x00, 0x00,	// Char 062 (>)
	0x3C, 0x66, 0x06, 0x0C, 0x18, 0x00, 0x18, 0x00,	// Char 063 (?)
	0x00, 0x18, 0x18, 0x7E, 0x18, 0x18, 0x00, 0x00,	// Char 064 (@)
	0x18, 0x3C, 0x66, 0x7E, 0x66, 0x66, 0x66, 0x00,	// Char 065 (A)
	0x7C, 0x66, 0x66, 0x7C, 0x66, 0x66, 0x7C, 0x00,	// Char 066 (B)
	0x3C, 0x66, 0x60, 0x60, 0x60, 0x66, 0x3C, 0x00,	// Char 067 (C)
	0x78, 0x6C, 0x66, 0x66, 0x66, 0x6C, 0x78, 0x00,	// Char 068 (D)
	0x7E, 0x60, 0x60, 0x78, 0x60, 0x60, 0x7E, 0x00,	// Char 069 (E)
	0x7E, 0x60, 0x60, 0x78, 0x60, 0x60, 0x60, 0x00,	// Char 070 (F)
	0x3C, 0x66, 0x60, 0x6E, 0x66, 0x66, 0x3C, 0x00,	// Char 071 (G)
	0x66, 0x66, 0x66, 0x7E, 0x66, 0x66, 0x66, 0x00,	// Char 072 (H)
	0x3C, 0x18, 0x18, 0x18, 0x18, 0x18, 0x3C, 0x00,	// Char 073 (I)
	0x1E, 0x0C, 0x0C, 0x0C, 0x0C, 0x6C, 0x38, 0x00,	// Char 074 (J)
	0x66, 0x6C, 0x78, 0x70, 0x78, 0x6C, 0x66, 0x00,	// Char 075 (K)
	0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x7E, 0x00,	// Char 076 (L)
	0x63, 0x77, 0x7F, 0x6B, 0x63, 0x63, 0x63, 0x00,	// Char 077 (M)
	0x66, 0x76, 0x7E, 0x7E, 0x6E, 0x66, 0x66, 0x00,	// Char 078 (N)
	0x3C, 0x66, 0x66, 0x66, 0x66, 0x66, 0x3C, 0x00,	// Char 079 (O)
	0x7C, 0x66, 0x66, 0x7C, 0x60, 0x60, 0x60, 0x00,	// Char 080 (P)
	0x3C, 0x66, 0x66, 0x66, 0x66, 0x3C, 0x0E, 0x00,	// Char 081 (Q)
	0x7C, 0x66, 0x66, 0x7C, 0x78, 0x6C, 0x66, 0x00,	// Char 082 (R)
	0x3C, 0x66, 0x60, 0x3C, 0x06, 0x66, 0x3C, 0x00,	// Char 083 (S)
	0x7E, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x00,	// Char 084 (T)
	0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x3C, 0x00,	// Char 085 (U)
	0x66, 0x66, 0x66, 0x66, 0x66, 0x3C, 0x18, 0x00,	// Char 086 (V)
	0x63, 0x63, 0x63, 0x6B, 0x7F, 0x77, 0x63, 0x00,	// Char 087 (W)
	0x66, 0x66, 0x3C, 0x18, 0x3C, 0x66, 0x66, 0x00,	// Char 088 (X)
	0x7E, 0x06, 0x0C, 0x18, 0x30, 0x60, 0x7E, 0x00,	// Char 089 (Y)
	0x66, 0x66, 0x66, 0x3C, 0x18, 0x18, 0x18, 0x00,	// Char 090 (Z)
	0x3C, 0x66, 0x06, 0x0C, 0x18, 0x00, 0x18, 0x00,	// Char 091 ([)
	0xC0, 0xC0, 0x30, 0x30, 0xC0, 0xC0, 0x30, 0x30,	// Char 092 (\)
	0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18,	// Char 093 (])
	0x33, 0x33, 0xCC, 0xCC, 0x33, 0x33, 0xCC, 0xCC,	// Char 094 (^)
	0x00, 0x00, 0x18, 0x00, 0x00, 0x18, 0x00, 0x00,	// Char 095 (_)

	0xF0, 0xF0, 0xF0, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 252 (.)
//	0xFF, 0xFF, 0xFF, 0x66, 0x66, 0x66, 0x3E, 0x00,	// Char 000 (.)

	0x00, 0x00, 0x3C, 0x06, 0x3E, 0x66, 0x3E, 0x00,	// Char 001 (.)
	0x00, 0x60, 0x60, 0x7C, 0x66, 0x66, 0x7C, 0x00,	// Char 002 (.)
	0x00, 0x00, 0x3C, 0x60, 0x60, 0x60, 0x3C, 0x00,	// Char 003 (.)
	0x00, 0x06, 0x06, 0x3E, 0x66, 0x66, 0x3E, 0x00,	// Char 004 (.)
	0x00, 0x00, 0x3C, 0x66, 0x7E, 0x60, 0x3C, 0x00,	// Char 005 (.)
	0x00, 0x0E, 0x18, 0x3E, 0x18, 0x18, 0x18, 0x00,	// Char 006 (.)
	0x00, 0x00, 0x3E, 0x66, 0x66, 0x3E, 0x06, 0x7C,	// Char 007 (.)
	0x00, 0x60, 0x60, 0x7C, 0x66, 0x66, 0x66, 0x00,	// Char 008 (.)
	0x00, 0x18, 0x00, 0x38, 0x18, 0x18, 0x3C, 0x00,	// Char 009 (.)
	0x00, 0x06, 0x00, 0x06, 0x06, 0x06, 0x06, 0x3C,	// Char 010 (.)
	0x00, 0x60, 0x60, 0x6C, 0x78, 0x6C, 0x66, 0x00,	// Char 011 (.)
	0x00, 0x38, 0x18, 0x18, 0x18, 0x18, 0x3C, 0x00,	// Char 012 (.)
	0x00, 0x00, 0x66, 0x7F, 0x7F, 0x6B, 0x63, 0x00,	// Char 013 (.)
	0x00, 0x00, 0x7C, 0x66, 0x66, 0x66, 0x66, 0x00,	// Char 014 (.)
	0x00, 0x00, 0x3C, 0x66, 0x66, 0x66, 0x3C, 0x00,	// Char 015 (.)
	0x00, 0x00, 0x7C, 0x66, 0x66, 0x7C, 0x60, 0x60,	// Char 016 (.)
	0x00, 0x00, 0x3E, 0x66, 0x66, 0x3E, 0x06, 0x06,	// Char 017 (.)
	0x00, 0x00, 0x7C, 0x66, 0x60, 0x60, 0x60, 0x00,	// Char 018 (.)
	0x00, 0x00, 0x3E, 0x60, 0x3C, 0x06, 0x7C, 0x00,	// Char 019 (.)
	0x00, 0x18, 0x7E, 0x18, 0x18, 0x18, 0x0E, 0x00,	// Char 020 (.)
	0x00, 0x00, 0x66, 0x66, 0x66, 0x66, 0x3E, 0x00,	// Char 021 (.)
	0x00, 0x00, 0x66, 0x66, 0x66, 0x3C, 0x18, 0x00,	// Char 022 (.)
	0x00, 0x00, 0x63, 0x6B, 0x7F, 0x3E, 0x36, 0x00,	// Char 023 (.)
	0x00, 0x00, 0x66, 0x3C, 0x18, 0x3C, 0x66, 0x00,	// Char 024 (.)
	0x00, 0x00, 0x7E, 0x0C, 0x18, 0x30, 0x7E, 0x00,	// Char 025 (.)
	0x00, 0x00, 0x66, 0x66, 0x66, 0x3E, 0x0C, 0x78,	// Char 026 (.)
	0x66, 0x3C, 0x66, 0x66, 0x66, 0x66, 0x3C, 0x00,	// Char 027 (.)
	0x0C, 0x12, 0x30, 0x7C, 0x30, 0x62, 0xFC, 0x00,	// Char 028 (.)
	0xDB, 0x3C, 0x66, 0x7E, 0x66, 0x66, 0x66, 0x00,	// Char 029 (.)
	0x00, 0x18, 0x18, 0x7E, 0x18, 0x18, 0x00, 0x00,	// Char 030 (.)
	0x00, 0x10, 0x30, 0x7F, 0x7F, 0x30, 0x10, 0x00,	// Char 031 (.)

	0x99, 0xFF, 0x99, 0x99, 0x99, 0x99, 0xC1, 0xFF,	// Char 128 (.)
	0xFF, 0xFF, 0xC3, 0xF9, 0xC1, 0x99, 0xC1, 0xFF,	// Char 129 (.)
	0xFF, 0x9F, 0x9F, 0x83, 0x99, 0x99, 0x83, 0xFF,	// Char 130 (.)
	0xFF, 0xFF, 0xC3, 0x9F, 0x9F, 0x9F, 0xC3, 0xFF,	// Char 131 (.)
	0xFF, 0xF9, 0xF9, 0xC1, 0x99, 0x99, 0xC1, 0xFF,	// Char 132 (.)
	0xFF, 0xFF, 0xC3, 0x99, 0x81, 0x9F, 0xC3, 0xFF,	// Char 133 (.)
	0xFF, 0xF1, 0xE7, 0xC1, 0xE7, 0xE7, 0xE7, 0xFF,	// Char 134 (.)
	0xFF, 0xFF, 0xC1, 0x99, 0x99, 0xC1, 0xF9, 0x83,	// Char 135 (.)
	0xFF, 0x9F, 0x9F, 0x83, 0x99, 0x99, 0x99, 0xFF,	// Char 136 (.)
	0xFF, 0xE7, 0xFF, 0xC7, 0xE7, 0xE7, 0xC3, 0xFF,	// Char 137 (.)
	0xFF, 0xF9, 0xFF, 0xF9, 0xF9, 0xF9, 0xF9, 0xC3,	// Char 138 (.)
	0xFF, 0x9F, 0x9F, 0x93, 0x87, 0x93, 0x99, 0xFF,	// Char 139 (.)
	0xFF, 0xC7, 0xE7, 0xE7, 0xE7, 0xE7, 0xC3, 0xFF,	// Char 140 (.)
	0xFF, 0xFF, 0x99, 0x80, 0x80, 0x94, 0x9C, 0xFF,	// Char 141 (.)
	0xFF, 0xFF, 0x83, 0x99, 0x99, 0x99, 0x99, 0xFF,	// Char 142 (.)
	0xFF, 0xFF, 0xC3, 0x99, 0x99, 0x99, 0xC3, 0xFF,	// Char 143 (.)
	0xFF, 0xFF, 0x83, 0x99, 0x99, 0x83, 0x9F, 0x9F,	// Char 144 (.)
	0xFF, 0xFF, 0xC1, 0x99, 0x99, 0xC1, 0xF9, 0xF9,	// Char 145 (.)
	0xFF, 0xFF, 0x83, 0x99, 0x9F, 0x9F, 0x9F, 0xFF,	// Char 146 (.)
	0xFF, 0xFF, 0xC1, 0x9F, 0xC3, 0xF9, 0x83, 0xFF,	// Char 147 (.)
	0xFF, 0xE7, 0x81, 0xE7, 0xE7, 0xE7, 0xF1, 0xFF,	// Char 148 (.)
	0xFF, 0xFF, 0x99, 0x99, 0x99, 0x99, 0xC1, 0xFF,	// Char 149 (.)
	0xFF, 0xFF, 0x99, 0x99, 0x99, 0xC3, 0xE7, 0xFF,	// Char 150 (.)
	0xFF, 0xFF, 0x9C, 0x94, 0x80, 0xC1, 0xC9, 0xFF,	// Char 151 (.)
	0xFF, 0xFF, 0x99, 0xC3, 0xE7, 0xC3, 0x99, 0xFF,	// Char 152 (.)
	0xFF, 0xFF, 0x81, 0xF3, 0xE7, 0xCF, 0x81, 0xFF,	// Char 153 (.)
	0xFF, 0xFF, 0x99, 0x99, 0x99, 0xC1, 0xF3, 0x87,	// Char 154 (.)
	0x99, 0xC3, 0x99, 0x99, 0x99, 0x99, 0xC3, 0xFF,	// Char 155 (.)
	0xF3, 0xED, 0xCF, 0x83, 0xCF, 0x9D, 0x03, 0xFF,	// Char 156 (.)
	0x24, 0xC3, 0x99, 0x81, 0x99, 0x99, 0x99, 0xFF,	// Char 157 (.)
	0xFF, 0xE7, 0xC3, 0x81, 0xE7, 0xE7, 0xE7, 0xE7,	// Char 158 (.)
	0xFF, 0xEF, 0xCF, 0x80, 0x80, 0xCF, 0xEF, 0xFF,	// Char 159 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 160 (.)
	0xFF, 0xE7, 0xE7, 0xE7, 0xFF, 0xFF, 0xE7, 0xFF,	// Char 161 (.)
	0x99, 0x99, 0x99, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 162 (.)
	0xC3, 0x9F, 0xC7, 0x93, 0xC7, 0xF3, 0x87, 0xFF,	// Char 163 (.)
	0xE7, 0xC1, 0x9F, 0xC3, 0xF9, 0x83, 0xE7, 0xFF,	// Char 164 (.)
	0x9D, 0x99, 0xF3, 0xE7, 0xCF, 0x99, 0xB9, 0xFF,	// Char 165 (.)
	0xC3, 0x99, 0xC3, 0xC7, 0x98, 0x99, 0xC0, 0xFF,	// Char 166 (.)
	0xF9, 0xF3, 0xE7, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 167 (.)
	0xF3, 0xE7, 0xCF, 0xCF, 0xCF, 0xE7, 0xF3, 0xFF,	// Char 168 (.)
	0xCF, 0xE7, 0xF3, 0xF3, 0xF3, 0xE7, 0xCF, 0xFF,	// Char 169 (.)
	0xFF, 0x99, 0xC3, 0x00, 0xC3, 0x99, 0xFF, 0xFF,	// Char 170 (.)
	0xC3, 0x99, 0x99, 0x93, 0x99, 0x99, 0x83, 0x9F,	// Char 171 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xE7, 0xE7, 0xCF,	// Char 172 (.)
	0xFF, 0xFF, 0xFF, 0x81, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 173 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xE7, 0xE7, 0xFF,	// Char 174 (.)
	0xFF, 0xFF, 0xFF, 0x81, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 175 (.)
	0xC3, 0x99, 0x91, 0x89, 0x99, 0x99, 0xC3, 0xFF,	// Char 176 (.)
	0xE7, 0xE7, 0xC7, 0xE7, 0xE7, 0xE7, 0x81, 0xFF,	// Char 177 (.)
	0xC3, 0x99, 0xF9, 0xF3, 0xCF, 0x9F, 0x81, 0xFF,	// Char 178 (.)
	0xC3, 0x99, 0xF9, 0xE3, 0xF9, 0x99, 0xC3, 0xFF,	// Char 179 (.)
	0xF9, 0xF1, 0xE1, 0x99, 0x80, 0xF9, 0xF9, 0xFF,	// Char 180 (.)
	0x81, 0x9F, 0x83, 0xF9, 0xF9, 0x99, 0xC3, 0xFF,	// Char 181 (.)
	0xC3, 0x99, 0x9F, 0x83, 0x99, 0x99, 0xC3, 0xFF,	// Char 182 (.)
	0x81, 0x99, 0xF3, 0xE7, 0xE7, 0xE7, 0xE7, 0xFF,	// Char 183 (.)
	0xC3, 0x99, 0x99, 0xC3, 0x99, 0x99, 0xC3, 0xFF,	// Char 184 (.)
	0xC3, 0x99, 0x99, 0xC1, 0xF9, 0x99, 0xC3, 0xFF,	// Char 185 (.)
	0x99, 0xFF, 0xC3, 0x99, 0x99, 0x99, 0xC3, 0xFF,	// Char 186 (.)
	0xC9, 0xFF, 0xC3, 0xF9, 0xC1, 0x99, 0xC1, 0xFF,	// Char 187 (.)
	0xFF, 0xFF, 0xE7, 0xFF, 0xFF, 0xE7, 0xE7, 0xCF,	// Char 188 (.)
	0xFF, 0xFF, 0x81, 0xFF, 0x81, 0xFF, 0xFF, 0xFF,	// Char 189 (.)
	0xFF, 0xFF, 0xE7, 0xFF, 0xFF, 0xE7, 0xFF, 0xFF,	// Char 190 (.)
	0xC3, 0x99, 0xF9, 0xF3, 0xE7, 0xFF, 0xE7, 0xFF,	// Char 191 (.)
	0xFF, 0xE7, 0xE7, 0x81, 0xE7, 0xE7, 0xFF, 0xFF,	// Char 192 (.)
	0xE7, 0xC3, 0x99, 0x81, 0x99, 0x99, 0x99, 0xFF,	// Char 193 (.)
	0x83, 0x99, 0x99, 0x83, 0x99, 0x99, 0x83, 0xFF,	// Char 194 (.)
	0xC3, 0x99, 0x9F, 0x9F, 0x9F, 0x99, 0xC3, 0xFF,	// Char 195 (.)
	0x87, 0x93, 0x99, 0x99, 0x99, 0x93, 0x87, 0xFF,	// Char 196 (.)
	0x81, 0x9F, 0x9F, 0x87, 0x9F, 0x9F, 0x81, 0xFF,	// Char 197 (.)
	0x81, 0x9F, 0x9F, 0x87, 0x9F, 0x9F, 0x9F, 0xFF,	// Char 198 (.)
	0xC3, 0x99, 0x9F, 0x91, 0x99, 0x99, 0xC3, 0xFF,	// Char 199 (.)
	0x99, 0x99, 0x99, 0x81, 0x99, 0x99, 0x99, 0xFF,	// Char 200 (.)
	0xC3, 0xE7, 0xE7, 0xE7, 0xE7, 0xE7, 0xC3, 0xFF,	// Char 201 (.)
	0xE1, 0xF3, 0xF3, 0xF3, 0xF3, 0x93, 0xC7, 0xFF,	// Char 202 (.)
	0x99, 0x93, 0x87, 0x8F, 0x87, 0x93, 0x99, 0xFF,	// Char 203 (.)
	0x9F, 0x9F, 0x9F, 0x9F, 0x9F, 0x9F, 0x81, 0xFF,	// Char 204 (.)
	0x9C, 0x88, 0x80, 0x94, 0x9C, 0x9C, 0x9C, 0xFF,	// Char 205 (.)
	0x99, 0x89, 0x81, 0x81, 0x91, 0x99, 0x99, 0xFF,	// Char 206 (.)
	0xC3, 0x99, 0x99, 0x99, 0x99, 0x99, 0xC3, 0xFF,	// Char 207 (.)
	0x83, 0x99, 0x99, 0x83, 0x9F, 0x9F, 0x9F, 0xFF,	// Char 208 (.)
	0xC3, 0x99, 0x99, 0x99, 0x99, 0xC3, 0xF1, 0xFF,	// Char 209 (.)
	0x83, 0x99, 0x99, 0x83, 0x87, 0x93, 0x99, 0xFF,	// Char 210 (.)
	0xC3, 0x99, 0x9F, 0xC3, 0xF9, 0x99, 0xC3, 0xFF,	// Char 211 (.)
	0x81, 0xE7, 0xE7, 0xE7, 0xE7, 0xE7, 0xE7, 0xFF,	// Char 212 (.)
	0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0xC3, 0xFF,	// Char 213 (.)
	0x99, 0x99, 0x99, 0x99, 0x99, 0xC3, 0xE7, 0xFF,	// Char 214 (.)
	0x9C, 0x9C, 0x9C, 0x94, 0x80, 0x88, 0x9C, 0xFF,	// Char 215 (.)
	0x99, 0x99, 0xC3, 0xE7, 0xC3, 0x99, 0x99, 0xFF,	// Char 216 (.)
	0x81, 0xF9, 0xF3, 0xE7, 0xCF, 0x9F, 0x81, 0xFF,	// Char 217 (.)
	0x99, 0x99, 0x99, 0xC3, 0xE7, 0xE7, 0xE7, 0xFF,	// Char 218 (.)
	0xC3, 0x99, 0xF9, 0xF3, 0xE7, 0xFF, 0xE7, 0xFF,	// Char 219 (.)

	0x66, 0x00, 0x66, 0x66, 0x66, 0x66, 0x3E, 0x00,	// Char 000 (Ü)

	0xE7, 0xE7, 0xE7, 0xE7, 0xE7, 0xE7, 0xE7, 0xE7,	// Char 221 (.)
	0xCC, 0xCC, 0x33, 0x33, 0xCC, 0xCC, 0x33, 0x33,	// Char 222 (.)
	0xFF, 0xFF, 0xE7, 0xFF, 0xFF, 0xE7, 0xFF, 0xFF,	// Char 223 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x99, 0x99, 0xC3,	// Char 224 (.)
	0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F,	// Char 225 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00,	// Char 226 (.)
	0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 227 (.)
	0xFF, 0xFF, 0xFF, 0xE7, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 228 (.)
	0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F,	// Char 229 (.)
	0x33, 0x33, 0xCC, 0xCC, 0x33, 0x33, 0xCC, 0xCC,	// Char 230 (.)
	0xFC, 0xFC, 0xFC, 0xFC, 0xFC, 0xFC, 0xFC, 0xFC,	// Char 231 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0x33, 0x33, 0xCC, 0xCC,	// Char 232 (.)
	0x00, 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F,	// Char 233 (.)
	0xFC, 0xFC, 0xFC, 0xFC, 0xFC, 0xFC, 0xFC, 0xFC,	// Char 234 (.)
	0xE7, 0xE7, 0xE7, 0xE0, 0xE0, 0xE7, 0xE7, 0xE7,	// Char 235 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0xF0, 0xF0, 0xF0, 0xF0,	// Char 236 (.)
	0xE7, 0xE7, 0xE7, 0xE0, 0xE0, 0xFF, 0xFF, 0xFF,	// Char 237 (.)
	0xFF, 0xFF, 0xFF, 0x07, 0x07, 0xE7, 0xE7, 0xE7,	// Char 238 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00,	// Char 239 (.)
	0xFF, 0xFF, 0xFF, 0xE0, 0xE0, 0xE7, 0xE7, 0xE7,	// Char 240 (.)
	0xE7, 0xE7, 0xE7, 0x00, 0x00, 0xFF, 0xFF, 0xFF,	// Char 241 (.)
	0xFF, 0xFF, 0xFF, 0x00, 0x00, 0xE7, 0xE7, 0xE7,	// Char 242 (.)
	0xE7, 0xE7, 0xE7, 0x07, 0x07, 0xE7, 0xE7, 0xE7,	// Char 243 (.)
	0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F, 0x3F,	// Char 244 (.)
	0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F,	// Char 245 (.)
	0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8,	// Char 246 (.)
	0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 247 (.)
	0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 248 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00,	// Char 249 (.)
	0xFC, 0xFC, 0xFC, 0xFC, 0xFC, 0xFC, 0x00, 0x00,	// Char 250 (.)
	0xFF, 0xFF, 0xFF, 0xFF, 0x0F, 0x0F, 0x0F, 0x0F,	// Char 251 (.)

	0x66, 0x00, 0x66, 0x66, 0x66, 0x66, 0x3E, 0x00,	// Char 000 (ü)

	0xE7, 0xE7, 0xE7, 0x07, 0x07, 0xFF, 0xFF, 0xFF,	// Char 253 (.)
	0x0F, 0x0F, 0x0F, 0x0F, 0xFF, 0xFF, 0xFF, 0xFF,	// Char 254 (.)
	0x0F, 0x0F, 0x0F, 0x0F, 0xF0, 0xF0, 0xF0, 0xF0	// Char 255 (.)
};

 bool pen = false;
 bool old_pen = false;
 bool is_printing = false;
 
 unsigned char tlen,h_f,bt,zl,bs;
 char txt[MAXLENGTH] = "HELLO WORLD";
 
 /*Init Ethernet Shield */
 byte mac[] = {0x90, 0xA2, 0xDA, 0x00, 0x1A, 0xDA}; //update with your MAC and IP
 byte ip[] = {192, 168, 0, 30 };

 byte gateway[] = { 192,168, 0, 1 };               // Gateway (optional)
 byte subnet[] = { 255, 255, 255, 0 }; 
 
 Server server(80);     

 
 //String txt = "WORL";
 
 /*Pen Specs (Pilot G1 0.5)*/ 
 int letter_width = 40;
 int line_break = 10;
 int line_hight = 5;
  
  int pos;
  int txt_pos = 0;

  /* PINS */
  const int buttonPin = 14;  // the number of the pushbutton pin
  const int feedButtonPin = 0;
  const int ledPin =  15;      // the number of the LED pin
  const int resetPin = 3;
  const int motorShieldReset = 16;


/*INIT PROGRAM */

void setup() {
  Serial.begin(9600);           
  Serial.println("Printer Initialisiert...");
   
  Ethernet.begin(mac, ip,gateway, subnet);
  server.begin();

  // INITIALIZE PIN MODES  
 
  pinMode(ledPin, OUTPUT);   
  pinMode(buttonPin, INPUT);
  pinMode(feedButtonPin,INPUT);
  pinMode(motorShieldReset,OUTPUT);
  
  Wire.begin();
  delayMicroseconds(40);
  
  
  // Reset Stepper shields and release Stepper
  digitalWrite(ledPin, HIGH);
  digitalWrite(motorShieldReset,LOW);
  delayMicroseconds(100);
  digitalWrite(motorShieldReset,HIGH);
  digitalWrite(ledPin, LOW);
  stepper.release(TOP_STEPPER);
  stepper.release(FRONT_STEPPER);


  servo_pen.attach(17);
  servo_pen.write(pos);

  stepper.setSpeed(TOP_STEPPER,150); 
  stepper.setSpeed(FRONT_STEPPER,150); 
  
  calibrate_top_stepper();


}

void led_blink(){

  for (int i=100;i< 100;i++){ 
    digitalWrite(ledPin, LOW); 
    delay(500);
    digitalWrite(ledPin, HIGH);
    delay(500);
  } 
}

  
void do_pen(int dir){
  if(dir == UP){
     // for(pos = 40; pos < 110; pos += 1){   
      servo_pen.write(100);               
      delay(100);                        
    //} 
  }
  
  if(dir == DOWN){
     servo_pen.write(40); 
     delay(400);
  }

}

void check_feed_button(){

  int feedButtonState = 0;
  
  feedButtonState = digitalRead(buttonPin);
  if(feedButtonState == HIGH){
      stepper.step(FRONT_STEPPER,10,FORWARD);
  }

}

void calibrate_top_stepper(){
    
   boolean calibrated = false;
   int buttonState = 0;         // variable for reading the pushbutton status
   
   // calibrate servo
   do_pen(DOWN);
   delay(300);
   do_pen(UP);     

   // calibrate steppers
   stepper.step(TOP_STEPPER,50,FORWARD);
   stepper.step(FRONT_STEPPER,80,FORWARD);

   
   while(true){
     
     buttonState = digitalRead(buttonPin);

     if(calibrated == false){
         if(buttonState == LOW){
             digitalWrite(ledPin, LOW); 
             stepper.step(TOP_STEPPER,10,BACKWARD);
         } else {
            if(calibrated == false){ 
             digitalWrite(ledPin, HIGH);
             stepper.step(TOP_STEPPER,10,BACKWARD);
             calibrated = true; 
            }
        }
    } else {
      digitalWrite(ledPin, LOW);   
      stepper.release(TOP_STEPPER); 
      //Serial.println("Reached...");
      delay(2000);
      break;
  }
 }
Serial.println("Stepper kalibriert.");
}


void printLine(int txt_length){


 tlen = txt_length; //sizeof(txt) / sizeof(char);
     
 for(zl=0;zl<8;zl++)
 {
   
   for (bs=0;bs<tlen;bs++)
    {
        
     for (bt=0;bt<8;bt++)
      if (!(zl&1))
      {
       
       h_f = font[ (int) txt[bs] *8 + (int)zl];
      
       //Move right (sim)

       {
        pen=((h_f<<bt) & 128);
        
        if(pen != old_pen){
          if(pen){
            do_pen(DOWN);
          } else {
            do_pen(UP);
          }
          old_pen = pen;
         
        }
        
        stepper.step(TOP_STEPPER,letter_width,FORWARD);
       }
     } else {
       
      
      h_f=font[(int)txt[tlen-bs-1]*8+(int)zl];
     
      //Move left (sim)
     
      for (bt=0;bt<8;bt++)
      {
        
       pen=((h_f>>bt) & 1);
       
       if(pen != old_pen){
          if(pen){
            do_pen(DOWN);
          } else {
            do_pen(UP);
          }
           old_pen = pen;
       }
       
       stepper.step(TOP_STEPPER,letter_width,BACKWARD);
      }
     
     }
    
    }//for bs
  
     do_pen(UP);
     pen=false;
     old_pen=false;
     stepper.step(FRONT_STEPPER,line_hight,FORWARD); 
    
   
   }//for zl

   stepper.step(FRONT_STEPPER,line_break, FORWARD);  
  
   
}


/* MAIN PROGRAM */

void loop() {

 
  //check_feed_button();
  
  Client client = server.available();
  int txt_pos = 0;
  int txt_old_pos = 0;
  
  if(client){
    boolean currentLineIsBlank = true;
    
    while(client.connected()){
       if(client.available()){ 
          
           char c  = client.read(); 
         
           if(c == '\n'){
             
              printLine(txt_pos);
              delay(10);
              server.println("1");
              
           } else {
              txt[txt_pos] = c;
              txt_pos++;
           }  
          
       }
    
    }
  
   // 
    txt_pos = 0;
  
  
    delay(1);
    client.stop();
  }
  
  /*
  if(pos > 0){
   
  }
 */
 
 /*
  printLine(11);
 
   while(1);
  */
}
