//
//  HIDWrapperConstants.m
//  HIDApproveSDKWrapper
//
//  Created by HID on 15/06/21.
//

#import<Foundation/Foundation.h>
#import<HIDWrapperConstants.h>
#import<HID_Approve_SDK/HIDTransaction.h>

NSString *const PWD_PROMPT_PROGRESS_EVENT_CODE = @"5000";
NSString *const PWD_PROMPT_PROGRESS_EVENT_TYPE = @"Progress";
NSString *const SIGN_TRANSACTION_FLOW = @"SIGN_TRASACTION";
NSString *const PWD_PROMPT_ERROR_EVENT_TYPE = @"Error";
NSString *const PWD_PROMPT_ERROR_EVENT_CODE = @"5001";
NSString *const PWD_EXPIRED_PROMPT_EVENT_CODE = @"5002";
NSString *const SDK_ERROR_MSG_KEY = @"hid.error.msg";
NSInteger const RENEW_EXPIRY_NOTIFICATION_DAYS = 20;
NSString *const BIO_ALREADY_ENROLLED = @"because it is enabled by another User in this Device";
NSString *const HID_GENERIC_EXCEPTION = @"Exception";
NSString *const HID_FINGERPRINT_EXCEPTION = @"FingerprintException";
NSString *const BIO_NOT_ENABLED = @"NoBioAuth";
NSString* const AUTH_EXCEPTION_CODE = @"5001";
NSString* const TRANSACTION_EXPIRED_CODE = @"1000";
NSString* const NO_EXCEPTION_CODE = @"2000";
NSString* const GENERIC_EXCEPTION_CODE = @"6000";
NSString* const BIO_ERROR_CODE = @"5003";
NSString* const BIO_FAILED_CODE = @"5004";
NSString* const BIO_ERROR = @"BiometricError";
NSString* const BIO_FAILED = @"BiometricFailed";
//Keys
NSString* const HOTP_LABEL_NAME = @"hotp";
NSString* const TOTP_LABEL_NAME = @"totp";
NSString* const HOTP_OTP_KEY = @"OATH_event";
NSString* const TOTP_OTP_KEY = @"OATH_time";
NSString* const HOTP_SIGN_KEY = @"OATH_OCRA_event_SIGN";
NSString* const TOTP_SIGN_KEY = @"OATH_OCRA_time_SIGN";
NSString* const PUSH_KEY_PUBLIC_LABEL_NAME = @"pkp";
NSString* const PUSH_KEY_IDP_PUBLIC_LABEL_NAME = @"pkip";
NSString* const SIGN_KEY_PUBLIC_LABEL_NAME = @"skp";
NSString* const PUSH_KEY_PUBLIC_LABEL = @"pushkeyPublic";
NSString* const PUSH_KEY_IDP_PUBLIC_LABEL = @"pushhkeyIDPPublic";
NSString* const SIGN_KEY_PUBLIC_LABEL = @"signkeyPublic";

NSString* const AC_USERID_KEY = @"userid";
NSString* const AC_SERVICE_KEY = @"serviceurl";
NSString* const AC_INVITE_CODE_KEY = @"invitecode";
NSString* const CONTAINER_FLOW_IDENTIFIER = @"dty";

NSString* const AUTHENTICATION_EXCEPTION_NAME = @"AuthenticationException";
NSString* const TRANSACTION_EXPIRED_EXCEPTION_NAME = @"TransactionExpiredException";
NSString* const FINGERPRINT_AUTH_REQUIRED_EXCEPTION_NAME = @"FingerprintAuthenticationRequiredException";
NSString* const FINGERPRINT_NOT_ENROLLED_EXCEPTION_NAME = @"FingerprintNotEnrolledException";
NSString* const GOOGLE_PLAY_SERVICES_OBSOLETE_EXCEPTION_NAME = @"GooglePlayServicesObsoleteException";
NSString* const INTERNAL_EXCEPTION_NAME = @"InternalException";
NSString* const INVALID_PASSWORD_EXCEPTION_NAME = @"InvalidPasswordException";
NSString* const LOST_CREDENTIALS_EXCEPTION_NAME = @"LostCredentialsException";
NSString* const PASSWORD_CANCELLED_EXCEPTION_NAME = @"PasswordCancelledException";
NSString* const PASSWORD_EXPIRED_EXCEPTION_NAME = @"PasswordExpiredException";
NSString* const PASSWORD_REQUIRED_EXCEPTION_NAME = @"PasswordRequiredException";
NSString* const REMOTE_EXCEPTION_NAME = @"RemoteException";
NSString* const SERVER_AUTH_EXCEPTION_NAME = @"ServerAuthenticationException";
NSString* const SERVER_OPERATION_FAILED_EXCEPTION_NAME = @"ServerOperationFailedException";
NSString* const SERVER_PROTOCOL_EXCEPTION_NAME = @"ServerProtocolException";
NSString* const UNSAFE_DEVICE_EXCEPTION_NAME = @"UnsafeDeviceException";
NSString* const UNSUPPORTED_DEVICE_EXCEPTION_NAME = @"UnsupportedDeviceException";
NSString* const DEVICE_ID = @"deviceid";
NSString* const INVALID_PARAMETER_EXCEPTION = @"InvalidParameterException";
NSString* const UNSUPPORTED_DEVICE_CODE = @"200";
NSString* const LOST_CREDENTIALS_CODE = @"106";
NSString* const INTERNAL_EXCEPTION_CODE = @"0";
NSString* const INVALID_PARAMETER_CODE = @"3";

NSString* const HID_INVALID_ARGUMENT_EXCEPTION_NAME = @"HIDInvalidArgumentException";
NSString* const HID_UNSUPPORTED_VERSION_EXCEPTION_NAME = @"HIDUnsupportedVersionException";
NSString* const HID_UNSUPPORTED_DEVICE_EXCEPTION_NAME = @"HIDUnsupportedDeviceException";
NSString* const HID_SERVER_PROTOCOL_EXCEPTION_NAME = @"HIDServerProtocolException";
NSString* const HID_UNSUPPORTED_OPERATION_MODE_EXCEPTION_NAME = @"HIDUnsupportedOperationModeException";
NSString* const HID_SERVER_OPERATION_FAILED_EXCEPTION_NAME = @"HIDServerOperationFailedException";
NSString* const HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME = @"HIDCredentialsExpiredException";
NSString* const HID_INVALID_CONTAINER_EXCEPTION_NAME = @"HIDInvalidContainerException";
NSString* const HID_INEXPLICIT_CONTAINER_EXCEPTION_NAME = @"HIDInexplicitContainerException";
NSString* const HID_SERVER_VERSION_EXCEPTION_NAME = @"HIDServerVersionException";
NSString* const HID_SERVER_UNSUPPORTED_OPERATION_NAME = @"HIDServerUnsupportedOperationException";
NSString* const HID_TRANSACTION_CANCELED_EXCEPTION_NAME = @"HIDTransactionCanceledException";
NSString* const HID_TRANSACTION_SIGNED_EXCEPTION_NAME = @"HIDTransactionSignedException";

NSString* const CODE_SECURE = @"secure";
NSString* const CODE_SIGN = @"sign";

HIDCancelationReasonCode const CANCELATION_REASON_CANCEL = USER_CANCEL;
HIDCancelationReasonCode const CANCELATION_REASON_SUSPICIOUS = NOTIFY_SUSPICIOUS;



