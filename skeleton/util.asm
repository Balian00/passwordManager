|; MOD(Ra, Rb, Rc)         Reg[Rc] <- Reg[Ra] % Reg[Rb]        (note: Rc should be a different register than Ra and Rb)
.macro MOD(Ra, Rb, Rc) DIV(Ra, Rb, Rc) MUL(Rc, Rb, Rc) SUB(Ra, Rc, Rc)

|; DOUBLE_ARR_OFFSET(Ra, Rb, Rc)
|; Computes 1D index from 2D array coordinates
.macro DOUBLE_ARR_OFFSET(Ra, Rb, Rc) SHLC(Rb, 8, Rc) ADD(Rc, Ra, Rc)