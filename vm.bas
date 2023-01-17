

Sub VM_init()

	'memset(@vmVariables(0), 0, sizeof(vmVariables)) 
	vmVariables(&h54) = &h81 
	vmVariables(VM_VARIABLE_RANDOM_SEED) = Timer
	 
#ifdef BYPASS_PROTECTION
   ' these 3 variables are set by the game code
   vmVariables(&hBC) = &h10 
   vmVariables(&hC6) = &h80 
   vmVariables(&hF2) = 4000 
   ' these 2 variables are set by the engine executable
   vmVariables(&hDC) = 33 
#endif

	' estudiar player->_markVar = @vmVariables(VM_VARIABLE_MUS_MARK) 
End Sub

Sub op_movConst()
	Dim As uint8_t variableId = fetchByte() 
	Dim As int16_t value      = fetchWord() 
	If deb=1 Then printf(!"VM  - op_movConst(0x%02X, %d)\n", variableId, value) 
	vmVariables(variableId) = value 
End Sub

Sub op_mov()
	Dim As uint8_t dstVariableId = fetchByte() 
	Dim As uint8_t srcVariableId = fetchByte() 	
	If deb=1 Then printf(!"VM  - op_mov(0x%02X, 0x%02X)\n", dstVariableId, srcVariableId) 
	vmVariables(dstVariableId) = vmVariables(srcVariableId) 
End Sub

Sub op_add()
	Dim As uint8_t dstVariableId = fetchByte() 
	Dim As uint8_t srcVariableId = fetchByte() 
	If deb=1 Then printf(!"VM  - op_add(0x%02X, 0x%02X)\n", dstVariableId, srcVariableId) 
	vmVariables(dstVariableId) += vmVariables(srcVariableId) 
End Sub

Sub op_addConst()
	if (res.currentPartId = &h3E86 And VM_PC = res.segBytecode + &h6D48) Then 
  
		If deb=1 Then printf(!"VM  - op_addConst() hack for non-stop looping gun sound bug\n") 
		' the script 0x27 slot 0x17 doesn´t stop the gun sound from looping, I
		' don´t really know why ; for now, let´s play the ´stopping sound´ like
		' the other scripts do
		'  (0x6D43) jmp(0x6CE5)
		'  (0x6D46) break
		'  (0x6D47) VAR(6) += -50
		'snd_playSound(&h5B, 1, 64, 1) 
	
	EndIf
  
	Dim As uint8_t variableId = fetchByte() 
	Dim As int16_t value      = fetchWord() 
	If deb=1 Then printf(!"VM  - op_addConst(0x%02X, %d)\n", variableId, value) 
	vmVariables(variableId) += value 
End Sub

Sub op_call()

	Dim As uint16_t offset = fetchWord() 
	Dim As uint8_t sp = _stackPtr 

	If deb=1 Then printf(!"VM  - op_call(0x%X)\n", offset) 
	_scriptStackCalls(sp) = VM_PC - res.segBytecode 

	if (_stackPtr = &hFF) Then 
		If deb=1 Then printf(!"VM  - op_call() ec=0x%X stack overflow\n", &h8F) 
	EndIf
  
	_stackPtr+=1 
	VM_PC = res.segBytecode + offset  
End Sub

Sub op_ret()
	If deb=1 Then printf(!"VM  - op_ret()\n") 
	if (_stackPtr = 0) Then 
		If deb=1 Then printf(!"VM  - op_ret() ec=0x%X stack underflow\n", &h8F) 
	EndIf
  	
	_stackPtr-=1 
	Dim As uint8_t sp = _stackPtr 
	VM_PC = res.segBytecode + _scriptStackCalls(sp) 
End Sub

Sub op_pauseThread()
	If deb=1 Then printf(!"VM  - op_pauseThread()\n") 
	gotoNextThread = true 
End Sub

Sub op_jmp()
	Dim As uint16_t pcOffset = fetchWord() 
	If deb=1 Then printf(!"VM  - op_jmp(0x%02X)\n", pcOffset) 
	VM_PC = res.segBytecode + pcOffset 	
End Sub

