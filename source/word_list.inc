; ------------------------------------------------------------------------------
; Word list functions header
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
; List header structure
; ------------------------------------------------------------------------------

wlist.head		equ 0					; List head
wlist.tail		equ 2					; List tail
wlist.freed		equ 4					; Freed nodes tail
wlist.node_size		equ 6					; Size of node
wlist.cursor		equ 8					; List cursor
wlist.end		equ $A					; End of list
wlist.struct_len	equ $C					; Length of structure

; ------------------------------------------------------------------------------
; List node header structure
; ------------------------------------------------------------------------------

wnode.next		equ 0					; Next node
wnode.previous		equ 2					; Previous node
wnode.list		equ 4					; List the node is part of
wnode.struct_len	equ 6					; Length of structure

; ------------------------------------------------------------------------------
