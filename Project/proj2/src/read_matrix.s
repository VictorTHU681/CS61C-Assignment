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

	mv s0, a0
	lw s1 0(a1)
	lw s2 0(a2) # transfer pointers to the ints
	
	# Malloc
	li t0 4
	mul t0, t0, s1
	mul a0, t0, s2
	mv s2, a0 # s2 is # of bytes to malloc & read in
	jal malloc
	mv s1, a0 # s1 is the pointer to malloced memory 

	# Read from file
	mv a1, s0
	li a2, 0 # read only 
	jal fopen

	mv s0, a0 # s0 is the descriptor
	mv a1, s0
	mv a2, s1
	li a3, 8 
	jal fread # First Read

	mv a1, s0
	mv a2, s1 # overwirte the previous read result
	mv a3, s2 
	jal fread # Second Read

	# Close the file
	mv a1, s0

    # Epilogue
	addi sp, sp, 16 
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw ra, 12(sp)
    ret
