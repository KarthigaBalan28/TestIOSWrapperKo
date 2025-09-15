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
#import "HIDKey.h"

/**
 * \file HIDServerAction.h
 * \brief ServerAction object.
 *
 */

/**
 * \brief Encapsulates an action extracted from an encrypted server message.
 */
@protocol HIDServerAction

/**
 * \brief Returns the message information for action
 * \return Message contents
 */
- (NSString*)toString;

/**
 * \brief Returns the nature of the action.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDNotImplemented if not implemented</li>
 * </ul>
 * </p>
 * \return Retrieves the action keyword, nil if not set yet or an error occurs.
 */
- (NSString*)getAction:(NSError**)error;

/**
 * \brief Retrieves the date associated with requested action
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDNotImplemented if not implemented</li>
 * </ul>
 * </p>
 * \return the date, nil if not provided or an error occurs.
 */
- (NSDate*)getDate:(NSError**)error;

/**
 * \brief Retrieves the expiration date associated with requested action
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDNotImplemented if not implemented</li>
 * </ul>
 * </p>
 * \return the date, nil if not provided or an error occurs.
 */
- (NSDate*)getExpiryDate:(NSError**)error;

/**
 * \brief Returns an optional payload related to the request action.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return payload related to the request action., nil if not set yet or an error occurs.
 */
- (NSString*)getPayload:(NSError**)error;
@end
   