Sub op_setSetVect()
	Dim As uint8_t threadId = fetchByte() 
	Dim As uint16_t pcOffsetRequested = fetchWord() 
	If deb=1 Then printf(!"VM  - op_setSetVect(0x%X, 0x%X)\n", threadId,pcOffsetRequested) 
	threadsData(REQUESTED_PC_OFFSET, threadId) = pcOffsetRequested 
End Sub

Sub op_jnz()
	Dim As uint8_t i = fetchByte() 
	If deb=1 Then printf(!"VM  - op_jnz(0x%02X)\n", i) 
	vmVariables(i)-=1  
	if (vmVariables(i) <> 0) Then 
		op_jmp() 
	else 
		fetchWord() 
	EndIf
  
End Sub

Sub op_condJmp()
	Dim As uint8_t opcode = fetchByte() 
   Dim As uint8_t var_   = fetchByte() 
   Dim As int16_t b      = vmVariables(var_) 
	Dim As int16_t a 

	if (opcode And &h80) Then 
		a = vmVariables(fetchByte()) 
	ElseIf  (opcode And &h40) Then
    	a = fetchWord()
   else 
    	a = fetchByte() 
	End If
	If deb=1 Then printf(!"VM  - op_condJmp(%d, 0x%02X, 0x%02X)\n", opcode, b, a) 

	' Check if the conditional value is met.
	Dim As BOOL expr = FALSE 
	Select Case  (opcode And 7)  
		Case 0 	' jz
			expr = IIf( (b = a) ,1,0)
			
		#Ifdef BYPASS_PROTECTION
	      if (res.currentPartId = 16000) Then 
	        '
	        ' 0CB8: jmpIf(VAR(0x29) == VAR(0x1E), @0CD3)
	        ' ...
	        '
	        if (b = &h29 And (opcode And &h80) <> 0) Then 
	  
	          ' 4 symbols
	          vmVariables(&h29) = vmVariables(&h1E) 
	          vmVariables(&h2A) = vmVariables(&h1F) 
	          vmVariables(&h2B) = vmVariables(&h20) 
	          vmVariables(&h2C) = vmVariables(&h21) 
	          ' counters
	          vmVariables(&h32) = 6 
	          vmVariables(&h64) = 20 
	          If deb=1 Then printf(!"SCPT - op_condJmp() bypassing protection\n") 
	          expr = TRUE 
	        
	        EndIf
	      EndIf
		#EndIf

		case 1  ' jnz
			expr = IIf( (b <> a) ,1,0)

		Case 2  ' jg
			expr = IIf( (b > a) ,1,0)

		Case 3  ' jge
			expr = IIf( (b >= a) ,1,0)

		Case 4  ' jl
			expr = IIf( (b < a) ,1,0)

		Case 5  ' jle
			expr = IIf( (b <= a) ,1,0)

		Case else 
			If deb=1 Then printf(!"VM  - op_condJmp() invalid condition %d\n", (opcode And 7)) 
	
   End Select


	if (expr) Then 
		op_jmp() 
	Else
		fetchWord() 
	EndIf

End Sub

Sub op_setPalette()
	Dim As uint16_t paletteId = fetchWord() 
	If deb=1 Then printf(!"VM  - op_changePalette(%d)\n", paletteId) 
	video.paletteIdRequested = paletteId Shr 8 
End Sub

Sub op_resetThread()

	Dim As uint8_t threadId = fetchByte() 
	Dim As uint8_t i =        fetchByte() 

	' FCS: WTF, this is cryptic as hell !!
	' int8_t n = (i & 0x3F) - threadId;  //0x3F = 0011 1111
	' The following is so much clearer

	' Make sure i within [0-VM_NUM_THREADS-1]
	i = i And (VM_NUM_THREADS-1)  
	Dim As int8_t n = i - threadId 

	if (n < 0) Then 
		If deb=1 Then printf(!"VM  - op_resetThread() ec=0x%X (n < 0)\n", &h880) 
		return 
	EndIf
  
	n +=1
	Dim As uint8_t a = fetchByte() 

	If deb=1 Then printf(!"VM  - op_resetThread(%d, %d, %d)\n", threadId, i, a) 

	if (a = 2) Then 
		Dim As uint16_t Ptr p = @threadsData(REQUESTED_PC_OFFSET, threadId) 
		while n
			n-=1
			*p = &hFFFE 
			p+=1
		Wend
	ElseIf  (a < 2) Then
		Dim As uint8_t Ptr p = @vmIsChannelActive(REQUESTED_STATE, threadId)
		while n
			n-=1  
			*p = a 
			p+=1
		Wend
	EndIf
  
