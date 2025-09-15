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
 * \file HIDConnectionConfiguration.h
 * \brief Connection configuration.
 *
 */

/**
 *\brief Configuration of server connections.
 * <p>
 * The HID Approve SDK connects to the server for authentication and provisioning purpose.
 * This class enables the application consuming the SDK to configure some of the connection settings:
 * <ul>
 * <li>timeout: the server connection timeout in seconds <i>(default: 30s, 0 means infinite)</i></li>
 * <li>retry: the number of retries after connection fails <i>(default: 0, 0 means no retry)</i></li>
 * <li>delegate: connection delegate to handle session-level tls events <i>(default: platform tls)</i></li>
 * </ul>
 */
@interface HIDConnectionConfiguration : NSObject
/**
 * \brief The server connection timeout in seconds (default: 30s, 0 means infinite)
 */
@property long timeout;
/**
 * \brief The number of retries after connection fails (default:0, 0 means no retry)
 */
@property long retry;
/**
 * \brief Connection delegate to handle session-level events (default: system default) For more details see <a href="https://developer.apple.com/documentation/foundation/urlsessiondelegate">urlsessiondelegate</a>
 */
@property id delegate;
@end
