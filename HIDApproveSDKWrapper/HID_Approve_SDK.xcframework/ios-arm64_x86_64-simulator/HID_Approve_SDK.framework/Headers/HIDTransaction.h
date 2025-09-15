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
#import "HIDKey.h"
#import "HIDServerAction.h"
/**
 * \file HIDTransaction.h
 * \brief Transaction object.
 *
 */

/**
 * \brief Transaction cancelation reason types.
 */
typedef NS_ENUM(NSInteger, HIDCancelationReasonCode) {
    USER_CANCEL,             ///< User chooses to discard the transaction for all devices.
    NOTIFY_SUSPICIOUS        ///< Flag the transaction as undesirable/suspicious, this may trigger server counter measures (based on server configuration)
};


/**
 * \brief Encapsulates a transaction and exposes an API to apply an action status and context.
 */
@protocol HIDTransaction <HIDServerAction>

/**
 * \brief Returns a list of status (for instance "accept", "deny", "report") that can be set for that transaction.
 * \return the NSString array contains the possible status values to be used with setStatus.
 * \see #setStatus:withSigningPassword:withSessionPassword:withParams:error:
 * <p>
 * The values are retrieved from the transaction response message sent back by the server. The returned names can
 * be used by the calling application to look up the corresponding value in a name/value pair resource file
 * for customization/localization of displayed text to user.
 * </p>
 */
- (NSArray*)getAllowedStatuses;

/**
 * \brief Returns the transaction text to be displayed to the user.
 * \return Transaction text string.
 */
- (NSString*)toString;

/**
 * \brief Communicates the status and context information of this transaction along with cryptographic signature.
 * \param status status to apply to transaction with signature.
 * <p>
 * The status must be one of the statuses returned by the getAllowedStatuses() method.
 * </p>
 * \param signPassword the password protecting the signature key. (can be nil if not required by the policy)
 * \param sessionPassword transaction protection key password (can be nil if not required by the policy)
 * \param parameters array of {@link NSParameter} objects
 * <p>
 * Parameter can be defined with following id:
 * <ul>
 * <li>{@link HID_PARAM_TX_MOBILE_CONTEXT}: Optional mobile context data <i>(expected base64, max 1000 characters)</i></li>
 * </ul>
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDAuthentication if password is incorrect.</li>
 * <li>#HIDTransactionCanceled if the transaction is canceled</li> 
 * <li>#HIDTransactionExpired if transaction is no longer valid</li>
 * <li>#HIDTransactionSigned if the transaction is already signed</li> 
 * <li>#HIDCredentialsExpired if key is no longer valid</li>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDPasswordExpired if expired password is given (changePassword required).
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDServerAuthentication if server rejects authentication</li>
 * <li>#HIDServerOperationFailed if the server encounters a failure for the operation requested.</li>
 * <li>#HIDServerUnsupportedOperation if the server does not support the operation.</li>
 * <li>#HIDPasswordRequired if required password was not provided and cached password is not available.</li>
 * </ul>
 * </p>
 * \return boolean true if successful.
 * \see {@link HIDContainer::findKeys:error:}
 * \see {@link HIDServerActionInfo::getProtectionKey:}
 * \see {@link HIDTransaction::getSigningKey:}
 */
- (BOOL)setStatus:(NSString*)status withSigningPassword:(NSString*)signPassword withSessionPassword:(NSString*)sessionPassword withParams:(NSArray*)parameters error:(NSError**)error;

/**
 * \brief Cancel/delete an existing pending transaction on the server.
 * \param message Optional message to be audited with action (default: "not specified by HID Approve SDK integrator") <i>(expected max 1000 characters)</i>
 * \param reason Defines the reason for cancellation (for example fraudulent/suspicious transaction).
 * \param sessionPassword Transaction protection key password (can be nil if not required by the policy).
 * \param error error details. It may be nil.
 *  <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDAuthentication if password is incorrect.</li>
 * <li>#HIDCredentialsExpired if key is no longer valid</li>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * <li>#HIDPasswordExpired if expired password is given (changePassword required).
 * <li>#HIDPasswordRequired if required password was not provided and cached password is not available.</li>
 * <li>#HIDServerAuthentication if server rejects authentication</li>
 * <li>#HIDServerOperationFailed if the server encounters a failure for the operation requested.</li>
 * <li>#HIDServerUnsupportedOperation if the server does not support the operation.</li>
 * <li>#HIDTransactionExpired if transaction is no longer valid</li>
 * <li>#HIDTransactionCanceled if the transaction is canceled</li> 
 * </ul>
 * </p>
 */
- (BOOL)cancel:(NSString*) message withCancelationReason:(HIDCancelationReasonCode)reason withSessionPassword:(NSString*)sessionPassword error:(NSError**)error;

/**
 * \brief Checks if the server supports canceling the transaction
 * @return return true if the transaction is cancelable
 **/
- (BOOL) isCancelable;

/**
 * \brief Gets status change date for the transaction.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDNotImplemented if not implemented</li>
 * </ul>
 * </p>
 * \return the date, nil if not set yet or an error occurs.
 */
- (NSDate*)getDate:(NSError**)error;
/**
 * \brief Gets the Signing Key object associated with that transaction.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return the key, nil if an error occurs.
 */
- (id<HIDKey>)getSigningKey:(NSError**)error;

/**
 * \brief Returns the nature of the action.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * </ul>
 * </p>
 * \return the nature of the action, nil if not set yet or an error occurs.
 */
- (NSString*)getAction:(NSError**)error;

/**
 * \brief Returns Retrieves the expiration date associated with requested action.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDNotImplemented if not implemented</li>
 * </ul>
 * </p>
 * \return the date, nil if not set yet or an error occurs.
 */
- (NSDate*)getExpiryDate:(NSError**)error;

/**
 * \brief Gets the CIBA authentication request id associated with the signed transaction.
 * \return The request ID as a string.
 */
- (NSString*)getRequestId:(NSError**)error;

/**
 * \brief Gets the signed OIDC ID Token associated with the signed transaction.
 * \return The ID Token as a string.
 */
- (NSString*)getIdToken:(NSError**)error;

@end
   
