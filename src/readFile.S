#include <mips/regdef.h>
#include <sys/syscall.h>

# a0 = buffer
# a1 = bufIncrSize
# a2 = fileDescriptor

#
#constants
#
BYTES_TO_READ = 1
MAX_BYTES_TO_READ = 9
NEW_LINE_ASCII = 10

#sizes
ABA_SIZE = 16
LTA_SIZE = 8
SRA_SIZE = 16
FRAME_SIZE = ABA_SIZE + LTA_SIZE + SRA_SIZE

#offsets
LTA_OFFSET = ABA_SIZE
TOTAL_BYTES_READ_OFFSET = LTA_OFFSET
LAST_READ_CHAR_OFFSET = LTA_OFFSET + 4

SRA_OFFSET = LTA_OFFSET + LTA_SIZE
GP_OFFSET = SRA_OFFSET
FP_OFFSET = SRA_OFFSET + 4
RA_OFFSET = SRA_OFFSET + 8

BUFFER_OFFSET = FRAME_SIZE
BUFF_INCR_SIZE_OFFSET = FRAME_SIZE + 4
FILE_DESCRIPTOR_OFFSET = FRAME_SIZE + 8


	.text
	.align	2
	.globl	readFile
	.ent	readFile

readFile:
	.frame	$fp, FRAME_SIZE, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	#creo stack frame
	subu	sp, sp, FRAME_SIZE
	# Guardo $gp y $fp en SRA
	.cprestore GP_OFFSET
    sw 		$fp, FP_OFFSET(sp)
    sw 		ra, RA_OFFSET(sp)
    move 	$fp,sp
    sw		a0, BUFFER_OFFSET($fp)
    sw 		a1, BUFF_INCR_SIZE_OFFSET($fp)
    sw 		a2, FILE_DESCRIPTOR_OFFSET($fp)
    
clearBuffer:
	lw		a0, BUFFER_OFFSET($fp)
	li 		a1, MAX_BYTES_TO_READ
	li		t0, 0 		# t0 = i
_forBuffer:
    bgeu 	t0, a1, readToBuffer	# si (i >= bufIncrSize) voy a read
    addu	t1, a0, t0		# t1 = &buffer + i
    sb		zero, 0(t1)		# buffer[i] = 0
    addiu	t0, t0, 1		# i++
    j _forBuffer

readToBuffer:

	li 		t1, MAX_BYTES_TO_READ	# t1 = cantidad maxima de bytes a leer
	li		t0, 0							# t0 = i
	sw		t0, TOTAL_BYTES_READ_OFFSET($fp)

_forRead:

	lw		t0, TOTAL_BYTES_READ_OFFSET($fp)
	li 		t1, MAX_BYTES_TO_READ
	bgeu 	t0, t1, _endRead	# si (i >= bufIncrSize) termino de leer

	lw		t2, BUFFER_OFFSET($fp)
	addu	t2, t2, t0

	#read from file
	li 		v0, SYS_read      				 # system call for read from file
	lw 		a0, FILE_DESCRIPTOR_OFFSET($fp)  	# file descriptor
	move	a1, t2							#buffer
	li 		a2, BYTES_TO_READ					# buffer length
	syscall 					        # read from file

	beq		v0, zero, _endRead		# si devuelve 0, termino de leer

	lw		t0, TOTAL_BYTES_READ_OFFSET($fp)
	lw		t2, BUFFER_OFFSET($fp)
	addu	t2, t2, t0
	lb		t3, 0(t2)		# t3 = ultimo caracter leido
	sb		t3, LAST_READ_CHAR_OFFSET($fp)

	lw		t0, TOTAL_BYTES_READ_OFFSET($fp)
	addi	t0, t0, 1		# i++
	sw		t0, TOTAL_BYTES_READ_OFFSET($fp)

	lb		t3, LAST_READ_CHAR_OFFSET($fp)
	li 		t4, NEW_LINE_ASCII
	beq		t3, t4, _endRead

	j		_forRead

_endRead:

	lw		v0, TOTAL_BYTES_READ_OFFSET($fp)
	lw 		gp, GP_OFFSET(sp)
	lw 		$fp, FP_OFFSET(sp)
	lw 		ra, RA_OFFSET(sp)
	addu 	sp,sp,FRAME_SIZE
	jr		ra


	.end readFile
    
  	.rdata
msg:
	.asciiz	"Hola mundo.\n"
msg2:
	.asciiz	"2:Hola mundo.\n"
    
