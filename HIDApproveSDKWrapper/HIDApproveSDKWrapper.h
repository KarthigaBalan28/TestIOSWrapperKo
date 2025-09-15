//
//  ApproveSDKWrapper.h
//  ApproveSDKWrapper
//
//  Created by HID on 19/04/21.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
@interface HIDApproveSDKWrapper : NSObject
-(void)createContainer : (NSString *)activationCode withPushId :(NSString *)PushId withPwdCallBack:(JSValue *)pwdCallback withExCallback: (JSValue *) ExceptionCallback;
-(void)renewContainer : (NSString *)password withPwdCallBack:(JSValue *)promptCallback withExceptionCallBack: (JSValue *)ExceptionCallback;
-(int)getContainerRenewableDate;
-(void)setPasswordForUser : (NSString *)password;
-(NSString *)getLoginFlow : (NSString *)pushId callBack: (JSValue *) genericExecutionCallback;
-(void)generateOTP : (NSString *)password  isBioEnabled : (bool) bioEnabled withSuccessCB : (JSValue *)success_CB failureCB : (JSValue *)failure_CB;
-(void)enableBiometrics : (NSString *)password statusCB : (JSValue *)bioStatusCallback;
-(void)disableBiometrics;
-(bool)checkBioAvailability;
-(void) signTransaction : (NSString *)transactionDetails withPwdPromptCallback : (JSValue *) pwdPromptCallback withSuccessCB : (JSValue *) successCB withFailureCB : (JSValue *) failureCB;
-(NSString *) retreiveTransaction : (NSString *)txID withPassword : (NSString *)pwd
                     isBioEnabled : (bool)isBioEnabled withCallback : (JSValue*)callback;
-(void) setNotificationStatus : (NSString *) txID withStatus : (NSString *)status withPassword :pwd withJSCallback : (JSValue *) onCompleteCB withPwdPromptCB : (JSValue *)pwdPromptCB;
-(void)transactionCancel:(NSString *)txId withMessage:(NSString *)message withReason:(NSString *)reason withCallback:(JSValue *)cancelCallback;
-(void) notifyPassword : (NSString *) password withMode : (NSString *)mode;
-(void) updatePassword : (NSString *) oldPassword newPassword : (NSString *)newPassword exceptionCallback : (JSValue *)ExceptionCallback isPasswordPolicy : (bool) isPasswordPolicy;
-(void) retrievePendingNotifications : (JSValue *)callback;
-(NSString *) getPasswordPolicy ;
-(void) setUsername: (NSString* )username;
-(bool) deleteContainer;
-(bool) deleteContainerWithReason:(NSString *)reason;
-(void) deleteContainerWithAuth : (NSString *)pwd withCallback : (JSValue *) callback;
-(void) deleteContainerWithAuthWithReason : (NSString *)pwd withReason: (NSString *)reason withCallback : (JSValue *) callback;
-(void) verifyPassword : (NSString *) pwd isBioEnabled : (bool) isBioEnabled withCallback : (JSValue *) callback;
-(void)generateOTP : (NSString *)password  isBioEnabled : (bool) bioEnabled withSuccessCB : (JSValue *)success_CB failureCB : (JSValue *)failure_CB withOTPLabel : (NSString *) otpLabel;
-(void) signTransaction : (NSString *)transactionDetails withPwdPromptCallback : (JSValue *) pwdPromptCallback withSuccessCB : (JSValue *) successCB withFailureCB : (JSValue *) failureCB  withOTPLabel : (NSString *) otpLabel;
-(NSString *) getDeviceProperty;
-(NSString *) getContainerFriendlyName;
-(NSString *) getMultiContainerFriendlyName;
-(void) setContainerFriendlyName : (NSString *)username withFriendlyName: (NSString *)friendlyName withSetNameCallback : (JSValue *)setNameCallback;
-(NSString *) getLockPolicy:(NSString *)otp_Key withCode: (NSString *)code;
-(NSString *)getInfo;
-(NSString *)getKeyList;
-(void) directClientSignature : (NSString *)txMessage withKeyMode:(NSString *)keyMode withGenerateCallback:(JSValue *)generateCallback;
-(void)directClientSignatureWithStatus: (NSString *)consensus withPassword:(NSString *)password withBiometricEnabled:(BOOL)isBiometricEnabled withDCSCallback:(JSValue *)dcsCallback;
@end



