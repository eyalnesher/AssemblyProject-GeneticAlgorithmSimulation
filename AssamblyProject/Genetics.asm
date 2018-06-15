
include Genetics.inc

.const
		
	one dword 1

	screenSizeX equ 1000
	screenSizeY equ 600


.code


random proc startRange: sdword, endRange: sdword

	push ebx
	push ecx
	push edx

	; Randomize

	mov edx, startRange
	mov ebx, endRange

	; Convert to unsigned
	add edx, 80000000H
	add ebx, 80000000H
	mov ecx, edx

	rand:
		rdrand eax ; rdrand tryies to create a rundom number and store it at eax
		jnc rand ; If rdrand failed, the function try it again

	sub ebx, edx ; Taking the range size

	; Taking the modulo
	xor edx, edx
	div ebx
	mov eax, edx

	add eax, ecx ; Now the division is in the range

	; Convert to signed
	add eax, 80000000H

	exitRandom:
		pop edx
		pop ecx
		pop ebx
		ret

random endp
	

generateRandomVector proc pVector: ptr Vector, startRange: sdword, endRange: sdword

	push eax
	push ebx

	invoke random, startRange, endRange
	mov ebx, pvector
	mov [ebx], eax
	invoke random, startRange, endRange
	mov ebx, pvector
	add [ebx + 4], eax

	pop ebx
	pop eax
	ret

generateRandomVector endp


initBall proc pBall: ptr Ball, pInitLoc: ptr Vector, dnaLength: dword, startRange: sdword, endRange: sdword

	push eax
	push ebx
	push ecx
	push edx
	push esi

	mov esi, pball
	mov ebx, pInitLoc
	mov ecx, [ebx]
	mov [esi], ecx
	mov ecx, [ebx + 4]
	mov [esi + 4], ecx
	lea esi, [esi + Sizeof(Ball) - 1]
	mov edx, 1
	mov [esi], edx ; The ball is alive

	xor ecx, ecx
	
	setDna:
		cmp ecx, dnaLength
			jg exitInitBall
		mov esi, pball
		lea esi, [esi + ecx*Sizeof(Vector) + Sizeof(Vector)]
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
	push ecx

	mov eax, pBall
	mov ebx, pForce
	mov ecx, [ebx]
	add [eax], ecx
	mov ecx, [ebx + 4]
	add [eax + 4], ecx

	pop ecx
	pop ebx
	pop eax
	ret

applyForce endp


isAlive proc pBall: ptr Ball

	push eax
	push ebx

	mov ebx, pBall
	mov eax, [ebx]
	cmp eax, 0
		jbe kill
	cmp eax, screenSizeX
		jge kill
	mov eax, [ebx + 4]
	cmp eax, 0
		jbe kill
	cmp eax, screenSizeY
		jge kill
	jmp exitIsAlive

	kill:
		lea ebx, [esi + Sizeof(Ball) - 1]
		xor eax, eax
		mov [ebx], eax ; The ball is dead
		
	exitIsAlive:
		pop ebx
		pop eax
		ret

isAlive endp


copyData proc pSource: dword, pDest: dword, dataLength: dword

	push eax
	push ebx
	push ecx
	push edx

	xor ebx, ebx
	mov eax, pSource
	mov edx, pDest

	copyingLoop:
		cmp ebx, dataLength
			jge exitCopyingBall
		lea ecx, [eax + ebx]
		mov cl, [ecx]
		mov [edx+ebx], cl
		inc ebx
		jmp copyingLoop

	exitCopyingBall:
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret

copyData endp


getElementInArray proc pArray: dword, index: dword, elementSize: dword

	push eax

	mov esi, pArray
	mov eax, elementSize
	imul eax, index
	add esi, eax ; The location in the memory of the current ball

	pop eax
	ret

getElementInArray endp


putElementInArray proc pElement: dword, pArray: dword, index: dword, elementSize: dword

	push esi

	invoke getElementInArray, pArray, index, elementSize ; The location of the destination
	invoke copyData, pElement, esi, elementSize

	pop esi
	ret

putElementInArray endp


;----------------Evolution----------------;

squaredDistance proc p1: ptr Vector, p2: ptr Vector

	push ebx
	push ecx

	mov eax, [p1]
	sub eax, [p2]
	imul eax, eax
	mov ecx, eax
	mov ebx, [p1+4]
	sub ebx, [p2+4]
	imul ebx, ebx
	add eax, ecx

	pop ecx
	pop ebx
	ret

squaredDistance endp

fitnessFunction proc pBall: ptr Ball, pTarget: ptr Vector

	push eax
	push esi
	sub esp, 16
	movupd [esp], xmm1

	cvtsi2sd xmm0, one
	mov esi, pBall
	assume esi: ptr Vector
	invoke squaredDistance, esi, pTarget
	cvtsi2sd xmm1, eax
	divsd xmm0, xmm1

	movupd xmm1, [esp]
	add esp, 16
	pop esi
	pop eax
	ret

fitnessFunction endp

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


crossover proc pParent1: ptr Ball, pParent2: ptr Ball, dnaLength: dword, pArray: dword, index: dword, pLocation: ptr Vector

	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	; picking a random number
	xor edx, edx
	mov eax, dnaLength
	mov ebx, 3
	div ebx
	mov ebx, dnaLength
	sub ebx, eax
	invoke random, eax, ebx
	mov ecx, eax

	; Making a new child
	invoke getElementInArray, pArray, index, Sizeof(Ball)

	; Initial location
	lea ebx, (Ball ptr [esi]).location
	invoke copyData, pLocation, ebx, Sizeof(Vector)

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
	
	; Life
	lea ebx, (Ball ptr [esi]).live
	mov eax, 1
	mov [ebx], eax

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

crossover endp


naturalSelection proc pMatingpool: dword, matingpoolSize: dword, pArray: dword, arraySize: dword, dnaLength: dword, pLocation: ptr Vector

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
		invoke crossover, ecx, esi, dnaLength, pArray, edx, pLocation
		
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


evolve proc pPopulation: dword, populationSize: dword, pMatingpool: dword, matingpoolSize: dword, dnaLength: dword, pLocation: ptr Vector, pTarget: ptr Vector

	invoke initMatingpool, pPopulation, populationSize, pMatingpool, matingpoolSize, pTarget
	invoke naturalSelection, pMatingpool, matingpoolSize, pPopulation, populationSize, dnaLength, pLocation
	ret

evolve endp


end
