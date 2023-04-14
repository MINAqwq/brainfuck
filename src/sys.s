/* Copyright (c) 2023 Mina Brüser */

.file "sys.s"

.set PROT_READ, 0x1
.set PROT_WRITE, 0x2

.set MAP_FILE, 0x0
.set MAP_PRIVATE, 0x2
.set MAP_ANON, 0x20

.set MREMAP_MAYMOVE, 0x1;

.data
err_str1:
.asciz "Error: failed to allocate  memory\n"
err_str2:
.asciz "Error: failed to map file into memory\n"

.text
.global memset
.type memset, @function
/* rdi: start ptr | rsi: size | rdx: val*/
memset:
	push %rbp
	mov %rsp, %rbp
	sub $8, %rsp

	push %rdi
	
	movq $0, -8(%rbp)
.L01:
	cmpq %rsi, -8(%rbp)
	je .L02

	movb $0, (%rdi)
	incq %rdi
	incq -8(%rbp)

	jmp .L01

.L02:
	pop %rdi

	add $8, %rsp
	pop %rbp
	ret

.global mem_alloc
.type mem_alloc, @function
/* rdi: size */
mem_alloc:
	/* mmap syscall for only memory */
	mov %rdi, %rsi
	mov $0, %rdi
	mov $PROT_WRITE, %rdx
	mov $0, %r9
	mov $-1, %r8

	mov $MAP_PRIVATE, %r10
	or $MAP_ANON, %r10

	mov $9, %rax
	syscall

	/* NULL Check */
	cmp $-1, %rax
	je .L03
	ret
.L03:
	lea err_str1(%rip), %rdi
	call print
	mov $20, %rdi
	call exit

.global mem_realloc
.type mem_realloc, @function
/* rdi: addr | rsi: old_len | rdx: new_len */
mem_realloc:
	/* mremap syscall */
	mov $MREMAP_MAYMOVE, %r10
	mov $0, %r8
	syscall
	ret

.global file_alloc
.type file_alloc, @function
/* rdi: size | rsi: fd */
file_alloc:
	/* mmap syscall */
	mov %rsi, %r8
	mov %rdi, %rsi

	mov $PROT_READ, %rdx
	mov $0, %rdi
	mov $0, %r9

	mov $MAP_PRIVATE, %r10
	or $MAP_FILE, %r10

	mov $9, %rax
	syscall

	/* NULL Check */
	cmp $-1, %rax
	je .L04
	ret
.L04:
	lea err_str2(%rip), %rdi
	call print
	mov $20, %rdi
	call exit

.global mem_free
.type mem_free, @function
/* rdi: addr | rsi: size */
mem_free:
	mov $11, %rax
	syscall
	ret

.global exit
.type exit, @function
exit:
	mov $60, %rax
	syscall

