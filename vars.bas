' -------- VARIABLES ---------

#Undef FALSE
#Undef TRUE
#define FALSE 0
#Define TRUE 1


#define uint8_t  ubyte
#define  int8_t  byte
#define uint16_t ushort
#define  int16_t short
#define uint32_t uinteger
#define  int32_t Integer

#Define  BOOL Byte



' definiciones
#Include "intern.bi"
#include "vm.bi"
#include "video.bi"
#Include "resource.bi"
#Include "datos.bi"


Dim Shared As Integer deb=0


' -------------------------------------------------------------------------------------------------------
'The game is divided in 10 parts.
#define GAME_NUM_PARTS 10

#define GAME_PART_FIRST   &h3E80
#define GAME_PART1       &h3E80
#define GAME_PART2       &h3E81   'Introduction
#define GAME_PART3       &h3E82
#define GAME_PART4       &h3E83   'Wake up in the suspended jail
#define GAME_PART5       &h3E84
#define GAME_PART6       &h3E85   'BattleChar sequence
#define GAME_PART7       &h3E86
#define GAME_PART8       &h3E87
#define GAME_PART9       &h3E88
#define GAME_PART10      &h3E89
#define GAME_PART_LAST    &h3E89

'MEMLIST_PART_PALETTE || MEMLIST_PART_CODE || MEMLIST_PART_POLY_CINEMATIC || MEMLIST_PART_VIDEO2
dim shared as uint16_t memListParts(GAME_NUM_PARTS-1,3) = { _
	{ &h14,                    &h15,                	&h16,                	&h00 }, _ ' 1: protection screens
	{ &h17,                    &h18,                	&h19,                	&h00 }, _ ' 2: introduction cinematic
	{ &h1A,                    &h1B,                	&h1C,                	&h11 }, _ ' 3: fase 1, saliendo del pozo
	{ &h1D,                    &h1E,                	&h1F,                	&h11 }, _ ' 4: fase 2, en la jaula colgante
	{ &h20,                    &h21,                	&h22,                	&h11 }, _ ' 5: fase 3, en los subterraneos
	{ &h23,                    &h24,                	&h25,                	&h00 }, _ ' 6: fase 4, en el circo de arena
	{ &h26,                    &h27,                	&h28,                	&h11 }, _ ' 7: fase 5, en la sauna de "chicas"
	{ &h29,                    &h2A,                	&h2B,                	&h11 }, _ ' 8: fase 6, final del juego
	{ &h7D,                    &h7E,                	&h7F,                	&h00 }, _ ' 9: pantalla de codigos de niveles
	{ &h7D,                    &h7E,                	&h7F,                	&h00 }  _ '10: ???
}
' 1:20,21,22
' 2:23,24,25
' 3:26,27,28
' 4:29,30,31
' 5:32,33,34
' 6:34,36,37
' 7:38,39,40
' 8:41,42,43

' saltar a un nivel concreto
' ejemplo -> LDKD: fase 1
' ----------------------------------------------------------------------------------------------------------



#define COLOR_BLACK &hFF
#define DEFAULT_ZOOM &h40 ' 64

'Dim Shared As uint16_t memListParts(GAME_NUM_PARTS, 4) 

'For each part of the game, four resources are referenced.
#define MEMLIST_PART_PALETTE 0
#define MEMLIST_PART_CODE    1
#define MEMLIST_PART_POLY_CINEMATIC  2
#define MEMLIST_PART_VIDEO2  3


' datos del juego, en concreto los BANKxx y el MEMLIST.BIN que contienen las 146 entidades
Dim Shared As UByte RAM(2048*1024) ' almacen de 2megas donde van las 146 entidades extraidas (en realidad, solo ocupan 1.6megas)
Dim Shared As Integer Entidad(146) ' punteros a cada entidad almacenada en la matriz RAM() para saber donde empieza cada una


' cambiar entre niveles, segun su codigo
Dim Shared As BOOL ChangeLevel=FALSE

' para saltarse la proteccion, ver VM.CPP
#Define BYPASS_PROTECTION

