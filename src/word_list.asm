; ------------------------------------------------------------------------------
; Word list functions
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

; ------------------------------------------------------------------------------
; Initialize word list
; ------------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Node size (node header included)
;	d1.w - Number of nodes in pool
;	a0.l - List address
; ------------------------------------------------------------------------------

InitWordList:
	movem.l	d0-d2/a1,-(sp)					; Save registers
	
	clr.l	wlist.head(a0)					; Reset head and tail
	clr.w	wlist.freed(a0)					; Reset freed nodes tail
	move.w	d0,wlist.node_size(a0)				; Set node size
	
	mulu.w	d1,d0						; Set end of list
	addi.w	#wlist.struct_len,d0
	add.w	a0,d0
	move.w	d0,wlist.end(a0)

	moveq	#wlist.struct_len,d0				; Reset cursor
	add.w	wlist.node_size(a0),d0
	add.w	a0,d0
	move.w	d0,wlist.cursor(a0)

	subq.w	#1,d1						; Node loop count
	lea	wlist.struct_len(a0),a1				; Node pool
	moveq	#0,d0						; Clear value

.SetupNodes:
	move.l	d0,(a1)+					; Reset links
	move.w	d0,(a1)+

	move.w	wlist.node_size(a0),d2				; Node data loop count
	subq.w	#wnode.struct_len,d2
	lsr.w	#1,d2
	subq.w	#1,d2

.ClearNode:
	move.w	d0,(a1)+					; Clear node data
	dbf	d2,.ClearNode					; Loop until node data is cleared
	dbf	d1,.SetupNodes					; Loop until all nodes are set up
	
	movem.l	(sp)+,d0-d2/a1					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Reset word list
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Word list address
; ------------------------------------------------------------------------------

ResetWordList:
	move.l	d0,-(sp)					; Save registers
	
	clr.l	wlist.head(a0)					; Reset list
	clr.w	wlist.freed(a0)					; Reset freed node tail
	
	moveq	#wlist.struct_len,d0				; Reset cursor
	add.w	wlist.node_size(a0),d0
	add.w	a0,d0
	move.w	d0,wlist.cursor(a0)

	clr.l	wlist.struct_len+wnode.next(a0)			; Reset next and previous links in first node
	
	move.l	(sp)+,d0					; Restore registers
	rts

; ------------------------------------------------------------------------------
; Add word list node
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a0.l  - Word list address
; RETURNS:
;	eq/ne - Success/Failure
;	a1.l  - Allocated word list node
; ------------------------------------------------------------------------------

AddWordListNode:
	movem.l	d0-d1/a2,-(sp)					; Save registers
	
	tst.w	wlist.head(a0)					; Are there any nodes?
	beq.s	.NoNodes					; If not, branch

; ------------------------------------------------------------------------------

	move.w	wlist.freed(a0),d0				; Were there any nodes that were freed?
	beq.s	.Append						; If not, branch
	
	movea.w	d0,a1						; If so, retrieve node
	move.w	wnode.next(a1),wlist.freed(a0)			; Set next free node

; ------------------------------------------------------------------------------

.SetLinks:
	movea.w	wlist.tail(a0),a2				; Get list tail
	move.w	a1,wlist.tail(a0)

	move.w	a1,wnode.next(a2)				; Set links
	move.w	a2,wnode.previous(a1)
	clr.w	wnode.next(a1)
	move.w	a0,wnode.list(a1)
	
; ------------------------------------------------------------------------------

.Finish:
	lea	wnode.struct_len(a1),a2				; Node data
	move.w	wlist.node_size(a0),d0				; Clear loop count
	subq.w	#wnode.struct_len,d0
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
	move.w	wlist.cursor(a0),d0				; Get cursor
	cmp.w	wlist.end(a0),d0					; Is there no more room?
	bcc.s	.Fail						; If so, branch

	movea.w	d0,a1
	add.w	wlist.node_size(a0),d0				; Advance cursor
	move.w	d0,wlist.cursor(a0)

	bra.s	.SetLinks					; Set links

; ------------------------------------------------------------------------------

.Fail:
	movem.l	(sp)+,d0-d1/a2					; Restore registers
	andi	#~4,sr						; Failure
	rts

; ------------------------------------------------------------------------------

.NoNodes:
	lea	wlist.struct_len(a0),a1				; Allocate at start of list node pool
	move.w	a1,wlist.head(a0)
	move.w	a1,wlist.tail(a0)
	move.w	a0,wnode.list(a1)
	bra.s	.Finish
	
; ------------------------------------------------------------------------------
; Remove word list node
; ------------------------------------------------------------------------------
; PARAMETERS:
;	a1.l  - Word list node
; RETURNS:
;	eq/ne - End of word list/Not end of word list
;	a1.l  - Next word list node
; ------------------------------------------------------------------------------

RemoveWordListNode:
	movem.l	d0/a0/a2,-(sp)					; Save registers
	
	move.w	wnode.next(a1),-(sp)				; Get next node
	movea.w	wnode.list(a1),a0				; Get list
	clr.w	wnode.list(a1)

	cmpa.w	wlist.head(a0),a1				; Is this the head node?
	beq.s	.Head						; If not, branch
	cmpa.w	wlist.tail(a0),a1				; Is this the tail node?
	beq.s	.Tail						; If so, branch

; ------------------------------------------------------------------------------

.Middle:
	movea.w	wnode.previous(a1),a2				; Fix links
	move.w	wnode.next(a1),wnode.next(a2)
	movea.w	wnode.next(a1),a2
	move.w	wnode.previous(a1),wnode.previous(a2)

; ------------------------------------------------------------------------------

.AppendFreed:
	move.w	wlist.freed(a0),d0				; Get freed list tail
	beq.s	.FirstFreed					; If there are no freed nodes, branch

	move.w	d0,wnode.next(a1)				; Set links
	move.w	a1,wlist.freed(a0)
	bra.s	.Finish	

.FirstFreed:
	move.w	a1,wlist.freed(a0)				; Set first freed node
	clr.w	wnode.next(a1)

; ------------------------------------------------------------------------------

.Finish:
	movem.l	(sp)+,d0/a0/a2					; Restore registers
	movea.w	(sp)+,a1					; Get next node
	
	cmpa.w	#0,a1						; Check if next node exists
	rts

; ------------------------------------------------------------------------------

.Tail:
	movea.w	wnode.previous(a1),a2				; Fix links
	move.w	a2,wlist.tail(a0)
	clr.w	wnode.next(a2)

	bra.s	.AppendFreed					; Append freed nodes

; ------------------------------------------------------------------------------

.Head:
	cmpa.w	wlist.tail(a0),a1				; Is this also the tail node?
	beq.s	.Last						; If so, branch

	movea.w	wnode.next(a1),a2				; Fix links
	move.w	a2,wlist.head(a0)
	clr.w	wnode.previous(a2)

	bra.s	.AppendFreed					; Append freed nodes

; ------------------------------------------------------------------------------

.Last:
	bsr.w	ResetList					; Reset list
	clr.w	(sp)
	bra.s	.Finish

; ------------------------------------------------------------------------------
