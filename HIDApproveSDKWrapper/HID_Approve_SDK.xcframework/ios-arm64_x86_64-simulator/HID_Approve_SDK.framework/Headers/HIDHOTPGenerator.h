/* ---------------------------------------------------------------------------
 (c) 2015-2025, HID Global Corporation, part of ASSA ABLOY.
 All rights reserved.
          
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 - Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------- */

#import <Foundation/Foundation.h>
#import "HIDOTPGenerator.h"

/**
 * \file HIDHOTPGenerator.h
 * \brief HOTP Synchronous OTP Generator.
 *
 */

/**
 * Represents parameters ruling a HOTP algorithm (RFC 4226).
 */
@protocol HIDHOTPAlgorithmParameters <HIDAlgorithmParameters>
    /**
     * Get Counter (Moving Factor) for calculation.
     * @return Returns counter.
     */
    -(uint64_t)getCounter;
    
    /**
     * Get Number of truncated digits (excluding the checksum digit).
     * @return Returns Code Digits.
     */
    -(int)getCodeDigits;
    
    /**
     * Determines if a checksum digit is added to the calculation.
     * @return Returns TRUE if checksum is requested.
     */
    -(BOOL)isCheckSum;
    
    /**
     * Offset used for truncation. Expected range is 0 - HashLength-5 (0-15 for HMAC-SHA-1), otherwise dynamic truncation is applied.
     * @return Return offset byte.
     */
    -(int)getTruncationOffset;
    
    /**
     * Message authentication code (MAC) Algorithm requested.
     * @return Return friendly name for MAC Algorithm.
     */
    -(NSString*)getMACAlgo;
@end
