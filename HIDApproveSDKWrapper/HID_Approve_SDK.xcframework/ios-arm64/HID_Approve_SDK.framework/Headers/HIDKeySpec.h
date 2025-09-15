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

/**
 * \file HIDKeySpec.h
 * \brief Key Spec instance.
 *
 */

/**
 *\brief Key Spec object for use with #HIDContainer.addKey:withProtectionPolicyId:withPassword:error:
 */
@interface HIDKeySpec: NSObject
/**
 * \brief Initialization of HIDKeySpec instance.
 * \param key Encoded key data bytes (expect JWK format)
 * \param format Key format
 * \return reference to HIDKeySpec instance
 */
-(id)init:(NSData*)key withFormat:(NSString*)format;
/**
 * Sets the algorithm associated with that key.
 * \param algorithm Key algorithm
 */
-(void)setAlgorithm:(NSString*)algorithm;
/**
 * Sets this key label.
 * \param label Key label
 */
-(void)setLabel:(NSString*)label;
/**
 * Sets an array of usage for that key.
 * \param keyUsage Key usage
 */
-(void)setUsage:(NSString*)keyUsage;
/**
 * Gets the algorithm associated with that key.
 * \return key algorithm
 */
-(NSString*)getAlgorithm;
/**
 * Gets this key label.
 * \return key label
 */
-(NSString*)getLabel;
/**
 * Gets an array of usage for that key.
 * \return key usage
 */
-(NSString*)getUsage;
/**
 * Gets key format.
 * \return key format
 */
-(NSString*)getFormat;
/**
 * Gets encoded key bytes.
 * \return encoded key bytes
 */
-(NSData*)getKey;
@end
