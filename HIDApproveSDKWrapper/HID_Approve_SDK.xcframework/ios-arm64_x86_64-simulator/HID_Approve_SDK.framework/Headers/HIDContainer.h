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
#import "HIDConnectionConfiguration.h"
#import "HIDKeySpec.h"
#import "HIDKey.h"
#import "HIDContainerInitialization.h"
#import "HIDProgressListener.h"
#import "HIDTransaction.h"

/**
 * \file HIDContainer.h
 * \brief Service container instance.
 *
 */

/**
 * \brief Encapsulates an active service container instance.
 */
@protocol HIDContainer

/**
 * \brief Get the identifier of this container.
 * \return The identifier.
 */
- (NSInteger)getId;

/**
 * \brief Gets the server URL associated with this container.
 * \return The NSString URL.
 */
- (NSString*)getServerURL;

/**
 * \brief Gets the Friendly Name associated with this container.
 * \return The NSString name.
 */
- (NSString*)getName;

/**
 * \brief Sets the Friendly Name associated with this container.
 * \param name Friendly name of container. <i>(expected max 128 characters)</i>
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return YES if property value was successfully updated.
 */
- (BOOL)setName:(NSString*)name error:(NSError**)error;

/**
 * \brief Gets the identifier of the user for this container.
 * \return Container user identifier
 */
- (NSString*)getUserId;

/**
 * \brief Retrieves a key handle from the secure keystore based on input parameter filter.
 * \param filter NSArray of HIDParameter objects with key property name and value. <i>(or nil for all keys)</i>
 * <p>
 * Filter parameter can be defined with the following id:
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
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return The HIDKey array of matching key items, nil if an error occurs.
 * Any provisioned asymmetric keys will be represented as an HIDKeyPair object.
 */
- (NSArray*)findKeys:(NSArray*)filter error:(NSError**)error;

/**
 * \brief Returns container property.
 * \param propertyId property name.
 * <p>
 * Supported property names:
 * <ul>
 * <li>#HID_PROPERTY_APPCUSTOMIZATION</li>
 * <li>#HID_PROPERTY_CHANNEL</li>
 * <li>#HID_PROPERTY_CREATION_DATE</li>
 * <li>#HID_PROPERTY_DOMAIN</li>
 * <li>#HID_PROPERTY_EXPIRY_DATE</li>
 * <li>#HID_PROPERTY_EXTERNALID</li>
 * <li>#HID_PROPERTY_ORIGINAL_CREATION_DATE</li>
 * <li>#HID_PROPERTY_PROTOCOL_VERSION</li>
 * <li>#HID_PROPERTY_RENEWAL_DATE</li>
 * <li>#HID_PROPERTY_SERIALNUMBER</li>
 * </ul>
 * </p>
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return The property value, nil if an error occurs.
 */
- (NSString*)getProperty:(NSString*)propertyId error:(NSError**)error;

/**
 * \brief Overrides a container property.
 * \param propertyId property name.
 * <p>
 * Supported property names:
 * <ul>
 * <li>#HID_PROPERTY_DOMAIN</li>
 * <li>#HID_PROPERTY_CHANNEL</li>
 * <li>#HID_PROPERTY_APPCUSTOMIZATION</li>
 * </ul>
 * </p>
 * \param propertyValue property value.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return YES if property has been successfully set.
 */
- (BOOL)setProperty:(NSString*)propertyId withValue:(NSString*)propertyValue error:(NSError**)error;

/**
 * \brief Gets the protection policy associated with container.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return the HIDProtectionPolicy used to protect the key, nil if an error occurs.
 */
- (id<HIDProtectionPolicy>)getProtectionPolicy:(NSError**)error;

/**
 * \brief Retrieve a list of pending transaction IDs from the container.
 * \param sessionPassword transaction protection key password (can be nil if not required by the policy)
 * \param parameters empty (reserved for future use)
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
 * \return the Array of transaction id values, nil if an error occurs.
 */
- (NSArray*)retrieveTransactionIds:(NSString*)sessionPassword withParams:(NSArray*)parameters error:(NSError**)error;

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

