% Copyright 2014, General Dynamics C4 Systems
%
% This software may be distributed and modified according to the terms of
% the GNU General Public License version 2. Note that NO WARRANTY is provided.
% See "LICENSE_GPLv2.txt" for details.
%
% @TAG(GD_GPL)
%

This module contains x64-specific TCB management functions. Specifically, these functions are used by the "CopyRegisters" operation to transfer x64-specific subsets of the register set.

There are presently no x64-specific register subsets defined, but in future this may be extended to transfer floating point registers and other coprocessor state.

%FIXME: add x64 floating point registers + any extra state

> module SEL4.Object.TCB.X64 where

\begin{impdetails}

> import SEL4.Machine(PPtr)
> import SEL4.Model
> import SEL4.Object.Structures
> import SEL4.API.Failures
> import SEL4.API.Invocation.X64
> import SEL4.Machine.RegisterSet(UserMonad, VPtr(..))
> import SEL4.Machine.RegisterSet.X64
> import Data.Bits

> import Data.Word(Word8)

\end{impdetails}

> decodeTransfer :: Word8 -> KernelF SyscallError CopyRegisterSets
> decodeTransfer _ = return X64NoExtraRegisters

> performTransfer :: CopyRegisterSets -> PPtr TCB -> PPtr TCB -> Kernel ()
> performTransfer _ _ _ = return ()

> sanitiseOrFlags :: Word
> sanitiseOrFlags = bit 1 .|. bit 9

> sanitiseAndFlags :: Word
> sanitiseAndFlags = (bit 12 - 1) .&. (complement (bit 3)) .&. (complement (bit 5)) .&. (complement (bit 8)) -- should be 0x111011010111

> -- FIXME x64: implement from abstract
> sanitiseRegister :: Bool -> Register -> Word -> Word
> sanitiseRegister _ r v =
>     let val = if r == FaultIP || r == NextIP then
>                  if v > 0x00007fffffffffff && v < 0xffff800000000000 then 0 else v
>               else v;
>         val' = if r == TLS_BASE then if val > 0x00007fffffffffff then 0x00007fffffffffff else val else val
>     in
>         if r == FLAGS then
>             (val' .|. sanitiseOrFlags) .&. sanitiseAndFlags
>         else val'

> getSanitiseRegisterInfo :: PPtr TCB -> Kernel Bool
> getSanitiseRegisterInfo _ = return False

> setTCBIPCBuffer :: VPtr -> UserMonad ()
> setTCBIPCBuffer ptr = return ()