End Sub

Sub op_selectVideoPage()
	Dim As uint8_t frameBufferId = fetchByte() 
	If deb=1 Then printf(!"VM  - op_selectVideoPage(%d)\n", frameBufferId) 
	changePagePtr1(frameBufferId) 
End Sub

Sub op_fillVideoPage()
	Dim As uint8_t pageId = fetchByte() 
	Dim As uint8_t color_ = fetchByte() 
	If deb=1 Then printf(!"VM  - op_fillVideoPage(%d, %d)\n", pageId, color_) 
	fillPage(pageId, color_) 
End Sub

Sub op_copyVideoPage()
	Dim As uint8_t srcPageId = fetchByte() 
	Dim As uint8_t dstPageId = fetchByte() 
	If deb=1 Then printf(!"VM  - op_copyVideoPage(%d, %d)\n", srcPageId, dstPageId) 
	copyPage(srcPageId, dstPageId, vmVariables(VM_VARIABLE_SCROLL_Y)) 
End Sub


Dim Shared As uint32_t lastTimeStamp= 0 
Sub op_blitFramebuffer()

	Dim As uint8_t pageId = fetchByte() 
	If deb=1 Then printf(!"VM  - op_blitFramebuffer(%d)\n", pageId) 
	
	' sin hacer inp_handleSpecialKeys() 

  Dim As int32_t delay = Timer - lastTimeStamp 
  Dim As int32_t timeToSleep = vmVariables(VM_VARIABLE_PAUSE_SLICES) * 20 - delay 

  ' The bytecode will set vmVariables[VM_VARIABLE_PAUSE_SLICES] from 1 to 5
  ' The virtual machine hence indicate how long the image should be displayed.

  if (timeToSleep > 0) Then 
    Sleep (timeToSleep),1 
  EndIf
  

  lastTimeStamp = Timer 

	'WTF ?
	vmVariables(&hF7) = 0 

	updateDisplay(pageId) 
End Sub

Sub op_killThread()
	If deb=1 Then printf(!"VM  - op_killThread()\n") 
	VM_PC = res.segBytecode + &hFFFF 
	gotoNextThread = TRUE 
End Sub

Sub op_drawString()
	Dim As uint16_t stringId = fetchWord() 
	Dim As uint16_t x = fetchByte() 
	Dim As uint16_t y = fetchByte() 
	Dim As uint16_t color_ = fetchByte() 

	If deb=1 Then printf(!"VM  - op_drawString(0x%03X, %d, %d, %d)\n", stringId, x, y, color_) 

	drawString(color_, x, y, stringId) 
End Sub

Sub op_sub()
	Dim As uint8_t i = fetchByte() 
	Dim As uint8_t j = fetchByte() 
	If deb=1 Then printf(!"VM  - op_sub(0x%02X, 0x%02X)\n", i, j) 
	vmVariables(i) -= vmVariables(j) 
End Sub

Sub op_and()
	Dim As uint8_t variableId = fetchByte() 
	Dim As uint16_t n = fetchWord() 
	If deb=1 Then printf(!"VM  - op_and(0x%02X, %d)\n", variableId, n) 
	vmVariables(variableId) = CUShort(vmVariables(variableId)) And n 
End Sub

Sub op_or()
	Dim As uint8_t variableId = fetchByte() 
	Dim As uint16_t value = fetchWord() 
	If deb=1 Then printf(!"VM  - op_or(0x%02X, %d)\n", variableId, value) 
	vmVariables(variableId) = CUShort(vmVariables(variableId)) Or value 
End Sub

Sub op_shl()
	Dim As uint8_t variableId = fetchByte() 
	Dim As uint16_t leftShiftValue = fetchWord() 
	If deb=1 Then printf(!"VM  - op_shl(0x%02X, %d)\n", variableId, leftShiftValue) 
	vmVariables(variableId) = CUShort(vmVariables(variableId)) Shl leftShiftValue 
End Sub

