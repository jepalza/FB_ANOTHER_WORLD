


Sub readVertices( p As uint8_t Ptr , zoom As uint16_t)

	video.poligono.bbw = *p * zoom \ 64 : p+=1
	video.poligono.bbh = *p * zoom \ 64 : p+=1
	video.poligono.numPoints = *p : p+=1  
	
	If deb=2 Then printf(!"ReadVertices W%d,H%d,NPoints %d,ZOOM %d:\n",video.poligono.bbw,video.poligono.bbh, video.poligono.numPoints,zoom)
	'Assert( (numPoints And 1) = 0 And numPoints < MAX_POINTS ) 

	'Read all points, directly from bytecode segment
	For i As Integer = 0 To video.poligono.numPoints        
		dim as PointVM ptr pt = @video.poligono.points(i) 
		pt->x = *p * zoom \ 64 : p+=1
		pt->y = *p * zoom \ 64 : p+=1
	Next

End Sub

'Sub Video( resParameter As Resource Ptr ,  stub As System Ptr)
'	  res(resParameter), sys(stub) 
'End Sub

Sub video_init() 

	Restore textos
	Dim aa As Integer
	Dim sa As string
	For f As Integer = 0 To 500
		Read aa,sa
		If aa=END_OF_STRING_DICTIONARY Then Exit for
		'TableEngId(aa)=aa
		TableEngStr(aa)=sa
	Next

	video.paletteIdRequested = NO_PALETTE_CHANGE_REQUESTED 

	Dim As uint8_t ptr tmp = callocate(4 * VID_PAGE_SIZE) ' VID_PAGE_SIZE=320*200/2, o osea, 32000, x 4 paginas=128k de video
	'memset(tmp,0,4 * VID_PAGE_SIZE) 
	
	for i As Integer= 0 To 3        
    	Video._pages(i) = tmp + (i * VID_PAGE_SIZE) ' la pag. 0 en la pos. 0, la pag. 1 en la pos. 32000, etc
	Next

	Video._curPagePtr3 = getPage(1) 
	Video._curPagePtr2 = getPage(2) 

	changePagePtr1(&hFE) 

	Video._interpTable(0) = &h4000 

	for i As integer= 1 To &h400 -1      
		Video._interpTable(i) = &h4000 \ i 
	Next

End Sub

/'
	This
'/
Sub setDataBuffer( dataBuf As uint8_t Ptr , offset As uint16_t) 
	Video._dataBuf  = dataBuf 
	Video._pData.pc = dataBuf + offset 
End Sub


/'  A shape can be given in two different ways:

	 - A list of screenspace vertices.
	 - A list of objectspace vertices, based on a delta from the first vertex.

	 This is a recursive function. '/
Sub readAndDrawPolygon(color_ As uint8_t , zoom As uint16_t , pt As PointVM) 
	If deb=2 Then printf(!"readAndDrawPolygon COLOR %d,ZOOM %d,X%d,Y%d:\n",color_,zoom,pt.x,pt.y)
	Dim As uint8_t i = VID_fetchByte() 'Video._pData.fetchByte() 

	'This is
	if (i >= &hC0) Then  ' 0xc0 = 192

		' WTF ?
		if (color_ And &h80) Then '0x80 = 128 (1000 0000)
			color_ = i And &h3F  '0x3F =  63 (0011 1111)
		EndIf

		' pc is misleading here since we are not reading bytecode but only vertices informations.
		readVertices(video._pData.pc, zoom) 

		fillPolygon(color_, zoom, pt) 
		
	Else

		i And= &h3F   '0x3F = 63
		if (i = 1) Then 
			If deb=2 then printf(!"VID - readAndDrawPolygon() ec=0x%X (i != 2)\n", &hF80) 
		ElseIf  (i = 2) Then
			' dibuja una segunda capa sobre la primera, sobre el fondo, como las puertas, el coche, la luz....
			readAndDrawPolygonHierarchy(zoom, pt)
		Else
			If deb=2 Then printf(!"VID - readAndDrawPolygon() ec=0x%X (i != 2)\n", &hFBB) 	
		EndIf
	End If
	'sleep
End Sub

