

#define MAX(x,y) IIf((x)>(y),(x),(y))
#define MIN(x,y) iif((x)<(y),(x),(y))


Function READ_BE_UINT16(b As uint8_t Ptr) As uint16_t 
	return (b[0] Shl 8) Or b[1]
End Function

Function READ_BE_UINT32(b As uint8_t ptr) As uint32_t 
	return (b[0] Shl 24) Or (b[1] Shl 16) Or (b[2] Shl 8) Or b[3]
End Function

Function INV(a As Integer) As Integer
	Return Not(a)
End Function


Dim Shared As uint8_t Ptr VM_PC

	
Type PtrVM
	As uint8_t Ptr pc
End Type

function fetchByte() As uint8_t
	Dim As uint8_t i
	i=*VM_PC
	VM_PC+=1
	return i  
End Function

Function fetchWord() As uint16_t
	Dim As uint16_t i = READ_BE_UINT16(VM_PC) 
	VM_PC += 2 
	return i 
End Function 



Type PointVM
	As int16_t x, y 
End Type 


