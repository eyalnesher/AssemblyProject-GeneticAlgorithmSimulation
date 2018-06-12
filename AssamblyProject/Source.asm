.686P
.model flat, stdcall 
.xmm
include Genetics.asm
include drd.inc
includelib drd.lib



Sleep proto :dword

.const

	arrayLength equ 100
	startRange dword -15
	endRange dword 15
	


.data


	; Pictures
	pimg Img<>
	targetImg Img<>
	location Vector <200, 300>

	balls Ball arrayLength dup(<>)

	live byte ?
	
	x dword 1
	y dword 0
	ballName byte "ball.bmp", 0
	targetName byte "target.bmp", 0
	looper dword 5
	slower byte 100
	steps byte ?
	
	currentForce dword 0


.code



main proc
	
	; Initializing the screen
	invoke createPopulation, offset balls, arrayLength, addr location, lifeSpan, startRange, endRange
	invoke drd_init, screenSizeX, screenSizeY, 0
	invoke drd_imageLoadFile, offset ballName, offset pimg
	invoke drd_imageLoadFile, offset targetName, offset targetImg
	invoke drd_imageSetTransparent, offset pimg, 0
	invoke drd_imageSetTransparent, offset targetImg, 0

	; For every generation
	evolvutionLoop:
		
		; For each force in the balls "DNA"
		xor ecx, ecx
		mov live, 0
		movementLoop:

			cmp ecx, lifeSpan
				je evolution
			push ecx
			
			; For each ball in the current generation
			xor ebx, ebx
			ballLoop:

				cmp ebx, arrayLength
					je movementLoopEnd
				push ebx
				push ecx
				push edx
				push esi


				; Getting the pointers
				invoke getElementInArray, offset balls, ebx, Sizeof(Ball)
				lea edi, [esi + ecx*Sizeof(Vector) + Sizeof(Vector)] ; The location in the memory of the current vector
				
				; Display
				invoke drd_processMessages
				invoke drd_imageDraw, offset pimg, dword ptr [esi], dword ptr [esi + 4]
				invoke drd_imageDraw, offset targetImg, target.x, target.y
				invoke drd_flip
				
				
				; Checking life
				lea edx, [esi + Size(Ball) - 1]
				cmp byte ptr [edx], 0
					je ballLoopEnd
				inc live

				; Moving
				assume esi: ptr Ball
				assume edi: ptr Vector
				invoke applyForce, esi, edi
				invoke isAlive, esi

				BallLoopEnd:
					pop esi
					pop edx
					pop ecx
					pop ebx
					inc ebx
					jmp ballLoop

			
			movementLoopEnd:
				;invoke Sleep, 10
				invoke drd_pixelsClear, 0

				pop ecx
				inc ecx
				jmp movementLoop

		; The evolution
		evolution:
			invoke evolve, offset balls, arrayLength, offset matingpool, matingpoolLength, lifeSpan
			;jmp evolvutionLoop

	quite:
		ret

main endp

end main