Sub fillPolygon(color_ As uint16_t , zoom As uint16_t , pt As PointVM) 
	If deb=2 Then printf(!"Fillpolygon COLOR %d,ZOOM %d,X%d,Y%d:\n",color_,zoom,pt.x,pt.y)

	if (video.poligono.bbw = 0 And video.poligono.bbh = 1 And video.poligono.numPoints = 4) Then 
		drawPoint(color_, pt.x, pt.y)
		return 
	EndIf
  
	Dim As int16_t x1 = pt.x - video.poligono.bbw \ 2
	Dim As int16_t x2 = pt.x + video.poligono.bbw \ 2
	Dim As int16_t y1 = pt.y - video.poligono.bbh \ 2
	Dim As int16_t y2 = pt.y + video.poligono.bbh \ 2

	If (x1 > 319 Or x2 < 0 Or y1 > 199 Or y2 < 0) Then 
		Return
	EndIf

	video._hliney = y1 
	
	Dim As uint16_t i, j 
	i = 0 
	j = video.poligono.numPoints - 1 
	
	x2 = video.poligono.points(i).x + x1 
	x1 = video.poligono.points(j).x + x1 

	i+=1 
	j-=1

	Dim As integer drawFct=0
	
	if (color_ < &h10) Then 
		drawFct=1  ' si color <16
	ElseIf  (color_ > &h10) Then
		drawFct=2  ' si color >16
   Else 
		drawFct=0  ' resto de casos, o sea, "0"
	End If

	Dim As uint32_t cpt1 = x1 Shl 16 
	Dim As uint32_t cpt2 = x2 Shl 16 

	while (1)  
		video.poligono.numPoints -= 2 
		if (video.poligono.numPoints < 1) Then 
			Exit Sub 'Exit While 
		EndIf
  
		Dim As uint16_t h 
		Dim As int32_t step1 = calcStep(video.poligono.points(j + 1), video.poligono.points(j), h) 
		Dim As int32_t step2 = calcStep(video.poligono.points(i - 1), video.poligono.points(i), h) 

		i+=1 
		j-=1 

		cpt1 = (cpt1 And &hFFFF0000) Or &h7FFF 
		cpt2 = (cpt2 And &hFFFF0000) Or &h8000 

		if (h = 0) Then 
			cpt1 += step1 
			cpt2 += step2 
		else
			for hh As integer =h To 1 Step -1       
				if (video._hliney >= 0) Then 
					x1 = cpt1 Shr 16 
					x2 = cpt2 Shr 16 
					if (x1 <= 319 And x2 >= 0) Then 
						if (x1 < 0) Then x1 = 0 
						if (x2 > 319) Then x2 = 319 
						If drawFct=1 Then drawLineN(x1, x2, color_)  ' si color <16
						If drawFct=2 Then drawLineP(x1, x2, color_)  ' si color >16
					   If drawFct=0 then drawLineBlend(x1, x2, color_)  ' resto de casos, pero .... eso seria siempre!!! 
					EndIf
				EndIf
				cpt1 += step1 
				cpt2 += step2 
				video._hliney +=1					
				if (video._hliney > 199) Then Exit Sub 
			Next	
		EndIf
	Wend

End Sub

/'
    What is read from the bytecode is not a pure screnspace polygon but a polygonspace polygon.

'/
Sub readAndDrawPolygonHierarchy(zoom As uint16_t , pgc As pointVM) 

	Dim As PointVM pt=pgc
	pt.x -= VID_fetchByte() * zoom \ 64 
	pt.y -= VID_fetchByte() * zoom \ 64 

	Dim As int16_t childs = VID_fetchByte() 
	If deb=2 Then printf(!"VID - readAndDrawPolygonHierarchy childs=%d\n", childs) 

	for i As Integer =childs To 0 Step -1      

		Dim As uint16_t off = VID_fetchWord() 

		Dim As PointVM po=pt

		po.x += VID_fetchByte() * zoom \ 64 
		po.y += VID_fetchByte() * zoom \ 64 

		Dim As uint16_t color_ = &hFF 
		Dim As uint16_t _bp = off 
		off And= &h7FFF 

		if (_bp And &h8000) Then 
			color_ = *video._pData.pc And &h7F 
			video._pData.pc += 2 
		EndIf
  

		Dim As uint8_t Ptr bak = video._pData.pc
		video._pData.pc = video._dataBuf + off * 2 

		readAndDrawPolygon(color_, zoom, Type(po.x,po.y))

		video._pData.pc = bak 
	
  Next

