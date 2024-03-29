
include Setmodel.inc
include Genetics.inc

.const
		
	one dword 1
	thousand dword 1000

	screenSizeX equ 1000
	screenSizeY equ 600

	obstacleX = 450
	obstacleY = 150
	obstacleWidth = 100
	obstacleHeight = 300


.code


initBasicBall proc pBall: ptr Ball, pInitLoc: ptr Vector

	push eax
	push ebx
	push ecx
	push esi

	; Initial location
	mov esi, pball
	lea esi, (Ball ptr [esi]).location
	mov ebx, pInitLoc

	lea eax, (Vector ptr [esi]).x
	mov ecx, (Vector ptr [ebx]).x
	mov [eax], ecx
	lea eax, (Vector ptr [esi]).y
	mov ecx, (Vector ptr [ebx]).y
	mov [eax], ecx

	; Initial valocity
	mov esi, pball
	lea esi, (Ball ptr [esi]).velocity
	mov (Vector ptr [esi]).x, 0
	mov (Vector ptr [esi]).y, 0

	; Initial life
	mov esi, pball
	mov (Ball ptr [esi]).live, 1

	pop esi
	pop ecx
	pop ebx
	pop eax
	ret

initBasicBall endp


initBall proc pBall: ptr Ball, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword

	push eax
	push ebx
	push ecx
	push edx
	push esi

	invoke initBasicBall, pBall, pInitLoc

	xor ecx, ecx
	
	setDna:
		cmp ecx, dnaLength
			jg exitInitBall
		mov esi, pball
		invoke getElementInArray, addr (Ball ptr [esi]).forces1, ecx, Sizeof(Vector)
		invoke generateRandomVector, esi, startRange, endRange
		inc ecx
		jmp setDna
	
	exitInitBall:
		pop esi
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret

initBall endp


createPopulation proc pPopulation: dword, arraySize: dword, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword
	
	push ebx
	push ecx
	push esi

	xor ecx, ecx
	
	createPop:
		cmp ecx, arraySize
			je exitCreatePopulation
		invoke getElementInArray, pPopulation, ecx, Sizeof(Ball)
		assume esi: ptr Ball
		invoke initBall, esi, pInitLoc, dnaLength, startRange, endRange
		inc ecx
		jmp createPop
	
	exitCreatePopulation:
		pop esi
		pop ecx
		pop ebx
		ret

createPopulation endp


applyForce proc pBall: ptr Ball, pForce: ptr Vector
	
	push eax
	push ebx

	mov eax, pBall
	lea eax, (Ball ptr [eax]).velocity
	mov ebx, pForce
	
	assume eax: ptr Vector
	assume ebx: ptr Vector
	invoke addVector, eax, ebx

	pop ebx
	pop eax
	ret

applyForce endp


move proc pBall: ptr Ball

	push eax
	push ebx

	mov eax, pBall
	lea ebx, (Ball ptr [eax]).velocity
	lea eax, (Ball ptr [eax]).location

	assume eax: ptr Vector
	assume ebx: ptr Vector
	invoke addVector, eax, ebx

	pop ebx
	pop eax
	ret

move endp


isAlive proc pBall: ptr Ball, pTarget: ptr Vector, radios: dword

	push ebx
	push ecx
	push edx

	
	mov ebx, pBall
	lea ebx, (Ball ptr [ebx]).location

	; Crashed x component
	mov eax, (Vector ptr [ebx]).x

	; Edges
	cmp eax, 0
		jle kill
	cmp eax, screenSizeX
		jge kill

	; Dead y component
	mov eax, (Vector ptr [ebx]).y
	cmp eax, 0
		jle kill
	cmp eax, screenSizeY
		jge kill

		; Obstacle
		obstacleCrashX:
			mov eax, (Vector ptr [ebx]).x
			xor edx, edx
			mov ecx, obstacleX
			cmp eax, ecx
				jl nextCrashedX
				inc edx
			nextCrashedX:
				add ecx, obstacleWidth
				cmp eax, ecx
					jg obstacleCrashY
					inc edx

		obstacleCrashY:
			mov eax, (Vector ptr [ebx]).y
			mov ecx, obstacleY
			cmp eax, ecx
				jl nextCrashedY
				inc edx
			nextCrashedY:
				add ecx, obstacleHeight
				cmp eax, ecx
					jg complete
					inc edx
				cmp edx, 4
					je kill

	complete:
		; Complete x component
		mov eax, (Vector ptr [ebx]).x
		mov ecx, pTarget
		mov ecx, (Vector ptr [ecx]).x
		sub ecx, radios
		cmp eax, ecx
			mov ebx, 1
			cmovb eax, ebx
			jl exitIsAlive
		add ecx, radios
		add ecx, radios
		cmp eax, ecx
			mov ebx, 1
			cmovg eax, ebx
			jg exitIsAlive

		; Complete y component
		mov ebx, pBall
		lea ebx, (Ball ptr [ebx]).location
		mov eax, (Vector ptr [ebx]).y
		mov ecx, pTarget
		mov ecx, (Vector ptr [ecx]).y
		sub ecx, radios
		cmp eax, ecx
			mov ebx, 1
			cmovb eax, ebx
			jl exitIsAlive
		add ecx, radios
		add ecx, radios
		cmp eax, ecx
			mov ebx, 1
			cmovg eax, ebx
			jg exitIsAlive

		; Complete
		mov ebx, pBall
		mov (Ball ptr [ebx]).live, 2
		mov eax, 2
		jmp exitIsAlive

	kill:
		mov ebx, pBall
		mov (Ball ptr [ebx]).live, 0
		xor eax, eax
		
	exitIsAlive:
		pop edx
		pop ecx
		pop ebx
		ret

