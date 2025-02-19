ori $t1,$t1,1023
lui $t4,511
nop
nop 
ori $t2,$t1,1024
lui $t5,1023
nop
nop 
add $t3,$t1,$t2
add $t6,$t4,$t5
nop
nop
ori $s1,$s1,12288
beq $0,$0,lable
nop
add $t3,$t2,$t1
lable:
add $t3,$t1,$t1

jr $s1