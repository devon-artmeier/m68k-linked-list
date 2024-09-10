; ------------------------------------------------------------------------------
; List functions
; ----------------------------------------------------------------------
; Copyright (c) 2024 Devon Artmeier
;
; Permission to use, copy, modify, and/or distribute this software
; for any purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIE
; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
; PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER 
; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
; PERFORMANCE OF THIS SOFTWARE.
; ------------------------------------------------------------------------------

	section m68k_rom_fixed
	include	"source/framework/md.inc"
	
; ------------------------------------------------------------------------------
; Initialize list
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - node size (Node header included)
;	d1.w - Number of nodes in pool
;	a0.l - List address
; ------------------------------------------------------------------------------

InitList:
	movem.l	d0-d2/a1,-(sp)					; Save registers
	
	clr.l	list.head(a0)					; Reset head
	clr.l	list.tail(a0)					; Reset tail
	clr.l	list.freed(a0)					; Reset freed nodes tail
	move.w	d0,list.node_size(a0)				; Set node size
	
	mulu.w	d1,d0						; Set end of list
	addi.w	#list.struct_len,d0
	add.l	a0,d0
	move.l	d0,list.end(a0)

	moveq	#list.struct_len,d0				; Reset cursor
	add.w	list.node_size(a0),d0
	add.l	a0,d0
	move.l	d0,list.cursor(a0)

	subq.w	#1,d1						; Node loop count
	lea	list.struct_len(a0),a1				; Node pool
	moveq	#0,d0						; Clear value

.SetupNodes:
	move.l	d0,(a1)+					; Reset links
	move.l	d0,(a1)+
	move.l	d0,(a1)+

	move.w	list.node_size(a0),d2				; Node data loop count
	subi.w	#node.struct_len,d2
	lsr.w	#1,d2
	subq.w	#1,d2

.ClearNode:
	move.w	d0,(a1)+					; Clear node data
	dbf	d2,.ClearNode					; Loop until node data is cleared
	dbf	d1,.SetupNodes					; Loop until all nodes are set up
	
	movem.l	(sp)+,d0-d2/a1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Reset list
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - List address
; ------------------------------------------------------------------------------

ResetList:
	move.l	d0,-(sp)					; Save registers
	
	clr.l	list.head(a0)					; Reset head
	clr.l	list.tail(a0)					; Reset tail
	clr.l	list.freed(a0)					; Reset freed nodes tail
	
	moveq	#list.struct_len,d0				; Reset cursor
	add.w	list.node_size(a0),d0
	add.l	a0,d0
	move.l	d0,list.cursor(a0)

	clr.l	list.struct_len+node.next(a0)			; Reset next and previous links in first node
	clr.l	list.struct_len+node.previous(a0)
	
	move.l	(sp)+,d0					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Add list node
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l  - List address
; RETURNS:
;	eq/ne - Success/Failure
;	a1.l  - Allocated list node
; ------------------------------------------------------------------------------

AddListNode:
	movem.l	d0-d1/a2,-(sp)					; Save registers

	tst.l	list.head(a0)					; Are there any nodes?
	beq.s	.NoNodes					; If not, branch

; ------------------------------------------------------------------------------

	move.l	list.freed(a0),d0				; Were there any nodes that were freed?
	beq.s	.Append						; If not, branch
	
	movea.l	d0,a1						; If so, retrieve node
	move.l	node.next(a1),list.freed(a0)			; Set next free node

; ------------------------------------------------------------------------------

.SetLinks:
	movea.l	list.tail(a0),a2				; Get list tail
	move.l	a1,list.tail(a0)

	move.l	a1,node.next(a2)				; Set links
	move.l	a2,node.previous(a1)
	clr.l	node.next(a1)
	move.l	a0,node.list(a1)
	
; ------------------------------------------------------------------------------

.Finish:
	lea	node.struct_len(a1),a2				; Node data
	move.w	list.node_size(a0),d0				; Clear loop count
	subi.w	#node.struct_len,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	moveq	#0,d1						; Zero

.ClearNode:
	move.w	d1,(a2)+					; Clear node data
	dbf	d0,.ClearNode					; Loop until node data is cleared

	movem.l	(sp)+,d0-d1/a2					; Restore registers
	ori	#4,sr						; Success
	rts

; ------------------------------------------------------------------------------

.Append:
	move.l	list.cursor(a0),d0				; Get cursor
	cmp.l	list.end(a0),d0					; Is there no more room?
	bcc.s	.Fail						; If so, branch

	movea.l	d0,a1
	moveq	#0,d1						; Advance cursor
	move.w	list.node_size(a0),d1
	add.w	d1,d0
	move.l	d0,list.cursor(a0)

	bra.s	.SetLinks					; Set links

; ------------------------------------------------------------------------------

.Fail:
	movem.l	(sp)+,d0-d1/a2					; Restore registers
	andi	#~4,sr						; Failure
	rts

; ------------------------------------------------------------------------------

.NoNodes:
	lea	list.struct_len(a0),a1				; Allocate at start of list node pool
	move.l	a1,list.head(a0)
	move.l	a1,list.tail(a0)
	move.l	a0,node.list(a1)
	bra.s	.Finish

; ------------------------------------------------------------------------------
; Remove list node
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l  - List node
; RETURNS:
;	eq/ne - End of list/Not end of list
;	a1.l  - Next list node
; ------------------------------------------------------------------------------

RemoveListNode:
	movem.l	d0/a0/a2,-(sp)					; Save registers
	
	move.l	node.next(a1),-(sp)				; Get next node
	movea.l	node.list(a1),a0				; Get list
	clr.l	node.list(a1)

	cmpa.l	list.head(a0),a1				; Is this the head node?
	beq.s	.Head						; If not, branch
	cmpa.l	list.tail(a0),a1				; Is this the tail node?
	beq.s	.Tail						; If so, branch

; ------------------------------------------------------------------------------

.Middle:
	movea.l	node.previous(a1),a2				; Fix links
	move.l	node.next(a1),node.next(a2)
	movea.l	node.next(a1),a2
	move.l	node.previous(a1),node.previous(a2)

; ------------------------------------------------------------------------------

.AppendFreed:
	move.l	list.freed(a0),d0				; Get freed list tail
	beq.s	.FirstFreed					; If there are no freed nodes, branch

	move.l	d0,node.next(a1)				; Set links
	move.l	a1,list.freed(a0)
	bra.s	.Finish	

.FirstFreed:
	move.l	a1,list.freed(a0)				; Set first freed node
	clr.l	node.next(a1)

; ------------------------------------------------------------------------------

.Finish:
	movea.l	(sp)+,a1					; Get next node
	movem.l	(sp)+,d0/a0/a2					; Restore registers
	
	cmpa.l	#0,a1						; Check if next node exists
	rts

; ------------------------------------------------------------------------------

.Tail:
	movea.l	node.previous(a1),a2				; Fix links
	move.l	a2,list.tail(a0)
	clr.l	node.next(a2)

	bra.s	.AppendFreed					; Append freed nodes

; ------------------------------------------------------------------------------

.Head:
	cmpa.l	list.tail(a0),a1				; Is this also the tail node?
	beq.s	.Last						; If so, branch

	movea.l	node.next(a1),a2				; Fix links
	move.l	a2,list.head(a0)
	clr.l	node.previous(a2)

	bra.s	.AppendFreed					; Append freed nodes

; ------------------------------------------------------------------------------

.Last:
	bsr.w	ResetList					; Reset list
	clr.l	(sp)
	bra.s	.Finish

; ------------------------------------------------------------------------------
