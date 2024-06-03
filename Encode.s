Encode:
	// input:
	// x0: the address of (pointer to) the binary tree node
	// x2: symbol to encode

    // registers:
    // x9: left node value
    // x10: right node value
    // x11: #1 (for printing)

    // callee start procedure
    subi sp, sp, #48    // allocate
    stur fp, [sp, #0]   // save old fp
    addi fp, sp, #40    // set new fp
    stur lr, [sp, #8]   // save return address

    // function
    ldur x9, [x0, #16]      // left_node <- *(node+2)
    ldur x10, [x0, #24]     // right_node <- *(node+3)
    subs xzr, x9, x10       // check if left_node == right_node
    b.eq Encode_end         // jump to end if nodes are equal

    // nested if statement
    // start = *left_node, end = *(left_node + 1), symbol = symbol

    // IsContain(*start, *end, symbol)
    stur x0, [fp, #0]   // save current node (x0) at fp[0]
    stur x2, [fp, #8]   // save current symbol (x2) at fp[1]
    stur x9, [fp, #16]  // save left node (x9) at fp[2]
    stur x10, [fp, #24] // save right node (10) at f[3]
    ldur x0, [x9, #0]   // dereference pointer to start
    ldur x1, [x9, #8]   // dereference pointer to end
    bl IsContain

    // Load variables that we saved
    ldur x0, [fp, #0]
    ldur x2, [fp, #8]
    ldur x9, [fp, #16]
    ldur x10, [fp, #24]

    subs xzr, x3, xzr   // check if x3 = 1 or x3 = 0
    b.eq Encode_0       // if return value of IsContain is 0, go to Encode_0
    putint xzr          // print 0
    addi x0, x9, xzr    // set first function argument to left_node
    bl Encode           // call Encode(left_node, symbol)
    b Encode_end        // jump to end procedure

Encode_0:
    addi x11, xzr, #1   // x1 <- #1
    putint x11          // print 1
    addi x0, x10, xzr   // set first function argument to right_node
    bl Encode           // call Encode(right_node, symbol)

Encode_end:
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #48    // deallocate stack frame

	br lr