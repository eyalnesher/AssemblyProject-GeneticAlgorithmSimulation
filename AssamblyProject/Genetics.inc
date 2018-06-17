.686P
.model flat, stdcall 
.xmm

include Vectorator.inc


;----------Functions' Declaration----------;


; Initial the location, velocity and life of the ball
initBasicBall proto pBall: ptr Ball, pInitLoc: ptr Vector

; Initialize a ball with the given location and random Vertors
initBall proto pBall: ptr Ball, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword

; Initialize a new random population of balls, all at the same location, which its size is the given size
createPopulation proto population: dword, arraySize: dword, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword

; Changes the velocity of the given ball by the given Vector.
; It simulates a physical force on the ball.
applyForce proto pBall: ptr Ball, pForce: ptr Vector

; Changes the location of the given ball by the ball's velocity.
move proto pBall: ptr Ball

; Checks if the ball soposed to be alive or dead.
; If it soposed to be dead, the function changes it's living byte.
; The value (of life) returned in eax
isAlive proto pBall: ptr Ball, pTarget: ptr Vector, radios: dword

; Check if the ball is alive or dead.
; If the ball is alive, his location is updated by the current force
update proto pBall: ptr Ball, forceIndex: dword, pTarget: ptr Vector, radios: dword

; Calculate the fitness of the given ball
fitnessFunction proto pBall: ptr Ball, pTarget: ptr Vector

; Picks a parent depends on his fitness
; Assumption: in xmm3 there is the sum of all the fitness values
evaluate proto pPopulation: dword, pTarget: ptr Vector

; Initialize the matingpool using the balls fitness
initMatingpool proto pBalls: dword, ballsSize: dword, pMatingpool: dword, matingpoolSize: dword, pTarget: ptr Vector

; Mutation. mutationRate is an integer between 0 and 100
mutation proto pBall: ptr Ball, mutationRate: dword, dnaLength: dword, startRange: dword, endRange: dword

; Crossover two parents and create a new child ball and put the child in a given array
crossover proto pParent1: ptr Ball, pParent2: ptr Ball, dnaLength: dword, pArray: dword, index: dword, pLocation: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

; Select to parents from the matingpool and make a new child
naturalSelection proto pMatingpool: dword, matingpoolSize: dword, pArray: dword, arraySize: dword, dnaLength: dword, pLocation: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

evolve proto pPopulation: dword, populationSize: dword, pMatingpool: dword, matingpoolSize: dword, dnaLength: dword, pLocation: ptr Vector, pTarget: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

;----------------Structures----------------;

; Vector structures
	
	

; Ball structure	
	Ball STRUCT
		
		; The location
		location Vector <>

		; tThe velocity
		velocity ReaVector <>

		; the acceleration
		acceleration ReaVector <>

		;The "DNA" of the ball		
		forces1 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces2 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces3 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces4 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces5 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces6 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces7 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces8 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces9 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces10 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces11 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces12 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces13 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces14 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces15 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces16 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces17 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces18 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces19 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>
		forces20 ReaVector <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>,
					   <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>, <>

		; Alive or dead
		live byte ?
	Ball ENDS




	




