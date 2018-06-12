.686P
.model flat, stdcall 
.xmm
include Genetics.inc

.code


random proc startRange: dword, endRange: dword

	push ebx
	push edx

	rand:
		rdrand eax ; rdrand tryies to create a rundom number and store it at eax
		jnc rand ; If rdrand failed, the function try it again
		mov ebx, endRange
		sub ebx, startRange
		xor edx, edx
		div ebx
		mov eax, edx
		add eax, startRange

	pop edx
	pop ebx
	ret

random endp
	

generateRandomVector proc pVector: ptr Vector, startRange: dword, endRange: dword

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


initBall proc pBall: ptr Ball, pInitLoc: ptr Vector, dnaLength: dword, startRange: dword, endRange: dword

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
			je exitInitBall
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


createPopulation proc population: dword, arraySize: dword, pInitLoc: ptr Vector, dnaLength: dword, startRange: dword, endRange: dword
	
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
	mov esi, pDest

	copyingLoop:
		cmp ebx, dataLength
			jge exitCopyingBall
		lea ecx, [eax + ebx]
		mov cl, [ecx]
		mov [edx], cl
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
	mov ebx, [p1]
	sub ebx, [p2]
	imul ebx, ebx
	add eax, ecx

	pop ecx
	pop ebx
	ret

squaredDistance endp

fitnessFunction proc pBall: ptr Ball

	push eax
	push esi
	sub esp, 8
	movupd [esp], xmm1

	cvtsi2sd xmm0, one
	mov esi, pBall
	assume esi: ptr Vector
	invoke squaredDistance, esi, addr target
	cvtsi2sd xmm1, eax
	divsd xmm0, xmm1

	movupd xmm1, [esp]
	add esp, 8
	pop esi
	pop eax
	ret

fitnessFunction endp

initMatingpool proc pBalls: dword, ballsSize: dword, pMatingpool: dword, matingpoolSize: dword

	push ebx
	push ecx
	push edx
	push esi
	sub esp, 8
	movupd  qword ptr [esp], xmm0
	sub esp, 8
	movupd qword ptr [esp], xmm1
	sub esp, 8
	movupd qword ptr [esp], xmm2

	; Sum calculation
	xor ebx, ebx
	xorpd xmm1, xmm1
	; For each ball
	fitnessSumLoop:
		cmp ebx, ballsSize
			jge matingpoolInit
		invoke getElementInArray, pBalls, ebx, Sizeof(Ball)
		assume esi: ptr Ball
		;invoke fitnessFunction, esi
		;addsd xmm1, xmm0
		inc ebx
		jmp fitnessSumLoop

	; The initialize of the matingpool
	matingpoolInit:

		xor ebx, ebx ; The ball index
		xor ecx, ecx ; The matingpool index
		; For each ball
		BallLoop:

			cmp ebx, ballsSize
				je exitinitMatingpool
			mov eax, matingpoolSize
			cvtsi2sd xmm2, eax
			invoke getElementInArray, pBalls, ebx, Sizeof(Ball)
			assume esi: ptr Ball
			invoke fitnessFunction, esi
			mulsd xmm0, xmm1
			divsd xmm2, xmm0
			
			; Initializing the mating pool
			xor edx, edx
			mov edi, esi
			initLoop:
			
				cmp ecx, matingpoolSize
					jge exitBallLoop
				cvtsi2sd xmm3, edx
				ucomisd xmm3, xmm2
					jge exitBallLoop
				invoke getElementInArray, pBalls, edi, Sizeof(Ball)
				invoke putElementInArray, esi, pMatingpool, ecx, Sizeof(Ball)
				inc ecx
				inc edx
				jmp initLoop
		
			exitBallLoop:
				inc ebx
				jmp BallLoop

	exitinitMatingpool:
		movupd xmm2, [esp]
		add esp, 8
		movupd xmm1, [esp]
		add esp, 8
		movupd xmm0, [esp]
		add esp, 8
		pop esi
		pop edx
		pop ecx
		pop ebx
		ret

initMatingpool endp


crossover proc pParent1: ptr Ball, pParent2: ptr Ball, dnaLength: dword, pArray: dword, index: dword

	push eax
	push ebx
	push edx
	sub esp, Sizeof(Ball) ; Creating a local variable in the stack

	; picking a random number
	xor edx, edx
	mov eax, dnaLength
	mov ebx, 3
	div ebx
	mov ebx, dnaLength
	sub ebx, edx
	invoke random, edx, ebx

	; Making a new child
	mov ebx, ebp
	invoke copyData, offset target, ebx, SizeOf(Vector)
	add ebx, Sizeof(Vector)
	invoke copyData, pParent1, ebx, eax
	mov edx, dnaLength
	sub edx, eax
	add ebx, eax
	invoke copyData, pParent2, ebx, edx

	
	mov ebx, esp
	invoke putElementInArray, ebx, pArray, index, Sizeof(Ball)

	add esp, Sizeof(Ball)
	pop edx
	pop ebx
	pop eax
	ret

crossover endp


naturalSelection proc pMatingpool: dword, matingpoolSize: dword, pArray: dword, arraySize: dword, dnaLength: dword

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
			jg getParents
		inc eax

		getParents:
			invoke getElementInArray, pMatingpool, eax, Sizeof(Ball)
			mov ecx, esi
			invoke getElementInArray, pMatingpool, ebx, Sizeof(Ball)

		; Crossover
		invoke crossover, ecx, esi, dnaLength, pArray, edx

	exitNaturalSelection:
		pop esi
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret

naturalSelection endp


evolve proc pPopulation: dword, populationSize: dword, pMatingpool: dword, matingpoolSize: dword, dnaLength: dword

	invoke initMatingpool, pPopulation, populationSize, pMatingpool, matingpoolSize
	invoke naturalSelection, pMatingpool, matingpoolSize, pPopulation, populationSize, dnaLength
	ret

evolve endp


end
