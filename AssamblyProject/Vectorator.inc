.686P
.model flat, stdcall 
.xmm

include Utilities.inc
;----------Functions' Declaration----------;

; Convert IntVector to RealVector
convertVectorIntToReal proto ptr Vector, ptr RealVector

; Convert RealVector to IntVector 
convertVectorRealToInt proto ptr Vector, ptr RealVector

; Generate a random Vector, which is components are numbers between the given range
generateRandomVector proto pVector: ptr Vector, startRange: sdword, endRange: sdword

; Add the second vector to the first one
addVector proto pVector1: ptr Vector, pVector2: ptr Vector

; Calculate the distance between two points
squaredDistance proto p1: ptr Vector, p2: ptr Vector

RealVector STRUCT
		x xmmword ?
		y xmmword ?
	RealVector ENDS

	Vector STRUCT
		x sdword ?
		y sdword ?
	Vector ENDS