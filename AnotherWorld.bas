

' para el empleo de MULTIKEY
#include "fbgfx.bi"
#if __FB_LANG__ = "fb"
Using FB 
#endif

' varios opcionales, usados tipicamente en "C"
#Include "crt\stdio.bi" ' printf(), scanf(), fopen(), etc
#Include "crt\stdlib.bi" ' malloc(),calloc(), etc
#Include "crt\mem.bi" ' memset(var,val,size) -> variable ptr, valor, tamano usar sizeof(variable))

' rutinas
#Include "vars.bas"
#Include "decs.bas"

' modulos
#Include "vm.bas"
#include "video.bas"
#include "descomp.bas"


	ScreenRes SCREEN_W*2, SCREEN_H*2, 8

	video_init() 

	Print
	Print "Leyendo 146 entidades."
	extrae_entidades() 

	VM_init() 

	'mixer.init() 

	'player.init() 

	Dim As Uint16_t part = GAME_PART1   ' This game part is the protection screen
	
	#Ifdef BYPASS_PROTECTION
  		part = GAME_PART2 ' con este entramos directos al juego, sin pasar por la proteccion
	#EndIf
	
   initForPart(part) 

	while MultiKey(SC_ESCAPE)=0 

		checkThreadRequests() 

		inp_updatePlayer() 

		'processInput() 

		hostFrame() 
	Wend

