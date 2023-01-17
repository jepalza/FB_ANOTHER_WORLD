
Type memlist
	As UByte  state
	As UByte  type_
	As UShort bufPtr
	As UShort unk4
	As UByte  rankNum
	As UByte  bankId
	As UInteger bankOffset
	As UShort unkC
	As UShort packedSize
	As UShort unk10
	As UShort size
End Type
Dim Shared As memlist mem 


Type UnpackContext 
	As uint16_t size
	As uint32_t crc
	As uint32_t chk
	As int32_t  datasize
End Type
Dim Shared As UnpackContext _unpCtx


Dim Shared As UByte BankIN(256*1024) ' temporal de entrada del BANKxx leido original
Dim Shared As UByte BankOUT(256*1024) ' temporal del BANKxx extraido
Dim Shared As Integer _iBuf=0 ' punteros entrada y salida de los BANKxx a tratar, temporales
Dim Shared As Integer _oBuf=0


' extrae UINT32 del BANKxx original
#Define READ32_BANK(A) (BankIN(A+3)+(BankIN(A+2) Shl 8)+(BankIN(A+1) Shl 16)+(BankIN(A) Shl 24))

Function rcr(CF As BOOL) As BOOL 
	Dim As BOOL rCF = (_unpCtx.chk And 1) 
	_unpCtx.chk Shr = 1 
	if (CF) Then _unpCtx.chk Or= &h80000000 
	return rCF 
End Function

Function nextChunk() As BOOL 
	Dim As BOOL CF = rcr(FALSE) 
	if (_unpCtx.chk = 0) Then 
		assert(_iBuf >= _startBuf) 
		_unpCtx.chk = READ32_BANK(_iBuf) : _iBuf -= 4 
		_unpCtx.crc Xor= _unpCtx.chk 
		CF = rcr(true) 
	EndIf
  
	return CF 
End Function

Function getCode(numChunks As uint8_t) As uint16_t 
	Dim As uint16_t c = 0 
	while numChunks 
		numChunks-=1
		c Shl = 1 
		if (nextChunk()) Then 
			c Or= 1 
		EndIf
	Wend
 
	return c 
End Function


Sub decUnk1(numChunks As uint8_t , addCount As uint8_t)
	Dim As uint16_t count = getCode(numChunks) + addCount + 1 
	
	'If deb=1 then printf(!"Bank::decUnk1(%d, %d) count=%d", numChunks, addCount, count) 
	
	_unpCtx.datasize -= count 
	while count
		count-=1
		assert(_oBuf >= _iBuf And _oBuf >= _startBuf) 
		BankOUT(_oBuf) = getCode(8) 
		_oBuf-=1
	Wend
End Sub 

' Note from fab: This look like run-length encoding.
Sub decUnk2(numChunks As uint8_t)
	Dim As uint16_t i = getCode(numChunks) 
	Dim As uint16_t count = _unpCtx.size + 1 
	
	'If deb=1 then printf(!"Bank::decUnk2(%d) i=%d count=%d", numChunks, i, count) 
	
	_unpCtx.datasize -= count 
	while count
		count-=1
		assert(_oBuf >= _iBuf And _oBuf >= _startBuf) 
		BankOUT(_oBuf) = BankOUT(_oBuf + i) 
		_oBuf-=1 
	Wend
    
End Sub

' Most resource in the banks are compacted.
Function unpack() As BOOL 
	
	_unpCtx.size = 0 
	_unpCtx.datasize = READ32_BANK(_iBuf): _iBuf -= 4 
	_oBuf = _unpCtx.datasize - 1 
	_unpCtx.crc = READ32_BANK(_iBuf): _iBuf -= 4 
	_unpCtx.chk = READ32_BANK(_iBuf): _iBuf -= 4 
	_unpCtx.crc Xor= _unpCtx.chk 
	
	While (_unpCtx.datasize > 0)
		if ( nextChunk()=0) Then  
			_unpCtx.size = 1 
			if ( nextChunk()=0) Then 
				decUnk1(3, 0) 
			Else
				decUnk2(8) 
			EndIf
		Else
			Dim As uint16_t c = getCode(2) 
			if (c = 3) Then 
				decUnk1(8, 8) 
			Else
				if (c < 2) Then 
					_unpCtx.size = c + 2 
					decUnk2(c + 9) 
				Else
					_unpCtx.size = getCode(8) 
					decUnk2(12) 
				EndIf
			EndIf
		EndIf
	Wend 
     
	return (_unpCtx.crc = 0) 
