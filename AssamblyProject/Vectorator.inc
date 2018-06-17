
include Utilities.inc

;----------Functions' Declaration----------;


; Generate a random Vector, which is components are numbers between the given range
; pVector - the offset of the vector
; startRange, endRange - the range of the random values of the vector
generateRandomVector proto pVector: ptr Vector, startRange: sdword, endRange: sdword

; Add the second vector to the first one
; pVector1 - the offset of the first vector
; pVector2 - the offset of the second vector
addVector proto pVector1: ptr Vector, pVector2: ptr Vector

; Calculate the distance between two points
; pVector1 - the offset of the first point (Vector)
; pVector2 - the offset of the second point (Vector)
squaredDistance proto p1: ptr Vector, p2: ptr Vector


;----------------Structures----------------;


	Vector STRUCT
		x sdword ?
		y sdword ?
	Vector ENDS
