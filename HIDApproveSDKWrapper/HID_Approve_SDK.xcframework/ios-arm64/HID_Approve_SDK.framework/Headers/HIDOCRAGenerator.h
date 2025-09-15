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
#import "HIDAsyncOTPGenerator.h"
#import "HIDOTPGenerator.h"
#import "HIDTOTPGenerator.h"

/**
 * \file HIDOCRAGenerator.h
 * \brief OCRA Asynchronous OTP Generator.
 *
 */

/**
 * \brief Represents the OCRA suite and associated runtime parameters.
 */
@protocol HIDOCRASuite
/**
 * Get HMAC Function used.
 * \return HMAC function (HMAC-SHA1, HMAC-SHA256, HMAC-SHA512)
 */
-(NSString*) getCryptoFunction;
/**
 * Get truncation size.
 * \return size of the truncation (0 no truncation).
 */
-(int)getCodeDigits;
/**
 * Get information whether OCRA suite includes counter in calculation.
 * \return bool.
 */
-(BOOL)hasCounter;
/**
 * Get information whether OCRA Suite include timestamp in its calculation
 * \return bool
 */
-(BOOL)hasTime;
/**
 * Get timestep value.
 * \return the timestep value or 0 if no timestep used in its calculation.
 */
-(uint64_t)getTimeStep;
/**
 * Get minimum challenge value, default value 0
 * \return Returns length.
 */
-(int)getMinChallengeLength;
/**
 * Get maximum challenge length.
 * \return Returns length.
 */
-(int)getMaxChallengeLength;
/**
 * Get challenge format.
 * \return format (numeric, hexadecimal, alphanumeric).
 */
-(NSString*)getChallengeFormat;
/**
 * Get information whether OCRA Suite requires PIN as input. See setPIN method of the HIDInputOCRAParameters.
 * \return the timestep value or 0 if no timestep used in its calculation.
 */
-(BOOL)isPinRequired;
/**
 * Get hash algorithm for the PIN.
 * \return PIN or NULL if not required.
 */
-(NSString*)getPINHashAlgo;
/**
 * Get information whether OCRA Suite requires session information as input. See setSession method of the HIDInputOCRAParameters.
 * \return PIN or NULL if not required.
 */
-(BOOL)isSessionRequired;
/**
 * Get session length.
 * \return length.
 */
-(int)getSessionLength;
/**
 * Get the full OCRA Suite.
 * \return Ocra Suite.
 */
-(NSString*)toString;
@end

/**
 * \brief Defines the OCRA algorithm parameters.
 */
@protocol HIDOCRAAlgorithmParameters <HIDAlgorithmParameters>
/**
 * Get client OCRASuite.
 * \return OCRASuite.
 */
-(id<HIDOCRASuite>)getClientOCRASuite;
/**
 * Get server OCRASuite.
 * \return Returns OCRASuite string.
 */
-(id<HIDOCRASuite>)getServerOCRASuite;
@end


/**
 * \brief Defines the OCRA algorithm parameters.
 */
@interface HIDOCRAInputAlgorithmParameters : HIDOTPInputAlgorithmParameters
{
@private
    NSString* _pin;
    NSString* _sessionInfo;
}

/**
 * init
 */
-(id)init:(NSString*)pin sessionInfo:(NSString*)session;

/**
 * Pass PIN value to be used for compute response.
 * \param pin PIN value to be used.
 */
-(void)setPin:(NSString*)pin;

/**
 * Get PIN value to be used for compute response.
 * \return PIN value to be used.
 */
-(NSString*)getPin;

/**
 * Pass SessionInfo value to be used for compute response.
 * \param sessionInfo value to be used.
 */
-(void)setSession:(NSString*)sessionInfo;

/**
 * Get SessionInfo value to be used for compute response.
 * \return SessionInfo value to be used.
 */
-(NSString*)getSession;

@end

@protocol HIDOCRAGenerator <HIDAsyncOTPGenerator>

@end


