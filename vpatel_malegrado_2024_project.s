//////////////////////////
//			//
// Project Submission	//
//			//
//////////////////////////

// Partner 1: Veeral Patel, A16416510
// Partner 2: Matthew Alegrado, A16752818

//////////////////////////
//			//
//	main		//
//                    	//
//////////////////////////

main:	lda x4, symbol
	ldur x0, [x4, #0]
	bl FindTail
	addi x2, x1, #24
	stur x2, [sp, #0]
	bl Partition
	// stop    // test partition
	ldur x0, [sp, #0]
	lda x5, encode
	ldur x1, [x5, #0]

CheckSymbol:
	ldur x2, [x1, #0]
	subs xzr, x2, xzr
	b.ge KeepEncode
	stop

KeepEncode:
	stur x1, [sp, #0]
	bl Encode
	ldur x1, [sp, #0]
	addi x1, x1, #8
	b CheckSymbol

	
////////////////////////
//                    //
//   FindTail         //
//                    //
////////////////////////
FindTail:
	// input:
	// x0: address of (pointer to) the first symbol of symbol array
	// output:
	// x1: address of (pointer to) the last symbol of symbol array

	// callee start procedure
    subi sp, sp, #56    // allocate
    stur fp, [sp, #0]   // save old fp
    addi fp, sp, #48    // set new fp
    stur lr, [sp, #8]   // save return address

    subi x3, xzr, #1      // Load -1 into register x2 by subtracting 1 from 0

	ldur x2, [x0, #16]
	subs xzr, x3, x2       // Subtract x2 from x3 (symbol) to check if it's -1
	b.eq tailfound

	stur x0, [sp, #16]
	stur x1, [sp, #24]
	addi x0, [x0, #16]
	BL FindTail
	b tail_notfound

tailfound:
    addi x1, x0, #0   // Store the address of the last symbol
    b tail_end
tail_notfound:
    ldur x0, [sp, #16] // restore x0
tail_end:
    // handle callee end procedures
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #56    // deallocate stack frame

    BR lr               // Return



////////////////////////
//                    //
//   FindMidpoint     //
//                    //
////////////////////////
FindMidpoint:
	// input:
	// x0: address of (pointer to) the first symbol of the symbol array
	// x1: address of (pointer to) the last symbol of the symbol array
	// x2: sum of the frequency of the left sub-array
	// x3: sum of the frequency of the right sub-array

	// callee start procedure
    subi sp, sp, #56    // allocate
    stur fp, [sp, #0]   // save old fp
    addi fp, sp, #48    // set new fp
    stur lr, [sp, #8]   // save return address

FindMidpoint_loop:
	ADDI x5, x0, #16
	SUBS x7, x5, x1     // Compare x5 with x1, setting flags
    B.EQ ReturnTail        // if (head + 2 == tail) goto TailFound
	
	SUBS X6, X3, X2		 // SUBTRACT the two, if greater brach to tail and then tranch to head
    B.LT UpdateTail     // if (left sum <= right sum) goto UpdateHead

UpdateHead:
    ADDI x0, x0, #16      // head = head + 2
	LDUR x7, x0,#8        
    ADD x2, x2, x7        // left sum = left sum + *(head)
	bl FindMidpoint_loop  // Recursive call to FindMidpoint
    b FindMidpoint_loop

UpdateTail:
	SUBI x1, x1, #16
	LDUR x7, x1, #8      // head = head + 2
    ADD x3, x3, x7        // left sum = left sum + *(head)
    bl FindMidpoint_loop       // Recursive call to FindMidpoint
    b FindMidpoint_loop
	
	// output:
	// x4: address of (pointer to) the first element of the right-hand side sub-array
ReturnTail:
    ADD x4, x1, xzr            // x4 = tail

    // handle callee end procedures
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #56    // deallocate stack frame

    br lr                 // return

FindMidpointEnd:
    // handle callee end procedures
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #56    // deallocate stack frame

////////////////////////
//                    //
//   Partition        //
//                    //
////////////////////////
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
    subi sp, sp, #56    // allocate
    stur fp, [sp, #0]   // save old fp
    addi fp, sp, #48    // set new fp
    stur lr, [sp, #8]   // save return address

    // function
    stur x0, [x2, #0]   // *node <- start
    stur x1, [x2, #8]   // *(node + 1) <- end
    subs xzr, x0, x1    // check start - end == 0
    b.eq Partition_null

    // else branch:

    // Save temp regs before calling FindMidpoint
    stur x0, [sp, #16]   // store x0 (variable 'start') at fp[0]
    stur x1, [sp, #24]   // store x1 (variable 'end') at fp[1]
    stur x2, [sp, #32]  // store x2 (variable 'node') at fp[2]
    ldur x2, [x0, #8]   // l_sum <- *(start + 1)
    ldur x3, [x1, #8]   // r_sum <- *(end + 1)
    bl FindMidpoint     // midpoint = x4 <- FindMidpoint(.)

    ldur x0, [sp, #16]   // load pre-call x0 value
    ldur x1, [sp, #24]   // load pre-call x1 value
    ldur x2, [sp, #32]  // load pre-call x2 value

    sub x10, x4, x0     // x10 = offset <- midpoint - start
    subi x10, x10, #8   // x10-- (address is -8) (CHANGED)

    addi x11, x2, #32    // x11: left_node <- node + 4

    lsl x10, x10, #2   // x13 = offset * 4
    addi x12, x2, #32    // x12 = node + 4
    add x12, x12, x10   // x12 = x12 + offset * 4   (right_node)

    stur x11, [x2, #16] // *(node + 2) <- left_node
    stur x12, [x2, #24] // *(node + 3) <- right_node

    // Store variables before Partition(start, midpoint-2, left_node)
    stur x1, [sp, #16]   // store x1 (variable 'end')
    stur x4, [sp, #24]   // store variable 'midpoint'
    stur x12, [sp, #32] // store right_node variable

    subi x1, x4, #16     // x1 = midpoint - 2 (second arg to partition)
    addi x2, x11, #0    // left_node = arg2, for partition
    bl Partition

    // Partition(midpoint, end, right_node)
    ldur x0, [sp, #24]   // load 'midpoint' into arg0
    ldur x1, [sp, #16]   // load 'end' into arg1
    ldur x2, [sp, #32]  // load 'right_node' into arg2

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
    addi sp, sp, #56    // deallocate stack frame

	br lr

	
////////////////////////
//                    //
//   IsContain        //
//                    //
////////////////////////
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
	b.lt IsContain_false    // exit while loop if start > end
	ldurb x9, [x0, #0]      // retrieve 1 byte, first char
	subs xzr, x2, x9       // compare the two chars
	b.eq IsContain_matching // if chars match, jump
	addi x0, x0, #2          // increment start by 2
	b IsContain_while       // return to top of while loop


IsContain_matching:
    addi x3, xzr, #1    // return value set to 1
    b IsContain_end

IsContain_false:
    addi x3, xzr, #0     // return value set to 1
    b IsContain_end

// handle callee end procedures
IsContain_end:
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #32    // deallocate stack frame

	br lr



////////////////////////
//                    //
//   Encode           //
//                    //
////////////////////////
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
    addi x11, xzr, #1   // x11 <- #1
    putint x11          // print 1
    add x0, x10, xzr   // set first function argument to right_node
    bl Encode           // call Encode(right_node, symbol)

Encode_end:
    ldur x0, [sp, #16]  // load old node before going to main
    ldur lr, [sp, #8]   // load return address
    ldur fp, [sp, #0]   // load old fp
    addi sp, sp, #56    // deallocate stack frame


	br lr
