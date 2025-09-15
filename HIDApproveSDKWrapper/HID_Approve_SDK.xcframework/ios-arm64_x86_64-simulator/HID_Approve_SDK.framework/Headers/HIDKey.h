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
#import "HIDIdentifier.h"
#import "HIDProtectionPolicy.h"
#import "HIDOTPGenerator.h"

/**
 * \file HIDKey.h
 * \brief Key instance.
 *
 */

/**
 * \brief Key instance.
 */
@protocol HIDKey
/**
 * \brief Gets the keyId associated with key.
 * \return the keyId, nil if not set.
 */
- (HIDIdentifier*)getId;
/**
 * \brief Gets the protection policy associated with key.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return The HIDProtectionPolicy used to protect the key, nil if an error occurs.
 */
- (id<HIDProtectionPolicy>)getProtectionPolicy:(NSError**)error;
/**
 * \brief Returns property for that key.
 * \param propertyId key property name.
 * <p>
 * The property name may be any of the following:
 * <ul>
 * <li>#HID_KEY_PROPERTY_USAGE</li>
 * <li>#HID_KEY_PROPERTY_LABEL</li>
 * <li>#HID_KEY_PROPERTY_CREATE</li>
 * <li>#HID_KEY_PROPERTY_EXPIRY</li>
 * </ul>
 * </p>
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return The key property value, nil if an error occurs.
 */
- (NSString*)getProperty:(NSString*)propertyId error:(NSError**)error;
/**
 * \brief Returns the default OTP generator associated with the key.
 * \param error error details. It may be nil.
 * \return The HIDOTPGenerator instance, nil if key is not supporting any OTP generators or an error occurs.
 */
- (id<HIDOTPGenerator>)getDefaultOTPGenerator:(NSError**)error;

/**
 * \brief Returns true when the key is extractable.
 * \param error error details. It may be nil.
 * \return true or false depending on whether the key is extractable or not.
 */
- (BOOL)isExtractable:(NSError**)error;
/**
 * \brief Gets the standard algorithm name for the key.
 * \param error error details. It may be nil.
 * \return The algorithm name.
 */
- (NSString*)getAlgorithm:(NSError**)error;
/**
 * \brief Gets the name of the primary encoding format of this key.
 * \param error error details. It may be nil.
 * \return The encoding format name.
 */
- (NSString*)getFormat:(NSError**)error;
/**
 * \brief Gets the key in its primary encoding format.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDAuthentication if key password is incorrect</li>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return the key in its primary encoding format, or nil if an error occurred
 */
- (NSData*)getEncoded:(NSError**)error;
/**
 * \brief Gets the key in its primary encoding format.
 * \param password the key password.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDAuthentication if key password is incorrect</li>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return The key in its primary encoding format, or nil if an error occurred.
 */
- (NSData*)getEncoded:(NSString*)password error:(NSError**)error;
@end
