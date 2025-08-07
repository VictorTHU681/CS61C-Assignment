.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

    # Prologue
	addi sp, sp, -20
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	sw s3, 12(sp)
	sw ra, 16(sp)

	mv s0 a0
	mv s1 a1
	mv s2 a2
	mv s3 a3
	
	# Open file
	mv a1, s0
	li a2, 1 # read only 
	jal fopen

	li t1, -1
	beq a0, t1, open_err 

	mv s0, a0 # s0 is the descriptor

	# Write in row and col
	addi sp, sp, -8
	sw s2, 0(sp)
	sw s3, 4(sp) # read row first 

	mv a1, s0
	mv a2, sp
	li a3, 2
	li a4, 4
	jal fwrite
	addi sp,sp ,8
	li a3, 2
	bne a0, a3, write_err

	# Write in matrix
	mv a1, s0
	mv a2, s1
	mul a3, s2, s3	
	li a4, 4
	jal fwrite
	mul a3, s2, s3	
	bne a0, a3, write_err

	# Close the file
	mv a1, s0
	jal fclose
	li t1, -1
	beq a0, t1, close_err 

    # Epilogue
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw s3, 12(sp)
	lw ra, 16(sp)
	addi sp, sp, 20

    ret

# Error Cases
open_err:
	li a1, 93 
	jal exit2	
write_err:
	li a1, 94 
	jal exit2	
close_err:
	li a1, 95 
	jal exit2	
