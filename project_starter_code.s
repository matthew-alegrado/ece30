//////////////////////////
//			//
// Project Submission	//
//			//
//////////////////////////

// Partner 1: Veeral Patel, A16416510
// Partner 2: (your name here), (Student ID here)

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
	ldr x2, [x0, #16]
	
	//compare x2 to -1, if it equals -1, returns pointer
	
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
	
	// output:
	// x4: address of (pointer to) the first element of the right-hand side sub-array
	
	br lr


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

	br lr


////////////////////////
//                    //
//   Encode           //
//                    //
////////////////////////
Encode:	
	// input:
	// x0: the address of (pointer to) the binary tree node 
	// x2: symbols to encode

	br lr
