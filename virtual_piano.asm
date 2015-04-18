; Concerns:
; - those crazy 'switch' statements
; - register use


; To work on:
; - stop user from going too low or too high; it breaks the program
;===============================================================================
; Virtual Piano -- a virtual and playable piano
; By SirPython of Code Review and GitHub
;
; virtual_piano.asm
;===============================================================================

%define ESC 1Bh

%define MIDI_CONTROL_PORT 0331h
%define MIDI_DATA_PORT 0330h
%define MIDI_UART_MODE 3Fh
%define MIDI_PIANO_INSTRUMENT 93h

start:
	call setup_midi
	mov ch, 60;				default octave(0)

.loop:
	call read_character
	call process_input

	cmp bh, 0;				if bad input
	je .loop

	call get_pitch

	cmp bh, 2;				if shouldn't play note (was an octave switch)
	je .loop

	call play_note
	
	jmp .loop
;--------------------------------------------------
; Plays a note
;
; IN: AL, CH = pitch, (octave * 12) + 60
; OUT: NONE
; ERR: NONE
; REG: AL

play_note:
	add al, ch;				apply the octave
	out dx, al;				DX will already contain MIDI_DATA_PORT from the setup_midi function

	mov al, 7Fh;			note duration
	out dx, al

	ret

;--------------------------------------------------
; Based on input, returns a pitch to be played
;
; IN: AH, AL = scan code, key code
; OUT: AL, CH = pitch OR 0 if no pitch, (octave * 12) + 60
; ERR: BH = 2, no pitch to be played
; REG: preserved

get_pitch:
	cmp al, 'a'
	je .a
	cmp al, 's'
	je .s
	cmp al, 'd'
	je .d
	cmp al, 'f'
	je .f
	cmp al, 'j'
	je .j
	cmp al, 'k'
	je .k
	cmp al, 'l'
	je .l
	cmp al, ';'
	je .sc

	cmp al, 'w'
	je .w
	cmp al, 'e'
	je .e
	cmp al, 'r'
	je .r
	cmp al, 't'
	je .t
	cmp al, 'i'
	je .i
	cmp al, 'o'
	je .o
	cmp al, 'p'
	je .p

	cmp al, 'z'
	je .z
	cmp al, 'x'
	je .x

.a: mov al, 0
	jmp .end
.s: mov al, 2
	jmp .end
.d: mov al, 4
	jmp .end
.f: mov al, 5
	jmp .end
.j: mov al, 7
	jmp .end
.k: mov al, 9
	jmp .end
.l: mov al, 11
	jmp .end
.sc: mov al, 12
	jmp .end

.w: mov al, 1
	jmp .end
.e: mov al, 3
	jmp .end
.r: jmp .f
	jmp .end
.t: mov al, 6
	jmp .end
.i: mov al, 8
	jmp .end
.o: mov al, 10
	jmp .end
.p: jmp .l
	jmp .end

.z: add ch, 12
	mov bh, 2
	jmp .end
.x: sub ch, 12
	mov bh, 2
	jmp .end


.end:
	ret

;--------------------------------------------------
; Set's up the MIDI ports for use
;
; IN: NONE
; OUT: NONE
; ERR: NONE
; REG: DX

setup_midi:
	push ax

	mov dx, MIDI_CONTROL_PORT
	mov al, MIDI_UART_MODE;	play notes as soon as they are recieved
	out dx, al

	mov dx, MIDI_DATA_PORT
	mov al, MIDI_PIANO_INSTRUMENT
	out dx, al

	pop ax
	ret

;--------------------------------------------------
; Checks to make sure that input is acceptable
;
; IN: AH, AL = scan code, key code
; OUT: BH = 1 (accpetable) or 0 (not acceptable)
; ERR: NONE
; REG: preserved

process_input:

.check_key_code:
	cmp al, 'a'
	je .safe
	cmp al, 's'
	je .safe
	cmp al, 'd'
	je .safe
	cmp al, 'f'
	je .safe
	cmp al, 'j'
	je .safe
	cmp al, 'k'
	je .safe
	cmp al, 'l'
	je .safe
	cmp al, ';'
	je .safe

	cmp al, 'w'
	je .safe
	cmp al, 'e'
	je .safe
	cmp al, 'r'
	je .safe
	cmp al, 't'
	je .safe
	cmp al, 'i'
	je .safe
	cmp al, 'o'
	je .safe
	cmp al, 'p'
	je .safe

.check_octave_code:
	cmp al, 'z'
	je .safe
	cmp al, 'x'
	je .safe

.is_exit:
	cmp al, ESC
	call exit

.err:
	xor bh, bh
	ret

.safe:
	mov bh, 1

;--------------------------------------------------
; Stops execution of the program
;
; IN: NONE
; OUT: NONE
; ERR: NONE
; REG: NONE

exit:
	hlt
	ret

;--------------------------------------------------
; Reads a single character from the user
;
; IN: NONE
; OUT: AH, AL = scan code, key code
; ERR: NONE
; REG: preserved

read_character:
	xor ah, ah
	int 16h;				BIOS 16h 00h
	ret
