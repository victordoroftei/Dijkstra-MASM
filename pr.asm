.386
.model flat, stdcall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

includelib msvcrt.lib
extern exit: proc
extern fopen: proc
extern fscanf: proc
extern fclose: proc
extern printf: proc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

public start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.data

n db 0
p db 0
m db 0
dest db 0
mat db 100 dup(0)		; matricea de adiacenta, reprezentata sub forma de vector
						; mat[i][j] va fi de fapt mat[i * n + j]

cost db 100 dup(0)		; vectorul de costuri
viz db 100 dup(0)		; vectorul de noduri vizitate
inf db 120				; infinit

nume_fisier db "input.txt", 0
mod_acces db "r", 0
format db "%d", 0
format2 db "%d ", 0
format3 db "%d %d %d", 0
descriptor dd -1

x dd 0
y dd 0
z dd 0
indice db 0
i dd 0

newline db 10, 0

mn db 0
k db 0

parent db 100 dup(0)
drum db 100 dup(0)
lungime_drum db 0
mesaj3 db "Drumul minim este: ", 10, 0
mesaj4 db "Costul drumului minim este: %d.", 0

.code

;#################################################################################################################################################;

citire PROC

	PUSH offset mod_acces
	PUSH offset nume_fisier
	CALL fopen	; fopen("input.txt", "r");
	ADD ESP, 8
	
	MOV descriptor, EAX
	
	PUSH offset n
	PUSH offset format
	PUSH descriptor
	CALL fscanf	; fscanf(descriptor, "%d", &n);
	ADD ESP, 12	
	
	PUSH offset p
	PUSH offset format
	PUSH descriptor
	CALL fscanf	; fscanf(descriptor, "%d", &p);
	ADD ESP, 12
	
	PUSH offset dest
	PUSH offset format
	PUSH descriptor
	CALL fscanf	; fscanf(descriptor, "%d", &p);
	ADD ESP, 12
	
	MOV AL, n
	MUL AL
	MOV m, AL
	
	MOV ECX, 0
	MOV CL, n
	DEC ECX	; ECX = n - 1
	
	Repeta1:
		
		MOV i, ECX
		
		PUSH offset z
		PUSH offset y
		PUSH offset x
		PUSH offset format3
		PUSH descriptor
		CALL fscanf	; fscanf(descriptor, "%d %d %d", &x, &y, &z);
		ADD ESP, 20
		
		CMP EAX, 3
		JNE Afara1
		
		MOV EAX, x
		MOV BL, n
		MUL BL	; AX = x * n
		
		MOV indice, AL	; indice = x * n
		
		MOV EAX, y
		ADD indice, AL	; indice = x * n + y
		
		MOV EAX, 0
		MOV AL, indice	; AL = x * n + y
		
		MOV EDI, offset mat
		ADD EDI, EAX
		
		MOV EDX, y
		
		MOV EBX, x
		
		MOV [parent + EDX], BL
		
		MOV EAX, z
		
		STOSB 
		
	JMP Repeta1
	
	Afara1:
	
		RET

citire ENDP

;#################################################################################################################################################;

initializare PROC

MOV ECX, 0
	MOV ESI, offset mat
	MOV EDI, offset mat
	Repeta2:
		
		MOV i, ECX
		
		MOV EAX, 0
		MOV AL, [mat + ECX]
		
		CMP AL, 0
		JE Verificare1
		JNE Afara2
		
		Verificare1:
		
		MOV EAX, i	; mat[indice] <=> a[indice / n][indice % n]
		MOV BL, n
		DIV BL
		CMP AH, AL
		JNE Asignare1
		JE Afara2
		
		Asignare1:
		
		MOV AL, inf
		MOV [mat + ECX], AL
		
		Afara2:
		
		MOV EAX, 0
		MOV AL, [mat + ECX]
		
		MOV ECX, i
		
	INC ECX
	CMP CL, m
	JL	Repeta2
	
	MOV ECX, 0
	Repeta3:
		
		MOV BL, n
		MOV AL, p
		MUL BL
		
		MOV EDX, 0
		MOV DL, CL	; EDX = i
		ADD DL, AL	; EDX = i + p * n
		
		MOV AL, [mat + EDX]	; mat[p * n + i] = mat[p][i]
		
		MOV [cost + ECX], AL
	
	INC ECX
	CMP CL, n
	JL Repeta3
	
	MOV ECX, 0
	MOV CL, p
	MOV [viz + ECX], 1
	
	RET