Sub op_shr()
	Dim As uint8_t variableId = fetchByte() 
	Dim As uint16_t rightShiftValue = fetchWord() 
	If deb=1 Then printf(!"VM  - op_shr(0x%02X, %d)\n", variableId, rightShiftValue) 
	vmVariables(variableId) = CUShort(vmVariables(variableId)) Shr rightShiftValue 
End Sub

Sub op_playSound()
	Dim As uint16_t resourceId = fetchWord() 
	Dim As uint8_t freq = fetchByte() 
	Dim As uint8_t vol = fetchByte() 
	Dim As uint8_t channel = fetchByte() 
	If deb=1 Then printf(!"VM  - op_playSound(0x%X, %d, %d, %d)\n", resourceId, freq, vol, channel) 
	snd_playSound(resourceId, freq, vol, channel) 
End Sub

Sub op_updateMemList()
'
	Dim As uint16_t resourceId = fetchWord() 
'	If deb=1 Then printf(!"VM  - op_updateMemList(%04x)\n", resourceId) 
	If ChangeLevel=TRUE Then 
		ChangeLevel=FALSE
		initForPart(resourceId)
	EndIf
'
'	if (resourceId = 0) Then 
'		player_stop() 
'		mixer_stopAll() 
'		res_invalidateRes() 
'	Else
'		res_loadPartsOrMemoryEntry(resourceId) 
'	EndIf
'  
End Sub

Sub op_playMusic()
	Dim As uint16_t resNum = fetchWord() 
	Dim As uint16_t delay = fetchWord() 
	Dim As uint8_t pos_ = fetchByte() 
	If deb=1 Then printf(!"VM  - op_playMusic(0x%X, %d, %d)\n", resNum, delay, pos_) 
	snd_playMusic(resNum, delay, pos_) 
End Sub

Sub initForPart(partId As uint16_t)

	'player_stop() 
	'mixer_stopAll() 

	'WTF is that ?
	vmVariables(&hE4) = &h14 

	'res_setupPart(partId) 
	Dim As uint16_t memListPartIndex = partId - GAME_PART_FIRST

	res.segPalettes =@RAM(Entidad(memListParts(memListPartIndex,MEMLIST_PART_PALETTE)))
	res.segBytecode =@RAM(Entidad(memListParts(memListPartIndex,MEMLIST_PART_CODE))) ': VM_PC  = res.segBytecode
	res.segCinematic=@RAM(Entidad(memListParts(memListPartIndex,MEMLIST_PART_POLY_CINEMATIC))) ': video._pData.pc = res.segCinematic
	res._segVideo2  =@RAM(Entidad(memListParts(memListPartIndex,MEMLIST_PART_VIDEO2))) ': video._pData.pc = res._segVideo2
		
	'Set all thread to inactive (pc at 0xFFFF or 0xFFFE )
	'memset(@threadsData, &hFF, sizeof(threadsData)) 
	For i As Integer=0 To NUM_DATA_FIELDS
		For g As Integer=0 To VM_NUM_THREADS
			threadsData(i,g)=VM_INACTIVE_THREAD
		Next
	Next

	memset(@vmIsChannelActive(0,0), 0, sizeof(vmIsChannelActive)) 
	
	Dim As Integer firstThreadId = 0 
	threadsData(PC_OFFSET, firstThreadId) = 0 	
End Sub

' This is called every frames in the infinite loop.
Sub checkThreadRequests()

	'Check if a part switch has been requested.
	if (res.requestedNextPart <> 0) Then 
		initForPart(res.requestedNextPart) 
		res.requestedNextPart = 0 
	EndIf
  
	
	' Check if a state update has been requested for any thread during the previous VM execution:
	'      - Pause
	'      - Jump

	' JUMP:
	' Note: If a jump has been requested, the jump destination is stored
	' in threadsData[REQUESTED_PC_OFFSET]. Otherwise threadsData[REQUESTED_PC_OFFSET] == 0xFFFF

	' PAUSE:
	' Note: If a pause has been requested it is stored in  vmIsChannelActive[REQUESTED_STATE][i]

	for threadId As Integer = 0 To VM_NUM_THREADS -1        
		vmIsChannelActive(CURR_STATE, threadId) = vmIsChannelActive(REQUESTED_STATE, threadId) 

		Dim As uint16_t n = threadsData(REQUESTED_PC_OFFSET, threadId) 

		if (n <> VM_NO_SETVEC_REQUESTED) Then 
			threadsData(PC_OFFSET, threadId) = IIf( (n = &hFFFE) , VM_INACTIVE_THREAD , n ) 
			threadsData(REQUESTED_PC_OFFSET, threadId) = VM_NO_SETVEC_REQUESTED 
		EndIf
	Next

