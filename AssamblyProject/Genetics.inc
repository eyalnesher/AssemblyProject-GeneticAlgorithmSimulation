.686P
.model flat, stdcall 
.xmm


;----------Functions' Declaration----------;

; Convert signed ranges to unsigned ranges and vice versa
adjust proto value: dword

; Generate a random numbern between the given range (not including the highest) using rdrand
random proto startRange: sdword, endRange: sdword

; Generate a random Vector, which is components are numbers between the given range
generateRandomVector proto pVector: ptr Vector, startRange: sdword, endRange: sdword

; Initialize a Ball with the given location and random Vertors
initBall proto pBall: ptr Ball, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword

; Initialize a new random population of Balls, all at the same location, which its size is the given size
createPopulation proto population: dword, arraySize: dword, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword

; Changing the location of the given Ball by the given Vector.
; It simulates a force on the Ball.
applyForce proto pBall: ptr Ball, pForce: ptr Vector

; Checks if the ball soposed to be alive or dead.
; If it soposed to be dead, the function changes it's living byte.
isAlive proto pBall: ptr Ball

; Copy the content of a ball to another ball
copyData proto pSource: dword, pDest: dword, dataLength: dword

; Return (in esi) the location at the memory of the ball in the given index in the given array
getElementInArray proto pArray: dword, index: dword, elementSize: dword

; Copy a Ball object to a specifiec location in an array
putElementInArray proto pElement: dword, pArray: dword, index: dword, elementSize: dword

; Calculate the distance between two points
squaredDistance proto p1: ptr Vector, p2: ptr Vector

; Calculate the fitness of the given ball
fitnessFunction proto pBall: ptr Ball, pTarget: ptr Vector

; Initialize the matingpool using the balls fitness
initMatingpool proto pBalls: dword, ballsSize: dword, pMatingpool: dword, matingpoolSize: dword, pTarget: ptr Vector

; Crossover two parents and create a new child ball and put the child in a given array
crossover proto pParent1: ptr Ball, pParent2: ptr Ball, dnaLength: dword, pArray: dword, index: dword, pLocation: ptr Vector

; Select to parents from the matingpool and make a new child
naturalSelection proto pMatingpool: dword, matingpoolSize: dword, pArray: dword, arraySize: dword, dnaLength: dword, pLocation: ptr Vector

evolve proto pPopulation: dword, populationSize: dword, pMatingpool: dword, matingpoolSize: dword, dnaLength: dword, pLocation: ptr Vector, pTarget: ptr Vector

;----------------Structures----------------;

; Vector structure	
	Vector STRUCT
		x sdword ?
		y sdword ?
	Vector ENDS

; Ball structure	
	Ball STRUCT
		
		; The location
		location Vector <> 

		;The "DNA" of the ball		
		forces1 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces2 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces3 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces4 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces5 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces6 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces7 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces8 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces9 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces10 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces11 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces12 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces13 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces14 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces15 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces16 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces17 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces18 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces19 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces20 Vector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>

		; Alive or dead
		live byte ?
	Ball ENDS




	