initializare ENDP

;#################################################################################################################################################;

Dijkstra PROC

MOV EDX, 1
	Repeta4:
		
		MOV AL, inf
		MOV mn, AL
		
		MOV ECX, 0
		Repeta5:
			
			MOV AL, [viz + ECX]
			CMP AL, 0
			JE Verificare2
			JNE Afara3
			
			Verificare2:
				
				MOV AL, [cost + ECX]
				CMP AL, mn
				JL Asignare2
				JGE Afara3
				
				Asignare2:
					
					MOV mn, AL
					MOV k, CL
			
			Afara3:
			
		INC ECX
		CMP CL, n
		JL Repeta5
			
		MOV EAX, 0
		MOV AL, k
		MOV [viz + EAX], 1

		MOV ECX, 0
		Repeta6:
			
			MOV AL, [viz + ECX]
			CMP AL, 0
			JE Verificare3
			JNE Afara4
			
			Verificare3:
				
				MOV BL, k
				MOV AL, n
				MUL BL	; AX (AL de fapt) = k * n
				
				MOV EBX, 0
				MOV BX, AX	; EBX = k * n
				ADD EBX, ECX	; EBX = k * n + i => mat[EBX] = mat[k][i]
				
				MOV AL, [mat + EBX]
				ADD AL, mn
				MOV BL, [cost + ECX]
				
				CMP BL, AL
				JG Asignare3
				JLE Afara4
				
				Asignare3:
					
					MOV [cost + ECX], AL
					
					MOV AL, k
					MOV [parent + ECX], AL 
			
			Afara4:
		
		INC ECX
		CMP CL, n
		JL Repeta6
		
	INC EDX
	CMP DL, n
	JLE Repeta4
	
	MOV ECX, 0
	MOV CL, p
	MOV [parent + ECX], -1
	
	MOV ECX, 0
	MOV CL, dest
	Repeta8:

		MOV EBX, 0
		MOV BL, lungime_drum
		
		MOV [drum + EBX], CL 
		INC lungime_drum
		
		MOV CL, [parent + ECX]
		
		CMP CL, -1
		JE Afara6
		
	JMP Repeta8
	
	Afara6:
	
		RET

Dijkstra ENDP

;#################################################################################################################################################;

afisari PROC

PUSH offset mesaj3
	CALL printf
	ADD ESP, 4
	
	MOV ECX, 0
	MOV CL, lungime_drum
	DEC CL
	Repeta9:
		
		MOV i, ECX
		
		MOV EAX, 0
		MOV AL, [drum + ECX]
		
		PUSH EAX
		PUSH offset format2
		CALL printf
		ADD ESP, 8
		
		MOV ECX, i
		
	DEC ECX
	CMP CL, 0
	JGE Repeta9
	
	PUSH offset newline
	CALL printf
	ADD ESP, 4
	
	PUSH offset newline
	CALL printf
	ADD ESP, 4
	
	MOV ECX, 0
	MOV CL, dest
	
	MOV EAX, 0
	MOV AL, [cost + ECX]
	
	PUSH EAX
	PUSH offset mesaj4
	CALL printf
	ADD ESP, 8
	
	PUSH offset newline
	CALL printf
	ADD ESP, 4
	
	RET

afisari ENDP

inchidere PROC

	PUSH descriptor
	CALL fclose	; fclose(descriptor);
	ADD ESP, 4
	
	RET

inchidere ENDP

;#################################################################################################################################################;

start:
	
	CALL citire
	
	CALL initializare
	
	CALL Dijkstra
	
	CALL afisari
	
	CALL inchidere
	
	PUSH 0
	CALL exit
	
end start