End Sub

function calcStep(p1 As PointVM , p2 As PointVM ,byref dy As uint16_t) As int32_t 
	dy = p2.y - p1.y 
	return (p2.x - p1.x) * video._interpTable(dy) * 4
End Function

Sub drawString(color_ As uint8_t , x As uint16_t , y As uint16_t , stringId As uint16_t) 
	Dim As String str_=TableEngStr(stringId)
   
	If deb=2 Then printf(!"drawString(%d, %d, %d, '%s')\n", color_, x, y, Left(str_,30)) 
	If str_="" Then Exit Sub
  
    'Used if the string contains a return carriage.
	Dim As uint16_t xOrigin = x 
	Dim As Integer len_ = len(str_) 
	for i As Integer = 1 To len_
		if ( Mid(str_,i,2) = "\n" ) Then 
			y += 8 
			x = xOrigin
			i+=1
			Continue For
		EndIf
		drawChar( Mid(str_,i,1), x, y, color_, video._curPagePtr1) 
		x+=1  
	Next

End Sub

Sub drawChar(character As String , x As uint16_t , y As uint16_t , color_ As uint8_t ,  buf As uint8_t Ptr) 
	If deb=2 Then printf(!"drawchar %s X%d Y%d COLOR%d \n",character,x,y,color_)
	if (x <= 39 And y <= 192) Then 
		Dim As uint8_t Ptr ft = @_font(0) + (Asc(character) - Asc(" ")) * 8 

		Dim As uint8_t Ptr p = buf + x * 4 + y * 160 

		for j As Integer = 0 To 7        
			Dim As uint8_t ch = *(ft + j) 
			for  i As Integer = 0 To 3        
				Dim As uint8_t b = *(p + i) 
				Dim As uint8_t cmask = &hFF 
				Dim As uint8_t colb = 0 
				if (ch And &h80) Then 
					colb Or= color_ Shl 4 
					cmask And= &h0F 
				EndIf
				ch Shl = 1 
				if (ch And &h80) Then 
					colb Or= color_ 
					cmask And= &hF0 
				EndIf
				ch Shl = 1 
				*(p + i) = (b And cmask) Or colb 
			Next
			p += 160 
		Next
	EndIf
  
End Sub

Sub drawPoint(color_ As uint8_t , x As int16_t , y As int16_t) 
	If deb=2 Then printf(!"drawPoint(COLOR %d, X%d, Y%d)\n", color_, x, y) 
	if (x >= 0 And x <= 319 And y >= 0 And y <= 199) Then 
		Dim As uint16_t off = y * 160 + x \ 2 
	
		Dim As uint8_t cmasko, cmaskn 
		if (x And 1) Then 
			cmaskn = &h0F 
			cmasko = &hF0 
		Else
			cmaskn = &hF0 
			cmasko = &h0F 
		EndIf
  
		Dim As uint8_t colb = (color_ Shl 4) Or color_ 
		if (color_ = &h10) Then 
			cmaskn And= &h88 
			cmasko =  INV(cmaskn) 
			colb = &h88 		
		ElseIf  (color_ = &h11) Then
			colb = *(video._pages(0) + off)
		EndIf
  
		Dim As uint8_t b = *(video._curPagePtr1 + off) 
		*(video._curPagePtr1 + off) = (b And cmasko) Or (colb And cmaskn) 
	EndIf
  
End Sub