isAlive endp


update proc pBall: ptr Ball, forceIndex: dword, pTarget: ptr Vector, radios: dword

	push esi

	invoke isAlive, pBall, pTarget, radios
	cmp eax, 0
		je exitUpdate
	cmp eax, 2
		je exitUpdate
	mov esi, pBall
	lea esi, (Ball ptr [esi]).forces1
	invoke getElementInArray, esi, forceIndex, Sizeof(Vector)
	assume esi: ptr Vector
	invoke applyForce, pBall, esi
	invoke move, pBall

	exitUpdate:
		pop esi
		ret

update endp


;----------------Evolution----------------;


fitnessFunction proc pBall: ptr Ball, pTarget: ptr Vector

	push eax
	push esi
	sub esp, 16
	movupd [esp], xmm1

	; f(b) = 1/(d(b))^2
	cvtsi2sd xmm0, one
	mov esi, pBall
	lea esi, (Ball ptr [esi]).location
	assume esi: ptr Vector
	invoke squaredDistance, esi, pTarget
	cvtsi2sd xmm1, eax
	divsd xmm0, xmm1

	; If the ball is dead, he should pass his genes to the next generation less often
	; If he ball completed his goal, he should pass his genes to the next generation more often
	movzx eax, (Ball ptr [esi]).live
	cmp eax, 1
		je exitFitnessFunction
		cmp eax, 2
			je completed
		cvtsi2sd xmm1, thousand
		divsd xmm0, xmm1
		jmp exitFitnessFunction

		completed:
			cvtsi2sd xmm1, thousand
			mulsd xmm0, xmm1
	

	exitFitnessFunction:
		movupd xmm1, [esp]
		add esp, 16
		pop esi
		pop eax
		ret

fitnessFunction endp


maxFitness proc pPopulation: dword, populationSize: dword , pTarget: ptr Vector

	push ecx
	sub esp, 16
	movupd [esp], xmm1

	xor ecx, ecx
	xorpd xmm1, xmm1
	maxFitnessLoop:
		cmp ecx, populationSize
			jge maxFitnessExit
		invoke getElementInArray, pPopulation, ecx, Sizeof(Ball)
		assume esi: ptr Ball
		invoke fitnessFunction, esi, pTarget
		comisd xmm1, xmm0
			jge nextMax
		movsd xmm1, xmm0

		nextMax:
			inc ecx
			jmp maxFitnessLoop

	maxFitnessExit:
		movsd xmm0, xmm1
		sub esp, 16
		movupd [esp], xmm1
		pop ecx
		ret

maxFitness endp


evaluate proc pBalls: dword, populationSize: dword, pMatingpool: dword, matingpoolSize: dword, pTarget: ptr Vector

	push eax
	push ebx
	push ecx
	push edx
	push esi
	sub esp, 16
	movupd  qword ptr [esp], xmm0
	sub esp, 16
	movupd qword ptr [esp], xmm1
	sub esp, 16
	movupd qword ptr [esp], xmm2
	sub esp, 16
	movupd qword ptr [esp], xmm3

	; Sum calculation
	xor ebx, ebx
	xorpd xmm1, xmm1
	; For each ball
	fitnessSumLoop:
		cmp ebx, populationSize
			jge matingpoolInit
		invoke getElementInArray, pBalls, ebx, Sizeof(Ball)
		assume esi: ptr Ball
		invoke fitnessFunction, esi, pTarget
		addsd xmm1, xmm0 ; The sum of all the fitness values
		inc ebx
		jmp fitnessSumLoop

	; The initialize of the matingpool
	matingpoolInit:

		xor ebx, ebx ; The ball index
		xor ecx, ecx ; The matingpool index
		; For each ball
		BallLoop:

			; The number of times the ball will be in the matingpool
			; For each ball
			cmp ebx, populationSize
				je exitEvaluate
			mov eax, matingpoolSize
			cvtsi2sd xmm2, eax
			invoke getElementInArray, pBalls, ebx, Sizeof(Ball)
			assume esi: ptr Ball
			invoke fitnessFunction, esi, pTarget
			mulsd xmm2, xmm0
			divsd xmm2, xmm1
			
			; Initializing the mating pool
			xor edx, edx
			initLoop:
			
				cmp ecx, matingpoolSize
					jae exitBallLoop
				cvtsi2sd xmm3, edx
				comisd xmm3, xmm2
					jae exitBallLoop
				invoke putElementInArray, esi, pMatingpool, ecx, Sizeof(Ball)
				inc ecx
				inc edx
				jmp initLoop
		
			exitBallLoop:
				inc ebx
				jmp BallLoop

	exitEvaluate:
		movupd xmm3, [esp]
		add esp, 16
		movupd xmm2, [esp]
		add esp, 16
		movupd xmm1, [esp]
		add esp, 16
		movupd xmm0, [esp]
		add esp, 16
		pop esi
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret

