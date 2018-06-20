
include Vectorator.inc


;----------Functions' Declaration----------;


; Initialize the location, velocity and life of the ball - the basic properties a ball have
; pBall - the offset of the ball
; pInitLoc - the offset of the initial location
initBasicBall proto pBall: ptr Ball, pInitLoc: ptr Vector

; Initialize a ball with basic properties and random Vertors as DNA
; pBall - the offset of the ball
; pInitLoc - the offset of the initial location
; dnaLength - the length of the DNA (the lifeSpan of the ball)
; startRange, endRange - the range of the random values of the vectors
initBall proto pBall: ptr Ball, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword

; Initialize a new random population of balls, all at the same location, which its size is the given size
; pPopulation - the offset of the array of balls representing the population
; pInitLoc - the offset of the initial location
; dnaLength - the length of the DNA (the lifeSpan of the ball)
; startRange, endRange - the range of the random values of the vectors of the balls
createPopulation proto pPopulation: dword, arraySize: dword, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword

; Changes the velocity of the given ball by the given Vector- add the two vectors
; It simulates a physical force on the ball.
; pBall - the offset of the ball
; pForce - the offset of the vector representng a force
applyForce proto pBall: ptr Ball, pForce: ptr Vector

; Changes the location of the given ball by the ball's velocity - add the two vectors
; pBall - the offset of the ball
move proto pBall: ptr Ball

; Checks if the ball soposed to be alive or dead.
; If it soposed to be dead, the function changes it's living byte to 0.
; If the ball completed his goal (reach the target, or at least to a given distance from it),
; the function changes it's living byte to 2.
; Otherwise, the living bit is 1.
; The value (of life) returned in eax
; pBall - the offset of the ball
; pTraget - the offset of the target
; radios - the maximum distance a ball can be from the target and still count as a ball which complete his goal
isAlive proto pBall: ptr Ball, pTarget: ptr Vector, radios: dword

; Check if the ball is alive or dead.
; If the ball is alive, his location is updated by the current force - 
; change the velocity by the force and then the location by the velocity.
; pBall - the offset of the ball
; pForce - the index of the force n the ball's DNA that changes the ball
; pTraget - the offset of the target
; radios - the maximum distance a ball can be from the target and still count as a ball which complete his goal
update proto pBall: ptr Ball, forceIndex: dword, pTarget: ptr Vector, radios: dword

; Calculate the fitness of the given ball - 1 divide the- distance squared
; pBall - the offset of the ball
; pTraget - the offset of the target
fitnessFunction proto pBall: ptr Ball, pTarget: ptr Vector

; Calculate the maximum fitness of a population
maxFitness proto pPopulation: dword, populationSize: dword , pTarget: ptr Vector

; Initialize the matingpool using the balls fitness values
; pPopulation - the offset of the array of balls representing the population
; populationSize - the size of the population
; pMatingpool - the offset of the mating pool
; matingpoolSize - the size of the mating pool
; pTraget - the offset of the target
evaluate proto pPopulation: dword, populationSize: dword, pMatingpool: dword, matingpoolSize: dword, pTarget: ptr Vector

; Mutation - changes a force randomly by a chance of mutationRate/100.
; pBall - the offset of the ball
; mutationRate - the probability a force will change, in percentage. It is an integer between 0 and 100
; dnaLength - the length of the DNA (the lifeSpan of the ball)
; startRange, endRange - the range of the random values of the vectors
mutation proto pBall: ptr Ball, mutationRate: dword, dnaLength: dword, startRange: dword, endRange: dword

; Crossover two parents and create a new child ball and put the child in a given array
; pParent1 - the offset of the first parent
; pParent2 - the offset of the second parent
; dnaLength - the length of the DNA (the lifeSpan of the ball)
; pPopulation - the offset of the array of balls representing the population
; index - the index of the population array where the ball is initialized
; pLocation - the offset of the initial location
; mutationRate - the probability a force will change, in percentage. It is an integer between 0 and 100
; startRange, endRange - the range of the random values of the vectors of the child
crossover proto pParent1: ptr Ball, pParent2: ptr Ball, dnaLength: dword, pPopulation: dword, index: dword, pLocation: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

; Selects to parents from the matingpool, make a new children and creates a new generation
; pMatingpool - the offset of the mating pool
; matingpoolSize - the size of the mating pool
; pPopulation - the offset of the array of balls representing the population
; populationSize - the size of the population
; dnaLength - the length of the DNA (the lifeSpan of the ball)
; pLocation - the offset of the initial location
; mutationRate - the probability a force will change, in percentage. It is an integer between 0 and 100
; startRange, endRange - the range of the random values of the vectors of the balls
naturalSelection proto pMatingpool: dword, matingpoolSize: dword, pPopulation: dword, populationSize: dword, dnaLength: dword, pLocation: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

; Evolves the population by initialize the mating pool and create a new generation
; pPopulation - the offset of the array of balls representing the population
; populationSize - the size of the population
; pMatingpool - the offset of the mating pool
; matingpoolSize - the size of the mating pool
; dnaLength - the length of the DNA (the lifeSpan of the ball)
; pLocation - the offset of the initial location
; pTraget - the offset of the target
; mutationRate - the probability a force will change, in percentage. It is an integer between 0 and 100
; startRange, endRange - the range of the random values of the vectors of the balls
evolve proto pPopulation: dword, populationSize: dword, pMatingpool: dword, matingpoolSize: dword, dnaLength: dword, pLocation: ptr Vector, pTarget: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

;----------------Structures----------------;


	Ball STRUCT
		
		; The location
		location Vector <>

		; tThe velocity
		velocity Vector <>

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

		; Alive or dead
		live byte ?
	Ball ENDS