' Blend=mezclar, hace transparencias, como la luz amarilla del ferrari o los rayos rojos del tunel
' Blend a line in the current framebuffer (_curPagePtr1)
Sub drawLineBlend(x1 As int16_t , x2 As int16_t , color_ As uint8_t) 
	If deb=2 Then printf(!"drawLineBlend(X1:%d, X2:%d, COLOR %d)\n", x1, x2, color_) 
	
	Dim As int16_t xmax = MAX(x1, x2) 
	Dim As int16_t xmin = MIN(x1, x2) 
	Dim As uint8_t Ptr p = Video._curPagePtr1 + (video._hliney * 160) + (xmin shr 1) 

	Dim As uint16_t w = (xmax \ 2) - (xmin \ 2) + 1 
	Dim As uint8_t cmaske = 0 
	Dim As uint8_t cmasks = 0 	
	
	if (xmin And 1) Then 
		w-=1 
		cmasks = &hF7 
	EndIf
  
	if (xmax And 1)=0 Then 
		w-=1
		cmaske = &h7F 
	EndIf

	if (cmasks <> 0) Then
		*p = (*p And cmasks) Or &h08 
		p+=1 
	EndIf
  
	while w
		*p = (*p And &h77) Or &h88 
		p+=1
		w-=1
	Wend
    
	if (cmaske <> 0) Then 
		*p = (*p And cmaske) Or &h80 
		p+=1
	EndIf

End Sub

Sub drawLineN(x1 As int16_t , x2 As int16_t , color_ As uint8_t) 
	If deb=2 Then printf(!"drawLineN(X1:%d, X2:%d, COLOR %d)\n", x1, x2, color_) 

	Dim As int16_t xmax = MAX(x1, x2) 
	Dim As int16_t xmin = MIN(x1, x2) 
	Dim As uint8_t Ptr p = video._curPagePtr1 + video._hliney * 160 + xmin Shr 1 

	Dim As uint16_t w = xmax \ 2 - xmin \ 2 + 1 
	Dim As uint8_t cmaske = 0 
	Dim As uint8_t cmasks = 0 	
	
	if (xmin And 1) Then 
		w-=1
		cmasks = &hF0 
	EndIf
  
	if (xmax And 1)=0 Then 
		w-=1
		cmaske = &h0F 
	EndIf
  
	Dim As uint8_t colb = ((color_ And &hF) Shl 4) Or (color_ And &hF) 	
	
	if (cmasks <> 0) Then 
		*p = (*p And cmasks) Or (colb And &h0F) 
		p+=1
	EndIf

	while w
		*p = colb 
		p+=1
		w-=1
	Wend
    
	if (cmaske <> 0) Then 
		*p = (*p And cmaske) Or (colb And &hF0) 
		p+=1	
	EndIf
  
End Sub

Sub drawLineP(x1 As int16_t , x2 As int16_t , color_ As uint8_t) 
	
	If deb=2 Then printf(!"drawLineP(X1:%d, X2:%d, COLOR %d)\n", x1, x2, color_) 
	
	Dim As int16_t xmax = MAX(x1, x2) 
	Dim As int16_t xmin = MIN(x1, x2) 
	
	Dim As uint16_t off = video._hliney * 160 + xmin Shr 1
	Dim As uint8_t Ptr p = video._curPagePtr1 + off 
	Dim As uint8_t Ptr q = video._pages(0) + off 

	Dim As uint8_t w = xmax \ 2 - xmin \ 2 + 1  
	Dim As uint8_t cmaske = 0 
	Dim As uint8_t cmasks = 0 	
	
	if (xmin And 1) Then 
		w-=1
		cmasks = &hF0 
	EndIf
  
	if (xmax And 1)=0 Then 
		w-=1
		cmaske = &h0F 
	EndIf

	if (cmasks <> 0) Then 
		*p = (*p And cmasks) Or (*q And &h0F) 
		p+=1
		q+=1
	EndIf
  
	while w  
		*p = *q 
		p+=1
		q+=1		
		w-=1	
	Wend

	if (cmaske <> 0) Then 
		*p = (*p And cmaske) Or (*q And &hF0) 
		p+=1
		q+=1
	EndIf
  
End Sub

Function getPage(page As uint8_t) As uint8_t Ptr
	Dim As uint8_t Ptr p 
	
	if (page <= 3) Then 
		p = video._pages(page) 
	Else
		Select Case  (page)  
			case &hFF 
				p = video._curPagePtr3 
	
			case &hFE 
				p = video._curPagePtr2 
	
			case else 
				p = video._pages(0)  ' XXX check
				If deb=2 Then printf(!"VID - getPage() p != [0,1,2,3,0xFF,0xFE] == 0x%X\n", page) 
			
		End Select
	EndIf
  
	return p 
End Function



