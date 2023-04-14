/* Copyright (c) 2023 Mina Brüser */

.file "io.s"

.set stdin, 0
.set stdout, 1

.text
.global strlen
.type strlen, @function
strlen:
	/* NULL Check */
	cmpq $0, %rdi
	jne .L01
	mov $0, %rax
	ret
	
.L01:
	push %rdi
	push %rsi
	mov $0, %rsi	
	
.L02:
	cmpb $0, (%rdi)
	je .L03
	
	inc %rsi
	inc %rdi
	jmp .L02
.L03:
	/* move str len in rax */
	mov %rsi, %rax

	pop %rsi
	pop %rdi
	ret
		

.global print
.type print, @function
print:
	call strlen

	/* write syscall setup */
	mov %rax, %rdx

	mov %rdi, %rsi
	mov $stdout, %rdi
	mov $1, %rax
	syscall

	xor %rax, %rax
	ret


.global printb
.type printb, @function
/* rdi: char */
printb:
	push %rbp
	mov %rsp, %rbp
	sub $8, %rsp

	mov %rdi, -8(%rbp) 

	/* print just one byte to stdout (putc basically)*/
	lea -8(%rbp), %rsi
	mov $stdout, %rdi
	mov $1, %rdx
	mov $1, %rax
	syscall

	add $8, %rsp
	pop %rbp
	ret

.global readb
.type readb, @function
readb:
	push %rbp
	mov %rsp, %rbp
	sub $8, %rsp

	/* read syscall */
	mov $stdin, %rdi
	lea -8(%rbp), %rsi
	mov $1, %rdx
	mov $0, %rax
	syscall

	/* store char in rax */
	mov -8(%rbp), %rax

	add $8, %rsp
	pop %rbp
	ret
	
