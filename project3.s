.data
	char_array: .space 500000
	
	#Invalid Messages
	not_valid: .asciiz "Invalid base-31 number."
	empty: .asciiz "Input is empty."
	too_long: .asciiz "Input is too long."
.text

.globl main
	main:										
		li $v0, 8							#getting input from user  
		la $a0, char_array
		li $a1, 500000
		syscall
		
		addi $s5, $0, 31 					#My Base 31
		
		add $t1, $0, 0 						#initializes $t1 to zero (stores character)
		add $t3, $0, 0 						#initializes $t3 to 1 (counter)
		li $t0, 10 							#10 is the ascii value of new line
		
		addi $t6, $0, 0 					#$t6 = $sum_reg. Initialized to 0
		addi $t7, $0, 0 					#contents of $t6 will be moved to t7 after multiplcation
		addi $t8, $0, 0 					#counter for spaces in between letters
		addi $t5, $0, 1 					#$t5 = $pow_reg Initialized to 1.
		addi $t4, $0, 32 					#stores 32 (space) in t4
		
		la $t2, char_array 					#stores string address into register
		lb $t1,0($t2) 						#loads first index of string
		beq $t1, $t0 invalid_empty 			#looks for new_line character at first index: checking if input is empty
		beq $t1, $0 invalid_empty			#looks for null character at first index: checking if input is empty
		
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
			beq $t1, 0, restart_arr
			bne $t1, $t4, invalid_baseChar
			j loop_three
			
	#Now that we know that the input is valid in terms of spaces, let's restart the counter
		restart_arr:
			sub $t2, $t2, $t3 	#restarting the pointer in char_array
			la $t3, 0 			#restaring the counter
	
		count_non_space_chars:
			lb $t1,0($t2)
			addi $t2, $t2, 1
			beq $t1, 32, count_non_space_chars
			beq $t1, 10, go_back_one
			beq $t1,0, go_back_one	
			beq $t3, 4, invalid_length
			addi $t3, $t3, 1 
			j count_non_space_chars
			
		#go back until you get to non-space characters. 
		go_back_one:
			addi $t2, $t2, -1
			
		go_back:
			addi $t2, $t2, -1
			lb $t1, 0($t2)
			beq $t1, 32, go_back 
		
		#Calling my subprogram to Convert
		li $s4, 0
		move $a0, $t1  #curr char
		move $a1, $t2  #string address
		move $a2, $t5  #power
		move $a3, $t3  #len
		
		addi $sp, $sp, -16
		#sw $ra, 0($sp)
		sw $a0, 0($sp) #curr char
		sw $a1, 4($sp) #string address
		sw $a2, 8($sp) #current power (initialized to 1)
		sw $a3, 12($sp) #length string
		
		jal Convert

		lw $v0, 0($sp)
		addi $sp, $sp, 4
		
		move $a0, $v0
		li $v0, 1 #prints contents of a0
		syscall

		Exit:
			li $v0,10 	#ends program
			syscall
		
		jr $ra	
	#-------------------------------------------------------------------------------------------------
	
.globl Convert
	Convert:
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $a3, 12($sp)
		addi $sp, $sp, 16

		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $s4, 4($sp)
		
		beq $a3, $0, finish
		
		lb $a0, 0($a1)
		addi $a1, $a1, -1
		addi $a3, $a3, -1

		check_string:
		  blt $a0, 48, invalid_base 		#checks if character is before 0 in ASCII chart
		  blt $a0, 58, Translate_Number 	#checks if character is between 48 and 57
		  blt $a0, 65, invalid_base 		#checks if character is between 58 and 64
		  blt $a0, 86, Translate_UpperCase 	#checks if character is between 65 and 85
		  blt $a0, 97, invalid_base 		#checks if character is between 76 and 96
		  blt $a0, 118, Translate_LowerCase #checks if character is between 97 and 117
		  blt $a0, 128, invalid_base 		#checks if character is between 118 and 127
		
		Translate_Number:
			addi $a0, $a0, -48 	#subtracts 48 from the ASCII value
			j multiply
			
		Translate_LowerCase:
		  addi $a0, $a0, -87 	#subtracts 87 from the ASCII value
		  j multiply
		  
		Translate_UpperCase:
			addi $a0, $a0, -55 	#subtracts 48 from the ASCII value
			j multiply
		
		multiply:
			mul $s4, $a0, $a2 		#multiplying the current char times a power of 31
			mul $a2, $a2, $s5 		#multiplying the power regester times 31, to get to the next power of 31
			
			addi $sp, $sp, -16
			sw $a0, 0($sp) #curr char
			sw $a1, 4($sp) #string address
			sw $a2, 8($sp) #current power (initialized to 1)
			sw $a3, 12($sp) #length string
			
			jal Convert
			
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			add $v0, $s4, $v0 
			
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
		
#Exit if string is too long
invalid_length:
  la $a0, too_long #loads string
  li $v0, 4 		#prints new line for string
  syscall

  j Exit
   
#Exit if string is empty
invalid_empty:
  la $a0, empty #loads string
  li $v0, 4 	#prints new line for string
  syscall

  j Exit

#Exit if we see spaces in the middle of character
invalid_baseChar:
	bgt $t8, 3, invalid_length
	
#Exit if string is Invalid, outside of range
invalid_base:
  la $a0, not_valid #loads string
  li $v0, 4 		#prints new line for string
  syscall

  j Exit