End Sub

Sub hostFrame()

	' Run the Virtual Machine for every active threads (one vm frame).
	' Inactive threads are marked with a thread instruction pointer set to 0xFFFF (VM_INACTIVE_THREAD).
	' A thread must feature a break opcode so the interpreter can move to the next thread.

	for threadId As Integer = 0 To VM_NUM_THREADS -1        
		if (vmIsChannelActive(CURR_STATE, threadId)) Then Continue For

		Dim As uint16_t n = threadsData(PC_OFFSET, threadId) 

		if (n <> VM_INACTIVE_THREAD) Then 

			' Set the script pointer to the right location.
			' script pc is used in executeThread in order
			' to get the next opcode.
			VM_PC=res.segBytecode + n

			_stackPtr = 0 

			gotoNextThread = FALSE 
			
			If deb=1 Then printf(!"VM  - hostFrame() INP=0x%02X   n=0x%02X *p=0x%02X\n", threadId, n, *VM_PC) 
				executeThread() 
				threadsData(PC_OFFSET, threadId) = VM_PC - res.segBytecode 'Since .pc is going to be modified by this next loop iteration, we need to save it.
			If deb=1 Then printf(!"VM  - hostFrame() OUT=0x%02X   pos=0x%X\n", threadId, threadsData(PC_OFFSET, threadId)) 
			
			If MultiKey(SC_ESCAPE) Then Exit Sub
		EndIf

	Next


End Sub



