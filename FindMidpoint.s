FindMidpoint:
	// input:
	// x0: address of (pointer to) the first symbol of the symbol array
	// x1: address of (pointer to) the last symbol of the symbol array
	// x2: sum of the frequency of the left sub-array
	// x3: sum of the frequency of the right sub-array
loop:
	ADD X5,[X0,#16]
	SUBS x7, x5, x1     # Compare x5 with x1, setting flags
    B.EQ TailFound        # if (head + 2 == tail) goto TailFound

	SUBS X6, X2, X3		 # SUBTRACT the two, if greater brach to tail and then tranch to head
    B.LE UpdateTail      # if (left sum <= right sum) goto UpdateHead
	B UpdateHead

UpdateTail:
    ADDI x0, [x0, #16]
	LDUR x7, [x0,#8]      # head = head + 2
    ADD x2, x2, x7        # left sum = left sum + *(head)
	BL loop       # Recursive call to FindMidpoint

UpdateHead:
	ADDI x1, [x1, #16]
	LDUR x7, [x1,#8]      # head = head + 2
    ADD x3, x3, x7        # left sum = left sum + *(head)
    BL loop       # Recursive call to FindMidpoint

	// output:
	// x4: address of (pointer to) the first element of the right-hand side sub-array
ReturnTail:
    ADD x4, x1, xzr            # x4 = tail
    br lr                 # return