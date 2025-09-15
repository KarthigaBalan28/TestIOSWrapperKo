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

/**
 * \file HIDProtectionPolicy.h
 * \brief Security policy for the protection of sensitive data.
 *
 */

/**
 * \brief Known types of lock policy.
 */
typedef enum
{
    HIDLockTypeNone,     ///< The credential never locks.
    HIDLockTypeLock,     ///< The credential locks after a certain number of attempts.
    HIDLockTypeDelay,    ///< An exponential delay is added for each failed authentication attempt using that credential.
    HIDLockTypeSilent    ///< The credential access is limited by delegating validation and blocking to server-side controls.
} HIDLockType;

/**
 * \brief Lock Policy with specific access constraints.
 */
@protocol HIDLockPolicy

/**
 * \brief returns the lock policy type.
 * \return the lock policy type.
 */
- (HIDLockType)lockType;

@end

/**
 * \brief The access to the credential will be locked after a configurable number of failed attempts.
 */
@protocol HIDCounterLockPolicy <HIDLockPolicy>

/**
 * \brief Returns the max counter value of the credential before it gets locked.
 * \return the max counter value of the credential before it gets locked.
 */
- (int)counter;

@end

/**
 * \brief The access to the credential will be limited by applying an exponential delay for each failed attempt.
 * <p>
 * An exponential delay is added for each failed authentication attempt using that credential. <br>
 * In other words, a throttling mechanism in which the user has to wait a short time before attempting another try to 
 * prevent a potential attacker from guessing the password.
 * <p>
 * For each failed attempt a counter is incremented. The delay doubles for each failed attempt, but to avoid creating too 
 * much delay the counter value is capped at {@link #counter}. <br>  
 * This counter is reset on the next successful authentication attempt.
 * </p>
 * For example, with an initial {@link #delay} of <b>2 seconds</b> and a max {@link #counter} of <b>6 attempts</b> we have the following:
 * <table border="1px" cellspacing="0" summary="">
 *  <tr><td>Attempts</td> <td>Seconds Delay</td></tr>
 *  <tr><td><tt>1</tt></td> <td><tt>2^1 = 2</tt></td></tr>
 *  <tr><td><tt>2</tt></td> <td><tt>2^2 = 4</tt></td></tr>
 *  <tr><td><tt>3</tt></td> <td><tt>2^3 = 8</tt></td></tr>
 *  <tr><td><tt>4</tt></td> <td><tt>2^4 = 16</tt></td></tr>
 *  <tr><td><tt>5</tt></td> <td><tt>2^5 = 32</tt></td></tr>
 *  <tr><td><tt>6 or more</tt></td> <td><tt>2^6 = 64</tt></td></tr>
 * </table>
 * <br>
 * An attacker trying to brute force the password after the 6th attempt will incur a 1 minute delay for each password attempt. <br>
 * Therefore based on minimum length 6 with a numeric password policy this could mean 10^6 minutes to find the right password (2 years)
 * @see
 * <p>
 * NIST recommended mechanism according to SP 800-63-3<br>
 * <a href="https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-63-3.pdf">https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-63-3.pdf</a>
 * </p>
 */
@protocol HIDDelayLockPolicy <HIDLockPolicy>

/**
 * \brief Returns the maximum counter value after which exponential delay is fixed.
 * \return the maximum counter value after which exponential delay is fixed.
 */
- (int)counter;

/**
 * \brief Returns the initial delay in seconds.
 * \return the initial delay in seconds.
 */
- (int)delay;

@end

/**
 * \brief Protection policy types.
 */
typedef enum
{
    HIDPolicyTypePassword,       ///< Item is protected by a password provided by the user.
    HIDPolicyTypeDevice,         ///< Item is protected by device-specific information.
    HIDPolicyTypeBioPassword     ///< Item is protected by external biometric policy.
    
} HIDPolicyType;

/**
 * \brief The protection policy defines the security parameters associated with a key or data item.
 */
@protocol HIDProtectionPolicy <NSObject>

/**
 * \brief Returns the protection policy identifier.
 * \return the protection policy ID.
 */
- (HIDIdentifier*)policyId;

/**
 * \brief Returns the protection policy type.
 * \return the protection policy type.
 */
- (HIDPolicyType)policyType;

/**
 * \brief Returns the lock policy.
 * \return the lock policy.
 */
- (id<HIDLockPolicy>)lockPolicy;

@end

/**
 * \brief Protection Policy with password specific constraints.
 * <p>
 * The restrictions may be any or all of the following:
 * <ul>
 * <li>Min and max character length</li>
 * <li>Min number of uppercase characters</li>
 * <li>Min number of lowercase characters</li>
 * <li>Min number of numeric characters</li>
 * <li>Min number of letter characters</li>
 * <li>Min number of symbol (non alphanumeric) characters</li>
 * <li>Max number of uppercase characters</li>
 * <li>Max number of lowercase characters</li>
 * <li>Max number of numeric characters</li>
 * <li>Max number of letter characters</li>
 * <li>Max number of symbol (non alphanumeric) characters</li>
 * <li>Min and Max age</li>
 * <li>Max password history</li>
 * <li>Allow/prohibit sequential characters</li>
 * </ul>
 * </p>
 */
@protocol HIDPasswordPolicy <HIDProtectionPolicy>
/**
 * \brief Changes the password bound to the protection policy identified by the protection policyId parameter. New password must respect the defined protection policy restrictions.
 * \param oldPassword old key password.
 * \param newPassword new key password.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDAuthentication if old key password is incorrect</li>
 * <li>#HIDInternal if unexpected error occurred.</li>
 * <li>#HIDInvalidPassword if new key password is not accepted by protection policy</li>
 * <li>#HIDPasswordNotYetUpdatable if the policy indicates that it is too early to update the password. </li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return YES if password was successfully changed.
 */
