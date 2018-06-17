

.code


convertVectorIntToReal proc pInt: ptr Vector, pReal ptr RealVector

	push eax
	push ebx
	push ecx
	movupd [esp], xmm10
	sub esp, 16

	mov eax, pInt
	mov ebx, pReal

	; X components
	mov ecx, (Vector ptr [eax]).x
	cvtsi2sd xmm0, ecx
	movsd (Vector ptr [ebx]).x, xmm0

	; Y components
	mov ecx, (Vector ptr [eax]).y
	cvtsi2sd xmm0, ecx
	movsd (Vector ptr [ebx]).y, xmm0

	movupd xmm0, [esp]
	add esp, 16
	pop ecx
	pop ebx
	pop eax
	ret

convertVectorIntToReal endp


convertVectorRealToInt proc pReal: ptr Vector, pInt ptr RealVector

	push eax
	push ebx
	push ecx
	movupd [esp], xmm10
	sub esp, 16

	mov eax, pReal
	mov ebx, pInt

	; X components
	movsd xmm0, (Vector ptr [eax]).x
	cvtsd2si ecx, xmm0
	mov (Vector ptr [ebx]).x, ecx

	; Y components
	movsd xmm0, (Vector ptr [eax]).y
	cvtsd2si ecx, xmm0
	mov (Vector ptr [ebx]).y, ecx

	movupd xmm0, [esp]
	add esp, 16
	pop ecx
	pop ebx
	pop eax
	ret

convertVectorRealToInt endp


generateRandomVector proc pVector: ptr Vector, startRange: sdword, endRange: sdword

	push eax
	push ebx

	invoke randInt, startRange, endRange
	mov ebx, pvector
	mov [ebx], eax
	invoke randInt, startRange, endRange
	mov ebx, pvector
	add [ebx + 4], eax

	pop ebx
	pop eax
	ret

generateRandomVector endp


addVector proc pVector1: ptr ReaVector, pVector2: ptr ReaVector

	push eax
	push ebx

	; Adding the x components
	mov eax, pVector1
	lea eax, (Vector ptr [eax]).x
	mov ebx, pVector2
	lea ebx, (Vector ptr [ebx]).x
	mov ebx, [ebx]
	add [eax], ebx

	; Adding the yx components
	mov eax, pVector1
	lea eax, (Vector ptr [eax]).y
	mov ebx, pVector2
	lea ebx, (Vector ptr [ebx]).y
	mov ebx, [ebx]
	add [eax], ebx

	pop ebx
	pop eax
	ret

addVector endp


squaredDistance proc p1: ptr Vector, p2: ptr Vector

	push ebx
	push ecx

	; X components
	mov eax, p1
	mov eax, (Vector ptr [eax]).x
	mov ebx, p2
	mov ebx, (Vector ptr [ebx]).x
	sub eax, ebx
	imul eax, eax
	mov ecx, eax
	
	; Y components
	mov eax, p1
	mov eax, (Vector ptr [eax]).y
	mov ebx, p2
	mov ebx, (Vector ptr [ebx]).y
	sub eax, ebx
	imul eax, eax
	add eax, ecx

	pop ecx
	pop ebx
	ret

squaredDistance endp

end