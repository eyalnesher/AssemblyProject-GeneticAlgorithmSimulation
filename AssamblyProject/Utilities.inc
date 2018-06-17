.686P
.model flat, stdcall 
.xmm

; Generate a random integer between the given range (not including the highest) using rdrand
randInt proto startRange: sdword, endRange: sdword

; Generate a random real number between 0 and 1
random proto

; Copy the content of a ball to another ball
copyData proto pSource: dword, pDest: dword, dataLength: dword

; Return (in esi) the location at the memory of the ball in the given index in the given array
getElementInArray proto pArray: dword, index: dword, elementSize: dword

; Copy a Ball object to a specifiec location in an array
putElementInArray proto pElement: dword, pArray: dword, index: dword, elementSize: dword
