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
 * \file HIDConstants.h
 * \brief Common Transaction Signing SDK Constants.
 *
 */
extern NSString *const HID_DEVICE_INFO_BRAND;                        ///< Device Info: Device brand name.
extern NSString *const HID_DEVICE_INFO_KEYSTORE;                     ///< Device Info: Keystore type. ("soft" or "hw")
extern NSString *const HID_DEVICE_INFO_MANUFACTURER;                 ///< Device Info: Device manufacturer name.
extern NSString *const HID_DEVICE_INFO_MODEL;                        ///< Device Info: Device model name.
extern NSString *const HID_DEVICE_INFO_NAME;                         ///< Device Info: User-assigned device name for iOS15 and earlier.  Generic device name for iOS16 and later.  *@see <a href="https://developer.apple.com/documentation/uikit/uidevice/1620015-name">https://developer.apple.com/documentation/uikit/uidevice/1620015-name</a>
extern NSString *const HID_DEVICE_INFO_OS;                           ///< Device Info: Operating System Name.
extern NSString *const HID_DEVICE_INFO_OS_NAME;                      ///< Device Info: Operating System platform name.
extern NSString *const HID_DEVICE_INFO_OS_VERSION;                   ///< Device Info: Operating System platform version.
extern NSString *const HID_DEVICE_INFO_PUSHID;                       ///< Device Info: Base64 representation of Apple Push Notification (APN) device token identifier.
extern NSString *const HID_DEVICE_INFO_PRODUCT;                      ///< Device Info: Device product name.
extern NSString *const HID_DEVICE_INFO_LOCALE;                       ///< Device Info: Device locale charset.
extern NSString *const HID_DEVICE_INFO_ISROOTED;                       ///< Device Info: Device is rooted.

extern NSString *const HID_KEY_PROPERTY_CREATE;                      ///< Key Creation Date as long.
extern NSString *const HID_KEY_PROPERTY_EXPIRY;                      ///< Key Expiration Date as long.
extern NSString *const HID_KEY_PROPERTY_LABEL;                       ///< Key Label.
extern NSString *const HID_KEY_PROPERTY_USAGE;                       ///< Key Usage.

extern NSString *const HID_KEY_PROPERTY_USAGE_ENCRYPT;               ///< Key Usage Value of encryption keys.
extern NSString *const HID_KEY_PROPERTY_USAGE_SIGN;                  ///< Key Usage Value of signing private keys.
extern NSString *const HID_KEY_PROPERTY_USAGE_TXPROTECT;             ///< Key Usage Value of transaction protection session keys.
extern NSString *const HID_KEY_PROPERTY_USAGE_OTP;                   ///< Key Usage Value of OTP keys
extern NSString *const HID_KEY_PROPERTY_USAGE_AUTH;                  ///< Key Usage Value of authentication
extern NSString *const HID_KEY_PROPERTY_USAGE_OPPRO;                  ///< Key Usage Value of oppro

extern NSString *const HID_CONTAINER_NAME;                           ///< Container friendly name
extern NSString *const HID_CONTAINER_URL;                            ///< URL of server managing this container
extern NSString *const HID_CONTAINER_ID;                             ///< Container unique id
extern NSString *const HID_CONTAINER_USERID;                         ///< User id

extern NSString *const HID_PARAM_TX_MOBILE_CONTEXT;                  ///< Transaction Parameter: mobile context data

extern NSString *const HID_PARAM_PROGRESSEVENT_LEVEL;                ///< Sync Event Level
extern NSString *const HID_PARAM_PROGRESSEVENT_MESSAGE;              ///< Sync Event Message
extern NSString *const HID_PARAM_PROGRESSEVENT_PERCENT;              ///< Sync Event Percent

//new for 5.5
extern NSString *const HID_PARAM_PASSWORD_PROGRESS_EVENT_TYPE;              ///< password event type
extern NSString *const HID_PARAM_PASSWORD_PROGRESS_EVENT_KEY_LABEL;         ///< password event key label
extern NSString *const HID_PARAM_PASSWORD_PROGRESS_EVENT_KEY_USAGE;         ///< password event key usage
extern NSString *const HID_PARAM_PASSWORD_PROGRESS_EVENT_TYPE_CONTAINER;    ///<  password event type container
extern NSString *const HID_PARAM_PASSWORD_PROGRESS_EVENT_TYPE_KEY;          ///<  password event type key
//

extern NSString *const HID_PLATFORM_CLASS_SOFTTOKEN;                 ///< The class name of the soft token

