# Objective: Convert input from base-31 to base-10
.data
	char_array: .space 3000
	#Invalid Messages
	not_valid: .asciiz "Invalid base-31 number."
	empty: .asciiz "Input is empty."
	too_long: .asciiz "Input is too long."
.text
.globl main

main:
	#getting input from user
	li $v0, 8  
    	la $a0, char_array
    	li $a1, 3000
    	syscall
	
	add $t1, $0, 0 #initializes $t1 to zero (stores character)
	add $t3, $0, $0 #initializes $t3 to zero (length counter)
	
	#checking is string empty before continuation
	la $t2, char_array #stores string address into register
	lb $t1,0($t2) #loads first index of string
	li $t0, 10 #10 is the ascii value of new line
	beq $t1, $t0 invalid_empty #looks for new_line character at first index: checking if input is empty
	
	addi $t5, $0, 1 	# $t5 = $pow_reg Initialized to 1.
	addi $t6, $0, 0 	# $t6 = $sum_reg. Initialized to 0
	addi $t7, $0, 0 	# contents of $t6 will be moved to t7
	addi $s4, $0, 31 	#s4 contains the multiplicand increment, the base 31
	addi $t4, $0, 32 	#stores 32 (space) in t4
	addi $t8, $0, 0 	#counter for spaces in between letters
	
	#Is_Valid_Spaces?
	loop_one:
		lb $t1,0($t2)     #loads first char of string
		addi $t2, $t2, 1  #increment pointer
		addi $t3, $t3, 1  #increment length counter
		beq $t1, $t4, loop_one #if the current char is a space, loop
		beq $t1, $t0, invalid_emptyOUT #if we pass all of the spaces and get to the end of string, it's empty
		beq $t1, $0, invalid_emptyOUT  #if we pass all of the spaces and get to the end of string, it's empty
		
	loop_two:
		lb $t1,0($t2) 		#loads next char of string
		addi $t2, $t2, 1 	#increments pointer
		addi $t3, $t3, 1 	#increment length counter
		addi $t8, $t8, 1
		beq $t1, $t0, restart_arr #If we get to the end of the string after seeing just spaces and chars "____abc", start rest of program
		beq $t1, 0, restart_arr
		bne $t1, $t4, loop_two 		#if we see another space, restart loop
		
	loop_three:
		lb $t1,0($t2)			#loads next char of string
		addi $t2, $t2, 1		#increments pointer
		addi $t3, $t3, 1		#increment length counter
		addi $t8, $t8, 1
		beq $t1, $t0, restart_arr	#branches to restart the array counter and pointer once we get to the end
		beq $t1, 0, restart_arr		#branches to restart the array counter and pointer once we get to the end
		bne $t1, $t4, invalid_baseChar	#If we see something that's not a space, after we already saw spaces then characters and then spaces "ex. a_b", its an invalid input
		j loop_three			#restart loop
		
	#Now that we know that the input is valid in terms of spaces, let's restart the counter
	restart_arr:
		sub $t2, $t2, $t3 	#restarting the pointer in char_array
		la $t3, 0 		#restarting the counter
		
	count_non_space_chars:
		lb $t1,0($t2)			#loads next char of string
		addi $t2, $t2, 1		#increments pointer
		beq $t1, 32, count_non_space_chars
		beq $t1, 10, go_back_one	#When we get to the end of the string, go back by one char.
		beq $t1,0, go_back_one		#When we get to the end of the string, go back by one char.
		beq $t3, 4, invalid_lengthOUT 	#If we have reached the count of 4, and we are still seeing more non-space characters, it is invalid 
		addi $t3, $t3, 1 		#increment length counter
		j count_non_space_chars		#Jumps to beginning of loop
		
	#go back until you get to non-space characters. 
	go_back_one:
		addi $t2, $t2, -1   	#decrements the pointer by one
	go_back:
		addi $t2, $t2, -1  	#decrements the pointer by one
		lb $t1, 0($t2)		#loads the current character in the string
		beq $t1, 32, go_back 	#if we see another space, go back some more
		
	move $a0, $t1  #curr char
	move $a1, $t2  #addr char
	move $a2, $t5  #power
	move $a3, $t3  #len
	
	jal Convert
	move $a0, $v0
	
	li $v0, 1 #prints contents of a0
	syscall
		
	li $v0,10 #ends program
	syscall
	
	#------------------------------------------------------------------------------------------
	#BRANCHS FOR PRINTING/EXIT ERROR MESSAGES	
	#Exit if string is too long
	invalid_lengthOUT:
		la $a0, too_long #loads string
      		li $v0, 4 #prints new line for string
		syscall
		
      		li $v0,10 #ends program
      		syscall
		
	#Exit if string is empty
	invalid_emptyOUT:
		la $a0, empty #loads string
      		li $v0, 4 #prints new line for string
      		syscall
		
		li $v0,10 #ends program
      		syscall

      #Exit if string is Invalid, outside of range
	invalid_baseOUT:
		la $a0, not_valid #loads string
		li $v0, 4 #prints new line for string
		syscall

      		li $v0,10 #ends program
      		syscall
	
	#Exit if we see spaces in the middle of character
	invalid_baseChar:
		bgt $t8, 3, invalid_lengthOUT
		j invalid_baseOUT
	 
	jr $ra
.globl Convert
	Convert:
		addi $sp, $sp, -24
		sw $ra ($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		beq $a3, $0, finish
		
		lb $a0, ($a1)			#loading current character of the string decrementally
		addi $a1, $a1, -1		#decrementing the address of the character	
		addi $a3, $a3, -1 		#decrement the length
		
		move $s0, $a0  #curr char
		move $s1, $a1  #addr char
		move $s2, $a2  #power
		move $s3, $a3  #len
		
		#j check_string			#Jumpt to check if string is valid. If so, convert to base-10
		
	check_string:
      		blt $t1, 48, invalid_base 		#checks if character is before 0 in ASCII chart
		blt $t1, 58, Translate_Number 		#checks if character is between 48 and 57
		blt $t1, 65, invalid_base 		#checks if character is between 58 and 64
      		blt $t1, 86, Translate_UpperCase 	#checks if character is between 65 and 85
		blt $t1, 97, invalid_base 		#checks if character is between 76 and 96
      		blt $t1, 118, Translate_LowerCase 	#checks if character is between 97 and 117
      		blt $t1, 128, invalid_base 		#checks if character is between 118 and 127
		
	Translate_Number:
		addi $t1, $t1, -48 	#subtracts 48 from the ASCII value
		j multiply			#converts this char to decimal, and adds it to the sum
		
	Translate_LowerCase:
      		addi $t1, $t1, -87 	#subtracts 87 from the ASCII value
	  	j multiply		#converts this char to decimal, and adds it to the sum
		
	Translate_UpperCase:
      		addi $t1, $t1, -55 	#subtracts 48 from the ASCII value
	  	j multiply		#converts this char to decimal, and adds it to the sum

	multiply:
		mult $t1, $t5 		#multiplying the current char of the string times a power of 31
		mflo $t6 		#moving the product
		add $t7, $t7, $t6 	#adding the product to the total sum
		mult $t5, $s0 		#multiplying the power regester times 31, to get to the next power of 31
		mflo $t5 		#storing the incrementation of the power register
		bne $t3, $zero Convert
		jal Convert
	
	add $v0, $s4, $v0 #Please Work
	
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra
	
	finish:
		li $v0, 0
		lw $ra, ($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		

	
	