- (BOOL)changePassword:(NSString*)oldPassword new:(NSString*)newPassword error:(NSError**)error;

/**
 * \brief When password caching is enabled, will verify and cache the password protecting the key for transaction signing. The cache is deleted when cache timeout is reached or cached password is used.
 * \param password the key password.
 * \param error error details. It may be nil.
 * <p>
 * Possible error codes are:
 * <ul>
 * <li>#HIDAuthentication if password is incorrect.</li>
 * <li>#HIDInvalidArgument if the given parameters are invalid or required parameters are missing.</li>
 * </ul>
 * </p>
 * \return The key in its primary encoding format, or nil if an error occurred.
 * \see #HIDPasswordPolicy.getCacheTimeout()
 * \see #HIDPasswordPolicy.isCacheEnabled()
 */
- (BOOL)verifyPassword:(NSString*)password error:(NSError**)error;

/**
 * \brief Get minimum password length.
 * \return the minimum password length.
 */
- (int)minLength;

/**
 * \brief Get maximum password length.
 * \return the maximum password length.
 */
- (int)maxLength;

/**
 * \brief Get minimum number of upper case letters.
 * \return the minimum number of upper case letters.
 */
- (int)minUpperCase;

/**
 * \brief Get minimum number of lower case letters.
 * \return the minimum number of lower case letters.
 */
- (int)minLowerCase;

/**
 * \brief Get the minimum number of numeric characters.
 * \return the minimum number of digits.
 */
- (int)minNumeric;

/**
 * \brief Get minimum number of special characters (non alphanumeric).
 * \return the minimum number of special characters.
 */
- (int)minNonAlpha;

/**
 * \brief Get minimum number of alphabetical characters.
 * \return the minimum number of alphabetical characters.
 */
- (int)minAlpha;

/**
 * \brief Get maximum number of upper case letters.
 * \return the maximum number of upper case letters.
 */
- (int)maxUpperCase;

/**
 * \brief Get maximum number of lower case letters.
 * \return the maximum number of lower case letters.
 */
- (int)maxLowerCase;

/**
 * \brief Get maximum number of numeric characters.
 * \return the maximum number of digits.
 */
- (int)maxNumeric;

/**
 * \brief Get maximum number of special characters (non alphanumeric).
 * \return the maximum number of special characters.
 */
- (int)maxNonAlpha;

/**
 * \brief Get maximum number of alphabetical characters.
 * \return the maximum number of alphabetical characters.
 */
- (int)maxAlpha;

/**
 * \brief Get minimum age for a password change.  This security setting
 * determines the period of time (in days) that a password must be used before
 * the user can change it.  It must be less than the maximum password age.
 * If 0, indicates to allow changes immediately.
 * \return the minimum password age in days.
 */
- (int)minAge;

/**
 * \brief Get maximum age for a password.  This determines how long (in days)
 * users can keep a password before they have to change it.
 * If 0, indicates that the password never expires.
 * \return the maximum password age in days.
 */
- (int)maxAge;

/**
 * \brief Get current password age since last change.
 * \return the current password age in days.
 */
- (int)currentAge;

/**
 * \brief Get max password history limit.  This security setting
 * determines the number of unique new passwords that have to be associated with
 * the the key before an old password can be reused.
 * \return the maximum password history size.
 */
- (int)maxHistory;

/**
 * \brief Gets password cache flag.
 * \return whether password cache is enabled.
 */
- (BOOL)isCacheEnabled;

/**
 * \brief Gets password sequence allowed flag.
 * \return sequence allowed
 */
- (BOOL)isSequenceAllowed;

/**
 * \brief Gets password cache timeout.
 * \return the cache timeout in seconds.
 */
- (int)getCacheTimeout;
@end

/**
 * \brief Working state of authentication with biometrics.
 */
typedef enum
{
    HIDBioAuthenticationStateEnabled,       ///< Authentication with biometrics is enabled, the SDK will accept password as nil in authentication methods.
    HIDBioAuthenticationStateNotEnabled,    ///< Authentication with biometrics is not enabled. To enable, a call to HIDBioPasswordPolicy.enableBioAuthentication is required.
    HIDBioAuthenticationStateNotCapable,    ///< The device has no biometric sensor, authentication with biometrics is not possible.
    HIDBioAuthenticationStateNotEnrolled,    ///< The user did not enrolled biometric features at the device level, authentication with biometrics cannot be enabled.
    HIDBioAuthenticationStateInvalidKey    ///< the cryptographic key has been invalidated.
} HIDBioAuthenticationState;

/**
 * \brief Protection policy with authentication with biometrics or password.
 */
@protocol HIDBioPasswordPolicy<HIDPasswordPolicy>

/**
 * \brief Enable authentication with biometrics.
 * \param sPassword the password of this policy.
 * \param error error details. It may be nil. 
 * \return true if successful.
 */
- (BOOL)enableBioAuthentication:(NSString*)sPassword error:(NSError**)error;

/**
 * \brief Disable authentication with biometrics.
 * \param error error details. It may be nil.
 * \return true if successful.
 */
- (BOOL)disableBioAuthentication:(NSError**)error;

/**
 * \brief Returns the current working state of authentication with biometrics.
 * \return the current working state of authentication with biometrics.
 */
- (HIDBioAuthenticationState)getBioAuthenticationState;

@end

/**
 * \brief Protection Policy with device derived key protection.
 */
@protocol HIDDevicePolicy <HIDProtectionPolicy>

@end

