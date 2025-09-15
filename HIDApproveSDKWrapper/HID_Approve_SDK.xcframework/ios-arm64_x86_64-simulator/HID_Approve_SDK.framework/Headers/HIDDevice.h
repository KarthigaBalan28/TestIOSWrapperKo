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
#import "HIDTransaction.h"
#import "HIDServerActionInfo.h"
#import "HIDServerAction.h"
#import "HIDConnectionConfiguration.h"
#import "HIDProgressListener.h"

/**
 * \file HIDDevice.h
 * \brief Main Device instance.
 *
 */

/**
 * \brief Parent device object used to query device information and discover any active containers.
 */
@protocol HIDDevice

/**
 * \brief Retrieves and decrypts an encrypted "server action" message received from the server.
 * \param actionId action ID message received in push notification, scan to approve or via \link HIDContainer.retrieveTransactionsIds() \endlink
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidContainer if the action id refers to a container that does not exist.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDInexplicitContainer if the action id cannot determine which container to apply. Invoke retrieveActionInfo with 'UserId' parameter. HID_ERROR_PARAMETERS includes list with ('UserId':user1,'UserId':user2..).</li>
 * </ul>
 * </p>
 * \return a HIDServerActionInfo instance containing action details, nil if an error occurs.
 */
- (id<HIDServerActionInfo>)retrieveActionInfo:(NSString*)actionId error:(NSError**)error;

/**
 * \brief Retrieves and decrypts an encrypted "server action" message received from the server.
 * \param actionId action ID message received in push notification, scan to approve or via \link HIDContainer.retrieveTransactionsIds() \endlink
 * \param userId user identifier of the container to be used to retrieve action info from (Optional).
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidContainer if the action id refers to a container that does not exist.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDInexplicitContainer if the action id cannot determine which container to apply. Invoke retrieveActionInfo with 'UserId' parameter. HID_ERROR_PARAMETERS includes list with ('UserId':user1,'UserId':user2..).</li>
 * </ul>
 * </p>
 * \return a HIDServerActionInfo instance containing action details, nil if an error occurs.
 */
- (id<HIDServerActionInfo>)retrieveActionInfo:(NSString*)actionId withUserID:(NSString*)userId error:(NSError**)error;

/**
 * \brief Retrieves device information.
 * \param propertyId deviceInfo property to retrieve.
 * <p>
 * Supported property names:
 * <ul>
 * <li>#HID_DEVICE_INFO_BRAND</li>
 * <li>#HID_DEVICE_INFO_KEYSTORE</li>
 * <li>#HID_DEVICE_INFO_LOCALE</li>
 * <li>#HID_DEVICE_INFO_MANUFACTURER</li>
 * <li>#HID_DEVICE_INFO_MODEL</li>
 * <li>#HID_DEVICE_INFO_NAME</li>
 * <li>#HID_DEVICE_INFO_OS</li>
 * <li>#HID_DEVICE_INFO_OS_NAME</li>
 * <li>#HID_DEVICE_INFO_OS_VERSION</li>
 * <li>#HID_DEVICE_INFO_PRODUCT</li>
 * <li>#HID_DEVICE_INFO_ISROOTED</li>
 * </ul>
 * </p>
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return the device property value, nil if an error occurs.
 */
- (NSString*)getDeviceInfo:(NSString*)propertyId error:(NSError**)error;

/**
 * \brief Returns the version of the transaction processor client API.
 * \return version of the SDK version number.
 */
- (NSString*)getVersion:(NSError**)error;

/**
 * \brief Retrieves a container based on input parameter filter.
 * \param filter array of HIDParameter objects required to specify container
 * <p>
 * Filter can indicate:
 * <ul>
 * <li>#HID_CONTAINER_NAME: Friendly Name of the container.</li>
 * <li>#HID_CONTAINER_URL: URL of server associated with the container.</li>
 * <li>#HID_CONTAINER_USERID: User identifier of the container.</li>
 * </ul>
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return list of containers or nil if not found.
 */
- (NSArray*)findContainers:(NSArray*)filter error:(NSError**)error;

