FindTail:
	// input:
	// x0: address of (pointer to) the first symbol of symbol array
	// output:
	// x1: address of (pointer to) the first symbol of symbol array
    subi x3, xzr, #1      // Load -1 into register x2 by subtracting 1 from 0

loop:
	ldur x2, [x0, #16]
	subs x4, x2, x3       // Subtract x2 from x3 (symbol) to check if it's -1
	b.eq tailfound

	addi x0, [x0, #16]
	B loop

tailfound:

    stur x1, [x0, #0]   // Store the address of the last symbol
    BR lr               // Return