End Function



Sub extrae_entidades()
	Dim As Integer reg=1
	Dim As Integer size
	Dim As Integer a,f
	Dim As String sc=Space(20)
	Dim As String sb=""
	Dim datos(20) As UByte
	Dim inicio_entidad As Integer=0 ' marco el inicio de cada entidad cuando la guardo en la matriz, para saber donde cae
	
	cls
	
	' nota: el fichero MEMLIST.BIN lo tengo en la carpeta anterior a esta, llamada DATA para tenerlo organizado todo
	Open "data\memlist.bin" For Binary As 1
	While Not Eof(1)
		sc=Space(20)
		Get #1, reg, sc
		reg+=len(sc)
		
		 Locate 2,1:Print "   Entidad:";a
		 a+=1
	    For f=1 To Len(sc)
	    	datos(f)=Asc(Mid(sc,f,1))
	    Next
	    
		mem.state      = datos( 1)
		mem.type_      = datos( 2)
		mem.bufPtr     = datos( 4)+(datos( 3) Shl 8) ' siempre es "0"? (pero se lee igualmente, para no romper la secuencia)
		mem.unk4       = datos( 6)+(datos( 5) Shl 8)
		mem.rankNum    = datos( 7)
		mem.bankId     = datos( 8)
		mem.bankOffset = datos(12)+(datos(11) Shl 8)+(datos(10) Shl 16)+(datos(9) Shl 24)
		mem.unkC       = datos(14)+(datos(13) Shl 8)
		mem.packedSize = datos(16)+(datos(15) Shl 8)
		mem.unk10      = datos(18)+(datos(17) Shl 8)
		mem.size       = datos(20)+(datos(19) Shl 8)
	
	   If mem.bankId=&hff Then GoTo no_existe_entidad
		
		' ahora, leo el BANK que corresponde entre los 14 que hay (de 00 a 0D)
		sc=" "

		_iBuf=0
		
		' abrimos el BANK correspodiente
		Open "data\BANK"+Hex(mem.bankId,2) For Binary As 2
		sc=Space(1024)
		While Not Eof(2)
			Get #2,_iBuf+1,sc
			For f=1 To 1024
				BankIN(_iBuf)=Asc(Mid(sc,f,1))
				_iBuf+=1
			Next
		Wend
		Close 2
		
		
		
	
		' trato el bloque localizado arriba
		_iBuf = mem.bankOffset + mem.packedSize -4
		If mem.size>mem.packedSize then  ' comprueba si esta empaquetado y se es asi, desempaqueta
			unpack() ' diferente tamano, descomprime
		Else			
			' si es tamano cero, no existe, o eso creo. Ocurre con la primera, la ultima y cuatro o cinco intermedias
			If mem.size=0 Then GoTo no_existe_entidad
			' caso contrario, si es mismo tamano orig. que comprimido, pued ser que no esta comprimido, por lo que lo copia tal cual
			For f=0 To mem.size-1
				BankOUT(f)=BankIN(f)
			Next		
		EndIf

		
		
		' y guardo el extraido
		Entidad(a-1)=inicio_entidad ' guardo la posicion que ocupa en la matriz cada entidad leida del 0 al 145
		
		For f=0 To mem.size-1
			RAM(f+inicio_entidad)=BankOUT(f) ' todas la entidades van seguidas en la misma matriz, a modo memoria RAM
		Next
		Entidad(a-1)=inicio_entidad
		inicio_entidad=inicio_entidad+mem.size
			
			
no_existe_entidad:
	Wend
	Close 1
	
	
	'Print Hex(RAM(Entidad(1)),2)
	'Print Hex(RAM(Entidad(24)),2)
	Print
	Print a-1;" Entidades leidas y descomprimidas"
	Print
End Sub