/**
 * \brief Triggers the container activation process to create a new container.
 * \param config initialization configuration see \link HIDContainerInitialization \endlink for details
 * \param sessionPassword transaction protection key password (can be nil if not required by the policy)
 * \param listener A HIDProgressListener implementation to which to report status information or receive password request events.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDUnsupportedDevice if device is not supported by policy.</li>
 * <li>#HIDInternal if an unexpected error occurred.</li>
 * <li>#HIDServerAuthentication if the server rejected the authentication.</li>
 * <li>#HIDInvalidPassword if password validation fails.</li>
 * <li>#HIDRemote if server responds with any other error.</li>
 * <li>#HIDPasswordCancelled if the password prompt dialog has been cancelled by the user. </li>
 * <li>#HIDUnsupportedOperationMode if the device does not support FIPS 140-2 requirements.</li>
 * <li>#HIDServerOperationFailed if the server encounters a failure for the operation requested.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return the container or nil if an error occurs.
 */
- (id<HIDContainer>)createContainer:(HIDContainerInitialization*)config withSessionPassword:(NSString*)sessionPassword withListener:(NSObject<HIDProgressListener>*)listener error:(NSError**)error;

/**
 * \brief Deletes a container identified by its ID.
 * The method notifies the server the container is deleted, thus requires the device to be online.
 * \param containerId id of the container.
 * \param sessionPassword transaction protection key password (can be nil if not required by the policy).
 * \param parameters can be empty (reserved for future use).
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDPasswordExpiredException if expired password is given (changePassword required).
 * <li>#HIDAuthenticationException if password is incorrect.
 * </ul>
 * </p>
 * \return YES if the delete was successfully performed.
 * \deprecated Deprecated in SDK 6.0. Integrations should replace calls with the \link deleteContainer:withSessionPassword:withReason:error: \endlink method.
 */
- (BOOL)deleteContainer:(NSInteger)containerId withSessionPassword:(NSString*)sessionPassword withParams:(NSArray*)parameters error:(NSError**)error;

/**
 * \brief Deletes a container identified by its ID.
 * The method notifies the server the container is deleted, thus requires the device to be online.
 * \param containerId id of the container.
 * \param sessionPassword transaction protection key password (can be nil if not required by the policy).
 * \param reason Optional message defining the reason for deletion for audit (default USER) <i>(expected max 1000 characters)</i>
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDPasswordExpiredException if expired password is given (changePassword required).
 * <li>#HIDAuthenticationException if password is incorrect.
 * </ul>
 * </p>
 * \return YES if the delete was successfully performed.
 */
- (BOOL)deleteContainer:(NSInteger)containerId withSessionPassword:(NSString*)sessionPassword withReason:(NSString*)reason error:(NSError**)error;


/**
 * \brief Sets connection configuration.
 * \param config configuration, see HIDConnectionConfiguration for details.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return false if error occurs
 */
- (BOOL)setConnectionConfiguration:(HIDConnectionConfiguration*)config error:(NSError**)error;
@end

/*! \mainpage Introduction
 *
 * This is the API documentation for HID Approve SDK for iOS/macOS.
 *
 * For an overview of the general concepts and supported use cases, please refer to online SDK documentation at https://docs.hidglobal.com/hid-approve-sdk/home.htm.
 *
 */


/**
 * \brief Factory for creating a new device instance.
 */
@interface HIDDeviceFactory : NSObject

/**
 * \brief Instantiate the device factory.
 */
+ (id)factory;

/**
 * \brief \b Deprecated. Create device instance
 * \param config optional connection configuration.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDUnsupportedVersion if upgrade from unsupported version</li>
 * </ul>
 * </p>
 * \return The HIDDevice instance.
 * \deprecated Deprecated in SDK 5.13. Integrations should replace calls with the \link getDevice:error: \endlink method.
 */
- (id<HIDDevice>)newInstance:(HIDConnectionConfiguration*)config error:(NSError**)error;

/**
 * \brief Return device instance
 * \param config optional connection configuration.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDUnsupportedVersion if upgrade from unsupported version</li>
 * <li>#HIDLostCredentials if critical keys are missing </li>
 * </ul>
 * </p>
 * \return An HIDDevice instance.
 */
- (id<HIDDevice>)getDevice:(HIDConnectionConfiguration*)config error:(NSError**)error;

/**
 * \brief Deletes all containers and keys contained in the device.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return YES if reset successful.
 */
+(BOOL)reset:(NSError**)error;
@end
