

'This table is used to play a sound
Dim shared as uint16_t frequenceTable(39) = { _
	&h0CFF, &h0DC3, &h0E91, &h0F6F, &h1056, &h114E, &h1259, &h136C, _
	&h149F, &h15D9, &h1726, &h1888, &h19FD, &h1B86, &h1D21, &h1EDE, _
	&h20AB, &h229C, &h24B3, &h26D7, &h293F, &h2BB2, &h2E4C, &h3110, _
	&h33FB, &h370D, &h3A43, &h3DDF, &h4157, &h4538, &h4998, &h4DAE, _
	&h5240, &h5764, &h5C9A, &h61C8, &h6793, &h6E19, &h7485, &h7BBD _
}


' fuentes vectoriales
Dim Shared as uint8_t _font(767) = { _
	&h00, &h00, &h00, &h00, &h00, &h00, &h00, &h00, &h10, &h10, &h10, &h10, &h10, &h00, &h10, &h00, _
	&h28, &h28, &h00, &h00, &h00, &h00, &h00, &h00, &h00, &h24, &h7E, &h24, &h24, &h7E, &h24, &h00, _
	&h08, &h3E, &h48, &h3C, &h12, &h7C, &h10, &h00, &h42, &hA4, &h48, &h10, &h24, &h4A, &h84, &h00, _
	&h60, &h90, &h90, &h70, &h8A, &h84, &h7A, &h00, &h08, &h08, &h10, &h00, &h00, &h00, &h00, &h00, _
	&h06, &h08, &h10, &h10, &h10, &h08, &h06, &h00, &hC0, &h20, &h10, &h10, &h10, &h20, &hC0, &h00, _
	&h00, &h44, &h28, &h10, &h28, &h44, &h00, &h00, &h00, &h10, &h10, &h7C, &h10, &h10, &h00, &h00, _
	&h00, &h00, &h00, &h00, &h00, &h10, &h10, &h20, &h00, &h00, &h00, &h7C, &h00, &h00, &h00, &h00, _
	&h00, &h00, &h00, &h00, &h10, &h28, &h10, &h00, &h00, &h04, &h08, &h10, &h20, &h40, &h00, &h00, _
	&h78, &h84, &h8C, &h94, &hA4, &hC4, &h78, &h00, &h10, &h30, &h50, &h10, &h10, &h10, &h7C, &h00, _
	&h78, &h84, &h04, &h08, &h30, &h40, &hFC, &h00, &h78, &h84, &h04, &h38, &h04, &h84, &h78, &h00, _
	&h08, &h18, &h28, &h48, &hFC, &h08, &h08, &h00, &hFC, &h80, &hF8, &h04, &h04, &h84, &h78, &h00, _
	&h38, &h40, &h80, &hF8, &h84, &h84, &h78, &h00, &hFC, &h04, &h04, &h08, &h10, &h20, &h40, &h00, _
	&h78, &h84, &h84, &h78, &h84, &h84, &h78, &h00, &h78, &h84, &h84, &h7C, &h04, &h08, &h70, &h00, _
	&h00, &h18, &h18, &h00, &h00, &h18, &h18, &h00, &h00, &h00, &h18, &h18, &h00, &h10, &h10, &h60, _
	&h04, &h08, &h10, &h20, &h10, &h08, &h04, &h00, &h00, &h00, &hFE, &h00, &h00, &hFE, &h00, &h00, _
	&h20, &h10, &h08, &h04, &h08, &h10, &h20, &h00, &h7C, &h82, &h02, &h0C, &h10, &h00, &h10, &h00, _
	&h30, &h18, &h0C, &h0C, &h0C, &h18, &h30, &h00, &h78, &h84, &h84, &hFC, &h84, &h84, &h84, &h00, _
	&hF8, &h84, &h84, &hF8, &h84, &h84, &hF8, &h00, &h78, &h84, &h80, &h80, &h80, &h84, &h78, &h00, _
	&hF8, &h84, &h84, &h84, &h84, &h84, &hF8, &h00, &h7C, &h40, &h40, &h78, &h40, &h40, &h7C, &h00, _
	&hFC, &h80, &h80, &hF0, &h80, &h80, &h80, &h00, &h7C, &h80, &h80, &h8C, &h84, &h84, &h7C, &h00, _
	&h84, &h84, &h84, &hFC, &h84, &h84, &h84, &h00, &h7C, &h10, &h10, &h10, &h10, &h10, &h7C, &h00, _
	&h04, &h04, &h04, &h04, &h84, &h84, &h78, &h00, &h8C, &h90, &hA0, &hE0, &h90, &h88, &h84, &h00, _
	&h80, &h80, &h80, &h80, &h80, &h80, &hFC, &h00, &h82, &hC6, &hAA, &h92, &h82, &h82, &h82, &h00, _
	&h84, &hC4, &hA4, &h94, &h8C, &h84, &h84, &h00, &h78, &h84, &h84, &h84, &h84, &h84, &h78, &h00, _
	&hF8, &h84, &h84, &hF8, &h80, &h80, &h80, &h00, &h78, &h84, &h84, &h84, &h84, &h8C, &h7C, &h03, _
	&hF8, &h84, &h84, &hF8, &h90, &h88, &h84, &h00, &h78, &h84, &h80, &h78, &h04, &h84, &h78, &h00, _
	&h7C, &h10, &h10, &h10, &h10, &h10, &h10, &h00, &h84, &h84, &h84, &h84, &h84, &h84, &h78, &h00, _
	&h84, &h84, &h84, &h84, &h84, &h48, &h30, &h00, &h82, &h82, &h82, &h82, &h92, &hAA, &hC6, &h00, _
	&h82, &h44, &h28, &h10, &h28, &h44, &h82, &h00, &h82, &h44, &h28, &h10, &h10, &h10, &h10, &h00, _
	&hFC, &h04, &h08, &h10, &h20, &h40, &hFC, &h00, &h3C, &h30, &h30, &h30, &h30, &h30, &h3C, &h00, _
	&h3C, &h30, &h30, &h30, &h30, &h30, &h3C, &h00, &h3C, &h30, &h30, &h30, &h30, &h30, &h3C, &h00, _
	&h3C, &h30, &h30, &h30, &h30, &h30, &h3C, &h00, &h00, &h00, &h00, &h00, &h00, &h00, &h00, &hFE, _
	&h3C, &h30, &h30, &h30, &h30, &h30, &h3C, &h00, &h00, &h00, &h38, &h04, &h3C, &h44, &h3C, &h00, _
	&h40, &h40, &h78, &h44, &h44, &h44, &h78, &h00, &h00, &h00, &h3C, &h40, &h40, &h40, &h3C, &h00, _
	&h04, &h04, &h3C, &h44, &h44, &h44, &h3C, &h00, &h00, &h00, &h38, &h44, &h7C, &h40, &h3C, &h00, _
	&h38, &h44, &h40, &h60, &h40, &h40, &h40, &h00, &h00, &h00, &h3C, &h44, &h44, &h3C, &h04, &h78, _
	&h40, &h40, &h58, &h64, &h44, &h44, &h44, &h00, &h10, &h00, &h10, &h10, &h10, &h10, &h10, &h00, _
	&h02, &h00, &h02, &h02, &h02, &h02, &h42, &h3C, &h40, &h40, &h46, &h48, &h70, &h48, &h46, &h00, _
	&h10, &h10, &h10, &h10, &h10, &h10, &h10, &h00, &h00, &h00, &hEC, &h92, &h92, &h92, &h92, &h00, _
	&h00, &h00, &h78, &h44, &h44, &h44, &h44, &h00, &h00, &h00, &h38, &h44, &h44, &h44, &h38, &h00, _
	&h00, &h00, &h78, &h44, &h44, &h78, &h40, &h40, &h00, &h00, &h3C, &h44, &h44, &h3C, &h04, &h04, _
	&h00, &h00, &h4C, &h70, &h40, &h40, &h40, &h00, &h00, &h00, &h3C, &h40, &h38, &h04, &h78, &h00, _
	&h10, &h10, &h3C, &h10, &h10, &h10, &h0C, &h00, &h00, &h00, &h44, &h44, &h44, &h44, &h78, &h00, _
	&h00, &h00, &h44, &h44, &h44, &h28, &h10, &h00, &h00, &h00, &h82, &h82, &h92, &hAA, &hC6, &h00, _
	&h00, &h00, &h44, &h28, &h10, &h28, &h44, &h00, &h00, &h00, &h42, &h22, &h24, &h18, &h08, &h30, _
	&h00, &h00, &h7C, &h08, &h10, &h20, &h7C, &h00, &h60, &h90, &h20, &h40, &hF0, &h00, &h00, &h00, _
	&hFE, &hFE, &hFE, &hFE, &hFE, &hFE, &hFE, &h00, &h38, &h44, &hBA, &hA2, &hBA, &h44, &h38, &h00, _
	&h38, &h44, &h82, &h82, &h44, &h28, &hEE, &h00, &h55, &hAA, &h55, &hAA, &h55, &hAA, &h55, &hAA _
}



