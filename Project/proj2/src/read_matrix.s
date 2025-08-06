.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp, sp, -16
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	sw ra, 12(sp)

	mv s0 a0
	mv s1 a1
	mv s2 a2
	
	# Open file
	mv a1, s0
	li a2, 0 # read only 
	jal fopen

	li t1, -1
	beq a0, t1, open_err 

	mv s0, a0 # s0 is the descriptor

	# read rows and cols
	mv a1, s0
	mv a2, s1 
	li a3, 4 
	jal fread

	li t1, 4
	bne a0, t1, read_err 

	mv a1, s0
	mv a2, s2 
	li a3, 4 
	jal fread

	li t1, 4
	bne a0, t1, read_err 

	# Malloc
	lw s1, 0(s1)
	lw s2, 0(s2) # transfer the pointer to int
	li t0 4
	mul t0, t0, s1
	mul a0, t0, s2
	mv s2, a0 # s2 is # of bytes to malloc & read in
	jal malloc
	
	beq x0, a0, malloc_err 

	mv s1, a0 # s1 is the pointer to malloced memory 

	# Read Matrix
	mv a1, s0
	mv a2, s1
	mv a3, s2 
	jal fread

	mv t1, s2	
	bne a0, t1, read_err 

	# Close the file
	mv a1, s0
	jal fclose
	
	li t1, -1
	beq a0, t1, close_err 
	
	mv a0, s1

    # Epilogue
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw ra, 12(sp)
	addi sp, sp, 16 
    ret

# Error Cases
malloc_err:
	li a1, 88
	jal exit2	
open_err:
	li a1, 90 
	jal exit2	
read_err:
	li a1, 91 
	jal exit2	
close_err:
	li a1, 92 
	jal exit2	
