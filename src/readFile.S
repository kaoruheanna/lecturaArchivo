#include <mips/regdef.h>
#include <sys/syscall.h>

# a0 = buffer
# a1 = bufIncrSize
# a2 = fileDescriptor

#
#constants
#

#sizes
ABA_SIZE = 16
LTA_SIZE = 0
SRA_SIZE = 16
FRAME_SIZE = ABA_SIZE + LTA_SIZE + SRA_SIZE

#offsets
LTA_OFFSET = ABA_SIZE

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
    
    #read from file
	li 		v0, SYS_read      				 # system call for read from file
	lw 		a0, FILE_DESCRIPTOR_OFFSET($fp)  # file descriptor
	lw 		a1, BUFFER_OFFSET($fp)  			# address of buffer to which to read
	lw 		a2, BUFF_INCR_SIZE_OFFSET($fp)  	# buffer length
	syscall         # read from file
	
	lw 		gp, GP_OFFSET(sp)
	lw 		$fp, FP_OFFSET(sp)
	lw 		ra, RA_OFFSET(sp)
	addu 	sp,sp,FRAME_SIZE
	jr		ra


	.end readFile
    
    
    
