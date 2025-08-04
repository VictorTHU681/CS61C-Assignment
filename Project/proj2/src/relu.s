.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Exceptions check
    li t1, 1
    bge a1, t1, Prologue 
    li a1, 78
    jal exit2  
Prologue:
    addi sp, sp, -12
    sw s0, 0(sp)
    sw ra, 4(sp)
    sw s1, 8 (sp)
    mv s0, a0
    mv s1, a1
loop_start:
    beq s1, x0, loop_end
    lw a0, 0(s0)
    bge a0, x0,do_nothing
    sw x0, 0(s0)
do_nothing:
    addi s0, s0, 4
    addi s1, s1, -1
    j loop_start
loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw ra, 4(sp)
    lw s1, 8 (sp)
    addi sp, sp, 12
	ret
