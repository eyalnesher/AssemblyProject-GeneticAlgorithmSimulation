
include Setmodel.inc
include Utilities.inc

.const

	ten dword 10

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

			pop edx
			pop ecx
			pop ebx
			ret

random endp


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
		mov cl, byte ptr [ecx]
		mov byte ptr [edx+ebx], cl
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

end
