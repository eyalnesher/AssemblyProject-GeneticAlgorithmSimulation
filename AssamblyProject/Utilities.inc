
; Generate a random integer between the given range (not including the highest) using rdrand
; startRange, endRange - the range of the random value
random proto startRange: sdword, endRange: sdword

; Copy the content of a ball to another ball
; pSource - the offset of the source
; pDest - the offset of the destination
; dataLength - the length of the copied data
copyData proto pSource: dword, pDest: dword, dataLength: dword

; Return (in esi) the location at the memory of the ball in the given index in the given array
; pArray - the offset of the array
; index - the index in the array we want to get the offset of
; elementSize - the size of each element in the array. We are assuming that all the elements are at the same size
getElementInArray proto pArray: dword, index: dword, elementSize: dword

; Copy a Ball object to a specifiec location in an array
; pArray - the offset of the array
; index - the index in the array we want to get the offset of
; elementSize - the size of each element in the array. We are assuming that all the elements are at the same size
putElementInArray proto pElement: dword, pArray: dword, index: dword, elementSize: dword
