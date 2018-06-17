
include Setmodel.inc
include Genetics.inc
include drd.inc
includelib drd.lib



Sleep proto :dword

.const

	location Vector <50, 300>
	target Vector <900, 300>
	obstacle Vector<450, 150>

	startRange dword -1
	endRange dword 2

	screenSizeX equ 1000
	screenSizeY equ 600

	arrayLength equ 50
	matingpoolLength equ 400
	lifeSpan equ 100
	mutationRate equ 3
	radios equ 34


.data

	
	
	; Pictures
	pimg Img<>
	targetImg Img<>
	obstacleImg Img<>

	ballName byte "ball.bmp", 0
	targetName byte "target.bmp", 0
	obstacleName byte "obstacle.bmp", 0

	balls Ball arrayLength dup(<>)
	matingpool Ball matingpoolLength dup(<>)

	live byte ?
	
	currentForce dword 0


.code



main proc
	
	; Initializing the screen
	invoke createPopulation, offset balls, arrayLength, addr location, lifeSpan, startRange, endRange
	invoke drd_init, screenSizeX, screenSizeY, 0
	invoke drd_imageLoadFile, offset ballName, offset pimg
	invoke drd_imageLoadFile, offset targetName, offset targetImg
	invoke drd_imageLoadFile, offset obstacleName, offset obstacleImg
	invoke drd_imageSetTransparent, offset pimg, 0
	invoke drd_imageSetTransparent, offset targetImg, 0

	; For every generation
	evolvutionLoop:
		
		; For each force in the balls "DNA"
		xor ecx, ecx
		movementLoop:

			mov live, 0
			cmp ecx, lifeSpan
				je evolution
			push eax
			push ecx
			
			; For each ball in the current generation
			xor ebx, ebx
			ballLoop:

				cmp ebx, arrayLength
					je movementLoopEnd
				push ebx
				push edx
				push esi


				; Getting the pointers
				invoke getElementInArray, offset balls, ebx, Sizeof(Ball)
				
				; Display
				push ecx
				invoke drd_processMessages
				invoke drd_imageDraw, offset pimg, dword ptr [esi], dword ptr [esi + 4]
				invoke drd_imageDraw, offset targetImg, target.x, target.y
				invoke drd_imageDraw, offset obstacleImg, obstacle.x, obstacle.y
				invoke drd_flip

				; Moving
				assume esi: ptr Ball
				assume edi: ptr Vector
				pop ecx
				invoke update, esi, ecx, addr target, radios
				cmp eax, 0
					je ballLoopEnd
				inc live

				ballLoopEnd:
					pop esi
					pop edx
					pop ebx
					inc ebx
					jmp ballLoop

			
			movementLoopEnd:
				invoke Sleep, 10
				invoke drd_pixelsClear, 0
				pop ecx
				xor eax, eax
				cmp live, al
					pop eax
					je evolution
				inc ecx
				jmp movementLoop

		; The evolution
		evolution:
			invoke evolve, offset balls, arrayLength, offset matingpool, matingpoolLength, lifeSpan, offset location, addr target, mutationRate, startRange, endRange
			jmp evolvutionLoop

	quite:
		ret

main endp


end main
