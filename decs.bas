' -------- DECLARACIONES ---------


	' video
	Declare Sub setDataBuffer(dataBuf As uint8_t Ptr,offset As uint16_t )
	Declare Sub readAndDrawPolygon(color_ As uint8_t ,zoom As uint16_t , pt As PointVM)
	Declare Sub fillPolygon(color_ As uint16_t,zoom As uint16_t,pt  As PointVM )
	Declare Sub readAndDrawPolygonHierarchy(zoom As uint16_t ,pt  As PointVM )
	declare function calcStep(p1 As PointVM ,p2  As PointVM ,ByRef dy As uint16_t ) as int32_t

	Declare Sub drawString(color_ As uint8_t ,x As uint16_t ,y As uint16_t ,strId As uint16_t )
	Declare Sub drawChar(c As String ,x  As uint16_t ,y As uint16_t,color_ As uint8_t ,buf As uint8_t Ptr)
	Declare Sub drawPoint(color_ As uint8_t ,x As int16_t ,y As int16_t )
	Declare Sub drawLineBlend(x1 As int16_t,x2 As int16_t,color_ As uint8_t )
	Declare Sub drawLineN(x1 As int16_t,x2 As int16_t,color_ As uint8_t )
	Declare Sub drawLineP(x1 As int16_t,x2 As int16_t,color_ As uint8_t )
	declare function getPage(page As uint8_t ) as uint8_t ptr
	Declare Sub changePagePtr1(page As uint8_t )
	Declare Sub fillPage(page As uint8_t ,color_ As uint8_t )
	Declare Sub copyPage(src As uint8_t , dst As uint8_t , vscroll As int16_t )
	Declare Sub copyPage2(src As uint8_t Ptr)
	Declare Sub changePal(pal As uint8_t )
	Declare Sub updateDisplay(page As uint8_t )
	
	
	
	' VM (maquina virtual)
	Declare Sub init() 
	
	Declare Sub op_movConst() 
	Declare Sub op_mov() 
	Declare Sub op_add() 
	Declare Sub op_addConst() 
	Declare Sub op_call() 
	Declare Sub op_ret() 
	Declare Sub op_pauseThread() 
	Declare Sub op_jmp() 
	Declare Sub op_setSetVect() 
	Declare Sub op_jnz() 
	Declare Sub op_condJmp() 
	Declare Sub op_setPalette() 
	Declare Sub op_resetThread() 
	Declare Sub op_selectVideoPage() 
	Declare Sub op_fillVideoPage() 
	Declare Sub op_copyVideoPage() 
	Declare Sub op_blitFramebuffer() 
	Declare Sub op_killThread() 	
	Declare Sub op_drawString() 
	Declare Sub op_sub() 
	Declare Sub op_and() 
	Declare Sub op_or() 
	Declare Sub op_shl() 
	Declare Sub op_shr() 
	Declare Sub op_playSound() 
	Declare Sub op_updateMemList() 
	Declare Sub op_playMusic() 

	Declare Sub initForPart(partId As uint16_t) 
	Declare Sub checkThreadRequests() 
	Declare Sub hostFrame() 
	Declare Sub executeThread() 

	Declare Sub inp_updatePlayer() 
	Declare Sub inp_handleSpecialKeys() 
	
	Declare Sub snd_playSound(resNum As uint16_t, freq As uint8_t, vol As uint8_t, channel As uint8_t) 
	Declare Sub snd_playMusic(resNum As uint16_t, delay As uint16_t, pos_ As uint8_t) 
	
	
	