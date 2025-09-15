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

/**
 * \file HIDOTPGenerator.h
 * \brief OTP Generator Base.
 *
 */

/**
 * Represents parameters ruling a cryptographic algorithm.
 */
@protocol HIDAlgorithmParameters

/**
 * Returns The version of the algorithm.
 * \return The version of the algorithm.
 */
-(NSString*) getStandardVersion;

/**
 * Returns The modes supported by the algorithm.
 * \return The modes supported by the algorithm as an array of strings.
 */
-(NSArray*) getModes;

@end

/**
 * \brief A base protocol for OTP generators
 */
@protocol HIDOTPGenerator <NSObject>

/**
 * The name of the generator. TOTP, HOTP, OCRA,...
 * \return The generator name.
 */
- (NSString*) getName;

/**
 * The type of OTP generator.
 * Supported types:
 * <ul>
 * <li>Synchronous (time or event based)</li>
 * <li>Asynchronous (challenge-response)</li>
 * </ul>
 * \return The generator type.
 */
- (NSString*)  getType;

/**
 * The version of OTP generator.
 * \return The generator version.
 */
- (NSString*)  getVersion;

/**
 * Returns The structure containing all of the algorithm parameters for OTP generator.
 * For instance OCRASuite, time-step, counter, length...
 * \return The instance of algorithm parameters.
 */
-(id<HIDAlgorithmParameters>) getAlgorithmParameters;

@end