Sub changePagePtr1(pageID As uint8_t) 
	If deb=2 Then printf(!"VID - changePagePtr1(%d)\n", pageID) 
	video._curPagePtr1 = getPage(pageID) 
End Sub



Sub fillPage(pageId As uint8_t , color_ As uint8_t) 
	If deb=2 Then printf(!"VID - fillPage(PAGE %d, COLOR %d)\n", pageId, color_) 
	Dim As uint8_t Ptr p = getPage(pageId) 

	' Since a palette indice is coded on 4 bits, we need to duplicate the
	' clearing color_ to the upper part of the byte.
	Dim As uint8_t c = (color_ Shl 4) Or color_ 
	memset(p, c, VID_PAGE_SIZE) 
End Sub

/'  This opcode is used once the background of a scene has been drawn in one of the framebuffer:
	   it is copied in the current framebuffer at the start of a new frame in order to improve performances. '/
Sub copyPage(srcPageId As uint8_t , dstPageId As uint8_t , vscroll As int16_t) 

	If deb=2 Then printf(!"VID - copyPage(SRC %d, DST %d)\n", srcPageId, dstPageId) 

	if (srcPageId = dstPageId) Then 
		return
	EndIf

	Dim As uint8_t Ptr p 
	Dim As uint8_t Ptr q 

	if (srcPageId >= &hFE Or ((srcPageId = (srcPageId And &hBF)) And &h80)=0) Then 

		p = getPage(srcPageId) 
		q = getPage(dstPageId) 
		memcpy(q, p, VID_PAGE_SIZE) 
			
	Else
         
		p = getPage(srcPageId And 3) 
		q = getPage(dstPageId) 
		if (vscroll >= -199 And vscroll <= 199) Then 
  
			Dim As uint16_t h = 200 
			if (vscroll < 0) Then 
				h +=  vscroll 
				p += -vscroll * 160 
			Else
				h -=  vscroll 
				q +=  vscroll * 160 
			EndIf
			memcpy(q, p, h * 160) 
		
		EndIf
  
	EndIf
  
End Sub




'Sub copyPage2( src As uint8_t Ptr) 
'	If deb=2 Then printf(!"VID - copyPage()\n") 
'	
'	Dim As uint8_t Ptr dst = video._pages(0) 
'	Dim As Integer h = 200 
'	
'	while h
'		h-=1
'		Dim As Integer w = 40 
'		while w
'			w-=1
'			Dim As uint8_t p(3) = { _
'				*(src + 8000 * 3), _
'				*(src + 8000 * 2), _
'				*(src + 8000 * 1), _
'				*(src + 8000 * 0) }
'			
'			for j As Integer = 0 To 3         
'				Dim As uint8_t acc = 0 
'				for i As Integer = 0 To 7         
'					acc Shl = 1 
'					acc Or= IIf ( (p(i And 3) And &h80) , 1 , 0 )
'					p(i And 3) Shl = 1 
'				Next
'				*dst = acc 
'				dst+=1  
'			Next
'			src +=1
'		Wend
'	Wend
'
'End Sub

/'
Note: The palettes set used to be allocated on the stack but I moved it to
      the heap so I could dump the four framebuffer and follow how
	  frames are generated.
'/
Sub changePal(palNum As uint8_t) 

	if (palNum >= 32) Then 
		return
	EndIf

	Dim As uint8_t Ptr p = res.segPalettes + palNum * 32  'colors are coded on 2bytes (565) for 16 colors = 32
	
	Dim As integer c1,c2,r,g,b,m
	m=0
	For f As integer=0 To 31 Step 2
		c1=*(p+f)
		c2=*(p+f+1)
    	r = (((c1 And &h0F) Shl 2) Or ((c1 And &h0F) Shr 2)) Shl 2 ' r
    	g = (((c2 And &hF0) Shr 2) Or ((c2 And &hF0) Shr 6)) Shl 2 ' g
    	b = (((c2 And &h0F) Shr 2) Or ((c2 And &h0F) Shl 2)) Shl 2 ' b
		'paleta(m)=RGBA(r,g,b,a)
		Palette m,r,g,b
		m+=1
	Next
	video.currentPaletteId = palNum 
End Sub

