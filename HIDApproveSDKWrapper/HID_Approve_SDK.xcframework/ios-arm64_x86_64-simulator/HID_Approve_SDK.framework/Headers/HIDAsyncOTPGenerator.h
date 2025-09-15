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

#import "HIDOTPGenerator.h"
#import <Foundation/Foundation.h>

/**
 * \file HIDAsyncOTPGenerator.h
 * \brief Asynchronous OTP Generator.
 *
 */

/**
 * \brief Base class for algorithm parameters provided by the API consumer.
 */
@interface HIDOTPInputAlgorithmParameters: NSObject


@end

/**
 * \brief Extends the OTP generator to support asynchronous challenge-response generation. (OCRA)
 * Computes OTP using externally provided challenge or transaction data.
 */
@protocol HIDAsyncOTPGenerator <HIDOTPGenerator>

/**
 * The type of OTP generator.
 * \return The Asynchronous generator type (challenge-response).
 */
-(NSString*)getType;

/**
 * Returns a challenge according to format specified in OCRA suit for one-way use cases (challenge-response and signature).
 * This method can be used by the client to provide the challenge to other parties (typically a server) so that it can authenticate the server using the asynchronous method.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return Formatted challenge.
 */
-(NSString*)getChallenge:(NSError**)error;

/**
 * Compute the response for one-way challenge-response. The params allows you to pass additional data to compute the OTP.
 * If there are no optional parameters, input can be omitted.
 * \param password OTP key password (if protected by password).
 * \param challenge The challenge for the mutual authentication.
 * \param input InputParameters (session info and PIN) as required by OCRASuite.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDPasswordRequired if required password was not provided.</li>
 * </ul>
 * </p>
 * \return Formatted response for challenge.
 */
-(NSString*)computeResponse:(NSString*)password  withChallenge:(NSString*)challenge withInputParams:(HIDOTPInputAlgorithmParameters*)input error:(NSError**)error;

/**
 * Compute the signature for one-way or two-way signature. For one-way signature, clientChallenge is empty.
 * If there are no optional parameters, input can be omitted.
 * \param password OTP key password (if protected by the password).
 * \param sigChallenge The challenge for the signature.
 * \param clientChallenge The challenge for client.
 * \param input InputParameters (session info and PIN) as required by OCRASuite.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return Formatted response for challenge.
 */
-(NSString*)computeSignature:(NSString*)password  withSigChallenge:(NSString*)sigChallenge withClientChallenge:(NSString*)clientChallenge  withInputParams:(HIDOTPInputAlgorithmParameters*)input error:(NSError**)error;
/**
 * Compute the client response for one-way challenge-response with optional parameters.
 * If there are no optional parameters, input can be omitted.
 * \param password OTP key password (if protected by password).
 * \param clientChallenge The challenge for a client.
 * \param serverChallenge The challenge for a server.
 * \param input InputParameters (session info and PIN) as required by OCRASuite.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return Formatted response for the challenge.
 */
-(NSString*)computeClientResponse:(NSString*)password withClientChallenge:(NSString*)clientChallenge withServerChallenge:(NSString*)serverChallenge withInputParams:(HIDOTPInputAlgorithmParameters*)input error:(NSError**)error;

/**
 * Compute the server response for one-way challenge-response or for two-way signature.
 * If there are no optional parameters, input can be omitted.
 * \param password OTP key password (if protected by password).
 * \param clientChallenge The challenge for client.
 * \param serverChallenge The challenge for server.
 * \param input InputParameters (session info and PIN) as required by OCRASuite.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return The formatted response for challenge.
 */
-(NSString*)computeServerResponse:(NSString*)password withClientChallenge:(NSString*)clientChallenge withServerChallenge:(NSString*)serverChallenge withInputParams:(HIDOTPInputAlgorithmParameters*)input error:(NSError**)error;

/**
 * For transaction signing use cases, this method permits a challenge to be formatted according to standard based on several input provided by the user. Typically for OCRA see Appendix A of the Certificate profile.
 * \param inputData An array of input data provided by the user. Returns the fully formatted challenge to use in computeResponse method.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return Formatted challenge.
*/
-(NSString*) formatSignatureChallenge:(NSArray*)inputData error:(NSError**)error;
@end