extern NSString *const HID_PARAM_SYNC_PROV_AUTHPOLICYID;             ///< SyncManager Parameter: End-user Provisioning Authentication Policy configured on server
extern NSString *const HID_PARAM_SYNC_TDS_AUTHPOLICYID;              ///< SyncManager Parameter: End-user Transaction Signing Authentication Policy configured on server
extern NSString *const HID_PARAM_SYNC_DEVICE_NAME;                   ///< SyncManager Parameter: Server device friendly name (optional)
extern NSString *const HID_PARAM_SYNC_DEVICE_TYPECODE;               ///< SyncManager Parameter: Server Device Type Code
extern NSString *const HID_PARAM_SYNC_DEVICEID;                      ///< SyncManager Parameter: Server device identifier
extern NSString *const HID_PARAM_SYNC_PSS;                           ///< SyncManager Parameter: Pre-Shared Secret
extern NSString *const HID_PARAM_SYNC_PUSHID;                        ///< SyncManager Parameter: APN device token identifier
extern NSString *const HID_PARAM_SYNC_PWD_ENCRYPT;                   ///< SyncManager Parameter: Encryption key password.
extern NSString *const HID_PARAM_SYNC_PWD_SIGN;                      ///< SyncManager Parameter: Signature key password.
extern NSString *const HID_PARAM_SYNC_PWD_TXPROTECT;                 ///< SyncManager Parameter: Transaction Protection Session key password.
extern NSString *const HID_PARAM_SYNC_SECRET;                        ///< SyncManager Parameter: Authentication secret (otp/password/challenge/etc)
extern NSString *const HID_PARAM_SYNC_PROTOCOL_VERSION;              ///< SyncManager Config: Requested protocol version
extern NSString *const HID_PARAM_SYNC_SERVER_CHANNEL;                ///< SyncManager Config: SyncManager server channel.
extern NSString *const HID_PARAM_SYNC_SERVER_CONTEXT;                ///< SyncManager Config: Server context (optional)
extern NSString *const HID_PARAM_SYNC_SERVER_DOMAIN;                 ///< SyncManager Config: Server domain.
extern NSString *const HID_PARAM_SYNC_SERVER_RETRY;                  ///< SyncManager Config: Connection retry.
extern NSString *const HID_PARAM_SYNC_SERVER_TIMEOUT;                ///< SyncManager Config: Connection timeout.
extern NSString *const HID_PARAM_SYNC_SERVER_URL;                    ///< SyncManager Config: provisioning URL.
extern NSString *const HID_PARAM_SYNC_USERID;                        ///< SyncManager Parameter: Server user identifier

extern NSString *const HID_PROPERTY_APPCUSTOMIZATION;                ///< Property: Application customization
extern NSString *const HID_PROPERTY_CHANNEL;                         ///< Property: Server provisioning channel.
extern NSString *const HID_PROPERTY_DOMAIN;                          ///< Property: Server domain.
extern NSString *const HID_PROPERTY_SERIALNUMBER;                    ///< Property: Device Serial number
extern NSString *const HID_PROPERTY_EXTERNALID;                      ///< Property: Device ID

extern NSString *const HID_ERROR_MESSAGE;                            ///< Custom error in NSError userInfo: internal message
extern NSString *const HID_ERROR_AUTH_REMAINING_TRIES;               ///< Custom error in NSError userInfo: number of remaining tries in case of authentication failure
extern NSString *const HID_ERROR_PARAMETERS;                         ///< Custom error in NSError userInfo: list of user identifiers suitable for this transaction

extern NSString *const HID_OTP_AUTHMODE_CHALLENGE_RESPONSE;          ///< OTP key can be used in One-Way Challenge-Response mode
extern NSString *const HID_OTP_AUTHMODE_MUTUAL_CHALLENGE_RESPONSE;   ///< OTP key can be used in Challenge-Response mode with server authentication
extern NSString *const HID_OTP_AUTHMODE_SIGNATURE;                   ///< OTP key can be used in signature mode
extern NSString *const HID_OTP_AUTHMODE_SIGNATURE_SERVER_AUTH;       ///< OTP key can be used in signature mode with server authentication

extern NSString *const HID_OCRASUITE_CHALLENGE_FORMAT_ALPHANUM;      ///< OCRA challenge format is alphanumeric
extern NSString *const HID_OCRASUITE_CHALLENGE_FORMAT_NUMERIC;       ///< OCRA challenge format is numeric
extern NSString *const HID_OCRASUITE_CHALLENGE_FORMAT_HEX;           ///< OCRA challenge format is hex

extern NSString *const HID_PROPERTY_PROTOCOL_VERSION;                ///< Property: current protocol version.
extern NSString *const HID_PROPERTY_ORIGINAL_CREATION_DATE;          ///< Property: container original creation date.
extern NSString *const HID_PROPERTY_CREATION_DATE;                   ///< Property: container creation date.
extern NSString *const HID_PROPERTY_RENEWAL_DATE;                    ///< Property: container renewal date.
extern NSString *const HID_PROPERTY_EXPIRY_DATE;                     ///< Property: container expiry date.