Sub executeThread()
	
	while gotoNextThread=0 
		Dim As uint8_t opcode = fetchByte() 
		
		'Print:Print "OPCODE: ";Hex(opcode,2);" DIR: ";*VM_PC
			
		' 1000 0000 is set
		if (opcode And &h80) Then 

			Dim As uint16_t off = ((opcode Shl 8) Or fetchByte()) * 2 
			res._useSegVideo2 = FALSE 
			Dim As int16_t x = fetchByte() 
			Dim As int16_t y = fetchByte() 
			Dim As int16_t h = y - 199 
			if (h > 0) Then 
				y = 199 
				x += h 			
			EndIf
  
			If deb=1 Then printf(!"vid_opcd_0x80 : opcode=0x%X off=0x%X x=%d y=%d\n", opcode, off, x, y) 

			' This switch the polygon database to "cinematic" and probably draws a black polygon over all the screen.
			setDataBuffer(res.segCinematic, off) 
			' este dibuja TODO, o sea, fondo, animaciones, y de todo.
			' COLOR_BLACK=F(255), DEFAULT_ZOOM=40(64)
			readAndDrawPolygon(COLOR_BLACK, DEFAULT_ZOOM, Type(x,y)) 

			Continue while
		EndIf
  

		' 0100 0000 is set
		if (opcode And &h40) Then 

			Dim As int16_t x, y 
			Dim As uint16_t off = fetchWord() * 2 
			x = fetchByte() 

			res._useSegVideo2 = FALSE 

			if (opcode And &h20)=0 Then 
				If (opcode And &h10)=0 Then  ' 0001 0000 is set
					x = (x Shl 8) Or fetchByte() 
				Else
					x = vmVariables(x) 
				EndIf
			Else
				if (opcode And &h10) Then  ' 0001 0000 is set
					x += &h100 
				EndIf
			EndIf
  

			y = fetchByte() 

			if (opcode And 8)=0 Then  ' 0000 1000 is set
				if (opcode And 4)=0 Then  ' 0000 0100 is set
					y = (y Shl 8) Or fetchByte() 
				Else
					y = vmVariables(y) 			
				EndIf
			EndIf
  

			Dim As uint16_t zoom = fetchByte() 

			if (opcode And 2)=0 Then ' 0000 0010 is set
				if (opcode And 1)=0 Then ' 0000 0001 is set
					VM_PC -=1
					zoom = &h40 
				Else
					zoom = vmVariables(zoom) 
				EndIf
			Else
				if (opcode And 1) Then ' 0000 0001 is set
					res._useSegVideo2 = TRUE 
					VM_PC -=1 
					zoom = &h40 	
				EndIf
			EndIf
  
			If deb=1 then printf(!"vid_opcd_0x40 : off=0x%X x=%d y=%d\n", off, x, y) 
			setDataBuffer(IIf(res._useSegVideo2 , res._segVideo2 , res.segCinematic), off) 
			readAndDrawPolygon(&hFF, zoom, Type(x, y)) 

			Continue while
		EndIf
  

		if (opcode > &h1A) Then 
			If deb=1 Then printf(!"VM  - executeThread() ec=0x%X invalid opcode=0x%X\n", &hFFF, opcode) 
		Else
			' 0x00 
			If (opcode=&h00) then op_movConst()
			If (opcode=&h01) then op_mov()
			If (opcode=&h02) then op_add()
			If (opcode=&h03) then op_addConst()
			' 0x04 
			If (opcode=&h04) then op_call()
			If (opcode=&h05) then op_ret()
			If (opcode=&h06) then op_pauseThread()
			If (opcode=&h07) then op_jmp()
			' 0x08 
			If (opcode=&h08) then op_setSetVect()
			If (opcode=&h09) then op_jnz()
			If (opcode=&h0A) then op_condJmp()
			If (opcode=&h0B) then op_setPalette()
			' 0x0C 
			If (opcode=&h0C) then op_resetThread()
			If (opcode=&h0D) then op_selectVideoPage()
			If (opcode=&h0E) then op_fillVideoPage()
			If (opcode=&h0F) then op_copyVideoPage()
			' 0x10 
			If (opcode=&h10) then op_blitFramebuffer()
			If (opcode=&h11) then op_killThread()
			If (opcode=&h12) then op_drawString()
			If (opcode=&h13) then op_sub()
			' 0x14 
			If (opcode=&h14) then op_and()
			If (opcode=&h15) then op_or()
			If (opcode=&h16) then op_shl()
			If (opcode=&h17) then op_shr()
			' 0x18 
			If (opcode=&h18) then op_playSound()
			If (opcode=&h19) then op_updateMemList()
			If (opcode=&h1A) then op_playMusic()
		EndIf
		
		
		'Print:Print "Pulsa una tecla para seguir"':Sleep
	Wend
    
End Sub



Sub inp_updatePlayer()

	' solo en la parte final
	'if (res.currentPartId = &h3E89) Then 
	'	Dim As Byte c = sys->input.lastChar 
	'	if (c = 8 Or /'c == 0xD |'/ c = 0 Or (c >= "a" And c <= "z")) Then 
	'		vmVariables(VM_VARIABLE_LAST_KEYCHAR) = c And  INV(&h20) 
	'		sys->input.lastChar = 0 
	'	EndIf
	'EndIf
  
	Dim As int16_t lr = 0 
	Dim As int16_t m  = 0 
	Dim As int16_t ud = 0 

	if MultiKey(SC_RIGHT) Then ' derecha
		lr = 1 
		m Or= 1 
	EndIf
  
	if MultiKey(SC_LEFT) Then ' izquierda
		lr = -1 
		m Or= 2 
	EndIf
  
	if MultiKey(SC_DOWN) Then ' abajo
		ud = 1 
		m Or= 4 
	EndIf

	vmVariables(VM_VARIABLE_HERO_POS_UP_DOWN) = ud 

	if MultiKey(SC_UP) Then ' arriba (subir)
		vmVariables(VM_VARIABLE_HERO_POS_UP_DOWN) = -1 
	EndIf
  
	if MultiKey(SC_UP) Then  ' arriba (saltar adelante)
		ud = -1 
		m Or= 8 
	EndIf
  
	vmVariables(VM_VARIABLE_HERO_POS_JUMP_DOWN) = ud 
	vmVariables(VM_VARIABLE_HERO_POS_LEFT_RIGHT) = lr 
	vmVariables(VM_VARIABLE_HERO_POS_MASK) = m 
	Dim As int16_t button = 0 

	' mantener CONTROL y cursores DER o IZQ para correr/saltar largo
	if MultiKey(SC_CONTROL) Then   ' CONTROL DER.: disparo, patadas
		button = 1 
		m Or= &h80 
	EndIf

	' saltar a un nivel concreto
	' ver modulo "vars.bas" para codigos
	if MultiKey(SC_F1) Then
		ChangeLevel=TRUE
		initForPart(GAME_PART9)
	EndIf

	vmVariables(VM_VARIABLE_HERO_ACTION) = button 
	vmVariables(VM_VARIABLE_HERO_ACTION_POS_MASK) = m 
