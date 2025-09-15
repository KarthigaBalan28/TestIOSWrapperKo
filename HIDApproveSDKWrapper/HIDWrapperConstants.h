//
//  HIDWrapperConstants.h
//  HIDApproveSDKWrapper
//
//  Created by HID on 15/06/21.
//
#import <Foundation/Foundation.h>
#import<HID_Approve_SDK/HIDTransaction.h>

extern NSString* const PWD_PROMPT_PROGRESS_EVENT_CODE;
extern NSString* const PWD_PROMPT_PROGRESS_EVENT_TYPE;
extern NSString* const PWD_PROMPT_ERROR_EVENT_CODE;
extern NSString* const PWD_PROMPT_ERROR_EVENT_TYPE;
extern NSString* const SIGN_TRANSACTION_FLOW;
extern NSString* const SDK_ERROR_MSG_KEY;
extern NSInteger const RENEW_EXPIRY_NOTIFICATION_DAYS;
extern NSString* const PWD_EXPIRED_PROMPT_EVENT_CODE;
extern NSString* const BIO_ALREADY_ENROLLED;
extern NSString* const HID_GENERIC_EXCEPTION;
extern NSString* const HID_FINGERPRINT_EXCEPTION;
extern NSString* const BIO_NOT_ENABLED;
extern NSString* const AUTH_EXCEPTION_CODE;
extern NSString* const TRANSACTION_EXPIRED_CODE;
extern NSString* const NO_EXCEPTION_CODE;
extern NSString* const GENERIC_EXCEPTION_CODE;
extern NSString* const BIO_ERROR_CODE;
extern NSString* const BIO_FAILED_CODE;
extern NSString* const BIO_ERROR;
extern NSString* const BIO_FAILED;
//Keys
extern NSString* const HOTP_LABEL_NAME;
extern NSString* const TOTP_LABEL_NAME;
extern NSString* const HOTP_OTP_KEY;
extern NSString* const TOTP_OTP_KEY;
extern NSString* const HOTP_SIGN_KEY;
extern NSString* const TOTP_SIGN_KEY;
extern NSString* const PUSH_KEY_PUBLIC_LABEL_NAME;
extern NSString* const PUSH_KEY_IDP_PUBLIC_LABEL_NAME;
extern NSString* const SIGN_KEY_PUBLIC_LABEL_NAME;
extern NSString* const PUSH_KEY_PUBLIC_LABEL;
extern NSString* const PUSH_KEY_IDP_PUBLIC_LABEL;
extern NSString* const SIGN_KEY_PUBLIC_LABEL;

extern NSString* const CONTAINER_FLOW_IDENTIFIER;
extern NSString* const AC_USERID_KEY;
extern NSString* const AC_SERVICE_KEY;
extern NSString* const AC_INVITE_CODE_KEY;
extern NSString* const AUTHENTICATION_EXCEPTION_NAME;
extern NSString* const TRANSACTION_EXPIRED_EXCEPTION_NAME;
extern NSString* const FINGERPRINT_AUTH_REQUIRED_EXCEPTION_NAME;
extern NSString* const FINGERPRINT_NOT_ENROLLED_EXCEPTION_NAME;
extern NSString* const GOOGLE_PLAY_SERVICES_OBSOLETE_EXCEPTION_NAME;
extern NSString* const INTERNAL_EXCEPTION_NAME;
extern NSString* const INVALID_PASSWORD_EXCEPTION_NAME;
extern NSString* const LOST_CREDENTIALS_EXCEPTION_NAME;
extern NSString* const PASSWORD_CANCELLED_EXCEPTION_NAME;
extern NSString* const PASSWORD_EXPIRED_EXCEPTION_NAME;
extern NSString* const PASSWORD_REQUIRED_EXCEPTION_NAME;
extern NSString* const REMOTE_EXCEPTION_NAME;
extern NSString* const SERVER_AUTH_EXCEPTION_NAME;
extern NSString* const SERVER_OPERATION_FAILED_EXCEPTION_NAME;
extern NSString* const SERVER_PROTOCOL_EXCEPTION_NAME;
extern NSString* const UNSAFE_DEVICE_EXCEPTION_NAME;
extern NSString* const UNSUPPORTED_DEVICE_EXCEPTION_NAME;
extern NSString* const DEVICE_ID;
extern NSString* const INVALID_PARAMETER_EXCEPTION;
extern NSString* const UNSUPPORTED_DEVICE_CODE;
extern NSString* const LOST_CREDENTIALS_CODE;
extern NSString* const INTERNAL_EXCEPTION_CODE;
extern NSString* const INVALID_PARAMETER_CODE;

extern NSString* const HID_INVALID_ARGUMENT_EXCEPTION_NAME;
extern NSString* const HID_UNSUPPORTED_VERSION_EXCEPTION_NAME;
extern NSString* const HID_UNSUPPORTED_DEVICE_EXCEPTION_NAME;
extern NSString* const HID_SERVER_PROTOCOL_EXCEPTION_NAME;
extern NSString* const HID_UNSUPPORTED_OPERATION_MODE_EXCEPTION_NAME;
extern NSString* const HID_SERVER_OPERATION_FAILED_EXCEPTION_NAME;
extern NSString* const HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME;
extern NSString* const HID_INVALID_CONTAINER_EXCEPTION_NAME;
extern NSString* const HID_INEXPLICIT_CONTAINER_EXCEPTION_NAME;
extern NSString* const HID_SERVER_VERSION_EXCEPTION_NAME;
extern NSString* const HID_SERVER_UNSUPPORTED_OPERATION_NAME;
extern NSString* const HID_TRANSACTION_CANCELED_EXCEPTION_NAME;
extern NSString* const HID_TRANSACTION_SIGNED_EXCEPTION_NAME;

extern NSString* const CODE_SECURE;
extern NSString* const CODE_SIGN;

extern const HIDCancelationReasonCode CANCELATION_REASON_CANCEL;
extern const HIDCancelationReasonCode CANCELATION_REASON_SUSPICIOUS;

