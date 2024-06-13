# UART-Extension
This is a SPI slave module, configurable by a 16 bits long bus. There are 3 UARTs as output.
### Input databus:
  - Bit 13 to 15: choose UART (0x0 for UART0, 0x1 for UART1, 0x2 for UART2).
  - Bit 9 to 12: choose function.
  - Bit 8: Read or write bit.
  - Bit 0 to 7: Data register.
  - 
### Functions:
  - 0x0 = Acces to FIFO TX.
  - 0x1 = Accès to FIFO RX.
  - 0x2 = Accès to UART's baudrate.
  - 0x3 = Configuration (DTR, CTS, RTS).
  - 0x4 = Current fill level of FIFO TX.
  - 0x5 = Current fill level of FIFO RX.



Device used: MachXO3LF-9400C.
Software used: Lattice Diamond.
