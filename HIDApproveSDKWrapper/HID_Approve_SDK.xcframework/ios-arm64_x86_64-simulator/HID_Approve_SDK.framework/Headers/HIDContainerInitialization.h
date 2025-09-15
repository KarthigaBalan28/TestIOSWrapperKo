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
 * \file HIDContainerInitialization.h
 * \brief Configuration for creation if a new HIDContainer
 *
 */

/**
 *\brief base container configuration
 */
@interface HIDContainerConfiguration : NSObject

/**
 * \brief The device friendly name. <i>(expected max 128 characters)</i>
 * <p>
 * This name will be communicated to the server and may be used by other applications
 * to help the end-user identify his/her device.
 */
@property NSString* deviceFriendlyName;
/**
 * \brief The container friendly name. <i>(expected max 128 characters)</i>
 */
@property NSString* containerFriendlyName;
/**
 * \brief The base64 representation of the device token identifier provided by notification service,
 * <p>
 * This identifier will be communicated to the server to allow it to send notifications.
 * Value should be left blank to disable push notification for device.
 */
@property NSString* pushId;
@end

/**
 *\brief Configuration for creation of a Container.
 *\see #HIDDevice.createContainer:withSessionPassword:withListener:error:
 */
@interface HIDContainerInitialization : HIDContainerConfiguration
/**
 * \brief The activation code.
 * <p>
 * This code encloses all the information needed to create a HIDContainer.
 * It may come from a QR code or any other channel.
 */
@property NSString* activationCode;
/**
 * \brief The user identifier. <i>(expected max 128 characters)</i>
 */
@property NSString* userId;
/**
 * \brief The invite code. <i>(expected max 62 characters)</i>
 * <p>
 * This is a short code provided by the server to ensure the Container creation
 * is genuine.
 */
@property NSString* inviteCode;
/**
 * \brief The authentication server URL. <i>(expected max 128 characters)</i>
 */
@property NSString* serverURL;

@end

/**
 *\brief Configuration for renew of a Container.
 *\see #HIDContainer.renew:withSessionPassword:withListner:error
 */
@interface HIDContainerRenewal : HIDContainerConfiguration
/**
 * \brief  Container keys password (if protected by password).
 */
@property NSString* password;
@end
