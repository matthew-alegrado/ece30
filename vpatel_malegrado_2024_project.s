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
	// x1: address of (pointer to) the first symbol of symbol array

loop:	
	ldur x2, [x0, #16]
	SUBIS XZR, X2, #-1 //compare X2 to -1
	B.EQ tailfound
	
	ADDI x0, [x0, #16]
	B loop

tailfound:
	STUR x1, [x0, #0]
	br lr


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
loop:    
	ADD X5,[X0,#16]
	SUBIS x7, x5, x1     # Compare x5 with x1, setting flags
    BEQ TailFound        # if (head + 2 == tail) goto TailFound
	
	SUBS X6, X2, X3		 # SUBTRACT the two, if greater brach to tail and then tranch to head 
    B.LE UpdateTail      # if (left sum <= right sum) goto UpdateHead
	B UpdateHead

UpdateTail:
    ADDI x0, [x0, #16]
	LDUR x7, [x0,#8]      # head = head + 2
    ADD x2, x2, x7        # left sum = left sum + *(head)
	B ContinueRecursion   # goto ContinueRecursion

UpdateHead:
	ADDI x1, [x1, #16]
	LDUR x7, [x1,#8]      # head = head + 2
    ADD x3, x3, x7        # left sum = left sum + *(head)
    B ContinueRecursion   # goto ContinueRecursion

ContinueRecursion:
    BL loop       # Recursive call to FindMidpoint

	// output:
	// x4: address of (pointer to) the first element of the right-hand side sub-array
ReturnTail:
    ADD x4, x1, xzr            # x4 = tail
    br lr                 # return	


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
	b.gt IsContain_false    // exit while loop if start > end
	ldurb x9, [x0, #0]      // retrieve 1 byte, first char
	ldurb x10, [x1, #0]     // retrieve second char
	subs xzr, x10, x9       // compare the two chars
	b.eq IsContain_matching // if chars match, jump
	addi x0, x0, 2          // increment start by 2
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
    subi sp, sp, #32    // allocate
    stur fp, [sp, #0]   // save old fp
    addi fp, sp, #24    // set new fp
    stur lr, [sp, #8]   // save return address

    // function
    ldur x9, [x0, #16]      // left_node <- *(node+2)
    ldur x10, [x0, #24]     // right_node <- *(node+3)
    subs xzr, x9, x10       // check if left_node == right_node
    b.eq Encode_end         // jump to end if nodes are equal

    // nested if statement
    // start = *left_node, end = *(left_node + 1), symbol = symbol
    stur x0, [fp, #0]   // save current node (x0) at fp[0]
    stur x2, [fp, #8]   // save current symbol (x2) at fp[1]
    ldur x0, [x9, #0]   // dereference pointer to start
    ldur x1, [x9, #8]   // dereference pointer to end
    bl IsContain        // call IsContain(*start, *end, symbol)
    ldur x0, [fp, #0]   // load the saved x0
    ldur x2, [fp, #8]   // load saved symbol

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
    addi sp, sp, #32    // deallocate stack frame

	br lr
