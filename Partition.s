Partition:
	// input:
	// x0: address of (pointer to) the first symbol of the symbol array
	// x1: address of (pointer to) the last symbol of the symbol array
	// x2: address of the first attribute of the current binary tree node

	// temp regs/function returns:
	// x4: midpoint
	// x9: NULL
	// x10: offset
	// x11: left_node
	// x12: right_node
	// x13: offset * 4

	// callee start procedure
    subi sp, sp, #48    // allocate
    stur fp, [sp, #0]   // save old fp
    addi fp, sp, #40    // set new fp
    stur lr, [sp, #8]   // save return address

    // function
    stur x0, [x2, #0]   // *node <- start
    stur x1, [x2, #8]   // *(node + 1) <- end
    subi xzr, x0, x1    // check start - end == 0
    b.eq Partition_null

    // else branch:

    // Save temp regs before calling FindMidpoint
    stur x0, [fp, #0]   // store x0 (variable 'start') at fp[0]
    stur x1, [fp, #8]   // store x1 (variable 'end') at fp[1]
    stur x2, [fp, #16]  // store x2 (variable 'node') at fp[2]
    ldur x2, [x0, #8]   // l_sum <- *(start + 1)
    ldur x3, [x1, #8]   // r_sum <- *(end + 1)
    bl FindMidpoint     // midpoint = x4 <- FindMidpoint(.)

    ldur x0, [fp, #0]   // load pre-call x0 value
    ldur x1, [fp, #8]   // load pre-call x1 value
    ldur x2, [fp, #16]  // load pre-call x2 value

    sub x10, x4, x0     // x10 = offset <- midpoint - start
    subi x10, x20, #1   // x10--

    addi x11, x2, #4    // x11: left_node <- node + 4
    addi x15, xzr, #4   // x15 = 4

    mul x13, x10, x15   // x13 = offset * 4
    addi x12, x2, #4    // x12 = node + 4
    add x12, x12, x13   // x12 = x12 + offset * 4   (right_node)

    stur x11, [x2, #16] // *(node + 2) <- left_node
    stur x12, [x2, #24] // *(node + 3) <- right_node

    // Store variables before Partition(start, midpoint-2, left_node)
    stur x1, [fp, #0]   // store x1 (variable 'end') at fp[0]
    stur x4, [fp, #8]   // store variable 'midpoint' at fp[1]
    stur x12, [fp, #16] // store right_node variable at fp[2]

    subi x1, x4, #2     // x1 = midpoint - 2 (second arg to partition)
    addi x2, x11, #0    // left_node = arg2, for partition
    bl Partition

    // Partition(midpoint, end, right_node)
    ldur x0, [fp, #8]   // load 'midpoint' into arg0
    ldur x1, [fp, #0]   // load 'end' into arg1
    ldur x2, [fp, #16]  // load 'right_node' into arg2

    bl Partition
    b Partition_end     // skip to end


Partition_null:         // start == end
    // NULL = -1
    subi x9, xzr, #1    // x9 == NULL
    stur x9, [x2, #16]  // *(node + 2) <- NULL
    stur x9, [x2, #24]  // *(node + 3) <- NULL

Partition_end:

    // handle callee end procedures
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #48    // deallocate stack frame

	br lr