evaluate endp


mutation proc pBall: ptr Ball, mutationRate: dword, dnaLength: dword, startRange: dword, endRange: dword

	push eax
	push ecx
	push esi

	mov esi, pBall
	lea esi, (Ball ptr [esi]).forces1
	; For each vector in the ball's DNA
	xor ecx, ecx
	mutationLoop:

		cmp ecx, dnaLength
			jge exitMutation

		invoke random, 0, 101
		cmp eax, mutationRate
			jge nextMutate

		mov eax, esi
		invoke getElementInArray, esi, ecx, Sizeof(Vector)
		assume esi: ptr Vector
		invoke generateRandomVector, esi, startRange, endRange
		mov esi, eax

		nextMutate:
			inc ecx
			jmp mutationLoop

	exitMutation:
		pop esi
		pop ecx
		pop eax
		ret

mutation endp


crossover proc pParent1: ptr Ball, pParent2: ptr Ball, dnaLength: dword, pPopulation: dword, index: dword, pLocation: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	; picking a random number
	invoke random, 0, dnaLength
	mov ecx, eax

	; Making a new child
	invoke getElementInArray, pPopulation, index, Sizeof(Ball)

	assume esi: ptr Ball
	invoke initBasicBall, esi, pLocation

	; Parent 1
	lea ebx, (Ball ptr [esi]).forces1
	mov eax, Sizeof(Vector)
	mul ecx
	mov edi, eax
	mov edx, pParent1
	lea edx, (Ball ptr [edx]).forces1
	invoke copyData, edx, ebx, eax

	; Parent 2
	mov edi, eax
	mov edx, dnaLength
	sub edx, ecx
	mov eax, Sizeof(Vector)
	mul edx
	add ebx, eax
	mov edx, pParent2
	lea edx, (Ball ptr [edx]).forces1
	add edx, edi
	invoke copyData, edx, ebx, eax

	; Mutation
	assume esi: ptr Ball
	invoke mutation, esi, mutationRate, dnaLength, startRange, endRange

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

crossover endp


naturalSelection proc pMatingpool: dword, matingpoolSize: dword, pPopulation: dword, populationSize: dword, dnaLength: dword, pLocation: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

	push eax
	push ebx
	push ecx
	push edx
	push esi

	xor edx, edx
	selectionLoop:

		cmp edx, populationSize
			jge exitNaturalSelection

		; Picks a random parent from the matingpool
		mov ecx, matingpoolSize
		invoke random, 0, ecx
		mov ebx, eax

		; Picks another random parent from the matingpool
		dec ecx
		invoke random, 0, ecx
		cmp ebx, eax ; The parents musn't be identicall
			jge getParents ; Now if the last ball in the matingpool wasn't been chosen yet, it could still be chosen
		inc eax

		getParents:
			invoke getElementInArray, pMatingpool, eax, Sizeof(Ball)
			mov ecx, esi
			invoke getElementInArray, pMatingpool, ebx, Sizeof(Ball)

		; Crossover
		invoke crossover, ecx, esi, dnaLength, pPopulation, edx, pLocation, mutationRate, startRange, endRange
		
		inc edx
		jmp selectionLoop

	exitNaturalSelection:
		pop esi
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret

naturalSelection endp


evolve proc pPopulation: dword, populationSize: dword, pMatingpool: dword, matingpoolSize: dword, dnaLength: dword, pLocation: ptr Vector, pTarget: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

	invoke evaluate, pPopulation, populationSize, pMatingpool, matingpoolSize, pTarget
	invoke naturalSelection, pMatingpool, matingpoolSize, pPopulation, populationSize, dnaLength, pLocation, mutationRate, startRange, endRange
	ret

evolve endp


end
