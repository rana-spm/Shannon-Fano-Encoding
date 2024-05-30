//////////////////////////
//			//
// Project Submission	//
//			//
//////////////////////////

// Partner 1: Rana Singh, A17545784
// Partner 2: Niharika Trivedi, (Student ID here)

//////////////////////////
//			//
//	main		//
//                    	//
//////////////////////////

// Tests FindMidpoint (and FindTail)
main:	
    // Allocate space on the stack
    SUBI SP, SP, #40       // Increase stack space to accommodate additional variables
    // Push old frame pointer onto the stack
    STUR FP, [SP, #0]
    // Set frame pointer
    ADDI FP, SP, #32
    // Push link register onto stack
    STUR LR, [FP, #0]

    // Load initial symbol array address
    LDA x4, symbol
    LDUR x0, [x4, #0]      // x0 is the head (first symbol)
	STUR x0, [SP, #8]      // Store original head address on stack
    bl FindTail            // Call FindTail to get the last symbol address in x1
	LDUR x0, [SP, #8]      // Load original head address from stack after FindTail call
    STUR x1, [SP, #16]     // Store original tail address on stack
    STUR x2, [SP, #24]     // Store original left sum on stack
    STUR x3, [SP, #32]     // Store original right sum on stack

    // Call FindMidpoint
    bl FindMidpoint
    putint x4              // Print the address returned in x4 which points to the start of the right sub-array

    // Restore the original values from the stack
    LDUR x0, [SP, #8]      // Restore head address
    LDUR x1, [SP, #16]     // Restore tail address
    LDUR x2, [SP, #24]     // Restore left sum
    LDUR x3, [SP, #32]     // Restore right sum

    // Restore Link Register and old frame pointer from Stack
    LDUR lr, [fp, #0]
    LDUR fp, [sp, #0]
    // Pop the stack
    ADDI sp, sp, #40
    stop


// main code for testing FindTail only
// main:	
// 	// Allocate space on the stack
//     SUBI SP, SP, #24
//     // Push old frame pointer onto the stack
//     STUR FP, [SP, #0]
//     // Set frame pointer
//     ADDI FP, SP, #16
//     // Push link register onto stack
//     STUR LR, [FP, #0]
// 	LDA x4, symbol
// 	LDUR x0, [x4, #0]
// 	STUR X0, [SP, #8]
// 	bl FindTail
// 	LDUR X0, [SP, #8]
// 	// Restore Link Register and old frame pointer from Stack
// 	putint X1 // print the tail address
//     LDUR LR, [FP, #0]
//     LDUR FP, [SP, #0]
//     // Pop the stack
//     ADDI SP, SP, #24
// 	STOP


	
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
	// Allocate space on the stack
    SUBI SP, SP, #24
    // Push old frame pointer onto the stack
    STUR FP, [SP, #0]
    // Set frame pointer
    ADDI FP, SP, #16
    // Push link register onto stack
    STUR LR, [FP, #0]
	// Save callee-saved X19 value on stack
	STUR X19, [SP, #8]
repeat:
	LDUR X19, [X0, #16] // store the address of the next symbol
	ADDI X19, X19, #1 // check if the next symbol is -1
	CBZ X19, endFindTail // if so, end the loop
	ADDI X0, X0, #16 // otherwise, move to the next symbol
	B repeat

endFindTail:
	ADD X1, X0, XZR // Save the address of the last symbol
	// Restore callee-saved X19 value from stack
	LDUR X19, [SP, #8]
    // Restore Link Register and old frame pointer from Stack
    LDUR LR, [FP, #0]
    LDUR FP, [SP, #0]
    // Pop the stack
    ADDI SP, SP, #24
    BR LR


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
	// Allocate space on the stack
    SUBI SP, SP, #32
    // Push old frame pointer onto the stack
    STUR FP, [SP, #0]
    // Set frame pointer
    ADDI FP, SP, #24
    // Push link register onto stack
    STUR LR, [FP, #0]
	// Save callee-saved X19, X20 values on stack
	STUR X19, [SP, #8]
	STUR X20, [SP, #16]

	LDUR X2, [X0, #8] // store the sum of the frequency of the left sub-array
	LDUR X3, [X1, #8] // store the sum of the frequency of the right sub-array
midPointLoop:
	ADDI X19, X0, #16 // check if head + 2 == tail
	SUBS XZR, X19, X1
	B.EQ endFindMidpoint
	SUBS XZR, X2, X3 // check left_sum <= right_sum
	B.GT else // if left_sum > right_sum, go to else condition
	ADDI X0, X0, #16 // move head to the next symbol
	LDUR X20, [X0, #8] // store the sum of the frequency of the left sub-array
	ADD X2, X2, X20 // update left_sum
	B midPointLoop
else:
	SUBI X1, X1, #16 // move tail to the previous symbol
	LDUR X20, [X1, #8] // store the sum of the frequency of the right sub-array
	ADD X3, X3, X20 // update right_sum
	B midPointLoop
	
endFindMidpoint:
	ADD X4, X1, XZR // Save the address of the last symbol
	// Restore callee-saved X19, X20 values from stack
	LDUR X19, [SP, #8]
	LDUR X20, [SP, #16]
    // Restore Link Register and old frame pointer from Stack
    LDUR LR, [FP, #0]
    LDUR FP, [SP, #0]
    // Pop the stack
    ADDI SP, SP, #32
    BR LR


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
    SUBI SP, SP, #40
    // Push old frame pointer onto the stack
    STUR FP, [SP, #0]
    // Set frame pointer
    ADDI FP, SP, #32
    // Push link register onto stack
    STUR LR, [FP, #0]
    // Save callee-saved registers X19, X20, X21, X22 on stack
    STUR X19, [SP, #8]
    STUR X20, [SP, #16]
    STUR X21, [SP, #24]
    STUR X22, [SP, #32]

    // Store start ptr and end ptr in the node
    STUR X0, [X2, #0]   // ∗node ← start
    STUR X1, [X2, #8]   // ∗(node + 1) ← end

    // Check if start == end
    SUB X19, X0, X1
    CBNZ X19, ElsePartition //If start =/= end, jump to ElsePartition

    // If condition: set left and right pointers to NULL (-1)
    SUBI X19, XZR, #1  // NULL = (-1)
    STUR X19, [X2, #16] // ∗(node + 2) ← NULL
    STUR X19, [X2, #24] // ∗(node + 3) ← NULL
    B endPartition

ElsePartition:
    // Calculate left_sum and right_sum
    LDUR X19, [X0, #8]  // left_sum = *(start + 1)
    LDUR X20, [X1, #8]  // right_sum = *(end + 1)

    // Setting arguments and calling FindMidpoint
    ADD X0, X0, XZR  // start
    ADD X1, X1, XZR  // end
    ADD X5, X19, XZR  // left_sum
    ADD X6, X20, XZR  // right_sum 
    BL FindMidpoint
    // Result (midpoint value) stored in X4 

    SUB X21, X4, X0  // Calculating (midpoint - start)
    SUBI X21, X21, #1 // offset = (midpoint - start) – 1

    // Calculate left and right nodes
    ADDI X19, X2, #32    // left_node = node + 4
    LSL X22, X21, #2      // offset*4
    ADD X20, X19, X22    // right_node = left_node + offset * 4

    // Store left and right node pointers
    STUR X19, [X2, #16]  // ∗(node + 2) ← left node
    STUR X20, [X2, #24]  // ∗(node + 3) ← right nodes


    // Setting arguments for first recursive call
    ADD X5, X0, XZR     // start 
    SUBI X6, X4, #2     // midpoint - 2
    ADD X7, X19, XZR    // left_node 
    BL Partition	// first recursive call

    // Setting arguments for second recursive call
    ADD X5, X4, XZR      // midpoint
    ADD X6, X1, XZR      // end
    ADD X7, X20, XZR     // right_node
    BL Partition	 // second recursive call

endPartition:
    // Restore callee-saved registers X19, X20, X21, X22 from stack
    LDUR X19, [SP, #8]
    LDUR X20, [SP, #16]
    LDUR X21, [SP, #24]
    LDUR X22, [SP, #32]
    // Restore Link Register and old frame pointer from Stack
    LDUR LR, [FP, #0]
    LDUR FP, [SP, #0]
    // Pop the stack
    ADDI SP, SP, #40
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