textos:
	Data &h001, "P E A N U T  3000"
	Data &h002, "Copyright  } 1990 Peanut Computer, Inc.\nAll rights reserved.\n\nCDOS Version 5.01"
	Data &h003, "2" 
	Data &h004, "3" 
	Data &h005, "." 
	Data &h006, "A" 
	Data &h007, "@" 
	Data &h008, "PEANUT 3000" 
	Data &h00A, "R" 
	Data &h00B, "U" 
	Data &h00C, "N" 
	Data &h00D, "P" 
	Data &h00E, "R" 
	Data &h00F, "O" 
	Data &h010, "J" 
	Data &h011, "E" 
	Data &h012, "C" 
	Data &h013, "T" 
	Data &h014, "Shield 9A.5f Ok" 
	Data &h015, "Flux % 5.0177 Ok" 
	Data &h016, "CDI Vector ok" 
	Data &h017, " %%%ddd ok" 
	Data &h018, "Race-Track ok" 
	Data &h019, "SYNCHROTRON" 
	Data &h01A, "E: 23%\ng: .005\n\nRK: 77.2L\n\nopt: g+\n\n Shield:\n1: OFF\n2: ON\n3: ON\n\nP~: 1\n" 
	Data &h01B, "ON" 
	Data &h01C, "-" 
	Data &h021, "|" 
	Data &h022, "--- Theoretical study ---" 
	Data &h023, " THE EXPERIMENT WILL BEGIN IN    SECONDS" 
	Data &h024, "  20" 
	Data &h025, "  19" 
	Data &h026, "  18" 
	Data &h027, "  4" 
	Data &h028, "  3" 
	Data &h029, "  2" 
	Data &h02A, "  1" 
	Data &h02B, "  0" 
	Data &h02C, "L E T ' S   G O" 
	Data &h031, "- Phase 0:\nINJECTION of particles\ninto synchrotron" 
	Data &h032, "- Phase 1:\nParticle ACCELERATION." 
	Data &h033, "- Phase 2:\nEJECTION of particles\non the shield." 
	Data &h034, "A  N  A  L  Y  S  I  S" 
	Data &h035, "- RESULT:\nProbability of creating:\n ANTIMATTER: 91.V %\n NEUTRINO 27:  0.04 %\n NEUTRINO 424: 18 %\n" 
	Data &h036, "   Practical verification Y/N ?" 
	Data &h037, "SURE ?" 
	Data &h038, "MODIFICATION OF PARAMETERS\nRELATING TO PARTICLE\nACCELERATOR (SYNCHROTRON)." 
	Data &h039, "       RUN EXPERIMENT ?" 
	Data &h03C, "t---t" 
	Data &h03D, "000 ~" 
	Data &h03E, ".2&h14dd" 
	Data &h03F, "gj5r5r" 
	Data &h040, "tilgor 25%" 
	Data &h041, "12% 33% checked" 
	Data &h042, "D=4.2158005584" 
	Data &h043, "d=10.00001" 
	Data &h044, "+" 
	Data &h045, "*" 
	Data &h046, "% 304" 
	Data &h047, "gurgle 21" 
	Data &h048, "DataDataDataData" 
	Data &h049, "Delphine Software" 
	Data &h04A, "By Eric Chahi" 
	Data &h04B, "  5" 
	Data &h04C, "  17" 
	Data &h12C, "0" 
	Data &h12D, "1" 
	Data &h12E, "2" 
	Data &h12F, "3" 
	Data &h130, "4" 
	Data &h131, "5" 
	Data &h132, "6" 
	Data &h133, "7" 
	Data &h134, "8" 
	Data &h135, "9" 
	Data &h136, "A" 
	Data &h137, "B" 
	Data &h138, "C" 
	Data &h139, "D" 
	Data &h13A, "E" 
	Data &h13B, "F" 
	Data &h13C, "        ACCESS CODE:" 
	Data &h13D, "PRESS BUTTON OR RETURN TO CONTINUE" 
	Data &h13E, "   ENTER ACCESS CODE" 
	Data &h13F, "   INVALID PASSWORD !" 
	Data &h140, "ANNULER" 
	Data &h141, "      INSERT DISK ?\n\n\n\n\n\n\n\n\nPRESS ANY KEY TO CONTINUE" 
	Data &h142, " SELECT SYMBOLS CORRESPONDING TO\n THE POSITION\n ON THE CODE WHEEL" 
	Data &h143, "    LOADING..." 
	Data &h144, "              ERROR" 
	Data &h15E, "LDKD" 
	Data &h15F, "HTDC" 
	Data &h160, "CLLD" 
	Data &h161, "FXLC" 
	Data &h162, "KRFK" 
	Data &h163, "XDDJ" 
	Data &h164, "LBKG" 
	Data &h165, "KLFB" 
	Data &h166, "TTCT" 
	Data &h167, "DDRX" 
	Data &h168, "TBHK" 
	Data &h169, "BRTD" 
	Data &h16A, "CKJL" 
	Data &h16B, "LFCK" 
	Data &h16C, "BFLX" 
	Data &h16D, "XJRT" 
	Data &h16E, "HRTB" 
	Data &h16F, "HBHK" 
	Data &h170, "JCGB" 
	Data &h171, "HHFL" 
	Data &h172, "TFBB" 
	Data &h173, "TXHF" 
	Data &h174, "JHJL" 
	Data &h181, " BY" 
	Data &h182, "ERIC CHAHI" 
	Data &h183, "         MUSIC AND SOUND EFFECTS" 
	Data &h184, " " 
	Data &h185, "JEAN-FRANCOIS FREITAS" 
	Data &h186, "IBM PC VERSION" 
	Data &h187, "      BY" 
	Data &h188, " DANIEL MORAIS" 
	Data &h18B, "       THEN PRESS FIRE" 
	Data &h18C, " PUT THE PADDLE ON THE UPPER LEFT CORNER" 
	Data &h18D, "PUT THE PADDLE IN CENTRAL POSITION" 
	Data &h18E, "PUT THE PADDLE ON THE LOWER RIGHT CORNER" 
	Data &h258, "      Designed by ..... Eric Chahi" 
	Data &h259, "    Programmed by...... Eric Chahi" 
	Data &h25A, "      Artwork ......... Eric Chahi" 
	Data &h25B, "Music by ........ Jean-francois Freitas" 
	Data &h25C, "            Sound effects" 
	Data &h25D, "        Jean-Francois Freitas\n             Eric Chahi" 
	Data &h263, "              Thanks To" 
	Data &h264, "           Jesus Martinez\n\n          Daniel Morais\n\n        Frederic Savoir\n\n      Cecile Chahi\n\n    Philippe Delamarre\n\n  Philippe Ulrich\n\nSebastien Berthet\n\nPierre Gousseau" 
	Data &h265, "Now Go Out Of This World" 
	Data &h190, "Good evening professor." 
	Data &h191, "I see you have driven here in your\nFerrari." 
	Data &h192, "IDENTIFICATION" 
	Data &h193, "Monsieur est en parfaite sante." 
	Data &h194, "Y\n" 
	Data &h193, "AU BOULOT !!!\n" 
	Data END_OF_STRING_DICTIONARY, "" 

