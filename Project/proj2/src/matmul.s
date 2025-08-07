.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

   # Error checks
	li t1, 1
	blt a1, t1, Ex1
	blt a2, t1, Ex1

	blt a4, t1, Ex2
	blt a5, t1, Ex2

	bne a2, a4, Ex3

   # Prologue

	addi sp, sp, -36 
	# pointer, rows, cols for first matrix
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp) # also size of dot product

	# pointer, cols for second matrix
	sw s3, 12(sp)
	sw s5, 20(sp)

	# ra	
	sw s4, 16(sp)

	# Destination	
	sw s6, 24(sp)

	sw s7, 28(sp) # outer counter
	sw s8, 32(sp) # inner counter

	mv s0, a0
	mv s1, a1
	mv s2, a2
	mv s3, a3
	mv s4, ra 
	mv s5, a5
	mv s6, a6
	li s7, 0 
	li s8, 0

outer_loop_start:
	beq s7, s1, outer_loop_end
inner_loop_start:
	beq s8, s5, inner_loop_end
	mv a0, s0
	mv a1, s3
	mv a2, s2

	li a3, 1
	mv a4, s5
	jal ra dot # Finished a computation

	sw a0, 0(s6) 
	addi s3, s3, 4
	addi s6, s6, 4
	addi s8, s8, 1
	j inner_loop_start	
inner_loop_end:
	beq s7, s1, outer_loop_end 	
	addi s7, s7, 1
	li t1, 4
	mul t0, t1, s2
	add s0, s0, t0
	mul t0, t1, s5
	sub s3, s3, t0 
	li s8 0
	j outer_loop_start 

outer_loop_end:
    # Epilogue
	mv ra s4
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw s4, 16(sp)
	lw s5, 20(sp)
	lw s6, 24(sp)
	lw s7, 28(sp)
	lw s8, 32(sp)
	addi sp, sp, 36
    ret

###############################
	# Error haddle
Ex1:
	# make sure a1>=1, a2>=1

	li a1 72
	jal exit2
Ex2:
	# make sure a4>=1, a5>=1

	li a1 73
	jal exit2
Ex3:

	li a1 74
	jal exit2
 
