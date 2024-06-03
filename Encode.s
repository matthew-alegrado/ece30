Encode:
	// input:
	// x0: the address of (pointer to) the binary tree node
	// x2: symbol to encode

    // registers:
    // x9: left node value
    // x10: right node value
    // x11: #1 (for printing)

    // callee start procedure
    subi sp, sp, #56    // allocate
    stur fp, [sp, #0]   // save old fp
    addi fp, sp, #48    // set new fp
    stur lr, [sp, #8]   // save return address

    // function
    ldur x9, [x0, #16]      // left_node <- *(node+2)
    ldur x10, [x0, #24]     // right_node <- *(node+3)
    subs xzr, x9, x10       // check if left_node == right_node
    b.eq Encode_end         // jump to end if nodes are equal

    // nested if statement
    // start = *left_node, end = *(left_node + 1), symbol = symbol

    // IsContain(*start, *end, symbol)
    stur x0, [sp, #16]   // save current node (x0) at sp[2]
    stur x2, [sp, #24]   // save current symbol (x2) at sp[3]
    stur x9, [sp, #32]  // save left node (x9) at sp[4]
    stur x10, [sp, #40] // save right node (10) at sp[5]
    ldur x0, [x9, #0]   // *left_node function arg
    ldur x1, [x9, #8]   // *(left_node + 1) function arg
    bl IsContain

    // Load variables that we saved
    ldur x0, [sp, #16]
    ldur x2, [sp, #24]
    ldur x9, [sp, #32]
    ldur x10, [sp, #40]

    subs xzr, x3, xzr   // check if x3 = 1 or x3 = 0
    b.eq Encode_0       // if return value of IsContain is 0, go to Encode_0
    putint xzr          // print 0
    add x0, x9, xzr     // set first function argument to left_node
    bl Encode           // call Encode(left_node, symbol)
    b Encode_end        // jump to end procedure

Encode_0:
    addi x11, xzr, #1   // x1 <- #1
    putint x11          // print 1
    add x0, x10, xzr   // set first function argument to right_node
    bl Encode           // call Encode(right_node, symbol)

Encode_end:
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #56    // deallocate stack frame

	br lr

IsContain:
	// input:
	// x0: address of (pointer to) the first symbol of the sub-array
	// x1: address of (pointer to) the last symbol of the sub-array
	// x2: symbol to look for

	// output:
	// x3: 1 if symbol is found, 0 otherwise

    // callee start procedure
	subi sp, sp, #32    // allocate
    stur fp, [sp, #0]   // save old fp
    addi fp, sp, #24    // set new fp
    stur lr, [sp, #8]   // save return address

	// while loop
	// x9/x10: first/second char value
IsContain_while:
	subs xzr, x1, x0        // compare start and end values
	b.gt IsContain_false    // exit while loop if start > end
	ldurb x9, [x0, #0]      // retrieve 1 byte, first char
	ldurb x10, [x1, #0]     // retrieve second char
	subs xzr, x10, x9       // compare the two chars
	b.eq IsContain_matching // if chars match, jump
	addi x0, x0, #2          // increment start by 2
	b IsContain_while       // return to top of while loop


IsContain_matching:
    addi x3, xzr, #1    // return value set to 1
    b IsContain_end

IsContain_false:
    addi x3, x3, #0     // return value set to 1
    b IsContain_end

// handle callee end procedures
IsContain_end:
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #32    // deallocate stack frame

	br lr