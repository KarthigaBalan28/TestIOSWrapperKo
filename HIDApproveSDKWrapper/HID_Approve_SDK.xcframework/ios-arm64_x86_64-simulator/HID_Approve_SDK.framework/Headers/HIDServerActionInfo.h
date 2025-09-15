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
#import "HIDContainer.h"
#import "HIDServerAction.h"
#import "HIDKey.h"

/**
 * \file HIDServerActionInfo.h
 * \brief Action details.
 *
 */

/**
 * \brief Action details from server.
 */
@protocol HIDServerActionInfo
/**
 * \brief Retrieves the container associated with that action.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return the container, nil if an error occurs.
 */
- (id<HIDContainer>)getContainer:(NSError**)error;

/**
 * \brief Retrieves the protection key associated with that action.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return The action protection session key, nil if an error occurs.
 */
- (id<HIDKey>)getProtectionKey:(NSError**)error;

/**
 * \brief Retrieves the action unique identifier.
 * \return action unique identifier.
 */
- (NSString*)getUniqueIdentifier;

/**
 * \brief Extracts the action data associated with this action info.
 * \param sessionPassword  protection key password (can be nil if not required by the policy)
 * \param parameters Reserved for future use.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDAuthentication if password is incorrect.</li>
 * <li>#HIDTransactionExpired if transaction is no longer valid</li>
 * <li>#HIDCredentialsExpired if key is no longer valid</li>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDPasswordExpired if expired password is given (changePassword required).
 * <li>#HIDServerAuthentication if server rejects authentication</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return a HIDServerAction instance containing action details, nil if an error occurs.
 */
- (id<HIDServerAction>)getAction:(NSString*)sessionPassword withParams:(NSArray*)parameters error:(NSError**)error;

@end
