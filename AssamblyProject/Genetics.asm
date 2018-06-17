
include Setmodel.inc
include Genetics.inc

.const
		
	one dword 1
	thousand dword 1000

	screenSizeX equ 1000
	screenSizeY equ 600


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

	; Initial acceleration
	mov esi, pball
	lea esi, (Ball ptr [esi]).acceleration
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


createPopulation proc population: dword, arraySize: dword, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword
	
	push ebx
	push ecx
	push esi

	xor ecx, ecx
	
	createPop:
		cmp ecx, arraySize
			je exitCreatePopulation
		mov ebx, population
		mov eax, ecx
		imul eax, Sizeof(Ball)
		lea esi, [ebx + eax]
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
	lea eax, (Ball ptr [eax]).acceleration
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
	push ecx

	mov eax, pBall
	lea ecx, (Ball ptr [eax]).acceleration
	lea ebx, (Ball ptr [eax]).velocity

	assume ebx: ptr Vector
	assume ecx: ptr Vector
	invoke addVector, ebx, ecx
	
	lea eax, (Ball ptr [eax]).location

	assume eax: ptr Vector
	assume ebx: ptr Vector
	invoke addVector, eax, ebx

	pop ecx
	pop ebx
	pop eax
	ret

move endp


isAlive proc pBall: ptr Ball, pTarget: ptr Vector, radios: dword

	push ebx
	push ecx

	mov ebx, pBall
	lea ebx, (Ball ptr [ebx]).location

	; Dead x component
	mov eax, (Vector ptr [ebx]).x
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


evaluate proc pPopulation: dword, pTarget: ptr Vector

	push ebx
	sub esp, 16
	movupd  xmmword ptr [esp], xmm0
	sub esp, 16
	movupd  xmmword ptr [esp], xmm1
	sub esp, 16
	movupd  xmmword ptr [esp], xmm2

	xor ebx, ebx
	invoke random
	movsd xmm1, xmm0
	xorpd xmm2, xmm2
	
	pickingLoop:
		comisd xmm1, xmm2
			jbe exitEvaluate
		invoke getElementInArray, pPopulation, ebx, Sizeof(Ball)
		assume esi: ptr Ball
		invoke fitnessFunction, esi, pTarget
		divsd xmm0, xmm3 ; Normalizing the fitness value
		subsd xmm1, xmm0
		inc ebx
		jmp pickingLoop

	exitEvaluate:
		movupd xmm2, [esp]
		add esp, 16
		movupd xmm1, [esp]
		add esp, 16
		movupd xmm0, [esp]
		add esp, 16
		pop ebx
		ret

evaluate endp


initMatingpool proc pBalls: dword, ballsSize: dword, pMatingpool: dword, matingpoolSize: dword, pTarget: ptr Vector

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
		cmp ebx, ballsSize
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
			cmp ebx, ballsSize
				je exitinitMatingpool
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

	exitinitMatingpool:
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

initMatingpool endp


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

		invoke randInt, 0, 101
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


crossover proc pParent1: ptr Ball, pParent2: ptr Ball, dnaLength: dword, pArray: dword, index: dword, pLocation: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	; picking a random number
	invoke randInt, 0, dnaLength
	mov ecx, eax

	; Making a new child
	invoke getElementInArray, pArray, index, Sizeof(Ball)

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


naturalSelection proc pMatingpool: dword, matingpoolSize: dword, pArray: dword, arraySize: dword, dnaLength: dword, pLocation: ptr Vector, mutationRate: sdword, startRange: sdword, endRange: sdword

	push eax
	push ebx
	push ecx
	push edx
	push esi

	xor edx, edx
	selectionLoop:

		cmp edx, arraySize
			jge exitNaturalSelection

		; Picks a random parent from the matingpool
		mov ecx, matingpoolSize
		invoke randInt, 0, ecx
		mov ebx, eax

		; Picks another random parent from the matingpool
		dec ecx
		invoke randInt, 0, ecx
		cmp ebx, eax ; The parents musn't be identicall
			jge getParents ; Now if the last ball in the matingpool wasn't been chosen yet, it could still be chosen
		inc eax

		getParents:
			invoke getElementInArray, pMatingpool, eax, Sizeof(Ball)
			mov ecx, esi
			invoke getElementInArray, pMatingpool, ebx, Sizeof(Ball)

		; Crossover
		invoke crossover, ecx, esi, dnaLength, pArray, edx, pLocation, mutationRate, startRange, endRange
		
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

	invoke initMatingpool, pPopulation, populationSize, pMatingpool, matingpoolSize, pTarget
	invoke naturalSelection, pMatingpool, matingpoolSize, pPopulation, populationSize, dnaLength, pLocation, mutationRate, startRange, endRange
	ret

evolve endp


end
