
#define MEMENTRY_STATE_END_OF_MEMLIST &hFF
#define MEMENTRY_STATE_NOT_NEEDED 0
#define MEMENTRY_STATE_LOADED 1
#define MEMENTRY_STATE_LOAD_ME 2

/'
	tipo de RESOURCE (type)
		"RT_SOUND"         =0
		"RT_MUSIC"         =1
		"RT_POLY_ANIM"     =2
		"RT_PALETTE"       =3
		"RT_BYTECODE"      =4  --> este es actualmente el lenguaje de programacion
		"RT_POLY_CINEMATIC"=5
'/		
' "resources" o grupos de trabajo, hay 146 en el MEMLIST.BIN, cada uno representa un nivel, o intro, o pantalla, o accion, etc
type MemEntry 
	As uint8_t  state         ' 0x0
	As uint8_t  type_         ' 0x1 Resource::ResType (ver arriba)
	As uint8_t  Ptr bufPtr    ' 0x2
	As uint16_t unk4          ' 0x4 unused
	As uint8_t  rankNum       ' 0x6
	As uint8_t  bankId        ' 0x7
	As uint32_t bankOffset    ' 0x8 0xA
	As uint16_t unkC          ' 0xC unused
	As uint16_t packedSize    ' 0xE  nota: algunos grupos estan comprimidos, otros no (creo que 4 o 5 no lo enstan)
	As uint16_t unk10         ' 0x10 unused
	As uint16_t size          ' 0x12
end Type


/'
     Note: state is not a boolean, it can have value 0, 1, 2 or 255, respectively meaning:
      0:NOT_NEEDED
      1:LOADED
      2:LOAD_ME
      255:END_OF_MEMLIST

    See MEMENTRY_STATE_* #defines above.
'/

Enum ResType
   RT_SOUND  = 0,
	RT_MUSIC  = 1,
	RT_POLY_ANIM = 2, ' full screen video buffer, size=0x7D00
	RT_PALETTE    = 3, ' palette (1024=vga + 1024=ega), size=2048
	RT_BYTECODE   = 4,
	RT_POLY_CINEMATIC   = 5
End Enum
	
Enum
	MEM_BLOCK_SIZE = 600 * 1024   '600kb total memory consumed (not taking into account stack and static heap)
End Enum
	

Type resource
	'As Video Ptr video
	'As Byte Ptr _dataDir
	'As MemEntry _memList(150)
	'As uint16_t _numMemList
	'As uint8_t Ptr _memPtrStart, _scriptBakPtr, _scriptCurPtr, _vidBakPtr, _vidCurPtr
	
	As uint16_t currentPartId, requestedNextPart
	As uint8_t Ptr segPalettes
	As uint8_t Ptr segBytecode
	As uint8_t Ptr segCinematic
	As uint8_t Ptr _segVideo2
	As BOOL _useSegVideo2
End Type
Dim Shared As resource res