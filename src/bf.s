/* Copyright (c) 2023 Mina Brüser */

.file "bf.s"

.text
.global read_file
.type read_file, @function
read_file:
	push %rbp
	mov %rsp, %rbp
	sub $32, %rsp

	call open_file
	/* move fd onto stack*/
	mov %rax, -8(%rbp)

	mov %rax, %rdi
	call get_file_size
	/* move size onto stack  */
	mov %rax, -16(%rbp)

	/* map file */
	mov -8(%rbp), %rsi
	mov %rax, %rdi
	call file_alloc
	
	/* move addr onto stack */
	mov %rax, -24(%rbp)

	/* interpret file content */
	mov %rax, %rdi
	call interpret

	/* cleanup */
	mov %rax, %rdi
	mov -16(%rbp), %rsi
	call mem_free

	mov -8(%rbp), %rdi
	call close_file

	add $32, %rsp
	pop %rbp
	ret

.global _start
_start:
	push %rbp
	mov %rsp, %rbp

	/* get argc */
	mov +8(%rbp), %rdi

	/* if (argc <= 1) then exit */
	cmp $1, %rdi
	jg .L01

	pop %rbp

	mov $10, %rdi
	call exit

.L01:
	/* get argv[1] */
	mov +24(%rbp), %rdi
	call read_file

	pop %rbp

	xor %rdi, %rdi
	call exit

