//////////////////////////
//			//
// Project Submission	//
//			//
//////////////////////////

// Partner 1: Rana Singh, A17545784
// Partner 2: Niharika Trivedi, A17940857

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
	// x1: address of (pointer to) the last symbol of symbol array
	SUBI SP, SP, #32   // Allocate space on the stack
    STUR FP, [SP, #0]  // Push old frame pointer onto the stack
    STUR LR, [SP, #8]  // Push link register onto stack
    ADDI FP, SP, #24   // Set frame pointer
    
    STUR X19, [SP, #16] // Save X19 value on stack
    STUR X0, [SP, #24] // Save the address of the first symbol on stack

	LDUR X19, [X0, #16]  // store the value of the next symbol
	ADDI X19, X19, #1    // check if the next symbol is -1
	CBNZ X19, repeat     // if so, end the loop
    ADD X1, X0, XZR      // Save the address of the last symbol
    B endFindTail
repeat:
	ADDI X0, X0, #16     // otherwise, move to the next symbol
	BL FindTail
    
endFindTail:
	
    LDUR X0, [SP, #24]  // Restore the address of the first symbol
	LDUR X19, [SP, #16] // Restore callee-saved X19 value from stack
    LDUR FP, [SP, #0]   // Restore Frame Pointer
    LDUR LR, [SP, #8]   // Restore Link Register and old frame pointer from Stack
    ADDI SP, SP, #32    // Pop the stack
    BR LR               // Return from function


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
	SUBI SP, SP, #64   // Allocate space on the stack
    STUR FP, [SP, #0]  // Push old frame pointer onto the stack
    STUR LR, [SP, #8]  // Push link register onto stack
    ADDI FP, SP, #56   // Set frame pointer
    
    STUR X19, [SP, #16] // Save X19 value on stack
	STUR X20, [SP, #24] // Save X20 value on stack
    STUR X0, [SP, #32]  // Save the address of the first symbol on stack
    STUR X1, [SP, #40]  // Save the address of the last symbol on stack
    STUR X2, [SP, #48]  // Save the sum of the frequency of the left sub-array on stack
    STUR X3, [SP, #56]  // Save the sum of the frequency of the right sub-array on stack

	ADDI X19, X0, #16 // check if head + 2 == tail
	SUBS XZR, X19, X1
    B.NE continueFM
    ADD X4, X1, XZR     // Save the address of the last symbol
    B endFindMidpoint
continueFM:
	SUBS XZR, X2, X3 // check left_sum <= right_sum
	B.LE lessThanOrEq // if left_sum <= right_sum, go to other condition
    // if left_sum > right_sum
    SUBI X1, X1, #16 // move tail to the previous symbol
    LDUR X20, [X1, #8] // store the frequency of the last symbol
    ADD X3, X3, X20 // update right_sum
    B repeatMidpoint
lessThanOrEq:
	ADDI X0, X0, #16 // move head to the next symbol
    LDUR X19, [X0, #8] // store the frequency of the first symbol
    ADD X2, X2, X19 // update left_sum
repeatMidpoint:
	BL FindMidpoint
	
endFindMidpoint:
	
    LDUR X3, [SP, #56]  // Restore the sum of the frequency of the right sub-array
    LDUR X2, [SP, #48]  // Restore the sum of the frequency of the left sub-array
    LDUR X1, [SP, #40]  // Restore the address of the last symbol
    LDUR X0, [SP, #32]  // Restore the address of the first symbol
    LDUR X20, [SP, #24] // Restore callee-saved X20 value from stack
	LDUR X19, [SP, #16] // Restore callee-saved X19 value from stack
    LDUR FP, [SP, #0]  // Restore Frame Pointer
    LDUR LR, [SP, #8]  // Restore Link Register and old frame pointer from Stack
    ADDI SP, SP, #64   // Pop the stack
    BR LR               // Return from function


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
	
    // Allocate space on the stack
    SUBI SP, SP, #64
    STUR FP, [SP, #0]  // Push old frame pointer onto the stack
    STUR LR, [SP, #8]  // Push link register onto stack
    ADDI FP, SP, #56   // Set frame pointer
    
    STUR X19, [SP, #16] // Save callee-saved X19 value on stack
    STUR X20, [SP, #24]
    STUR X0, [SP, #32] // Save the address of the first symbol on stack
    STUR X1, [SP, #40] // Save the address of the last symbol on stack
    STUR X2, [SP, #48] // Save the address of the first attribute of the current binary tree node on stack

    // Store start ptr and end ptr in the node
    STUR X0, [X2, #0]   // ∗node ← start
    STUR X1, [X2, #8]   // ∗(node + 1) ← end

    // Check if start == end
    SUBS XZR, X0, X1
    B.NE ElsePartition //If start =/= end, jump to ElsePartition

    // If condition: set left and right pointers to NULL (-1)
    SUBI X19, XZR, #1  // NULL = (-1)
    STUR X19, [X2, #16] // ∗(node + 2) ← NULL
    STUR X19, [X2, #24] // ∗(node + 3) ← NULL
    B endPartition

ElsePartition:
    // Calculate left_sum and right_sum
    LDUR X2, [X0, #8]  // left_sum = *(start + 1)
    LDUR X3, [X1, #8]  // right_sum = *(end + 1)  
    // Call MidPoint with X0 = start, X1 = end, X2 = left_sum, X3 = right_sum
    BL FindMidpoint    // Result (midpoint value) stored in X4 
    STUR X4, [SP, #56]  // Save the midpoint value on stack
    LDUR X2, [SP, #48]  // Restore the address of the first attribute of the current binary tree node

    SUB X20, X4, X0  // Calculating (midpoint - start)
    SUBI X20, X20, #8 // offset = (midpoint - start) – 1

    // Calculate left and right nodes
    ADDI X19, X2, #32    // left_node = node + 4
    LSL X20, X20, #2      // offset*4
    ADD X20, X19, X20    // right_node = left_node + offset * 4

    // Store left and right node pointers
    STUR X19, [X2, #16]  // ∗(node + 2) ← left node
    STUR X20, [X2, #24]  // ∗(node + 3) ← right nodes

    // Setting arguments for first recursive call
    SUBI X1, X4, #16     // midpoint - 2
    ADD X2, X19, XZR    // left_node
    // Call Partition with X0 = start, X1 = midpoint - 2, X2 = left_node
    BL Partition	// first recursive call
    
    LDUR X4, [SP, #56]  // Restore the midpoint value from stack
    // Setting arguments for second recursive call
    ADD X0, X4, XZR      // midpoint
    LDUR X1, [SP, #40]    // end
    ADD X2, X20, XZR     // right_node
    // Call Partition with X0 = midpoint, X1 = end, X2 = right_node
    BL Partition	 // second recursive call

endPartition:
    // Restore callee-saved registers from stack
    LDUR X2, [SP, #48]
    LDUR X1, [SP, #40]
    LDUR X0, [SP, #32]
    LDUR X20, [SP, #24]
    LDUR X19, [SP, #16]
    // Restore Link Register and old frame pointer from Stack
    LDUR FP, [SP, #0]  // Restore Frame Pointer
    LDUR LR, [SP, #8]  // Restore Link Register and old frame pointer from Stack
    ADDI SP, SP, #64   // Pop the stack
    BR LR
	
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
    SUBI SP, SP, #56
    STUR FP, [SP, #0]  // Push old frame pointer onto the stack
    STUR LR, [SP, #8]  // Push link register onto stack
    ADDI FP, SP, #48   // Set frame pointer
	// Save callee-saved X19, X20 values on stack
	STUR X19, [SP, #16]
	STUR X20, [SP, #24]
    STUR X0, [SP, #32] // Save the address of the first symbol on stack
    STUR X1, [SP, #40] // Save the address of the last symbol on stack
    STUR X2, [SP, #48] // Save the symbol to look for on stack

    ADDI X3, XZR, #0 // initialize x3 to 0
    LDUR X20, [X1, #0] // load the last symbol of the sub-array
repeatIsContain:
    LDUR X19, [X0, #0] // load the current symbol
    SUBS XZR, X19, X2 // check if head == symbol
    B.EQ returnTrue     
    SUBS XZR, X19, X20 // check if head == tail
    B.EQ endIsContain // if so, end the loop
	ADDI X0, X0, #16 // otherwise, move to the next symbol
	B repeatIsContain

returnTrue:
    ADDI X3, XZR, #1 // set x3 to 1
endIsContain:
	// Restore callee-saved X19, X20 values from stack
    LDUR X2, [SP, #48]
    LDUR X1, [SP, #40]
    LDUR X0, [SP, #32]
	LDUR X20, [SP, #24]
	LDUR X19, [SP, #16]
    // Restore Link Register and old frame pointer from Stack
    LDUR FP, [SP, #0]  // Restore Frame Pointer
    LDUR LR, [SP, #8]  // Restore Link Register and old frame pointer from Stack
    ADDI SP, SP, #56   // Pop the stack
    BR LR


////////////////////////
//                    //
//   Encode           //
//                    //
////////////////////////
Encode:	
	// input:
	// x0: the address of (pointer to) the binary tree node 
	// x2: symbols to encode

    // Allocate space on the stack
    SUBI SP, SP, #48
    STUR FP, [SP, #0]  // Push old frame pointer onto the stack
    STUR LR, [SP, #8]  // Push link register onto stack
    ADDI FP, SP, #40   // Set frame pointer
    // Save callee-saved registers X19, X20 on stack
    STUR X19, [SP, #16]
    STUR X20, [SP, #24]
    STUR X0, [SP, #32] // Save the address of the binary tree node on stack
    STUR X2, [SP, #40] // Save the address of the symbols to encode on stack    
    
    LDUR X19, [X0, #16]  // Loading left node into register X19
    LDUR X20, [X0, #24]  // Loading right node into register X20

    SUBS XZR, X19, X20 // Checking if left node = right node
    B.EQ endEncode   // If left node == right node, end the function

ifEncode:
    LDUR X0, [X19, #0]   // Loading *(left node) = start
    LDUR X1, [X19, #8]   // Loading *(left node+1) = end
    // Call IsContain with X0 = *left_node, X1 = *(left_node + 1), X2 = symbol
    BL IsContain    // Result of IsContain is stored in X3

    CBZ X3, PrintOne // If X3 == 0, jump to PrintOne, else PC = PC+4, and we go to PrintZero

PrintZero:  
    PUTINT XZR // Prints zero
    ADD X0, X19, XZR  // Setting argument (node) as left node for Encode recursion
    // Call Encode with X0 = left_node, X2 = symbol
    BL Encode   // Encode recursion with left node and symbol as arguments
    B endEncode   // End the function

PrintOne:
    ADDI X19, XZR, #1 // Saving 1 in X4 (to be printed)
    PUTINT X19  // Prints 1
    ADD X0, X20, XZR  // Setting argument (node) for Encode recursion
    // Call Encode with X0 = right_node, X2 = symbol
    BL Encode   // Encode recursion with right node and symbol as arguments

endEncode:
    // Restore callee-saved registers X19, X20 from stack
    LDUR X2, [SP, #40]
    LDUR X0, [SP, #32]
    LDUR X20, [SP, #24]
    LDUR X19, [SP, #16] 
    
    // Restore Link Register and old frame pointer from Stack
    LDUR FP, [SP, #0]  // Restore Frame Pointer
    LDUR LR, [SP, #8]  // Restore Link Register and old frame pointer from Stack
    ADDI SP, SP, #48   // Pop the stack
    BR LR
