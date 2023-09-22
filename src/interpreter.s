/* Copyright (c) 2023 Mina Brüser */

.file "interpreter.s"

.data
str_unknown_synbol:
.asciz "error: unknown symbol in code\n"

.text
.global interpret
.type interpret, @function
/* rdi: file start addr */
interpret:
	push %rbp
	mov %rsp, %rbp
	sub $4136, %rsp

	/* move addr onto stack */
	mov %rdi, -8(%rbp)

	/* set memory to 0 */
	lea -4136(%rbp), %rdi
	mov $4096, %rsi
	mov $0, %rdx
	call memset
	
	/* restore file addr */
	mov -8(%rbp), %rdi

	/* initialize mem index */
	movq $0, -16(%rbp)

	/* initialize ptr to loop stack*/
	movq $0, -24(%rbp)

	/* initialize size from loop stack */
	movq $0, -32(%rbp)

.LOOP_START:
	/* NULL check */
	cmpb $0, (%rdi)
	je .LOOP_END

	/* + */
	cmpb $43, (%rdi)
	jne .L01
	mov %rsp, %rcx
	add -16(%rbp), %rcx
	incb (%rcx)
	jmp .L08

.L01:
	/* - */
	cmpb $45, (%rdi)
	jne .L02
	mov %rsp, %rcx
	add -16(%rbp), %rcx
	decb (%rcx)
	jmp .L08

.L02:
	/* < */
	cmpb $60, (%rdi)
	jne .L03
	decb -16(%rbp)
	jmp .L08

.L03:
	/* > */
	cmpb $62, (%rdi)
	jne .L04
	incq -16(%rbp)
	jmp .L08

.L04:
	/* . */
	cmpb $46, (%rdi)
	jne .L05
	mov %rsp, %rcx
	add -16(%rbp), %rcx
	push %rdi
	mov (%rcx), %rdi
	call printb
	pop %rdi
	jmp .L08

.L05:
	/* , */
	cmpb $44, (%rdi)
	jne .L06
	mov %rsp, %rcx
	add -16(%rbp), %rcx
	push %rdi
	push %rcx
	call readb
	pop %rcx
	mov %rax, (%rcx)
	pop %rdi
	jmp .L08

.L06:
	/* [ */
	cmpb $91, (%rdi)
	jne .L07
	mov %rsp, %rcx
	add -16(%rbp), %rcx

	/* if value at mem index is not zero enter loop */
	cmpb $0, (%rcx)
	je .skip_loop
	
	call enter_loop
	jmp .L08

.skip_loop:
	/* go to next ] */
	inc %rdi
	cmpb $93, (%rdi)
	jne .skip_loop
	jmp .L08

.L07:
	/* ] */
	cmpb $93, (%rdi)
	jne .L09
	mov %rsp, %rcx
	add -16(%rbp), %rcx

	/* if value at mem index is zero leave loop, otherwise jump */
	cmpb $0, (%rcx)
	je .leave
	call pop_loop
	jmp .L08

.leave:
	call leave_loop

.L08:
	inc %rdi
	jmp .LOOP_START


.L09:
	/* if newline, ignore */
	cmpb $10, (%rdi)
	je .L08

	/* if tab, ignore */
	cmpb $9, (%rdi)
	je .L08

	/* if space, ignore */
	cmpb $32, (%rdi)
	je .L08

	/* unknown symbol */
	lea str_unknown_synbol(%rip), %rdi
	call print

	mov $1, %rdi
	call exit
	ret

.LOOP_END:
	/* end interpret */
	add $4136, %rsp
	pop %rbp
	ret

.global enter_loop
.type enter_loop, @function
/* rdi: addr to store */
enter_loop:
	cmpq $0, -32(%rbp)
	jne .resize

.init_alloc:
	push %rdi
	mov $8, %rdi
	call mem_alloc

	/* save callstack pointer on stack */
	mov %rax, -24(%rbp)

	/* increment callstack size (should be 1 now) */
	incq -32(%rbp)

	pop %rdi

	/* save address on callstack */
	mov %rdi, (%rax)
	ret

.resize:
	push %rdi
	push %rsi
	push %rdx

	/* callstack addr */
	mov -24(%rbp), %rdi

	/* multiply by array lenght for old size */
	mov -32(%rbp), %rsi
	mov $8, %rax
	mul %rsi
	mov %rax, %rsi

	/* new size */
	mov %rsi, %rdx
	add $8, %rdx

	call mem_realloc

	incq -32(%rbp)

	/* index with old size */
	mov %rdi, %rcx
	add %rsi, %rcx

	pop %rdx
	pop %rsi
	pop %rdi

	/* save addr on callstack */
	mov %rdi, (%rcx)
	ret	

/* its not really a pop, because it wont change the callstack */
.global pop_loop
.type pop_loop, @function
pop_loop:
	/* save callstack pointer in rbx and size in rcx */
	mov -24(%rbp), %rbx
	mov -32(%rbp), %rcx

	/* multiply size by 8 */
	mov $8, %rax
	dec %rcx
	mul %rcx

	/* index */
	add %rax, %rbx

	/* write addr to rdi */
	movq (%rbx), %rdi
	ret

.global leave_loop
.type leave_loop, @function
leave_loop:
	push %rdi
	push %rsi

	/* save callstack pointer in rdi and size in rcx */
	mov -24(%rbp), %rdi
	mov -32(%rbp), %rcx

	cmp $1, %rcx
	jne .shrink

.delete:
	mov $8, %rsi
	call mem_free

	/* null out callstack */
	movq $0, -24(%rbp)
	decq -32(%rbp)

	pop %rsi
	pop %rdi

	ret

.shrink:
	push %rdx

	/* size * addr_len */
	mov $8, %rax
	mul %rcx

	/* save old size in rsi */
	mov %rax, %rsi
	
	/* save new size in rdx */
	sub $8, %rax
	mov %rax, %rdx

	/* shrink callstack by 8 */
	call mem_realloc

	/* decrement size */
	decq -32(%rbp)

	pop %rdx
	pop %rsi
	pop %rdi

	ret
