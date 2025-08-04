.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    # Exceptions:
    li t1, 1
    bge a1, t1, Prologue
    li a1, 77
	jal exit2
    
Prologue:
    addi sp, sp, -16
    sw s0, 0(sp) # pointer to curr int
    sw s1, 4(sp) # const, length of vector
    sw s2, 8(sp) # curr biggest int
    sw s3, 12(sp) # index of curr int
    mv s0, a0
    mv s1, a1
    li s3, 0
    li a0, 0
    lw s2, 0(s0)
loop_start:
	beq s1, s3, loop_end
    lw a1, 0(s0)
    bge s2 ,a1, do_nothing
    mv s2, a1 
    mv a0, s3
do_nothing:
    addi s0, s0, 4
    addi s3, s3, 1
	j loop_start
loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    addi sp, sp, 16
    ret
