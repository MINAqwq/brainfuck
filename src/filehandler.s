/* Copyright (c) 2023 Mina Brüser */

.file "filehandler.s"

.set O_RDONLY, 0
.data
err_str1:
.asciz "Error: file not found :/\n"
		

.text
.global open_file
.type open_file, @function
/* rdi: str_ptr */
open_file:
	/* NULL Check*/
	cmp $0, %rdi
	jne .L01
	mov $40, %rdi
	call exit
.L01:
	/* open syscall */
	mov $O_RDONLY, %rsi
	mov $0, %rdx
	mov $2, %rax
	syscall

	/* error handling */
	cmp $0, %rax	
	jl .L02
	ret
.L02:
	lea err_str1(%rip), %rdi
	call print

	mov $41, %rdi
	call exit

.global close_file
.type close_file, @function
/* rdi: fd */
close_file:
	/* close syscall */
	mov $3, %rax
	syscall
	
	ret

.global get_file_size
.type get_file_size, @function
/* rdi: fd */
get_file_size:
	push %rbp
	mov %rsp, %rbp
	/* make space for the stat struct */
	sub $152, %rsp

	/* fstat syscall */
	lea -152(%rbp), %rsi
	mov $5, %rax
	syscall

	/* file size is on offset 48 in this stat struct */
	movq -104(%rbp), %rax

	add $152, %rsp
	pop %rbp
	ret