/**
 * \brief Adds a key to the container.
 * \param keySpec the specification containing the key data (expect JWS formatted key).
 * \param protectionPolicyId the protection policy Id for that key.
 * \param password The password protecting that key. It can be set to nil if the protection policy does not require password to be set.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return false if error occurs.
 */
- (BOOL)addKey:(HIDKeySpec*)keySpec withProtectionPolicyId:(HIDIdentifier*)protectionPolicyId withPassword:(NSString*)password error:(NSError**)error;
    
/**
 * \brief Checks if FIPS 140-2 mode is required.
 * \return YES if the container instance has FIPS mode enabled.
 */
- (BOOL)isFIPSModeEnabled;

/**
 * \brief Gets the first creation date of this container.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return the first creation date
 */
-(NSDate*)getOriginalCreationDate:(NSError**)error;

/**
 * \brief Gets the activation or renewal creation date for this container.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return the creation date
 */
-(NSDate*)getCreationDate:(NSError**)error;

/**
 * \brief Gets the server defined expiration date this container.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return the expire date
 */
-(NSDate*)getExpiryDate:(NSError**)error;

/**
 * \brief Gets the renewal date limit for this container to remain fully functional (support is limited or not working after this date).
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return the renewal date of container
 */
-(NSDate*)getRenewalDate:(NSError**)error;

/**
 * \brief Verify whether the container renewal is possible.
 * \param sessionPassword transaction protection key password (can be nil if not required by the policy)
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if container is not renewable or unexpected error occurs</li>
 * </ul>
 * </p>
 * \return YES if the container is renewable.
 */
-(Boolean)isRenewable:(NSString*)sessionPassword  error:(NSError**)error;;

/**
 * \brief Triggers the container service key renewal process with the server for all container keys.
 * \param config renewal configuration see \link HIDContainerRenewal \endlink for details
 * \param sessionPassword transaction protection key password (can be nil if not required by the policy)
 * \param listener A HIDProgressListener implementation to which to report status information or receive password request events.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDAuthentication if password is incorrect.</li>
 * <li>#HIDInternal if an unexpected error occurred.</li>
 * <li>#HIDServerAuthentication if the server rejected the authentication.</li>
 * <li>#HIDInvalidPassword if password validation fails.</li>
 * <li>#HIDPasswordExpired if password is expired.</li>
 * <li>#HIDRemote if server responds with any other error.</li>
 * <li>#HIDServerOperationFailed if the server encounters a failure for the operation requested.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDPasswordRequired if required password was not provided.</li>
 * </ul>
 * </p>
 * \return the container or nil if an error occurs.
 */
- (Boolean)renew:(HIDContainerRenewal*)config withSessionPassword:(NSString*) sessionPassword withListener:(NSObject<HIDProgressListener>*)listener error:(NSError**)error;

/**
 * \brief Updates container information.
 * <p>
 * This method is used by the application to notify of a change in one of the externally generated device attributes.
 * </p>
 * \param propertyId deviceInfo property to update.
 * <p>
 * Supported name attributes:
 * <ul>
 * <li>#HID_DEVICE_INFO_PUSHID: update of the 'pushId', set up at provisioning and used by the server to notify the correct phone. Value may be nil or empty to disable push notification for device.</li>
 * </ul>
 * \param propertyValue the new value to replace.
 * \param sessionPassword transaction protection key password (can be nil if not required by the policy)
 * \param parameters empty (reserved for future use)
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
 * \return YES if property value was successfully updated.
 */
- (BOOL)updateDeviceInfo:(NSString*)propertyId withValue:(NSString*)propertyValue withPassword:(NSString*)sessionPassword withParams:(NSArray*)parameters error:(NSError**)error;

/**
 * \brief Generates a Direct Client Signature (DCS) transaction for approval
 * \param message The logon or operation validation message to be displayed with the transaction for approval <i>(expected max 1000 characters)</i>
 * \param key The signing key to be used for approval of the transaction
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDServerUnsupportedOperation if the server does not support the operation.</li>
 * </ul>
 * </p>
 * \return The generated transaction object for signing.
 */
- (id<HIDTransaction>) generateAuthenticationRequest:(NSString*)message withKey:(HIDIdentifier*) key error:(NSError**)error;

@end
