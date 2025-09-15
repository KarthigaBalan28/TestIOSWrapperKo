/* ---------------------------------------------------------------------------
 (c) 2015-2024, HID Global Corporation, part of ASSA ABLOY.
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
 * \file HIDLog.h
 * \brief Define constants required to configure HID Approve SDK logging behavior.
 * \brief SDK logs are based on Apple OSLog, but can also be redirected to a log file located in the application bundle.<br>
 * \brief Add below preferences key/value pairs to your application to configure logging behavior.
 */

/** @name SDK logging preference keys
 *  Following strings define preference keys to add to your application to configure HID Approve SDK logging behavior
 */
///@{
/** This key controls SDK logging behavior (disabled or enabled). It also controls the log level (log verbosity) of the SDK when logging is enabled. */
extern NSString *const HID_PREFKEY_LOG_LEVEL;
/** When SDK log are enabled, this key controls if log should also be redirected to a log file located in the application bundle.<br>
When this key is missing, no log file will be created.<br>
The string value may contain NSSearchPathDirectory enum by using percent sign (for example, %NSCachesDirectory%/Logs.txt).*/
extern NSString *const HID_PREFKEY_LOG_LOGFILEPATH;
///@}

/** @name SDK logging level values
 *  Following strings define all SDK log level (from disabled to the log verbosity when enabled).
 */
///@{
/** Define SDK log level to disabled, meaning no logs will be generated (default value) */
extern NSString *const HID_PREFVALUE_LOG_LEVEL_OFF;
/** Define SDK log level to log only error events */
extern NSString *const HID_PREFVALUE_LOG_LEVEL_ERROR;
/** Define SDK log level to log useful information and errors events */
extern NSString *const HID_PREFVALUE_LOG_LEVEL_INFO;
/** Define SDK log level to log all useful events during software debugging */
extern NSString *const HID_PREFVALUE_LOG_LEVEL_VERBOSE;
///@}

/** @name SDK log file path values
 *  Following strings define all SDK log file path values.
 */
///@{
/** Define SDK log file path to default value ("%NSApplicationSupportDirectory%/ApproveSDK.log"). */
extern NSString *const HID_PREFVALUE_LOG_LOGFILEPATH_SUPPORTDIR;
///@}
