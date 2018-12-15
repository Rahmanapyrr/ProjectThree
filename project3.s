.data
	char_array: .space 500000
	
	#Invalid Messages
	not_valid: 	.asciiz "Invalid base-31 number."
	empty: 		.asciiz "Input is empty."
	too_long: 	.asciiz "Input is too long."
.text

.globl main
	main:										
		li $v0, 8							#getting input from user  
		la $a0, char_array
		li $a1, 500000
		syscall
		
		la $t2, char_array 						#stores string address into register
		
		addi $s5, $0, 31 						#My Base 31
		add $t1, $0, 0 							#initializes $t1 to zero (stores character)
		add $t3, $0, 0 							#initializes $t3 to 1 (counter)
		
		li $t0, 10 							#10 is the ascii value of new line
		
		addi $t4, $0, 32 						#stores 32 (space) in t4
		addi $t5, $0, 1 						#$t5 = $pow_reg Initialized to 1.
		addi $t6, $0, 0 						#$t6 = $sum_reg. Initialized to 0
		addi $t8, $0, 0 						#counter for spaces in between letters
		
		#Is_Valid_Spaces?
		loop_one:
			lb $t1,0($t2)
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			beq $t1, $t4, loop_one
			beq $t1, $t0, invalid_empty
			beq $t1, $0, invalid_empty
			
		loop_two:
			lb $t1,0($t2)
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			addi $t8, $t8, 1
			beq $t1, $t0, restart_arr
			beq $t1, 0, restart_arr
			bne $t1, $t4, loop_two
			
		loop_three:
			lb $t1,0($t2)
			addi $t2, $t2, 1
			addi $t3, $t3, 1
			addi $t8, $t8, 1
			beq $t1, $t0, restart_arr
			blez $t1, restart_arr
			bne $t1, $t4, invalid_baseChar
			j loop_three
			
		#Now that we know that the input is valid in terms of spaces, let's restart the counter
		restart_arr:
			sub $t2, $t2, $t3 		#restarting the character array pointer
			li $t3, 0 			#restaring the counter
	
		count_non_space_chars:
			lb $t1,0($t2)
			addi $t2, $t2, 1
			beq $t1, 32, count_non_space_chars
			beq $t1, 10, go_back_one
			beq $t1,0, go_back_one	
			beq $t3, 4, invalid_length
			addi $t3, $t3, 1 
			j count_non_space_chars
			
		#go back, until you get to non-space characters. 
		go_back_one:
			addi $t2, $t2, -1
			
		go_back:
			addi $t2, $t2, -1
			lb $t1, 0($t2)
			beq $t1, 32, go_back 
		
		#Call subprogram
		li $s4, 0
		addi $sp, $sp, -16
		sw $t1, 0($sp) 		#curr char
		sw $t2, 4($sp) 		#string address
		sw $t5, 8($sp) 		#current power (initialized to 1)
		sw $t3, 12($sp) 	#string length
		
		jal Convert

		lw $a0, 0($sp)
		addi $sp, $sp, 4
		li $v0, 1 			#prints contents of a0
		syscall

	Exit:
		li $v0,10 			#ends program
		syscall
	
		jr $ra	

.globl Convert
	Convert:				#loading args off the stack
		lw $a0, 0($sp)			#char
		lw $a1, 4($sp)			#string
		lw $a2, 8($sp)			#power
		lw $a3, 12($sp)			#string length
		addi $sp, $sp, 16

		addi $sp, $sp, -8		#allocating space for return values
		sw $ra, 0($sp)
		sw $s4, 4($sp)
		
		beq $a3, $0, finish
		
		lb $a0, 0($a1)			#decrementing values for next recursive iteration
		addi $a1, $a1, -1
		addi $a3, $a3, -1
		  
		check_string: 
		  ble $a0, 47, invalid_base 		#checks if character is before 0 in ASCII chart
		  ble $a0, 57, Translate_Number 	#checks if character is between 48 and 57
		  ble $a0, 64, invalid_base 		#checks if character is between 58 and 64
		  ble $a0, 85, Translate_UpperCase 	#checks if character is between 65 and 85
		  ble $a0, 96, invalid_base 		#checks if character is between 85 and 96
		  ble $a0, 117, Translate_LowerCase	#checks if character is between 96 and 117
		  blt $a0, 128, invalid_base 		#checks if character is between 118 and 127
		
		Translate_Number:
			addi $a0, $a0, -48 				#minus -48 from the ASCII value
			j multiply
			
		Translate_LowerCase:
			addi $a0, $a0, -87 				#minus 87 from the ASCII value
			j multiply
		  
		Translate_UpperCase:
			addi $a0, $a0, -55 				#minus 48 from the ASCII value
			j multiply
		
		multiply:
			mul $s4, $a0, $a2 				#multiplying the current char times a power of 31 and storing it in subsum
			mul $a2, $a2, $s5 				#multiplying the power regester times 31, to get to the next power of 31
			
			addi $sp, $sp, -16
			sw $a0, 0($sp) 					#current char
			sw $a1, 4($sp) 					#string address
			sw $a2, 8($sp) 					#current power 
			sw $a3, 12($sp) 				#string length
			
			jal Convert
		
		lw $v0, 0($sp)
		addi $sp, $sp, 4
		add $v0, $s4, $v0 		#adding the subsum with the previous return value (sub_sum)
		
		lw $ra, 0($sp)
		lw $s4, 4($sp)
		addi $sp, $sp, 8

		addi $sp, $sp, -4
		sw $v0, 0($sp)
						
		jr $ra
		
		finish:
			li $v0, 0
			lw $ra, 0($sp)
			lw $s4, 4($sp)
			addi $sp, $sp, 8
			
			addi $sp, $sp, -4
			sw $v0, 0($sp)
			
			jr $ra
	
invalid_length:
	la $a0, too_long 	#loads string
	li $v0, 4 			#prints string
	syscall

	j Exit
   
invalid_empty:
	la $a0, empty 	
	li $v0, 4 	
	syscall

	j Exit

invalid_baseChar:
	bge $t8, 4, invalid_length
	lb $t1,0($t2)
	addi $t2, $t2, 1
	addi $t8, $t8, 1
	bne $t1, 10 invalid_baseChar

invalid_base:
	la $a0, not_valid 		
	li $v0, 4 				
	syscall

	j Exit
