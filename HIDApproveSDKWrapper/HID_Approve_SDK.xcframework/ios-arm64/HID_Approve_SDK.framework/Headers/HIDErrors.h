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

/**
 * \file HIDErrors.h
 * \brief SDK Error codes.
 *
 */
extern NSString *const HIDErrorDomain;      ///< The domain of errors returned by the sdk

/**
 * Enumeration HIDErrorCodes
 * \brief SDK error codes.
 */
typedef enum
{
    //API errors
    //Internal errors
    HIDInternal,                            /**< (0) An unexpected error occurred. */
    HIDNotImplemented,                      /**< (1) The method is not implemented. */
    HIDUnsupportedOperation,                /**< (2) The operation is not supported by the object. */
    HIDInvalidArgument,                     /**< (3) An invalid argument was encountered. */
    HIDKeyGenerationFailure,                /**< (4) Unable to generate internal credential. */
    HIDProtectionPolicyFailure,             /**< (5) Unable to create or locate internal protection policy. */
    HIDSecureDataFailure,                   /**< (6) Unable to create or locate internal credential data. */
    HIDUnsupportedVersion,                  /**< (7) Container version is not supported */
    HIDInvalidContainer,                    /**< (8) An invalid container*/
    HIDInexplicitContainer,                 /**< (9) Container is ambigious and cannot be explicitly determined*/
    
    //Credential errors
    HIDAuthentication=100,                  /**< (100) Authentication failed. */
    HIDInvalidPassword,                     /**< (101) The password fails policy requirements. */
    HIDCredentialsExpired,                  /**< (102) The credentials used to sign the transaction have expired. */
    HIDPasswordExpired,                     /**< (103) The password has expired and requires a change of password. */
    HIDPasswordNotYetUpdatable,             /**< (104) The password cannot be changed yet. */
    HIDPasswordRequired,                    /**< (105) The required password was not provided. */
    HIDLostCredentials,                     /**< (106) The provisioning key securing the transaction has been wiped. */
    HIDInvalidChallengeTooLong,             /**< (107) The challenge is too long with respect to the OTP configuration. */
    HIDInvalidChallengeBadFormat,           /**< (108) The challenge does not have the format expected by the OTP configuration. */
    HIDPasswordCancelled,                   /**< (109) The password event has been cancelled by the user. */

    //Device errors
    HIDUnsupportedDevice=200,               /**< (200) The device configuration is not supported. */
    HIDUnsafeDevice,                        /**< (201) The device is not safe enough to store sensitive secrets. */
    HIDFingerprintNotEnrolled,              /**< (202) Fingerprints have not been enrolled. */
    HIDUserCancelled,                       /**< (203) The user has cancelled the operation. */
    HIDFingerprintAuthenticationRequired,   /**< (204) Authentication with fingerprint is required to perform the operation. */
    HIDUnsupportedOperationMode,            /**< (205) Mode operation required by the server is not supported by the device. */

    //Communication errors
    HIDServerAuthentication=300,            /**< (300) Authentication to the server failed. */
    HIDServerVersion,                       /**< (301) The server protocol version is not supported by the client or does not support client operation. */
    HIDServerProtocol,                      /**< (302) An unexpected failure has occurred in the implementation layer. */
    HIDRemote,                              /**< (303) Execution of a remote method call failed. */
    HIDServerUnsupportedOperation,          /**< (304) Operation not supported by the server. */
    HIDServerOperationFailed,               /**< (305) The server operation failed. */

    // Transaction errors
    HIDTransactionExpired=1000,             /**< (1000) The transaction has expired. */
    HIDTransactionContainerInvalid,         /**< (1001) The transaction id refers to a container that does not exist. It may happen if the container is deleted locally without notifying the server. */
    HIDTransactionCanceled,                 /**< (1002) The transaction has been canceled. */
    HIDTransactionSigned,                   /**< (1003) The transaction has already been signed.*/
} HIDErrorCode;
