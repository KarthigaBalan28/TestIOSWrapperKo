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
 * \file HIDParameter.h
 * \brief Parameter object containing name value pair.
 *
 */

/**
 * \brief Encoding types
 */
typedef enum
{
    HIDParameterEncodingNone,
    HIDParameterEncodingBase64,
    HIDParameterEncodingByteArray,
    HIDParameterEncodingHex,
    HIDParameterEncodingDecimal,
    HIDParameterEncodingUTF8,
    HIDParameterEncodingDefault = 0
} HIDParameterEncoding;

/**
 * \brief  Value types
 */
typedef enum
{
    HIDParameterTypeString,
    HIDParameterTypeInteger,
    HIDParameterTypeByteArray,
    HIDParameterTypeLong,
    HIDParameterTypeDefault=0
} HIDParameterType;

/**
 * \brief Represents a parameter consisting of an id/value pair.
 * <p>
 * Reserved for future use, a type and encoding attribute are also available to represent more complex data.
 */
@interface HIDParameter : NSObject

/**
 * \brief The parameter key.
 */
@property(nonatomic,retain) NSString* key;

/**
 * \brief The parameter value.
 */
@property(nonatomic,retain) NSString* value;

/**
 * \brief The parameter encoding.
 */
@property(nonatomic,assign) HIDParameterEncoding encoding;

/**
 * \brief The parameter type.
 */
@property(nonatomic,assign) HIDParameterType type;

/**
 * \brief Creates an instance of parameter with specified key and value.
 * \param value the parameter value.
 * \param key the parameter key.
 * \return an instance of HIDParameter.
 * <p>
 * Encoding is HIDParameterEncodingNone (#HIDParameterEncoding) and type is HIDParameterTypeString (#HIDParameterType).
 * </p>
 */
+ (id)parameterWithString:(NSString*)value forKey:(NSString*)key;

/**
 * \brief Initializes an instance of parameter with specified key and value.
 * \param value the parameter value.
 * \param key the parameter key.
 * \return an instance of HIDParameter.
 * <p>
 * Encoding is HIDParameterEncodingNone (#HIDParameterEncoding) and type is HIDParameterTypeString (#HIDParameterType).
 * </p>
 */
- (id)initWithString:(NSString*)value forKey:(NSString*)key;

@end
