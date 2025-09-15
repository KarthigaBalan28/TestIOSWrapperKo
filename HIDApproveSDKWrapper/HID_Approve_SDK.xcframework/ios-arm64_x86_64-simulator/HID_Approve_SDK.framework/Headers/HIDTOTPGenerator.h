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
#import "HIDHOTPGenerator.h"

/**
 * \file HIDTOTPGenerator.h
 * \brief TOTP Synchronous OTP Generator.
 *
 */

/**
 * Represents parameters ruling a TOTP algorithm (RFC 6238).
 */
@protocol HIDTOTPAlgorithmParameters <HIDHOTPAlgorithmParameters>
    /**
     * Return the clock used for the calculation (seconds)
     * @return Returns number of seconds as "Unix time". (i.e., the number of seconds elapsed since
     * midnight UTC of January 1, 1970).
     */
    -(uint64_t)getClock;
    
    /**
     * Return the timestep used for calculation.
     * @return Returns TimeStep as number of seconds.
     */
    -(uint64_t)getTimeStep;
    
    /**
     * Return the start time used for clock synchronization.
     * @return Returns Start Time as number of seconds.
     */	
    -(uint64_t)getStartTime;
@end