End Sub

Sub inp_handleSpecialKeys()

	Dim As Integer input_pause=0 ' inventada
	Dim As Integer input_code=1 ' inventada

	if MultiKey(SC_P) Then ' pausa
		if (res.currentPartId <> GAME_PART1 And res.currentPartId <> GAME_PART2) Then 
			input_pause = FALSE 
			while input_pause=0  
				'processEvents() 
				Sleep 200,1 
			Wend	
		EndIf
		input_pause = FALSE 
	EndIf
  

	if (input_code) Then 
		input_code = FALSE 
		if (res.currentPartId <> GAME_PART_LAST And res.currentPartId <> GAME_PART_FIRST) Then 
			res.requestedNextPart = GAME_PART_LAST 
		EndIf
	EndIf
  

	' XXX
	if (vmVariables(&hC9) = 1) Then 
		If deb=1 then printf(!"VM  - inp_handleSpecialKeys() unhandled case (vmVariables[0xC9] == 1)") 
	EndIf
  

End Sub

Sub snd_playSound(resNum As uint16_t , freq As uint8_t , vol As uint8_t , channel As uint8_t)

	'If deb=1 then printf(!"snd_playSound(0x%X, %d, %d, %d)\n", resNum, freq, vol, channel) 
	
	'Dim As uint16_t memListPartIndex = resNum - GAME_PART_FIRST
	'Dim As MemEntry Ptr me = @RAM(Entidad(memListParts(memListPartIndex,0))) ' @res._memList(resNum) 

	'if (me->state <> MEMENTRY_STATE_LOADED) Then 
	'	return
	'EndIf
	'
	'if (vol = 0) Then 
	'	mixer_stopChannel(channel) 
	'Else
	'	Dim As MixerChunk mc 
	'	memset(@mc, 0, sizeof(mc)) 
	'	mc.data = me->bufPtr + 8  ' skip header
	'	mc.len = READ_BE_UINT16(me->bufPtr) * 2 
	'	mc.loopLen = READ_BE_UINT16(me->bufPtr + 2) * 2 
	'	if (mc.loopLen <> 0) Then 
	'		mc.loopPos = mc.len 
	'	EndIf
  
	'	assert(freq < 40) 
	'	mixer_playChannel(channel And 3, @mc, frequenceTable(freq), MIN(vol, &h3F)) 
	'EndIf
  
End Sub

Sub snd_playMusic(resNum As uint16_t , delay As uint16_t , pos_ As uint8_t)

	'If deb=1 then printf(!"snd_playMusic(0x%X, %d, %d)\n", resNum, delay, pos_) 

	'if (resNum <> 0) Then 
	'	player->loadSfxModule(resNum, delay, pos_) 
	'	player->start() 
	'ElseIf  (delay <> 0) Then
	'	player->setEventsDelay(delay)
	'else 
	'	player->stop() 
	'EndIf
End Sub

'Sub saveOrLoad(@ser As Serializer)
'	Serializer__Entry entries() = {
'		SE_ARRAY(vmVariables, &h100, Serializer__SES_INT16, VER(1)),
'		SE_ARRAY(_scriptStackCalls, &h100, Serializer__SES_INT16, VER(1)),
'		SE_ARRAY(threadsData, &h40 * 2, Serializer__SES_INT16, VER(1)),
'		SE_ARRAY(vmIsChannelActive, &h40 * 2, Serializer__SES_INT8, VER(1)),
'		SE_END()
'	}
'	ser.saveOrLoadEntries(entries) 
'End Sub