Sub updateDisplay(pageId As uint8_t) 

	If deb=2 Then printf(!"VID - updateDisplay(%d)\n", pageId) 

	if (pageId <> &hFE) Then 
		if (pageId = &hFF) Then 
			Swap video._curPagePtr2, video._curPagePtr3
		Else
			video._curPagePtr2 = getPage(pageId) 
		EndIf
	EndIf


	' vuelca la matriz de pantalla en la zona visible (x2)
	ScreenLock
	Dim As uint16_t height = SCREEN_H
	Dim As uint8_t ptr p   = ScreenPtr
	Dim As uint8_t ptr src = video._curPagePtr2
	Dim As integer pitch
	ScreenInfo ,,,,pitch
	while height
		height-=1
		for i As integer= 0 to (SCREEN_W \ 2) -1
			' modo 320x200 dejar estas
			'p[i * 2 + 0] = *(src + i) shr 4     ' primer pixel
			'p[i * 2 + 1] = *(src + i) And &h0F  ' segundo, seguido en "x" del anterior
			' modo 640x400 poner estas
			p[i * 4 + 0] = *(src + i) shr 4
			p[i * 4 + 1] = *(src + i) shr 4
			p[i * 4 + pitch +0] = *(src + i) shr 4
			p[i * 4 + pitch +1] = *(src + i) shr 4
			'
			p[i * 4 + 2] = *(src + i) And &h0F
			p[i * 4 + 3] = *(src + i) And &h0F
			p[i * 4 + pitch +2] = *(src + i) And &h0F
			p[i * 4 + pitch +3] = *(src + i) And &h0F
		next
		p += pitch*2 ' siguiente linea (para modo 320x200 quitar el "*2")
    src += SCREEN_W\2
	Wend
	screenunlock



	'Check if we need to change the palette
	If (video.paletteIdRequested <> NO_PALETTE_CHANGE_REQUESTED) Then 
		changePal(video.paletteIdRequested) 
		video.paletteIdRequested = NO_PALETTE_CHANGE_REQUESTED 
	EndIf

	'Q: Why 160 ?
	'A: Because one byte gives two palette indices so
	'   we only need to move 320/2 per line.
  'updateDisplay(_curPagePtr2) 
End Sub

'Sub saveOrLoad(@ser As Serializer) 
	'Dim As uint8_t mask = 0 
	'if (ser._mode = Serializer__SM_SAVE) Then 
  
	'	for  i As Integer = 0 To 3         
	'		if (_pages(i) = _curPagePtr1) Then 
	'			mask Or= i Shl 4
	'		EndIf
  
	'		if (_pages(i) = _curPagePtr2) Then 
	'			mask Or= i Shl 2
	'		EndIf
  
	'		if (_pages(i) = _curPagePtr3) Then 
	'			mask Or= i Shl 0
	'		EndIf
	'	
	'	Next
	'
	'EndIf
  
	'Dim As Serializer__Entry entries() = { _
	'	SE_INT(@currentPaletteId, Serializer__SES_INT8, VER(1)), _
	'	SE_INT(@paletteIdRequested, Serializer__SES_INT8, VER(1)), _
	'	SE_INT(@mask, Serializer__SES_INT8, VER(1)), _
	'	SE_ARRAY(_pages(0), Video__VID_PAGE_SIZE, Serializer__SES_INT8, VER(1)), _
	'	SE_ARRAY(_pages(1), Video__VID_PAGE_SIZE, Serializer__SES_INT8, VER(1)), _
	'	SE_ARRAY(_pages(2), Video__VID_PAGE_SIZE, Serializer__SES_INT8, VER(1)), _
	'	SE_ARRAY(_pages(3), Video__VID_PAGE_SIZE, Serializer__SES_INT8, VER(1)), _
	'	SE_END() _
	'} 
	'
	'ser.saveOrLoadEntries(entries) 

	'if (ser._mode = Serializer__SM_LOAD) Then 
	'	_curPagePtr1 = _pages((mask Shr 4) And &h3) 
	'	_curPagePtr2 = _pages((mask Shr 2) And &h3) 
	'	_curPagePtr3 = _pages((mask Shr 0) And &h3) 
	'	changePal(currentPaletteId) 
	'EndIf
  
'End Sub
