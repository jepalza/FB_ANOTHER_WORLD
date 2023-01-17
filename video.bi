
'Type StrEntry 
'	As uint16_t id_
'	As string str_
'End Type
Dim Shared As string TableEngStr(&h265)
'Dim Shared As int16_t TableEngId(&h193)

Type PolygonVM
	As uint16_t bbw
	As uint16_t bbh 
	As uint8_t numPoints
	As pointVM points(49) 'MAX_POINTS=50 
End Type

Type res2 As resource

' This is used to detect the end of  _stringsTableEng and _stringsTableDemo
#define END_OF_STRING_DICTIONARY &hFFFF

' Special value when no palette change is necessary
#define NO_PALETTE_CHANGE_REQUESTED &hFF

Dim Shared As Integer SCREEN_W = 320
Dim Shared As Integer SCREEN_H = 200
Dim Shared As integer VID_PAGE_SIZE 
	VID_PAGE_SIZE=(SCREEN_W * SCREEN_H / 2)

type videoVM

	'As uint8_t _font(1024) ' 1024 ?
	'As StrEntry _stringsTableEng(1024) ' 1024 ? 
	'As StrEntry _stringsTableDemo(1024) ' 1024 ? 

	As res2 Ptr res 
	'As System_ Ptr sys 

	As uint8_t paletteIdRequested, currentPaletteId 
	As uint8_t Ptr _pages(3) ' 4 paginas

	' I am almost sure that:
	' _curPagePtr1 is the work buffer
	' _curPagePtr2 is the background buffer1
	' _curPagePtr3 is the background buffer2
	As uint8_t Ptr _curPagePtr1, _curPagePtr2, _curPagePtr3

	As PolygonVM poligono 
	As int16_t _hliney 

	'Precomputer division lookup table
	As uint16_t _interpTable(&h3FF) ' 0x400

	As PtrVM _pData 
	As uint8_t Ptr _dataBuf 
 
End Type 
Dim Shared As videoVM Video




function VID_fetchByte() As uint8_t
	Dim As uint8_t i
	i=*video._pData.pc
	video._pData.pc+=1
	return i  
End Function

Function VID_fetchWord() As uint16_t
	Dim As uint16_t i = READ_BE_UINT16(video._pData.pc) 
	video._pData.pc+=2 
	return i 
End Function 

