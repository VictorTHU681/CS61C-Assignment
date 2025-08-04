.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
	# Exceptions
Ex1:
	li t1, 1
	bge a2, t1, Ex2 	
	li a1, 75
	jal exit2
Ex2:	
	bge a3, t1, Ex3	
	li a1, 76
	jal exit2
Ex3:
	bge a4, t1, setup 	
	li a1, 76
	jal exit2
setup:
	li t0, 0 # return value
	li t2, 4 # byte offset
	mul t1, t2, a3 
	mul t2, t2, a4 # byte stride for each vector
loop_start:
	beq a2, x0, loop_end	
	lw t3, 0(a0)
	lw t4, 0(a1)
	mul t3, t3, t4
	add t0, t0, t3 # one computation
	add a0, a0, t1	
	add a1, a1, t2	
	addi a2, a2, -1
	j loop_start
loop_end:
	mv a0, t0
	ret
