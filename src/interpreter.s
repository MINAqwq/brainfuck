/* Copyright (c) 2023 Mina Brüser */

.file "interpreter.s"

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

.L05:	/* , */
	cmpb $44, (%rdi)
	jne .L06
	mov %rsp, %rcx
	add -16(%rbp), %rcx
	push %rdi
	call readb
	mov %rax, (%rcx)
	pop %rdi
	jmp .L08

.L06:

.L08:
	inc %rdi
	jmp .LOOP_START
.LOOP_END:
	/* end interpret */
	
	add $4136, %rsp
	pop %rbp
	ret

.global enter_loop
.type enter_loop, @function
/* rdi: addr to store | rsi: call stack ptr */
enter_loop:
	cmp $0, %rsi
	je .MMAP
.MMAP:
	ret	
