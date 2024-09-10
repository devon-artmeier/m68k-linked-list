; ------------------------------------------------------------------------------
; List functions header
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

list.head		equ 0					; List head
list.tail		equ 4					; List tail
list.freed		equ 8					; Freed nodes tail
list.node_size		equ $C					; Size of node
list.cursor		equ $E					; List cursor
list.end		equ $12					; End of list
list.struct_len		equ $16					; Length of structure

; ------------------------------------------------------------------------------
; List node header structure
; ------------------------------------------------------------------------------

node.next		equ 0					; Next node
node.previous		equ 4					; Previous node
node.list		equ 8					; List the node is part of
node.struct_len		equ $C					; Length of structure

; ------------------------------------------------------------------------------
