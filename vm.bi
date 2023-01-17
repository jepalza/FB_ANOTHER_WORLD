

#define VM_NUM_THREADS 64
#define VM_NUM_VARIABLES 256
#define VM_NO_SETVEC_REQUESTED &hFFFF
#define VM_INACTIVE_THREAD     &hFFFF


Enum ScriptVars 
		VM_VARIABLE_RANDOM_SEED 			= &h3C,
		VM_VARIABLE_LAST_KEYCHAR         = &hDA,
		VM_VARIABLE_HERO_POS_UP_DOWN     = &hE5,
		VM_VARIABLE_MUS_MARK             = &hF4,
		VM_VARIABLE_SCROLL_Y             = &hF9,
		VM_VARIABLE_HERO_ACTION          = &hFA,
		VM_VARIABLE_HERO_POS_JUMP_DOWN   = &hFB,
		VM_VARIABLE_HERO_POS_LEFT_RIGHT  = &hFC,
		VM_VARIABLE_HERO_POS_MASK        = &hFD,
		VM_VARIABLE_HERO_ACTION_POS_MASK = &hFE,
		VM_VARIABLE_PAUSE_SLICES         = &hFF
End Enum


'For threadsData navigation
#define PC_OFFSET 0
#define REQUESTED_PC_OFFSET 1
#define NUM_DATA_FIELDS 2

'For vmIsChannelActive navigation
#define CURR_STATE 0
#define REQUESTED_STATE 1
#define NUM_THREAD_FIELDS 2


	'Dim Shared As Mixer Ptr mixer 
	'Dim Shared As SfxPlayer Ptr player 

	Dim Shared As int16_t vmVariables(VM_NUM_VARIABLES) 
	Dim Shared As uint16_t _scriptStackCalls(VM_NUM_THREADS) 
	Dim Shared As uint16_t threadsData(NUM_DATA_FIELDS, VM_NUM_THREADS) 

	' This array is used:
	'     0 to save the channel´s instruction pointer
	'     when the channel release control (this happens on a break).
	'     1 When a setVec is requested for the next vm frame.
	Dim Shared As uint8_t vmIsChannelActive(NUM_THREAD_FIELDS, VM_NUM_THREADS) 

	Dim Shared As uint8_t _stackPtr 
	Dim Shared As BOOL gotoNextThread 



