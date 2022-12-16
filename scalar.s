;; preseed values for registers
lil r0, -0x5d54
lih r0, -0x1cbf7
lil r1, -0x11150
lih r1, 0x1e98a
lil r2, 0x12419
lih r2, 0x1f3d6
lil r3, -0x5e32
lih r3, -0x94c
lil r4, -0x14dc0
lih r4, 0x83e4
lil r5, 0x1406b
lih r5, -0x1f02d
lil r6, -0xc0b6
lih r6, 0x1dfdb
lil r7, 0x1e6b5
lih r7, -0xf08e
lil r8, 0x1f6c6
lih r8, -0x710a
lil r9, 0x11b8c
lih r9, 0x60cc
lil r10, -0x1708d
lih r10, -0x1aa3d
lil r11, 0x1ea18
lih r11, 0x1176b
lil r12, -0x5237
lih r12, 0xa0ed
lil r13, 0x112eb
lih r13, -0x1aa01
lil r14, -0x11eba
lih r14, 0x1d722
lil r15, 0x19547
lih r15, 0x5828
lil r16, 0xff6f
lih r16, 0x1abcf
lil r17, -0x586e
lih r17, -0x9c85
lil r18, 0x28f6
lih r18, 0x190ec
lil r19, 0x13302
lih r19, -0x181fc
lil r20, -0x14a84
lih r20, -0x193ef
lil r21, 0x9d03
lih r21, 0x188a2
lil r22, -0xc2b1
lih r22, -0x1b1b2
lil r23, 0x1513e
lih r23, -0xe1e5
lil r24, 0xc574
lih r24, -0x15e26
lil r25, 0x1837f
lih r25, -0x544d
lil r26, -0xc512
lih r26, -0x9235
lil r27, 0xa17a
lih r27, -0x1dba1
lil r28, -0x147bb
lih r28, -0x10820
lil r29, -0xcca
lih r29, -0x142b3
lil r30, -0xee1
lih r30, 0x1d8ca
lil r31, -0x12ad6
lih r31, -0x1f73c
;; random scalar arithmetic
and  r0, r0, r1
or   r0, r0, r2
or   r2, r2, r1
or   r0, r0, r0
sub  r0, r2, r1
shr  r2, r1, r2
shl  r2, r1, r2
mul  r2, r1, r0
and  r2, r2, r0
and  r1, r2, r1
add  r2, r1, r2
add  r0, r0, r1
shr  r0, r2, r1
or   r0, r2, r2
sub  r2, r0, r1
xor  r0, r0, r0
shl  r1, r2, r2
and  r1, r0, r1
and  r2, r1, r1
not  r1, r1
sub  r0, r2, r2
add  r0, r0, r0
xor  r1, r2, r1
sub  r1, r2, r0
or   r2, r2, r0
not  r1, r0
shl  r1, r0, r0
add  r0, r0, r0
or   r0, r1, r2
and  r2, r2, r2
xor  r2, r2, r0
or   r2, r1, r1
add  r1, r1, r2
shr  r0, r2, r0
shl  r2, r2, r1
add  r1, r2, r0
add  r0, r2, r2
shl  r2, r1, r1
or   r2, r1, r2
add  r2, r1, r1
or   r2, r1, r1
add  r2, r1, r2
mul  r2, r2, r2
or   r2, r2, r0
shr  r2, r2, r2
mul  r2, r1, r2
or   r2, r2, r2
sub  r2, r1, r1
not  r0, r1
not  r0, r0
xor  r0, r1, r0
and  r0, r0, r0
mul  r0, r1, r2
and  r2, r0, r0
shr  r2, r0, r1
xor  r0, r0, r1
mul  r2, r2, r0
sub  r2, r1, r1
mul  r1, r1, r2
xor  r0, r0, r1
and  r2, r2, r2
xor  r2, r2, r1
xor  r2, r0, r1
and  r2, r1, r0
sub  r0, r0, r2
add  r0, r2, r2
shl  r2, r0, r1
shl  r2, r2, r2
shr  r2, r1, r1
or   r1, r2, r1
mul  r1, r1, r2
xor  r0, r1, r2
and  r0, r1, r1
mul  r0, r0, r1
mul  r2, r2, r0
xor  r1, r2, r2
or   r1, r2, r0
sub  r2, r0, r1
xor  r0, r2, r2
and  r1, r2, r0
or   r1, r0, r0
shr  r2, r1, r2
xor  r1, r2, r1
not  r2, r1
or   r0, r1, r1
or   r2, r0, r1
not  r1, r2
sub  r1, r1, r1
mul  r0, r1, r0
and  r1, r2, r0
not  r1, r1
and  r2, r0, r1
sub  r1, r1, r1
and  r1, r0, r1
not  r1, r0
not  r2, r1
mul  r2, r0, r1
shl  r0, r0, r1
shl  r2, r0, r1
shr  r1, r0, r0
