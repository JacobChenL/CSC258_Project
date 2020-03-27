#####################################################################
#
# CSC258H5S Winter 2020 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Litao Chen, 1004545842
# - Student 2 (if any): Name, Student Number
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - Here are some register that won' change its value and its meaning
# - $t0 = 0 means game is on, $t0 = 1 means game ends
# - $a1 represents the birdBlock
# - $a2 represents the direction that bird will move
# - $a3 represents the
#####################################################################
.data 
    displayAddress: .word  0x10008000
    green: .word 0x4bff7b
    yellow: .word 0xfff86b
    white: .word 0xffffff
    black : .word 0x000000
    background: .word 0x00ffdd
    birdBlock: .word 1688,1696,1816,1820,1824,1828,1944,1952	# set 1x10008000 as 0, it means the index of unit that bird is at
    lowerk: .word 0xffff006a
    newline: .asciiz "\n"
    keyStore: .word 0xffff0004

.text
.globl main

main:

ChangeBackground:
  lw $t0, displayAddress
  lw $t1, background
  li $t2, 0        		# Initialize beginning  
  li $t3, 1024     		# Initialize end  
  
start_loop_1:  
  beq $t2, $t3, end_loop 
  sw $t1, $t2($t1)	        # paint the  t2th unit red.  
  
  addi $t2, $t2, 1    		# Increment counter  
  b start_loop_1  
end_loop:        
 

StartSeting:
    la $a1, birdBlock		# $a1 = &birdBlock or birdBlock[0]
    j setBird			# initial the position of bird

INITDONE:
    GAMEINIT:			# A while loop
        li $t0, 0		# $t0 = 0 game continue, $t0 = 1 game ends
        li $v0, 30      	# call getTime(), $a0 = lower 32 bits, $a1 = upper 32 bits
        syscall
        move $t1,$a0		# $t1 = lower 32 bits (in millisecond)
    GAMEON:			
        bne $t0, 0, GAMEOVER	# if $t0 !=0, GAMEOVER
        checkMove1:
            lui $t4, 0xffff	# $t4 = first few bit of keyboard address
            lw $t3, 0($t4)	# $t3 = 0xffff0000
            andi $t3, $t3, 0x1  # $t3 = $t3(int)
            beqz $t3, checkMove2 # if $t3 == 0, jump to checkMove2
            lw $t5, 4($t4)	# else $t3 has a value, $t5 = the keyboard input
            la $a1, birdBlock	# $a1 = &birdBlock
            li $a2, -128	# $a2 = -128, the direction of moving to up
            beq $t5, 102, Move	# if $t5 = 102 ( the keyboard input == 'f', jump to Move
            j checkMove2	# else the keyboard input != 'f', jump to checkMove2
            
        checkMove2:
            addi $t2, $t1, 500	# set time interval as 0.5 sec, $t2 is future time
            li $v0, 30		# get time again
            syscall
            la $a1, birdBlock	# $a1 = birdBlock and pass it to the code block
            li $a2, 128		# represent the same colume but next row
            bge $a0, $t2, Move	# if current time is larger than futrue game, call  remove
            j checkMove1	# jump to checkMove1
        j GAMEON		# jump to the beginning of the loop
    
    
    
    GAMEOVER:
        li $v0, 10
        syscall


setBird:
    BIRDINIT:
        li $t1, 0		# Index of the loop
        li $t2, 0		# Index of the birdBlock array
        lw $t3, displayAddress	# $t3 = displayAddress
        lw $t4, yellow		# $t4 = yellow
    GETBIRD:
        beq $t1, 8, DONE	# if $t1 = 8, Done
        addi $t1, $t1, 1	# $t1 = $t1 + 1
        add $t5, $t2, $t2	# $t5 = 2 * $t2 (index)
        add $t5, $t5, $t5	# $t5 = 4 * $t2 
        add $t7, $a1, $t5	# $t7 = &birdBlock + 4 * Index
        lw $t5, 0($t7)		# $t5 = birdBlock[Index]
        add $t6, $t5, $t3	# $t6 = birdBlock[Index] + displayAddress
        sw $t4, 0($t6)		# load yellow on the bit map at $t5
        addi $t2, $t2, 1	# Index = Index + 1
        j GETBIRD
    DONE:
        j INITDONE
        
Move:
    REMOVEINIT:
        li $t1, 0		# Index of the loop
        li $t2, 0		# Index of the birdBlock array
        lw $t3, displayAddress	# $t3 = displayAddress
        lw $t4, black		# $t4 = black
    REMOVEBIRD:
        beq $t1, 8, REMOVEDONE	# if $t1 = 8, Done
        addi $t1, $t1, 1	# $t1 = $t1 + 1
        add $t5, $t2, $t2	# $t5 = 2 * $t2 (index)
        add $t5, $t5, $t5	# $t5 = 4 * $t2 
        add $t7, $a1, $t5	# $t7 = &birdBlock + 4 * Index
        lw $t5, 0($t7)		# $t5 = birdBlock[Index]
        add $t6, $t5, $t3	# $t6 = birdBlock[Index] + displayAddress
        sw $t4, 0($t6)		# load black on the bit map at $t5
        addi $t2, $t2, 1	# Index = Index + 1
        j REMOVEBIRD
    REMOVEDONE:
        j drop
        

drop:
    DROPINIT:
        li $t1,0		# $t1 = 0 is the index of the loop
        la $t2, birdBlock	# $t2 = &birdBlock
    DROP:
        bge $t1,8, DROPDONE	# if $t1 >= 8, loop ends
        add $t3, $t1,$t1	
        add $t3, $t3, $t3	# $t3 = 4 * $t1 , $t1 is loop index and it is also the index of array
        add $t4, $t3, $t2	# $t4 = &birdBlock + index * 4
        lw $t5, 0($t4)		# $t5 = birdBlock[$t1]
        add $t5, $t5, $a2	# $t5 = $t5 + 128, same colume, next row
        sw $t5, 0($t4)		# birdBlock[$t1] = $t5, new address
        addi $t1, $t1, 1	# $t1 = $t1 + 1
        j DROP			
    DROPDONE:
        j setBird		# jump to setBird to draw the bird at new position
        
        
    

        
    
