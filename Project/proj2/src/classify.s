.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

	li t0 5
	bne a0 t0 argc_err
	addi sp sp -52
	sw ra 0(sp)
	sw s0 4(sp)
	sw s1 8(sp)
	sw s2 12(sp)
	sw s3 16(sp)
	sw s4 20(sp)
	sw s5 24(sp)
	sw s6 28(sp)
	sw s7 32(sp)
	sw s8 36(sp)
	sw s9 40(sp)
	sw s10 44(sp)
	sw s11 48(sp)

	mv s1 a1 # pointer to pointers
	mv s2 a2 # 0 -> print 

	# =====================================
    # LOAD MATRICES
    # =====================================
    # Load pretrained m0
	lw a0 4(s1)	
	addi sp sp -8
	mv a1 sp
	addi a2 sp 4
	jal read_matrix
	mv s0 a0 # s0 is the pointer to matrix
	lw s3 0(sp) #row of m0
	lw s4 4(sp) #col of m0
	addi sp sp 8

    # Load pretrained m1
	addi sp sp -8
	mv a1 sp
	addi a2 sp 4
	lw a0 8(s1)	
	jal read_matrix
	mv s5 a0 # s5 is the pointer to matrix
	lw s6 0(sp) #row of m1
	lw s7 4(sp) #col of m1
	addi sp sp 8

    # Load input matrix
	lw a0 12(s1)	
	addi sp sp -8
	mv a1 sp
	addi a2 sp 4
	jal read_matrix
	mv s8 a0 # s8 is the pointer to matrix
	lw s9 0(sp) #row of input
	lw s10 4(sp) #col of input
	addi sp sp 8


    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
	
	# 1.
	li t0 4
	mul t0 t0 s3
	mul a0 t0 s10
	jal malloc
	beq x0 a0 malloc_err
	mv s11 a0 # s11 is the pointer to destination
	mv a0 s0
	mv a1 s3	
	mv a2 s4	

	mv a3 s8
	mv a4 s9	
	mv a5 s10	

	mv a6 s11
	jal matmul
	
	# free m0 and input
	mv a0 s0
	jal free
	mv a0 s8
	jal free

	# 2.
	mul a1 s10 s3 
	mv s0 a1 # of m0*input
	mv a0 s11
	jal relu
	
	# 3.
	li t0 4
	mul t0 s6 t0 
	mul a0 s10 t0 
	jal malloc
	beq x0 a0 malloc_err
	mv s4 a0 # s4 is the pointer to final matrix

	mv a0 s5
	mv a1 s6	
	mv a2 s7	
	mv a3 s11
	mv a4 s3	
	mv a5 s10	
	mv a6 s4
	jal matmul
	
	# free 
	mv a0 s11
	jal free

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
	lw a0 16(s1)
	mv a1 s4	
	mv a2 s6
	mv a3 s10
	jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
	mv a0 s4
	mul a1 s6 s10
	jal argmax
	mv s0 a0 # s0 is the index of max value

    # Print classification
	bne x0 s2 not_print
	mv a1 s0
	jal print_int

    # Print newline afterwards for clarity
	li a1 10
	jal print_char

not_print:
	# free
	mv a0 s4
	jal free	

	mv a0 s0

	lw ra 0(sp)
	lw s0 4(sp)
	lw s1 8(sp)
	lw s2 12(sp)
	lw s3 16(sp)
	lw s4 20(sp)
	lw s5 24(sp)
	lw s6 28(sp)
	lw s7 32(sp)
	lw s8 36(sp)
	lw s9 40(sp)
	lw s10 44(sp)
	lw s11 48(sp)
	addi sp sp 52

    ret

argc_err:
	li a1 89
	jal exit2
malloc_err:
	li a1 88
	jal exit2
