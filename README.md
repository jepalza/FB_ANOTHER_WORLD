# FB_ANOTHER_WORLD
Freebasic "Another World" interprete

Based on source from Aminet:
https://aminet.net/package/game/actio/anotherworld_os4

Copyrights from Fabien Sanglard, Gregory Montoir, Eric Chahi

My job was just to port it to FreeBasic, with changes in file management, movement control, obtaining resources, etc. But the virtual machine (VM bytecode interpreter) and the graphics system are pretty much the same.

It has no sound and has a few bugs, but it can be played back and have fun with the phases.

Keys:
Cursor for movement, Control for Jump/Run/Hit/fire, ESC to exit and F1 to change Level (for example, first level is "LDKD")
If you Want to see independents levels, then Change variable name in line 41 in main module:
#Ifdef BYPASS_PROTECTION
part = GAME_PART2 ' change this, for example with GAME_PART3, or 4 o even GAME_PART8 in order to see Final Scene!!
#EndIf

English using Google translate, optional Original Spanish:
Mi trabajo ha sido simplemente portarlo a FreeBasic, con cambios en la administración de archivos, control de movimiento, obtención de recursos, etc. Pero la máquina virtual (intérprete de código de bytes de VM) y el sistema de gráficos son prácticamente lo mismo.

No tiene sonido y tiene algunos errores, pero se puede jugar y divertirse con las fases.

Teclas:
Cursor para movimiento, Control para saltar/correr/golpear/disparar, ESC para salir y F1 para cambiar de nivel (por ejemplo, el primer nivel es "LDKD")
Si quieres ver los niveles independientes, cambia el nombre de la variable en la línea 41 del módulo principal:
#Ifdef BYPASS_PROTECTION
part = GAME_PART2 'cambia esto, por ejemplo con GAME_PART3, o 4 o incluso GAME_PART8 para ver la escena final !!
#Endif
