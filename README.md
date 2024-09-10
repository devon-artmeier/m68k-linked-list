# Simple Doubly Linked Lists for the Motorola 68000

Title says it all: this implements a basic doubly linked list system for the Motorola 68000.

## How To Use

Each list must be prefixed with a header structure. Simply allocate **list.struct_len** number of bytes at the beginning of the list's memory space. Immediately after that will be the node pool, which should be allocated with **\[NODE SIZE (HEADER INCLUDED)\] \* \[NUMBER OF NODES\]** bytes.

Each node in a list must be the same size as each other, and must also be prefixed with its own header. When defining a node structure, allocate **node.struct_len** number of bytes at the start before defining the rest of the node.

To initialize a list, call the following:

        move.w  #[NODE SIZE (HEADER INCLUDED)],d0
        move.w  #[NUMBER OF NODES],d1
        lea     [LIST ADDRESS],a0
        jsr     InitList

You can reset a list by calling **ResetList**.

To add a node to a list, call the following:

        lea     [LIST_ADDRESS],a0
        jsr     AddListNode

And then, if successful, the zero flag will be set, the new node's address will be stored in register **a1**, and the new node's data area will be wiped clean. If it failed, the zero flag will be cleared and register a1 will be undefined.

To remove a node from a list, call the following:

        lea     [NODE ADDRESS],a1
        jsr     RemoveListNode

If it was the last node in the list, then the zero flag will be set, and register **a1** will be 0. Otherwise, the zero flag will be cleared and register **a1** will contain the address to the node that was linked next in the removed node.

## What's the Difference Between "Lists" and "Word Lists"?

Regular lists use longwords to hold addresses. If you know that your list is going to be allocated in an area of memory that can be addressed as a word, then word lists are recommended to both save some memory space and utilize slightly faster code to managing it.

To use word lists, use the **wlist** and **wnode** prefixes when allocating memory and defining node structures, and also use the **InitWordList**, **ResetWordList**, **AddWordListNode**, and **RemoveWordListNode** functions.
