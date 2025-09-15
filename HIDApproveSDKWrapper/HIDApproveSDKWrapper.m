//
//  ApproveSDKWrapper.m
//  ApproveSDKWrapper
//
//  Created by HID on 19/04/21.
//
#import "HIDApproveSDKWrapper.h"
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <HID_Approve_SDK/HIDContainer.h>
#import <HID_Approve_SDK/HIDProtectionPolicy.h>
#import <HID_Approve_SDK/HIDDevice.h>
#import <HID_Approve_SDK/HIDParameter.h>
#import <HID_Approve_SDK/HIDOTPGenerator.h>
#import <HID_Approve_SDK/HIDSyncOTPGenerator.h>
#import <HID_Approve_SDK/HIDAsyncOTPGenerator.h>
#import <HID_Approve_SDK/HIDConstants.h>
#import <HID_Approve_SDK/HIDErrors.h>
#import <HID_Approve_SDK/HIDOCRAGenerator.h>
#import <HID_Approve_SDK/HIDServerActionInfo.h>
#import <HID_Approve_SDK/HIDKey.h>
#import "HIDWrapperConstants.h"
@interface ContainerEventListener : NSObject <HIDProgressListener>
@property (strong) dispatch_group_t group;
@property (nonatomic , strong) NSString* monitorObj;
@property (strong) JSValue *pwdCallback;
@property (strong) JSValue *exceptionCallback;
@end

@implementation ContainerEventListener

/**
* This is the initializer for the ContainerEventListener class.
* @param pwdCallback is the callback to handle password prompts.
* @param exceptionCallback is the callback to handle exceptions.
*
* @returns id - an instance of ContainerEventListener
*/
- (id)initWithParams:(JSValue*) pwdCallback withExceptionCallback :(JSValue*) exceptionCallback
{
    self = [super init];
    self.pwdCallback = pwdCallback;
    self.exceptionCallback = exceptionCallback;
    return self;
}

/**
* This method is called when an event is received from the HID SDK. It checks if the event is a password prompt event and handles it accordingly.
*
* @param event is the HIDEvent that is received
* @returns HIDEventResult - an instance of HIDEventResult with the appropriate code and password if applicable
*/
-( HIDEventResult*)onEventReceived:(NSObject<HIDEvent>*)event {
    NSLog(@"ApproveSDKWrapper ---> HID:HIDEventResult_onEventReceived Event Triggered");
    if ([event isKindOfClass:[HIDPasswordPromptEvent class]]) {
        NSLog(@"ApproveSDKWrapper ---> HID:HIDEventResult_onEventReceived Password Event Triggered");
        HIDPasswordPromptEvent* pwdEvent = (HIDPasswordPromptEvent*)event;
        id<HIDPasswordPolicy> pwdPolicy = [pwdEvent passwordPolicy];
        NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[NSNumber alloc] initWithInt:([pwdPolicy minLength])],@"minLength",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxLength])],@"maxLength",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minNumeric])],@"minNumeric",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxNumeric])],@"maxNumeric",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minAlpha])],@"minAlpha",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxAlpha])],@"maxAlpha",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxUpperCase])],@"maxUpperCase",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minUpperCase])],@"minUpperCase",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxLowerCase])],@"maxLowerCase",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minLowerCase])],@"minLowerCase",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxAge])],@"maxAge",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxNonAlpha])],@"maxSpl",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minNonAlpha])],@"minSpl",
                             nil];
        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options: NSJSONWritingPrettyPrinted error:&jsonError];
        if(!jsonData){
            NSLog(@"ApproveSDKWrapper ---> HID:HIDEventResult_onEventReceived Error while converting JSON %@", jsonError);
        }else{
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            //NSLog(@"PasswordPolicy is %@", jsonString);
            dispatch_async(dispatch_get_main_queue(),^{
                if(self.pwdCallback != nil){
                    [self.pwdCallback callWithArguments:@[@"",jsonString]];
                }
            });
        }
        self.group = dispatch_group_create();
        dispatch_group_enter(self.group);
        //NSLog(@"Waiting for Password Input");
        dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
        //NSLog(@"Got Notified with password %@",self.monitorObj);
        NSString* pwd = self.monitorObj;
        self.monitorObj = nil;
        return [[HIDPasswordPromptResult alloc] initWithCode:Continue andPassword:pwd];
    }
    return [[HIDEventResult alloc] initWithCode:(Continue)];
}

/**
* This method is called to notify the listener with the password input.
*
* @param password is the password input provided by the user
*/
- (void)notifyPasswordToListener : (NSString*) password{
    self.monitorObj = password;
    //NSLog(@"Notifying with password");
    dispatch_group_leave(self.group);
}
@end

//Transaction Event Listener

@interface TransactionMonitor : NSObject
@property (nonatomic, strong) id<HIDTransaction> transaction;
@property (nonatomic, strong) NSString *consensus;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL isBiometricEnabled;
- (void)setTransaction:(id<HIDTransaction>)transaction;
- (id<HIDTransaction>)getTransaction;
- (void)setUserInputWithConsensus:(NSString *)consensus
                         password:(NSString *)password
              biometricEnabled:(BOOL)isBiometricEnabled;
- (void)waitForUserInput;
- (void)clear;
@end
@implementation TransactionMonitor {
    NSCondition *_condition;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _condition = [[NSCondition alloc] init];
    }
    return self;
}
- (void)setTransaction:(id<HIDTransaction>)transaction {
    @synchronized (self) {
        _transaction = transaction;
    }
}
- (id<HIDTransaction>)getTransaction {
    @synchronized (self) {
        return _transaction;
    }
}
- (void)setUserInputWithConsensus:(NSString *)consensus
                         password:(NSString *)password
              biometricEnabled:(BOOL)isBiometricEnabled {
    [_condition lock];
    _consensus = consensus;
    _password = password;
    _isBiometricEnabled = isBiometricEnabled;
    [_condition signal]; // Notify waiting thread
    [_condition unlock];
}
- (void)waitForUserInput {
    [_condition lock];
    [_condition wait]; // Wait until user input is set
    [_condition unlock];
}
- (void)clear {
    @synchronized (self) {
        _transaction = nil;
        _consensus = nil;
        _password = nil;
        _isBiometricEnabled = NO;
    }
}
@end


@interface HIDApproveSDKWrapper()
@property (strong) ContainerEventListener* eventListener;
@property (strong , nonatomic) NSString* tsMonitorObj;
@property (nonatomic, strong) TransactionMonitor *transactionMonitor;
@property (strong) dispatch_group_t tsGroup;
@property (strong, nonatomic) NSString* username;
@end

@implementation HIDApproveSDKWrapper : NSObject

/**
* This method is used to create the container.
*
* @param activationCode - ActivationCode/Provision String to create the container.
* @param PushId - Push ID to be set for the container.
* @param pwdCallback - Callback to handle the password prompt.
* @param ExceptionCallback - Callback to handle exceptions.
*/
-(void)createContainer:(NSString *)activationCode withPushId:(NSString *)PushId withPwdCallBack:(JSValue *)pwdCallback withExCallback:(JSValue *)ExceptionCallback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSLog(@"ApproveSDKWrapper ---> HID:createContainer createContainer is called");
        NSError* deviceError;
        NSError* containerError;
        NSError *jsonError;
        NSData *objectData = [activationCode dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *acJson = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&jsonError];        HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
        if(jsonError != nil){
            NSLog(@"ApproveSDKWrapper ---> HID:createContainer %@",[jsonError localizedDescription]);
            [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"Invalid ActivationCode Format",[jsonError localizedDescription]])];
            return;
        }
        id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
        HIDContainerInitialization *containerInitialization = [[HIDContainerInitialization alloc] init];
        NSLog(@"ApproveSDKWrapper ---> HID:createContainer Provision String: %@" ,activationCode);
        if([[acJson allKeys] containsObject:CONTAINER_FLOW_IDENTIFIER]){
            containerInitialization.activationCode = activationCode;
            NSLog(@"ApproveSDKWrapper ---> HID:createContainer Automatic Activation");
        }
        else{
            NSLog(@"ApproveSDKWrapper ---> HID:createContainer Manual Activaion");
            containerInitialization.userId = [acJson objectForKey:AC_USERID_KEY];
            containerInitialization.serverURL = [acJson objectForKey:AC_SERVICE_KEY];
            containerInitialization.inviteCode = [acJson objectForKey:AC_INVITE_CODE_KEY];
        }
        if(![self isEmptyString:PushId]){
            NSData *pushIdData = [self  dataFromHexString:PushId];
            NSString* pushIDFinal = [pushIdData base64EncodedStringWithOptions:NSUTF8StringEncoding];
            NSLog(@"ApproveSDKWrapper ---> HID:createContainer PushId after Encoding is %@",pushIDFinal);
            containerInitialization.pushId =pushIDFinal;
        }
        self.eventListener = [[ContainerEventListener alloc] initWithParams:(pwdCallback) withExceptionCallback:(ExceptionCallback)];
        id<HIDContainer> pContainer = [pDevice createContainer:containerInitialization  withSessionPassword:nil withListener:self.eventListener error:&containerError];
        if(deviceError != nil){
            NSLog(@"ApproveSDKWrapper ---> HID:createContainer Device Error while creating container %@", [deviceError localizedDescription]);
            int deviceErrCode = (int)[deviceError code];
            if(deviceErrCode == 0){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[INTERNAL_EXCEPTION_NAME,[deviceError localizedDescription]])];
            }else if(deviceErrCode == 3){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,[deviceError localizedDescription]])];
            }else if(deviceErrCode == 7){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[HID_UNSUPPORTED_VERSION_EXCEPTION_NAME,[deviceError localizedDescription]])];
            }else if (deviceErrCode == 106){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[LOST_CREDENTIALS_EXCEPTION_NAME,[deviceError localizedDescription]])];
            }else{
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"Device Error",[deviceError localizedDescription]])];
            }
        }
        else if(containerError != nil){
            NSLog(@"ApproveSDKWrapper ---> HID:createContainer error while creating container %@", [containerError localizedDescription]);
            int errorCode = (int)[containerError code];
            if(errorCode == 100){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[AUTHENTICATION_EXCEPTION_NAME,@(errorCode)])];
                NSLog(@"ApproveSDKWrapper ---> HID:createContainer Authentication Exception %d %@", errorCode, [containerError localizedDescription]);
            }else if(errorCode == 204){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[FINGERPRINT_AUTH_REQUIRED_EXCEPTION_NAME,@(errorCode)])];
                NSLog(@"ApproveSDKWrapper ---> HID:createContainer Fingerprint Exception %d %@", errorCode, [containerError localizedDescription]);
            }else if(errorCode == 202){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[FINGERPRINT_NOT_ENROLLED_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 206){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[GOOGLE_PLAY_SERVICES_OBSOLETE_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 101){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[INVALID_PASSWORD_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 106){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[LOST_CREDENTIALS_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 109){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[PASSWORD_CANCELLED_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 303){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[REMOTE_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 300){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[SERVER_AUTH_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 200){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[HID_UNSUPPORTED_DEVICE_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 0){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[INTERNAL_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 302){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[HID_SERVER_PROTOCOL_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 205){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[HID_UNSUPPORTED_OPERATION_MODE_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 305){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[HID_SERVER_OPERATION_FAILED_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 3){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,@(errorCode)])];
            }else{
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"Container Error",[containerError localizedDescription]])];
            }
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:createContainer Container Creation Complete");
            [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"No  Error",@"success"])];
        }});
    
}

/**
* This method is used to execute a callback with parameters.
*
* @param callback - The JSValue callback to be executed.
* @param params - An array of parameters to be passed to the callback.
*/
-(void) executeGenericCallback : (JSValue *)callback withParams : (NSArray *)params{
    NSLog(@"ApproveSDKWrapper ---> HID:executeGenericCallback params count = %lu", (unsigned long)params.count);

    for (NSUInteger i = 0; i < params.count; i++) {
        id param = [params objectAtIndex:i];
        NSLog(@"ApproveSDKWrapper ---> HID:executeGenericCallback Param[%lu]: %@", (unsigned long)i, param);
    }
    if(callback != nil){
        dispatch_async(dispatch_get_main_queue(),^{
            [callback callWithArguments:(params)];
        });
    }
}

/**
* This method is used to renew the user container.
*
* @param password - Password to be used for renewing the container.
* @param promptCallback - Callback to handle password prompts.
* @param ExceptionCallback - Callback to handle exceptions.
*/
-(void) renewContainer:(NSString *)password withPwdCallBack:(JSValue *)promptCallback withExceptionCallBack:(JSValue *)ExceptionCallback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{NSLog(@"ApproveSDKWrapper ---> HID:renewContainer renewContainer is called");
        NSError* renewalError;
        NSError* error;
        id<HIDContainer> currentContainer = [self getSingleUserContainer];
        if(currentContainer == nil){
            NSLog(@"ApproveSDKWrapper ---> HID:renewContainer No Containers Found");
            [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"Container Exception",@"Exception while fetching the container"])];
            return;
        }
        Boolean isRenewable = [currentContainer isRenewable:@"" error:&error];
        if(error != nil){
            NSLog(@"ApproveSDKWrapper ---> HID:renewContainer error while fetching container Renewal %@", [error localizedDescription]);
            [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"Renewal Error",[error localizedDescription]])];
        }
        //cannot process with renew if container is not renewable
        if (!isRenewable) {
            NSLog(@"ApproveSDKWrapper ---> HID:renewContainer Container is not Renewable");
            [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"Renewal Exception",@"Exception container is not renewable"])];
            return;
        }
        // Container creation configuration
        HIDContainerRenewal* config = [[HIDContainerRenewal alloc] init];
        //Set PushId nil if empty
        [config setPushId:nil];
        //Set container friendly name from the existing container
        NSString *containerFriendlyName = [self getContainerFriendlyName];
        if(containerFriendlyName == nil || [containerFriendlyName isEqualToString:@""]){
            NSLog(@"ApproveSDKWrapper ---> HID:renewContainer Container Friendly Name is empty, setting to HID");
            containerFriendlyName = @"HID";
        }else{
            [config setContainerFriendlyName:containerFriendlyName];
        }
        NSLog(@"ApproveSDKWrapper ---> HID:renewContainer Container Friendly Name is %@", containerFriendlyName);
        // Change setContainerFriendlyName to below mentioned code once SDK bug is fixed
        //[config setContainerFriendlyName:[currentContainer getName]];
        //set container password(if device policy used set an empty password)
        [config setPassword:password];
        
        ContainerEventListener* renewListener = [[ContainerEventListener alloc] initWithParams:(promptCallback) withExceptionCallback:(ExceptionCallback)];
        
        [currentContainer renew:config withSessionPassword:@"" withListener:renewListener error:&renewalError];
        
        if(renewalError != nil){
            NSLog(@"ApproveSDKWrapper ---> HID:renewContainer error while renewing container %@", [renewalError localizedDescription]);
            NSLog(@"ApproveSDKWrapper ---> HID:renewContainer Exception in renewing container %d",(int)[error code]);
            int errorCode = (int)[renewalError code];
            if(errorCode == 100){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[AUTHENTICATION_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 106){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[LOST_CREDENTIALS_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 105 || errorCode == 203){
                NSLog(@"ApproveSDKWrapper ---> HID:renewContainer Biometric cancled or Password not entered");
                [self executeGenericCallback:(promptCallback) withParams:(@[PWD_PROMPT_PROGRESS_EVENT_TYPE,PWD_PROMPT_PROGRESS_EVENT_CODE])];
            }else if(errorCode == 200){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[UNSUPPORTED_DEVICE_EXCEPTION_NAME,[renewalError localizedDescription]])];
            }else if(errorCode == 0){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[INTERNAL_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 300){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[SERVER_AUTH_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 101){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[INVALID_PASSWORD_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 103){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[PASSWORD_EXPIRED_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 303){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[REMOTE_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 302){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[SERVER_PROTOCOL_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 305){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[SERVER_OPERATION_FAILED_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 3){
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,@(errorCode)])];
            }else{
                [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"Renewal Error",[renewalError localizedDescription]])];
            }
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:renewContainer Container Renewal Succesful");
            [self executeGenericCallback:(ExceptionCallback) withParams:(@[@"No  Error",@"success"])];
        }
    });
}

/**
* This method is used to get the number of days between the start and end date.
*
* @param startDate - The start date.
* @param endDate - The end date.
*
* @returns NSInteger - The number of days between the start and end date.
*/
- (NSInteger) numberOfDaysBetween:(NSDate *)startDate toDate:(NSDate *)endDate {
    unsigned int unitFlags = NSCalendarUnitDay;
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorianCalendar components:unitFlags fromDate:startDate  toDate:endDate  options:0];
    return [comps day];
}

/**
* This method is used to get the Container Renewable Date
*
* @param container - The container for which the renewable data is to be fetched.
* @param genericExecuteCallback - The callback to handle the response.
*
* @returns int -  the number of days remaining for the container to renew.
*/
-(int) getContainerRenewableData:(id<HIDContainer>)container callback:(JSValue *)genericExecuteCallback{
    NSError* error;
    NSDate *renewalDate = [container getRenewalDate:&error];
    if(error != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData error while fetching container Renewal %@", [error localizedDescription]);
        [self executeGenericCallback:(genericExecuteCallback) withParams:(@[@"Renewal Error",[error localizedDescription]])];
        return 0;
    }
    NSDate *currentDate = [NSDate date];
    NSInteger remainingDays = [self numberOfDaysBetween:currentDate toDate:renewalDate];
    if(remainingDays < RENEW_EXPIRY_NOTIFICATION_DAYS){
        [self executeGenericCallback:(genericExecuteCallback) withParams:(@[@"DaysToExpire",@(remainingDays)])];
    }
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData Container expires in %zd day%s", remainingDays, remainingDays == 1 ? "" : "s");
    [self executeGenericCallback:(genericExecuteCallback) withParams:(@[@"RenewTime", @(remainingDays)])];
    return remainingDays;
}

/**
* This method is used to get the Container Renewable Date.
*
* @return int - the number of days remaining for the container to renew.
*/
-(int)getContainerRenewableDate{
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData HID In getContainerRenewableDate");
    NSError *error = nil;
    NSDate *expiryDate = [pContainer getExpiryDate:&error];
    if (error) {
        NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData Error getting expiry date: %@", [error localizedDescription]);
        return (pow(10, 9) + 7);
    }
    
    NSDate *creationDate = [pContainer getCreationDate:&error];
    if (error) {
        NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData Error getting creation date: %@", [error localizedDescription]);
        return (pow(10, 9) + 7);
    }
    
    NSTimeInterval containerExpiry = [expiryDate timeIntervalSince1970];
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData Container Expiry Date is %f", containerExpiry);
    NSTimeInterval containerStart = [creationDate timeIntervalSince1970];
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData Container Creation Date is %f", containerStart);
    int startDays = [self getDaysFromMilli:[self getWrtCurrentTime:containerStart*1000]];
    int endDays = [self getDaysFromMilli:[self getWrtCurrentTime:containerExpiry*1000]];
    int totalDays = [self getDaysFromMilli:(labs(containerExpiry - containerStart) * 1000)];
    return [self calFinalDays:totalDays end:endDays];
}

/**
* This method is used to calculate the final days left for the container to be renewable.
*
* @param total - Total days of the container.
* @param end - Days left for the container to expire.
*
* @return int - Number of days left for the container to be renewable.
*/
-(int)calFinalDays:(int)total end:(int)end {
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData  calFinalDays Total Days is %d", total);
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData  calFinalDays End Days is %d", end);
    float perc = ((float)end / (float)total) * 100;
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData  calFinalDays Percentage is %f", perc);
    if (end<=2 || perc < 20.0f) return end;  // if 2 or fewer days are left || percentage is in last 20% of expiry time
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerRenewableData  calFinalDays Returning %d", (-1 * end));
    return (-1 * end);
}

/**
* This method is used to get the number of days from milliseconds
*
* @param milliSeconds - The milliseconds to be converted to days.
*
* @returns int - The number of days from the milliseconds.
*/
-(int)getDaysFromMilli:(long)milliSeconds {
    return (int)(milliSeconds / (1000 * 60 * 60 * 24));
}

/**
* This method is used to get the absolute difference between the current time and the given time.
*
* @param time - The time in milliseconds to compare with the current time.
*
* @returns long - The absolute difference in milliseconds between the current time and the given time.
*/
- (long)getWrtCurrentTime:(long)time {
    long currentMilli = (long)([[NSDate date] timeIntervalSince1970] * 1000);
    return labs(time - currentMilli);
}

/**
* This method is used to check whether the container is renewable or not
*
* @param container - The container to check for renewability.
*
* @returns bool - true if the container is renewable, false otherwise.
*/
-(bool) isContainerRenewable:(id<HIDContainer>) container {
    NSError* error;
    Boolean isRenewable = [container isRenewable:@"" error:&error];
    if(error != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:isContainerRenewable error while fetching container Renewal %@", [error localizedDescription]);
        return false;
    }
    if(isRenewable){
        return true;
    }
    return false;
}

/**
* This method is used to set the Password/Pin for the User.
*
* @param password - The password to be set for the user.
*/
-(void) setPasswordForUser:(NSString *)password{
    [self.eventListener notifyPasswordToListener:(password)];
    
}

/**
* This method is used to get the Login Flow whether the User is registered or not and if registered how many containers are present
*
* @param pushId - The Push ID to be set for the container.
* @param genericExecutionCallback - The callback to handle the response.
*
* @return NSString - "Register" if not registered, "SingleLogin,userId" if single container exists, "MultiLogin,userId1|userId2|..." if multiple containers exist
*/
-(NSString *)getLoginFlow:(NSString *)pushId callBack:(JSValue *)genericExecutionCallback{
    NSLog(@"ApproveSDKWrapper ---> HID:getLoginFlow GetLoginFlow New called from Wrapper Framework with new change");
    NSLog(@"ApproveSDKWrapper ---> HID:getLoginFlow PushID is %@",pushId);
    NSError* deviceError;
    NSError* containerError;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    
    if (deviceError != nil) {
        NSLog(@"ApproveSDKWrapper ---> HID:getLoginFlow error while fetching Container Configuration. Device Error User Info: %@", [deviceError userInfo]);
        NSLog(@"ApproveSDKWrapper ---> HID:getLoginFlow error while fetching Container Configuration %@", [deviceError localizedDescription]);
        int errorCode = (int)[deviceError code];
        if(errorCode == 0){
            [self executeGenericCallback:(genericExecutionCallback) withParams:(@[INTERNAL_EXCEPTION_NAME,@(errorCode)])];
        }else if(errorCode == 3){
            [self executeGenericCallback:(genericExecutionCallback) withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,@(errorCode)])];
        }else if(errorCode == 7){
            [self executeGenericCallback:(genericExecutionCallback) withParams:(@[HID_UNSUPPORTED_VERSION_EXCEPTION_NAME,@(errorCode)])];
        }else if (errorCode == 106){
            [self executeGenericCallback:(genericExecutionCallback) withParams:(@[LOST_CREDENTIALS_EXCEPTION_NAME,@(errorCode)])];
        }else{
            [self executeGenericCallback:(genericExecutionCallback) withParams:(@[@"Device Error",[deviceError localizedDescription]])];
        }
        return @"Error";
    }
    
    NSMutableArray *filterContainers = [[NSMutableArray alloc] init];
    NSArray *pContainers = [pDevice findContainers:filterContainers error:&containerError];
    if (containerError != nil) {
        NSLog(@"ApproveSDKWrapper ---> HID:getLoginFlow error while findContainers %@", [containerError localizedDescription]);
        int errorCode = (int)[deviceError code];
        if(errorCode == 0){
            [self executeGenericCallback:(genericExecutionCallback) withParams:(@[INTERNAL_EXCEPTION_NAME,@(errorCode)])];
        }else if(errorCode == 3){
            [self executeGenericCallback:(genericExecutionCallback) withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,@(errorCode)])];
        }else{
            [self executeGenericCallback:(genericExecutionCallback) withParams:(@[@"Container Error",[deviceError localizedDescription]])];
        }
        return @"Error";
    }
    
    if ([pContainers count] == 0) {
        NSLog(@"ApproveSDKWrapper ---> HID:getLoginFlow No Containers Found, prompting for register");
        return @"Register";
    }
    
    if ([pContainers count] == 1) {
        if (![self isEmptyString:pushId]) {
            [self updatePushIdForContainer:pContainers[0] pushId:pushId];
        }
        
        NSString *loginType = @"SingleLogin,";
        NSString *username = [pContainers[0] getUserId];
        
        [self getInfo];
        [self getKeyList];
        
        NSLog(@"ApproveSDKWrapper ---> HID:getLoginFlow Single Login Flow with UserId %@", username);
        
        return [loginType stringByAppendingString:username];
    } else {
        NSMutableString *multiflowString = [[NSMutableString alloc] initWithString:@"MultiLogin,"];
        
        for (id<HIDContainer> pContainerLoop in pContainers) {
            if (![self isEmptyString:pushId]) {
                [self updatePushIdForContainer:pContainerLoop pushId:pushId];
            }
            [multiflowString appendString:[pContainerLoop getUserId]];
            [multiflowString appendString:@"|"];
        }
        
        NSLog(@"ApproveSDK ---> HID:getLoginFlow GetLoginFlowString is %@", multiflowString);
        
        return [multiflowString substringToIndex:([multiflowString length] - 1)];
    }
}

/**
* This method is used to update the Push ID for the Container.
*
* @param container - The container for which the Push ID is to be updated.
* @param pushId - The Push ID to be set for the container.
*/
- (void)updatePushIdForContainer:(id<HIDContainer>)container pushId:(NSString *)pushId {
    NSData *pushIdData = [self dataFromHexString:pushId];
    NSString *pushIDFinal = [pushIdData base64EncodedStringWithOptions:NSUTF8StringEncoding];
    NSLog(@"ApproveSDKWrapper ---> HID:updatePushIdForContainer PushId after Encoding is %@", pushIDFinal);
    NSError *pushIDError = nil;
    BOOL pushIDStatus = [container updateDeviceInfo:HID_DEVICE_INFO_PUSHID withValue:pushIDFinal withPassword:nil withParams:nil error:&pushIDError];
    NSLog(@"ApproveSDKWrapper ---> HID:updatePushIdForContainer PushID status is %@", pushIDStatus ? @"yes" : @"No");
    if (pushIDError != nil) {
        NSLog(@"ApproveSDKWrapper ---> HID:updatePushIdForContainer error while updating push ID %@", [pushIDError localizedDescription]);
    }
}

/**
*This method is used to generate the OTP for HOTP - OATH_event.
*
* @param password - Password to be used for generating the OTP. It can be "" if Biometrics are enabled
* @param bioEnabled - Boolean to indicate if biometrics are enabled or not.
* @param success_CB - Callback to handle success response.
* @param failure_CB - Callback to handle failure response.
*/
-(void)generateOTP:(NSString *)password isBioEnabled:(bool)bioEnabled withSuccessCB:(JSValue *)success_CB failureCB:(JSValue *)failure_CB{
    [self generateOTPInternal:password isBioEnabled: bioEnabled withSuccessCB:success_CB failureCB:failure_CB otpKeyLabel:HOTP_OTP_KEY];
}

/**
* This method is used to generate the OTP.
*
* @param password - Password to be used for generating the OTP. It can be "" if Biometrics are enabled
* @param bioEnabled - Boolean to indicate if biometrics are enabled or not.
* @param success_CB - Callback to handle success response.
* @param failure_CB - Callback to handle failure response.
* @param otpLabel - The label for the OTP key, can be TOTP or HOTP.
*/
-(void)generateOTP:(NSString *)password isBioEnabled:(bool)bioEnabled withSuccessCB:(JSValue *)success_CB failureCB:(JSValue *)failure_CB withOTPLabel:(NSString *)otpLabel{
    NSString * otp_key = HOTP_OTP_KEY;
    if([otpLabel isEqualToString: TOTP_LABEL_NAME]){
        otp_key = TOTP_OTP_KEY;
    }
    NSLog(@"ApproveSDKWrapper ---> HID:generateOTP with OtpKeyLabel %@",otp_key);
    [self generateOTPInternal:password isBioEnabled: bioEnabled withSuccessCB:success_CB failureCB:failure_CB otpKeyLabel:otp_key];
}

/**
* This method is used to generate the OTP internally.
*
* @param password - Password to be used for generating the OTP. It can be "" if Biometrics are enabled
* @param bioEnabled - Boolean to indicate if biometrics are enabled or not.
* @param success_CB - Callback to handle success response.
* @param failure_CB - Callback to handle failure response.
* @param otpKeyLabel - The label for the OTP key will be set in accordance with TOTP or HOTP.
*/
-(void)generateOTPInternal:(NSString *)password isBioEnabled:(bool)bioEnabled withSuccessCB:(JSValue *)success_CB failureCB:(JSValue *)failure_CB otpKeyLabel : (NSString *) otpKeyLabel{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSError* error;
        id<HIDContainer> pContainer = [self getSingleUserContainer];
        if(pContainer == nil){
            NSLog(@"ApproveSDKWrapper ---> HID:generateOTP No Containers Found");
            [self executeGenericCallback:(failure_CB) withParams:(@[@"Container Exception",@"Exception while fetching the container"])];
            return;
        }
        NSMutableArray* filter = [[NSMutableArray alloc] init];
//        [filter addObject:[HIDParameter parameterWithString:otpKeyLabel forKey:HID_KEY_PROPERTY_LABEL]];
        [filter addObject:[HIDParameter parameterWithString:HID_KEY_PROPERTY_USAGE_OTP forKey:HID_KEY_PROPERTY_USAGE]];
        
        NSArray* keys = [pContainer findKeys:filter error:&error];
        
        id<HIDKey> pKey = [keys objectAtIndex:0];
        
        NSLog(@"ApproveSDKWrapper ---> HID:generateOTP Found Keys %@",keys);
        if (!pKey) {
            NSLog(@"ApproveSDKWrapper ---> HID:generateOTP No OTP key found");
            [self executeGenericCallback:(failure_CB) withParams:(@[@"No OTP Key Found",@"No OTP Key Found"])];
        }else{
            if (keys.count > 1) {
                NSLog(@"ApproveSDKWrapper ---> HID:generateOTP More than one OTP key found");
                NSLog(@"ApproveSDKWrapper ---> HID:generateOTP More than one OTP key found");
                for (id<HIDKey> key in keys) {
                    NSLog(@"ApproveSDKWrapper ---> HID:generateOTP - Key: %@", key);
                    NSLog(@"ApproveSDKWrapper ---> HID:generateOTP Checking key: %@", [key getProperty:HID_KEY_PROPERTY_LABEL error:nil]);
                    NSString *keyLabel = [key getProperty:HID_KEY_PROPERTY_LABEL error:nil];
                    if ([keyLabel isEqualToString:otpKeyLabel] && keyLabel != nil) {
                        pKey = key;
                        NSLog(@"ApproveSDKWrapper ---> HID:generateOTP - Selected Key: %@", pKey);
                        break;
                    }
                }
            }
        }
        
        NSString *lockPolicy = [self getLockPolicy:otpKeyLabel withCode:CODE_SECURE];
        NSLog(@"ApproveSDKWrapper ---> HID:generateOTP get lock policy: %@", lockPolicy);
        
        
        id<HIDOTPGenerator> pOTPGenerator = [pKey getDefaultOTPGenerator:(&error)];
        NSString* OTP = bioEnabled ?[((id<HIDSyncOTPGenerator>) pOTPGenerator) getOTP:(nil) error:(&error)] :  [((id<HIDSyncOTPGenerator>) pOTPGenerator) getOTP:(password) error:(&error)];
        if(error != nil){
            NSLog(@"ApproveSDKWrapper ---> HID:generateOTP Exception in generateOTP %@",[error localizedDescription]);
            NSLog(@"ApproveSDKWrapper ---> HID:generateOTP Exception in generateOTP %d",(int)[error code]);
            int errorCode = (int)[error code];
            if(errorCode == 100){
                NSLog(@"ApproveSDKWrapper ---> HID:generateOTP Authentiation Exception while generating OTP");
                [self executeGenericCallback:(failure_CB) withParams:(@[AUTHENTICATION_EXCEPTION_NAME,[error localizedDescription]])];
            }else if(errorCode == 204){
                [self executeGenericCallback:(failure_CB) withParams:(@[FINGERPRINT_AUTH_REQUIRED_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 202){
                [self executeGenericCallback:(failure_CB) withParams:(@[FINGERPRINT_NOT_ENROLLED_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 101){
                [self executeGenericCallback:(failure_CB) withParams:(@[INVALID_PASSWORD_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 106){
                [self executeGenericCallback:(failure_CB) withParams:(@[LOST_CREDENTIALS_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 105 || errorCode == 203){
                NSLog(@"ApproveSDKWrapper ---> HID:generateOTP Biometric cancelled or wrong fingerprint entered");
                [self executeGenericCallback:(failure_CB) withParams:(@[PASSWORD_REQUIRED_EXCEPTION_NAME,[error localizedDescription]])];
            }else if (errorCode == 103){
                [self executeGenericCallback:(failure_CB) withParams:(@[PASSWORD_EXPIRED_EXCEPTION_NAME,[error localizedDescription]])];
            }else if(errorCode == 200){
                [self executeGenericCallback:(failure_CB) withParams:(@[UNSUPPORTED_DEVICE_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 102){
                [self executeGenericCallback:(failure_CB) withParams:(@[HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 0){
                [self executeGenericCallback:(failure_CB) withParams:(@[INTERNAL_EXCEPTION_NAME,@(errorCode)])];
            }else if(errorCode == 3){
                [self executeGenericCallback:(failure_CB) withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,@(errorCode)])];
            }else{
                [self executeGenericCallback:(failure_CB) withParams:(@[@"OTPException",[error localizedDescription]])];
            }
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:generateOTP Finished OTP generated, OTP: %@",OTP);
            [self executeGenericCallback:(success_CB) withParams: (@[OTP])];
        }
    });
}

/**
* This method is used to get the Password/Pin Policy for the container.
*
* @returns NSString - A JSON string containing the password policy details.
*/
-(NSString*)getPasswordPolicy {
    
    __block NSString *jsonString = @"";
    __block NSData *jsonData = nil;
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        id<HIDContainer> pContainer = [self getSingleUserContainer];
        id<HIDProtectionPolicy> policy = [pContainer getProtectionPolicy:(&error)];
        id<HIDPasswordPolicy> pwdPolicy = (id<HIDPasswordPolicy>)policy;
        NSLog(@"ApproveSDKWrapper ---> HID:getPasswordPolicy PasswordPolicy is called");
        NSLog(@"ApproveSDKWrapper ---> HID:getPasswordPolicy PasswordPolicy is %@",pwdPolicy);
        
        NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[NSNumber alloc] initWithInt:([pwdPolicy minLength])],@"minLength",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxLength])],@"maxLength",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minNumeric])],@"minNumeric",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxNumeric])],@"maxNumeric",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minAlpha])],@"minAlpha",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxAlpha])],@"maxAlpha",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxUpperCase])],@"maxUpperCase",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minUpperCase])],@"minUpperCase",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxLowerCase])],@"maxLowerCase",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minLowerCase])],@"minLowerCase",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxAge])],@"maxAge",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minAge])],@"minAge",
                             [[NSNumber alloc] initWithInt:([pwdPolicy currentAge])],@"currentAge",
                             [[NSNumber alloc] initWithInt:([pwdPolicy maxNonAlpha])],@"maxSpl",
                             [[NSNumber alloc] initWithInt:([pwdPolicy minNonAlpha])],@"minSpl",
                             [[NSNumber alloc] initWithInt:([self getContainerRenewableData:pContainer callback:nil])],@"profileExpiryDate",
                             nil];
        NSError *jsonError;
        jsonData = [NSJSONSerialization dataWithJSONObject:obj options: NSJSONWritingPrettyPrinted error:&jsonError];
        int errorCode = (int)[error code];
        if(!jsonData){
            NSLog(@"ApproveSDKWrapper ---> HID:getPasswordPolicy Error while converting JSON %@", jsonError);
            return;
        }else if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:getPasswordPolicy Internal Exception while fetching Password Policy %@", [error localizedDescription]);
        }else if(errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:getPasswordPolicy Invalid Argument Exception while fetching Password Policy %@", [error localizedDescription]);
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:getPasswordPolicy Exception while fetching Password Policy %@", [error localizedDescription]);
        }
    });
    if(jsonString != nil){
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"ApproveSDKWrapper ---> HID:getPasswordPolicy PasswordPolicy is %@", jsonString);
        return jsonString;
    }
    return nil;
}

/**
* This method is used to update the Password/Pin for the container.
*
* @param oldPassword - Old Password/Pin of the container.
* @param newPassword - New Password/Pin to be set for the container.
* @param exceptionCallback - Callback to handle exceptions
* @param isPasswordPolicy - Boolean to check the container password policy is present or not
*
*/
-(void) updatePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword exceptionCallback:(JSValue *)exceptionCallback isPasswordPolicy:(bool)isPasswordPolicy{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* error;
        id<HIDContainer> pContainer = [self getSingleUserContainer];
        id<HIDPasswordPolicy> pwdPolicy = (id<HIDPasswordPolicy>)[pContainer getProtectionPolicy:&error];
        [pwdPolicy changePassword:(oldPassword) new:newPassword error:(&error)];
        if(error != nil){
            int errorCode = (int)[error code];
            NSDictionary* errorInfo = [error userInfo];
            NSString * msg = errorInfo[SDK_ERROR_MSG_KEY];
            NSLog(@"ApproveSDKWrapper --> HID:updatePassword error while Updating User PIN %@",msg);
            NSLog(@"ApproveSDKWrapper --> HID:updatePassword error is %@",[error localizedDescription]);
            if(errorCode == 100){
                [self executeGenericCallback:(exceptionCallback) withParams:(@[@"AuthenticationException",msg])];
            }else if(errorCode == 101){
                [self executeGenericCallback:(exceptionCallback) withParams:(@[@"InvalidPasswordException",msg])];
            }else if (errorCode == 200){
                [self executeGenericCallback:(exceptionCallback) withParams:(@[@"UnsupportedDeviceException",msg])];
            }else if (errorCode == 106){
                [self executeGenericCallback:exceptionCallback withParams:(@[@"LostCredentialsException",msg])];
            }else if (errorCode == 0){
                [self executeGenericCallback:exceptionCallback withParams:(@[@"InternalException",msg])];
            }else if (errorCode == 3){
                [self executeGenericCallback:exceptionCallback withParams:(@[@"InvalidArgumentException",msg])];
            }else if (errorCode == 104){
                [self executeGenericCallback:exceptionCallback withParams:(@[@"PasswordNotYetUpdatable",msg])];
            }else{
                [self executeGenericCallback:exceptionCallback withParams:(@[@"Exception",[error localizedDescription]])];
            }
        }else{
            NSLog(@"ApproveSDKWrapper --> HID:updatePassword Password changed successfully");
            [self executeGenericCallback:exceptionCallback withParams:(@[@"UpdatePassword",@"updateSuccess"])];
        }
    });
}

/**
* This method is used to verify the password and biometric authentication.
*
* @param pwd - Password to be verified, pass "" if biometrics are enabled.
* @param isBioEnabled - Boolean to check if biometrics are enabled or not.
* @param callback - Callback function to handle the response.
*/
-(void)verifyPassword:(NSString *)pwd isBioEnabled:(bool)isBioEnabled withCallback:(JSValue *)callback{
    NSError *error;
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    if(!isBioEnabled && [self isEmptyString: pwd]){
        [self executeGenericCallback : callback withParams:(@[@"error",AUTHENTICATION_EXCEPTION_NAME,AUTH_EXCEPTION_CODE])];
    }
    id<HIDPasswordPolicy> pPolicy = (id<HIDPasswordPolicy>)[pContainer getProtectionPolicy:(&error)];
    
    if(isBioEnabled){
        [pPolicy verifyPassword:nil error:&error];
    }else{
        [pPolicy verifyPassword:pwd error:&error];
    }if(error != nil){
        NSLog(@"ApproveSDKWrapper ----> HID:verifyPassword Error While Verify Password %@",[error localizedDescription]);
        int errorCode = (int)[error code];
        if(errorCode == 100){
            NSLog(@"ApproveSDKWrapper ---> HID:verifyPassword Authentication Exception");
            [self executeGenericCallback:callback withParams:@[@"error",AUTHENTICATION_EXCEPTION_NAME,AUTH_EXCEPTION_CODE]];
        }else if(errorCode == 105 || errorCode == 203){
            [self executeGenericCallback:callback withParams:@[@"error",HID_FINGERPRINT_EXCEPTION,BIO_ERROR_CODE]];
        }else if(errorCode == 0){
            [self executeGenericCallback:callback withParams:@[@"error",INTERNAL_EXCEPTION_NAME,GENERIC_EXCEPTION_CODE]];
        }else if(errorCode == 3){
            [self executeGenericCallback:callback withParams:@[@"error",HID_INVALID_ARGUMENT_EXCEPTION_NAME,GENERIC_EXCEPTION_CODE]];
        }else{
            [self executeGenericCallback:(callback) withParams:(@[@"error",[error localizedDescription], GENERIC_EXCEPTION_CODE])];
        }
    }else{
        [self executeGenericCallback:(callback) withParams:(@[@"success",@"NoException" ,NO_EXCEPTION_CODE])];
    }
    
}

/**
* This method is used to enable the Biometrics.
*
* @param password - Password to be used for enabling the biometrics.
* @param bioStatusCallback to fetch the biometric status
*
*/
-(void)enableBiometrics:(NSString *)password statusCB:(JSValue *)bioStatusCallback{
    NSError *error;
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    id<HIDProtectionPolicy> policy = [pContainer getProtectionPolicy:(&error)];
    if([policy policyType] != HIDPolicyTypeBioPassword){
        NSLog(@"ApproveSDKWrapper ---> HID:enableBiometrics Policy Does not support Biometric");
        [self executeGenericCallback:(bioStatusCallback) withParams:(@[@FALSE,@"Policy does not support biometric"])];
        return;
    }
    id<HIDBioPasswordPolicy> bioPasswordPolicy = (id<HIDBioPasswordPolicy>)policy;
    if([bioPasswordPolicy getBioAuthenticationState] != HIDBioAuthenticationStateEnabled){
        [bioPasswordPolicy enableBioAuthentication:password error:&error ];
    }
    if(error != nil){
        int errorCode = (int)[error code];
        if(errorCode == 100){
            NSLog(@"ApproveSDKWrapper ---> HID:enableBiometrics Authentication Error while enabling biometrics with error message");
            [self executeGenericCallback:(bioStatusCallback) withParams:(@[@FALSE,@"PIN is incorrect"])];
        }else if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:enableBiometrics Internal Error while enabling biometrics with error message %@",[error localizedDescription]);
            [self executeGenericCallback:(bioStatusCallback) withParams:(@[@FALSE,@"Internal Error while enabling biometrics"])];
        }else if(errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:enableBiometrics Invalid Argument Error while enabling biometrics with error message %@",[error localizedDescription]);
            [self executeGenericCallback:(bioStatusCallback) withParams:(@[@FALSE,@"Invalid Argument Error while enabling biometrics"])];
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:enableBiometrics Error while enabling biometrics with error message %@",[error localizedDescription]);
            [self executeGenericCallback:(bioStatusCallback) withParams:(@[@FALSE,@"Biometric enrollment got failed"])];
        }
    }else{
        NSLog(@"ApproveSDKWrapper ---> HID:enableBiometrics Successfully Enabled Biometrics");
        [self executeGenericCallback:(bioStatusCallback) withParams:(@[@TRUE,@"Success"])];
    }
}

/**
*     This method is used to disable the Biometrics
*
*/
-(void)disableBiometrics{
    NSLog(@"ApproveSDKWrapper ---> HID:disableBiometrics disableBiometrics called from Wrapper Framework");
    NSError *error;
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    id<HIDProtectionPolicy> policy = [pContainer getProtectionPolicy:(&error)];
    if([policy policyType] != HIDPolicyTypeBioPassword){
        NSLog(@"ApproveSDKWrapper ---> HID:disableBiometrics Policy Does not support Biometric");
        return;
    }
    id<HIDBioPasswordPolicy> bioPasswordPolicy = (id<HIDBioPasswordPolicy>)policy;
    [bioPasswordPolicy enableBioAuthentication:nil error:&error];
    int errorCode = (int)[error code];
    if(error != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:disableBiometrics Error while disabling biometrics with error message %@",[error localizedDescription]);
    }else if(errorCode == 0){
        NSLog(@"ApproveSDKWrapper ---> HID:disableBiometrics Internal Error while disabling biometrics with error message %@",[error localizedDescription]);
    }else if(errorCode == 3){
        NSLog(@"ApproveSDKWrapper ---> HID:disableBiometrics Invalid Argument Error while disabling biometrics with error message %@",[error localizedDescription]);
    }else{
        NSLog(@"ApproveSDKWrapper ---> HID:disableBiometrics Successfully Disabled Biometrics");
    }
}

/**
* This method is used to check the availability of Biometrics
*
* @return bool value "true" or "false"
*/
-(bool) checkBioAvailability{
    NSError *error;
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    id<HIDProtectionPolicy> policy = [pContainer getProtectionPolicy:(&error)];
    if([policy policyType] != HIDPolicyTypeBioPassword){
        NSLog(@"ApproveSDKWrapper ---> HID:checkBioAvailability Policy Does not support biometric");
        return FALSE;
    }
    id<HIDBioPasswordPolicy> bioPasswordPolicy = (id<HIDBioPasswordPolicy>)policy;
    if([bioPasswordPolicy getBioAuthenticationState] == HIDBioAuthenticationStateEnabled){
        NSLog(@"ApproveSDKWrapper ---> HID:checkBioAvailability Bio Policy enabled");
        return TRUE;
    }
    if([bioPasswordPolicy getBioAuthenticationState] == HIDBioAuthenticationStateNotEnabled){
        NSLog(@"ApproveSDKWrapper ---> HID:checkBioAvailability Bio Policy Not enabled");
        return FALSE;
    }
    if([bioPasswordPolicy getBioAuthenticationState] == HIDBioAuthenticationStateNotCapable){
        NSLog(@"ApproveSDKWrapper ---> HID:checkBioAvailability Bio Policy with the current device is not possible");
        return FALSE;
    }
    if([bioPasswordPolicy getBioAuthenticationState] == HIDBioAuthenticationStateNotEnrolled){
        NSLog(@"ApproveSDKWrapper ---> HID:checkBioAvailability Biometric Feature in Device is not enrolled");
        return FALSE;
    }
    if([bioPasswordPolicy getBioAuthenticationState] == HIDBioAuthenticationStateInvalidKey){
        NSLog(@"ApproveSDKWrapper ---> HID:checkBioAvailability Bio Policy key has been invalidated");
        return FALSE;
    }
    if(error != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:checkBioAvailability Error while enabling biometrics with error message %@",[error localizedDescription]);
        return FALSE;
    }
    return FALSE;
}

/**
* This method is used to sign a transaction with default OCRA HOTP label.
*
* @param transactionDetails - Details of the transaction to be signed.
* @param pwdPromptCallback - Callback function to prompt for password.
* @param successCB - Callback function for successful response.
* @param failureCB - Callback function for failed response.
*/
-(void)signTransaction:(NSString *)transactionDetails withPwdPromptCallback:(JSValue *)pwdPromptCallback withSuccessCB:(JSValue *)successCB withFailureCB:(JSValue *)failureCB{
    [self signTransactionInternal :transactionDetails withPwdPromptCallback:pwdPromptCallback withSuccessCB:successCB withFailureCB:failureCB withOTPKey: HOTP_SIGN_KEY];
}

/**
* This method is used to sign a transaction.
*
* @param transactionDetails - Details of the transaction to be signed.
* @param pwdPromptCallback - Callback function to prompt for password.
* @param successCB - Callback function for successful response.
* @param failureCB - Callback function for failed response.
* @param otpLabel - The label for the OTP key, can be "HOTP" or "TOTP".
*/
-(void)signTransaction:(NSString *)transactionDetails withPwdPromptCallback:(JSValue *)pwdPromptCallback withSuccessCB:(JSValue *)successCB withFailureCB:(JSValue *)failureCB withOTPLabel:(NSString *)otpLabel{
    NSString * otp_key = HOTP_SIGN_KEY;
    if([otpLabel isEqualToString: TOTP_LABEL_NAME]){
        otp_key = TOTP_SIGN_KEY;
    }
    NSLog(@"ApproveSDKWrapper ---> HID:signTransaction with OtpKeyLabel %@",otp_key);
    [self signTransactionInternal :transactionDetails withPwdPromptCallback:pwdPromptCallback withSuccessCB:successCB withFailureCB:failureCB withOTPKey: otp_key];
}

/**
* This method is used to sign a transaction internally.
*
* @param transactionDetails - Details of the transaction to be signed.
* @param pwdPromptCallback - Callback function to prompt for password.
* @param successCB - Callback function for successful response.
* @param failureCB - Callback function for failed response.
* @param otp_Key - The label for the OTP key will be set in accordance with TOTP or HOTP.
*/
-(void)signTransactionInternal:(NSString *)transactionDetails withPwdPromptCallback:(JSValue *)pwdPromptCallback withSuccessCB:(JSValue *)successCB withFailureCB:(JSValue *)failureCB withOTPKey:(NSString *) otp_Key{ dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
    NSError *error;
    NSLog(@"ApproveSDKWrapper ---> HID:signTransaction InsideSignTransaction");
    bool isBioEnabled = [self checkBioAvailability];
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    NSMutableArray* filter = [[NSMutableArray alloc] init];
//    [filter addObject:[HIDParameter parameterWithString:otp_Key forKey:HID_KEY_PROPERTY_LABEL]];
    [filter addObject:[HIDParameter parameterWithString:HID_KEY_PROPERTY_USAGE_OTP forKey:HID_KEY_PROPERTY_USAGE]];
    NSArray* keys = [pContainer findKeys:filter error:&error];
    
    NSLog(@"ApproveSDKWrapper ---> HID:signTransaction Found Keys %@",keys);
   
    id<HIDKey> pKey = [keys objectAtIndex:0];
    
    if (!pKey) {
        NSLog(@"ApproveSDKWrapper ---> HID:signTransaction No OTP key found");
        [self executeGenericCallback:(failureCB) withParams:(@[@"No OTP Key Found",@"No OTP Key Found"])];
    }else{
        if (keys.count > 1) {
            NSLog(@"ApproveSDKWrapper ---> HID:signTransaction More than one OTP key found");
            NSLog(@"ApproveSDKWrapper ---> HID:signTransaction More than one OTP key found");
            for (id<HIDKey> key in keys) {
                NSLog(@"ApproveSDKWrapper ---> HID:signTransaction - Key: %@", key);
                NSLog(@"ApproveSDKWrapper ---> HID:signTransaction Checking key: %@", [key getProperty:HID_KEY_PROPERTY_LABEL error:nil]);
                NSString *keyLabel = [key getProperty:HID_KEY_PROPERTY_LABEL error:nil];
                if ([keyLabel isEqualToString:otp_Key] && keyLabel != nil) {
                    pKey = key;
                    NSLog(@"ApproveSDKWrapper ---> HID:signTransaction - Selected Key: %@", pKey);
                    break;
                }
            }
        }
    }
    
    NSString *lockPolicy = [self getLockPolicy:otp_Key withCode:CODE_SIGN ];
    NSLog(@"ApproveSDKWrapper ---> HID:signTransaction get lock policy: %@", lockPolicy);
    
    
    id<HIDAsyncOTPGenerator> pAsyncAOTPGenerator = (id<HIDAsyncOTPGenerator>)[pKey getDefaultOTPGenerator:(&error)];
    NSArray *tsDetails = [transactionDetails componentsSeparatedByString:(@"~")];
    NSString *challenge = [pAsyncAOTPGenerator formatSignatureChallenge:(tsDetails) error:(&error)];
    HIDOCRAInputAlgorithmParameters *inputParams = [[HIDOCRAInputAlgorithmParameters alloc] init];
    if(isBioEnabled){
        NSString *otp = [pAsyncAOTPGenerator computeSignature:(nil)
                                             withSigChallenge:(challenge) withClientChallenge:(nil) withInputParams:(inputParams) error:(&error)];
        if(error != nil){
            int errorCode = (int)[error code];
            if(errorCode == 105 || errorCode == 203){
                [self invokeTsPasswordAuth:(pAsyncAOTPGenerator)
                             withChallenge:(challenge)
                             withEventType:[error localizedDescription]
                             withEventCode:(PWD_PROMPT_PROGRESS_EVENT_CODE)
                             withSuccessCB:(successCB)
                             withFailureCB:(failureCB)
                           withPwdPromptCB:(pwdPromptCallback)];
            }else if (errorCode == 103){  // PasswordExpired Exception
                [self invokeTsPasswordAuth:(pAsyncAOTPGenerator)
                             withChallenge:(challenge)
                             withEventType:(PWD_PROMPT_ERROR_EVENT_TYPE)
                             withEventCode:(PWD_EXPIRED_PROMPT_EVENT_CODE)
                             withSuccessCB:(successCB)
                             withFailureCB:(failureCB)
                           withPwdPromptCB:(pwdPromptCallback)];
            }else if (errorCode == 0){  // PasswordExpired Exception
                [self executeGenericCallback:(failureCB) withParams:(@[INTERNAL_EXCEPTION_NAME,[error localizedDescription]])];
                NSLog(@"ApproveSDKWrapper ---> HID:signTransaction Internal Exception while signTs %@", [error localizedDescription]);
            }else if (errorCode == 3){  // PasswordExpired Exception
                [self executeGenericCallback:(failureCB) withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,[error localizedDescription]])];
                NSLog(@"ApproveSDKWrapper ---> HID:signTransaction Invalid Argument Exception while signTs %@", [error localizedDescription]);
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:signTransaction Exception occured while signTs %@", [error localizedDescription]);
                [self executeGenericCallback:(failureCB) withParams:(@[@"signTSError",[error localizedDescription]])];
            }
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:signTransaction Code Generated is %@", otp);
            [self executeGenericCallback:(successCB) withParams:(@[otp])];
        }
    }else {
        [self invokeTsPasswordAuth:(pAsyncAOTPGenerator)
                     withChallenge:(challenge)
                     withEventType:(PWD_PROMPT_PROGRESS_EVENT_TYPE)
                     withEventCode:(PWD_PROMPT_PROGRESS_EVENT_CODE)
                     withSuccessCB:(successCB)
                     withFailureCB:(failureCB)
                   withPwdPromptCB:(pwdPromptCallback)];
    }
});
}

/**
*
*This method is used to get the Password for the Transaction Sign flow.
*
*@param eventType - Event type for the password prompt.
*@param eventCode - Event code for the password prompt.
*@param pwdPromptCB - Callback function to prompt for password.
*
*@return NSString - The password entered by the user.
*/
-(NSString* )getPasswordFromUIAsync : (NSString* ) eventType withEventCode:(NSString*) eventCode withPwdPromptCB: (JSValue*) pwdPromptCB{
    [self executeGenericCallback:(pwdPromptCB) withParams:(@[eventType,eventCode])];
    self.tsGroup = dispatch_group_create();
    dispatch_group_enter(self.tsGroup);
    //NSLog(@"ApproveSDKWrapper ---> TS waiting for Password");
    dispatch_group_wait(self.tsGroup, DISPATCH_TIME_FOREVER);
    //NSLog(@"ApproveSDKWrapper ---> TS Notified with Password");
    return self.tsMonitorObj;
}

/**
*
* This method is used to invoke the password authentication for Transaction Sign flow.
*
* @param pAsyncOTPGenerator - The asynchronous OTP generator.
* @param challenge - The challenge string for the OTP generation.
* @param eventType - The event type for the password prompt.
* @param eventCode - The event code for the password prompt.
* @param successCB - Callback function for successful response.
* @param failureCB - Callback function for failed response.
* @param pwdPromptCB - Callback function to prompt for password.
*/
-(void)invokeTsPasswordAuth : (id<HIDAsyncOTPGenerator>) pAsyncOTPGenerator withChallenge:(NSString*) challenge withEventType:(NSString*)eventType  withEventCode:(NSString*) eventCode withSuccessCB: (JSValue *)successCB withFailureCB: (JSValue *)failureCB withPwdPromptCB:(JSValue*) pwdPromptCB{
    NSError *error;
    //    NSString* pwd = [self getPasswordFromUIAsync:(eventType) withEventCode:(eventCode) withPwdPromptCB:(pwdPromptCB)];
    [self executeGenericCallback:(pwdPromptCB) withParams:(@[eventType,eventCode])];
    self.tsGroup = dispatch_group_create();
    dispatch_group_enter(self.tsGroup);
    //NSLog(@"ApproveSDKWrapper ---> TS waiting for Password");
    dispatch_group_wait(self.tsGroup, DISPATCH_TIME_FOREVER);
    //NSLog(@"ApproveSDKWrapper ---> TS Notified with Password");
    HIDOCRAInputAlgorithmParameters *inputParams = [[HIDOCRAInputAlgorithmParameters alloc] init];
    NSString *otp = [pAsyncOTPGenerator computeSignature:(self.tsMonitorObj)
                                        withSigChallenge:(challenge) withClientChallenge:(nil) withInputParams:(inputParams) error:(&error)];
    if(error != nil){
        int errorCode = (int)[error code];
        if(errorCode == 105 || errorCode == 203){
            [self invokeTsPasswordAuth:(pAsyncOTPGenerator)
                         withChallenge:(challenge)
                         withEventType:[error localizedDescription]
                         withEventCode:(PWD_PROMPT_PROGRESS_EVENT_CODE)
                         withSuccessCB:(successCB)
                         withFailureCB:(failureCB)
                       withPwdPromptCB:(pwdPromptCB)];
        }else if(errorCode == 100){
            NSLog(@"ApproveSDKWrapper ---> HID:invokeTsPasswordAuth Authentication Exception so recursing");
            [self invokeTsPasswordAuth:(pAsyncOTPGenerator)
                         withChallenge:(challenge)
                         withEventType:(PWD_PROMPT_ERROR_EVENT_TYPE)
                         withEventCode:(PWD_PROMPT_ERROR_EVENT_CODE)
                         withSuccessCB:(successCB)
                         withFailureCB:(failureCB)
                       withPwdPromptCB:(pwdPromptCB)];
        }else if (errorCode == 103){  // PasswordExpired Exception
            NSLog(@"ApproveSDKWrapper ---> HID:invokeTsPasswordAuth PasswordExpired Exception so recursing");
            [self invokeTsPasswordAuth:(pAsyncOTPGenerator)
                         withChallenge:(challenge)
                         withEventType:(PWD_PROMPT_ERROR_EVENT_TYPE)
                         withEventCode:(PWD_EXPIRED_PROMPT_EVENT_CODE)
                         withSuccessCB:(successCB)
                         withFailureCB:(failureCB)
                       withPwdPromptCB:(pwdPromptCB)];
        }
        else{
            NSLog(@"ApproveSDKWrapper ---> HID:invokeTsPasswordAuth Exception occured while signTs %@", [error localizedDescription]);
            [self executeGenericCallback:(failureCB) withParams:(@[@"signTSError",[error localizedDescription]])];
        }
    }else{
        //NSLog(@"ApproveSDKWrapper ---> Secure Code Generated is %@", otp);
        self.tsGroup = nil;
        [self executeGenericCallback:(successCB) withParams:(@[otp])];
    }
}

/**
* This method notifies the password to the monitor based (for Sign Transaction) on the mode.
*
* @param password - The password to notify.
* @param mode - The mode of operation - SIGN_TRANSACTION_FLOW
*/
-(void)notifyPassword:(NSString *)password withMode:(NSString *)mode{
    NSLog(@"ApproveSDKWrapper ---> HID:notifyPassword notifyPassword called with mode %@", mode);
    if([mode isEqualToString:(SIGN_TRANSACTION_FLOW)]){
        self.tsMonitorObj = password;
        dispatch_group_leave(self.tsGroup);
    }
}

/**
* This method is used to get the single user container.
*
* @return HIDContainer -  representing the present container.
*/
-(id<HIDContainer>)getSingleUserContainer{
    //  NSLog(@"ApproveSDKWrapper ---> getSingleUserContainer called from Wrapper Framework");
    NSError* deviceError;
    NSError* containerError;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    NSMutableArray* filterContainers = [[NSMutableArray alloc]init];
    if(_username != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:getSingleUserContainer Username is %@", _username);
        [filterContainers addObject:[HIDParameter parameterWithString: (_username) forKey:HID_CONTAINER_USERID]];
    }
    NSArray* pConatiners  = [pDevice findContainers:filterContainers error:&containerError];
    if ([pConatiners count] == 0) {
        return nil;
    }
    if(deviceError != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:getSingleUserContainer error while creating container %@", [deviceError localizedDescription]);
        return nil;
    }else if(containerError != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:getSingleUserContainer error while creating container %@", [containerError localizedDescription]);
        return nil;
    }
    return [pConatiners objectAtIndex:(0)];
}

/**
* This method deletes the container.
*
* @return bool - true if the container is deleted successfully, false otherwise.
*/
-(bool) deleteContainer{
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    NSError* deviceError;
    NSError* error;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    if(pContainer == nil){
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainer Containers not found while deleting");
        return FALSE;
    }
    
    if(deviceError != nil){
        int errorCodeDevice = (int)[deviceError code];
        if(errorCodeDevice == 0){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainer Internal Exception While Deleting %@",[deviceError localizedDescription]);
            return FALSE;
        }else if (errorCodeDevice == 3){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainer Invalid Argument Exception While Deleting Container  %@",[deviceError localizedDescription]);
            return FALSE;
        }else if (errorCodeDevice == 7){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainer Unsupported Version Exception While Deleting Container %@",[deviceError localizedDescription]);
            return FALSE;
        }else if (errorCodeDevice == 106){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainer Lost Credentials Exception While Deleting Container %@",[deviceError localizedDescription]);
            return FALSE;
        }else{
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainer DeviceError While Deleting Container @%@",[deviceError localizedDescription]);
            return FALSE;
        }
    }
    [pDevice deleteContainer:([pContainer getId]) withSessionPassword:(nil) withParams:(nil) error:(&error)];
    
    if(error != nil){
        int errorCode = (int)[error code];
        if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainer Internal Exception While Deleting Container %@",[deviceError localizedDescription]);
            return FALSE;
        }else if (errorCode == 3){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainer Invalid Argument Exception While Deleting Container %@",[deviceError localizedDescription]);
            return FALSE;
        }else{
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainer DeviceError While Deleting Container %@",[error localizedDescription]);
            return FALSE;
        }
    }
    return TRUE;
}

/**
* This method deletes the container with reason - no authentication.
*
* @param reason - The reason for deleting the container.
* @return bool - true if the container is deleted successfully, false otherwise.
*/
-(bool) deleteContainerWithReason:(NSString *)reason{
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    NSError* deviceError;
    NSError* error;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    if(pContainer == nil){
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithReason Containers not found while deleting");
        return FALSE;
    }
    
    if(deviceError != nil){
        int errorCodeDevice = (int)[deviceError code];
        if(errorCodeDevice == 0){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainerWithReason Internal Exception While Deleting %@",[deviceError localizedDescription]);
            return FALSE;
        }else if (errorCodeDevice == 3){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainerWithReason Invalid Argument Exception While Deleting Container  %@",[deviceError localizedDescription]);
            return FALSE;
        }else if (errorCodeDevice == 7){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainerWithReason Unsupported Version Exception While Deleting Container %@",[deviceError localizedDescription]);
            return FALSE;
        }else if (errorCodeDevice == 106){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainerWithReason Lost Credentials Exception While Deleting Container %@",[deviceError localizedDescription]);
            return FALSE;
        }else{
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainerWithReason DeviceError While Deleting Container @%@",[deviceError localizedDescription]);
            return FALSE;
        }
    }
    NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithReason Deleting Container with reason %@", reason);
    if(reason == nil || [reason isEqualToString: @""]){
        reason = nil;  // If reason is empty, set it to nil
    }
    
    [pDevice deleteContainer:([pContainer getId]) withSessionPassword:(nil) withReason:reason error:(&error)];
    
    if(error != nil){
        int errorCode = (int)[error code];
        if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainerWithReason Internal Exception While Deleting Container %@",[deviceError localizedDescription]);
            return FALSE;
        }else if (errorCode == 3){
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainerWithReason Invalid Argument Exception While Deleting Container %@",[deviceError localizedDescription]);
            return FALSE;
        }else{
            NSLog(@"ApproveSDKWrapper ----> HID:deleteContainerWithReason DeviceError While Deleting Container %@",[error localizedDescription]);
            return FALSE;
        }
    }
    return TRUE;
}

/**
* This method retrieves pending notifications.
*
* @param callback - The callback function to execute after retrieving notifications.
*/
-(void) retrievePendingNotifications:(JSValue *)callback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        id<HIDContainer> pContainer = [self getSingleUserContainer];
        NSError* error;
        NSArray* txIDArray = [pContainer retrieveTransactionIds:nil withParams:nil error:&error];
        if(error != nil){
            int errorCode = (int)[error code];
            if (errorCode == 100){
                NSLog(@"ApproveSDKWrapper ----> HID:retrievePendingNotifications Error while Retrieveing Notifications Authentication Exception %@",[error localizedDescription]);
                [self executeGenericCallback:callback withParams:@[@"failure", AUTHENTICATION_EXCEPTION_NAME, @(errorCode)]];
                return;
            }else if (errorCode == 1000){
                NSLog(@"ApproveSDKWrapper ----> HID:retrievePendingNotifications Error while Retrieveing Notifications Transaction Expired Exception %@",[error localizedDescription]);
                [self executeGenericCallback:callback withParams:@[@"failure", TRANSACTION_EXPIRED_EXCEPTION_NAME, @(errorCode)]];
                return;
            }else if (errorCode == 102){
                NSLog(@"ApproveSDKWrapper ----> HID:retrievePendingNotifications Error while Retrieveing Notifications Credentials Expired Exception %@",[error localizedDescription]);
                [self executeGenericCallback:callback withParams:@[@"failure", HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME, @(errorCode)]];
                return;
            }else if (errorCode == 0){
                NSLog(@"ApproveSDKWrapper ----> HID:retrievePendingNotifications Error while Retrieveing Notifications Internal Exception %@",[error localizedDescription]);
                [self executeGenericCallback:callback withParams:@[@"failure", INTERNAL_EXCEPTION_NAME, @(errorCode)]];
                return;
            }else if (errorCode == 103){
                NSLog(@"ApproveSDKWrapper ----> HID:retrievePendingNotifications Error while Retrieveing Notifications Password Expired Exception %@",[error localizedDescription]);
                [self executeGenericCallback:callback withParams:@[@"failure", PASSWORD_EXPIRED_EXCEPTION_NAME, @(errorCode)]];
                return;
            }else if (errorCode == 300){
                NSLog(@"ApproveSDKWrapper ----> HID:retrievePendingNotifications Error while Retrieveing Notifications Server Authentication Exception %@",[error localizedDescription]);
                [self executeGenericCallback:callback withParams:@[@"failure", SERVER_AUTH_EXCEPTION_NAME, @(errorCode)]];
                return;
            }else if (errorCode == 3){
                NSLog(@"ApproveSDKWrapper ----> HID:retrievePendingNotifications Error while Retrieveing Notifications Invalid Argument Exception %@",[error localizedDescription]);
                [self executeGenericCallback:callback withParams:@[@"failure", HID_INVALID_ARGUMENT_EXCEPTION_NAME, @(errorCode)]];
                return;
            }else{
                NSLog(@"ApproveSDKWrapper ----> HID:retrievePendingNotifications Error while Retrieveing Notifications %@",[error localizedDescription]);
                [self executeGenericCallback:callback withParams:@[@"failure", [error localizedDescription]]];
                return;
            }
        }
        if([txIDArray count] == 0){
            [self executeGenericCallback:callback withParams:@[@"failure", @"{}"]];
            return;
        }
        NSMutableArray* jsonArray = [[NSMutableArray alloc] init];
        for(int i =0; i<[txIDArray count]; i++){
            // [jsonArray addObject: [NSDictionary dictionaryWithObjectsAndKeys:[txIDArray objectAtIndex:i], [NSString stringWithFormat:@"%d",i] , nil]];
            [jsonArray addObject: [txIDArray objectAtIndex:i]];
        }
        NSDictionary* jsonObj = [NSDictionary dictionaryWithObjectsAndKeys:jsonArray,@"txIDs", nil];
        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options: NSJSONWritingPrettyPrinted error:&jsonError];
        if(!jsonData){
            NSLog(@"ApproveSDKWrapper ---> HID:retrievePendingNotifications Error while converting JSON %@", jsonError);
            [self executeGenericCallback:callback withParams:@[@"failure", [jsonError localizedDescription]]];
            return;
        }else{
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"ApproveSDKWrapper ---> HID:retrievePendingNotifications TransactionInfo is %@", jsonString);
            [self executeGenericCallback:callback withParams:(@[@"success",jsonString])];
        }
    });
}

/**
* This method is used to retrieve the transaction details.
*
* @param txID - Transaction ID to retrieve the transaction details.
* @param pwd - Password to be used for transaction retrieval, pass "" if biometrics are enabled.
* @param isBioEnabled - Boolean to check if biometrics are enabled or not.
* @param callback - Callback function to handle the response.
*
* @return NSString - JSON string containing transaction details or error message.
*/
-(NSString *) retreiveTransaction:(NSString *)txID withPassword:(NSString *)pwd isBioEnabled:(bool)isBioEnabled withCallback:(JSValue *)callback{
    NSError* deviceError;
    NSError* error;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    if(deviceError != nil){
        int errorCodeDevice = (int)[deviceError code];
        if(errorCodeDevice == 0){
            NSLog(@"ApproveSDKWrapper ----> HID:retreiveTransaction Internal Exception %@",[deviceError localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", INTERNAL_EXCEPTION_NAME, @(errorCodeDevice)]];
            return @"";
        }else if (errorCodeDevice == 3){
            NSLog(@"ApproveSDKWrapper ----> HID:retreiveTransaction Invalid Argument Exception %@",[deviceError localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", HID_INVALID_ARGUMENT_EXCEPTION_NAME, @(errorCodeDevice)]];
            return @"";
        }else if (errorCodeDevice == 7){
            NSLog(@"ApproveSDKWrapper ----> HID:retreiveTransaction Unsupported Version Exception %@",[deviceError localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", HID_UNSUPPORTED_VERSION_EXCEPTION_NAME, @(errorCodeDevice)]];
            return @"";
        }else if (errorCodeDevice == 106){
            NSLog(@"ApproveSDKWrapper ----> HID:retreiveTransaction Lost Credentials Exception %@",[deviceError localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", LOST_CREDENTIALS_EXCEPTION_NAME, @(errorCodeDevice)]];
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Error while creating HID Device %@", [deviceError localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure",[deviceError localizedDescription]]];
            return @"";
        }
    }
    id<HIDServerActionInfo> transactionInfo = [pDevice retrieveActionInfo:txID error:&error];
    id<HIDContainer> pContainer = [transactionInfo getContainer:&error];
    NSString* username = [pContainer getUserId];
    _username = username;
    id<HIDTransaction> pTransaction = (id<HIDTransaction>)[transactionInfo getAction:nil withParams:nil error:&error];
    id<HIDPasswordPolicy> pPolicy = (id<HIDPasswordPolicy>) [pContainer getProtectionPolicy:&error];
    
    if (error != nil){
        int errorCode = (int)[error code];
        if (errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Internal Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", INTERNAL_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else if (errorCode == 8){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Invalid Container Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", HID_INVALID_CONTAINER_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else if (errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Invalid Argument Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", HID_INVALID_ARGUMENT_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else if (errorCode == 9){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Inexplicit Container Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", HID_INEXPLICIT_CONTAINER_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else if(errorCode == 100){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Authentication Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", AUTHENTICATION_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else if (errorCode == 1000){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Transaction Expired Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", TRANSACTION_EXPIRED_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else if(errorCode == 102){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Credentials Expired Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else if (errorCode == 103){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Password Expired Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", PASSWORD_EXPIRED_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else if (errorCode == 300){
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Server Authentication Exception %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure", SERVER_AUTH_EXCEPTION_NAME, @(errorCode)]];
            return @"";
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Error while retreiving transaction %@", [error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[@"failure",@"Exception", [error localizedDescription]]];
            return @"";
        }
    }
    
    NSString* tds = [pTransaction toString];
    NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction tds is %@", tds);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          tds, @"tds", username, @"username", nil];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options: NSJSONWritingPrettyPrinted error:&jsonError];
    if(!jsonData){
        NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction Error while converting JSON %@", jsonError);
        [self executeGenericCallback:callback withParams:@[@"failure",@"JSONException",[jsonError localizedDescription]]];
    }else{
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"ApproveSDKWrapper ---> HID:retreiveTransaction TransactionInfo is %@", jsonString);
        [self executeGenericCallback:callback withParams:(@[@"success",@"No Exception",jsonString])];
    }
    return @"";
    
}

/**
* This method sets the notification status for a transaction/notification.
*
* @param txID - The transaction ID.
* @param status - The status to set (e.g., "approve", "deny", "report").
* @param pwd - The password for authentication, if Biometric is not enabled and if enabled passed "".
* @param onCompleteCB - The callback function to execute after setting the status.
* @param pwdPromptCB - The callback function to prompt for password, if required.
*/
-(void) setNotificationStatus:(NSString *)txID withStatus:(NSString *)status withPassword:(id)pwd withJSCallback:(JSValue *)onCompleteCB withPwdPromptCB:(JSValue *)pwdPromptCB{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        bool isPasswordTimeoutFlow = ![pwd isEqualToString:@""];
        NSError* deviceError;
        NSError* error;
        HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
        id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
        
        id<HIDServerActionInfo> transactionInfo = [pDevice retrieveActionInfo:txID error:&error];
        
        id<HIDTransaction> pTransaction = (id<HIDTransaction>)[transactionInfo getAction:nil withParams:nil error:&error];
        if(error != nil){
            int errorCode = (int)[error code];
            if(errorCode == 100){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Authentication Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[AUTHENTICATION_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if( errorCode == 300){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Server Authentication Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[SERVER_AUTH_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if(errorCode == 1000){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Transaction Expired Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[TRANSACTION_EXPIRED_EXCEPTION_NAME,TRANSACTION_EXPIRED_CODE])];
            }else if( errorCode == 0){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Internal Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[INTERNAL_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if (errorCode == 8){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Invalid Container Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[HID_INVALID_CONTAINER_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if (errorCode == 3){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Invalid Argument Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if (errorCode == 9){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Inexplicit Container Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[HID_INEXPLICIT_CONTAINER_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if (errorCode == 102){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Credentials Expired Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if (errorCode == 103){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Password Expired Exception %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[PASSWORD_EXPIRED_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Transaction getAction: %@", [error localizedDescription] );
                [self executeGenericCallback:pwdPromptCB withParams:(@[PWD_PROMPT_ERROR_EVENT_TYPE,PWD_PROMPT_ERROR_EVENT_CODE])];
            }
        }
        if(isPasswordTimeoutFlow){
            [self invokePasswordAuthNotification:(pTransaction) withPassword:(pwd) withStatus:(status) withCompletionCB:(onCompleteCB) withPwdPromptCB:(pwdPromptCB)];
            return;
        }
        bool result = [pTransaction setStatus:status withSigningPassword:nil withSessionPassword:(nil) withParams:nil error:(&error)];
        if(error != nil){
            int errorCode = (int)[error code];
            if(errorCode == 105 || errorCode == 203){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", @"FingerPrintException");
                [self executeGenericCallback:pwdPromptCB withParams:(@[PWD_PROMPT_PROGRESS_EVENT_TYPE,PWD_PROMPT_PROGRESS_EVENT_CODE])];
            }else if(errorCode == 100 || errorCode == 105){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", @"PasswordException");
                [self executeGenericCallback:pwdPromptCB withParams:(@[PWD_PROMPT_PROGRESS_EVENT_TYPE,PWD_PROMPT_PROGRESS_EVENT_CODE])];
            }else if(errorCode == 1000){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", @"TransactionExpiredException");
                [self executeGenericCallback:pwdPromptCB withParams:(@[TRANSACTION_EXPIRED_EXCEPTION_NAME,TRANSACTION_EXPIRED_CODE])];
            }else if(errorCode == 102){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", @"CredentialsExpiredException");
                [self executeGenericCallback:pwdPromptCB withParams:(@[HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if(errorCode == 0){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[INTERNAL_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if(errorCode == 103){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[PASSWORD_EXPIRED_EXCEPTION_NAME,PWD_EXPIRED_PROMPT_EVENT_CODE])];
            }else if(errorCode == 300){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[SERVER_AUTH_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if(errorCode == 3){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else if(errorCode == 301){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", [error localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:(@[HID_SERVER_VERSION_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error While Updating the notification status %@", [error localizedDescription] );
                [self executeGenericCallback:pwdPromptCB withParams:(@[@"Exception",PWD_PROMPT_ERROR_EVENT_CODE])];
            }
        }
        else if(deviceError != nil){
            NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Device Error While Updating the notification status %@", [deviceError localizedDescription]);
            int errorCodeDevice = (int)[deviceError code];
            if(errorCodeDevice == 0){
                NSLog(@"ApproveSDKWrapper ----> HID:setNotificationStatus Internal Exception %@",[deviceError localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:@[INTERNAL_EXCEPTION_NAME, PWD_PROMPT_ERROR_EVENT_CODE]];
            }else if (errorCodeDevice == 3){
                NSLog(@"ApproveSDKWrapper ----> HID:setNotificationStatus Invalid Argument Exception %@",[deviceError localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:@[HID_INVALID_ARGUMENT_EXCEPTION_NAME, PWD_PROMPT_ERROR_EVENT_CODE]];
            }else if (errorCodeDevice == 7){
                NSLog(@"ApproveSDKWrapper ----> HID:setNotificationStatus Unsupported Version Exception %@",[deviceError localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:@[HID_UNSUPPORTED_VERSION_EXCEPTION_NAME, PWD_PROMPT_ERROR_EVENT_CODE]];
            }else if(errorCodeDevice == 106){
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Lost Credentials Exception %@", [deviceError localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:@[LOST_CREDENTIALS_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE]];
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:setNotificationStatus Error while creating HID Device %@", [deviceError localizedDescription]);
                [self executeGenericCallback:pwdPromptCB withParams:@[@"Exception",PWD_PROMPT_ERROR_EVENT_CODE]];
            }
        }else{
            [self executeGenericCallback:onCompleteCB withParams:(@[result?@"true":@"false"])];
        }
    });
}

/**
*
*This method is used to invoke the password authentication notification for Set Notification Status flow.
*
*@param transaction - The HIDTransaction object representing the transaction.
*@param pwd - The password to authenticate the transaction.
*@param status - The status to set for the transaction.
*@param onCompleteCB - The callback function to execute after setting the status.
*@param promptCB - The callback function to prompt for password, if required.
*/
-(void)invokePasswordAuthNotification: (id<HIDTransaction>) transaction withPassword : (NSString*)pwd withStatus : (NSString* ) status withCompletionCB :(JSValue* )onCompleteCB withPwdPromptCB : (JSValue *)promptCB {
    NSError* error;
    NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Inside Password TimeOut flow");
    bool result = [transaction setStatus:status withSigningPassword:pwd withSessionPassword:(nil) withParams:nil error:(&error)];
    if(error != nil){
        int errorCode = (int)[error code];
        if(errorCode == 100 || errorCode == 105){
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", [error localizedDescription]);
            [self executeGenericCallback:promptCB withParams:(@[PWD_PROMPT_ERROR_EVENT_TYPE,PWD_PROMPT_ERROR_EVENT_CODE])];
        }else if(errorCode == 1000){
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", [error localizedDescription]);
            [self executeGenericCallback:promptCB withParams:(@[TRANSACTION_EXPIRED_EXCEPTION_NAME,TRANSACTION_EXPIRED_CODE])];
        }else if(errorCode == 102){
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", @"CredentialsExpiredException");
            [self executeGenericCallback:promptCB withParams:(@[HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
        }else if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", [error localizedDescription]);
            [self executeGenericCallback:promptCB withParams:(@[INTERNAL_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
        }else if(errorCode == 103){
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", [error localizedDescription]);
            [self executeGenericCallback:promptCB withParams:(@[PASSWORD_EXPIRED_EXCEPTION_NAME,PWD_EXPIRED_PROMPT_EVENT_CODE])];
        }else if(errorCode == 300){
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", [error localizedDescription]);
            [self executeGenericCallback:promptCB withParams:(@[SERVER_AUTH_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
        }else if(errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", [error localizedDescription]);
            [self executeGenericCallback:promptCB withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
        }else if(errorCode == 301){
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", [error localizedDescription]);
            [self executeGenericCallback:promptCB withParams:(@[HID_SERVER_VERSION_EXCEPTION_NAME,PWD_PROMPT_ERROR_EVENT_CODE])];
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", [error localizedDescription]);
            [self executeGenericCallback:promptCB withParams:(@[@"Exception",PWD_PROMPT_ERROR_EVENT_CODE])];
        }
    }else{
        [self executeGenericCallback:onCompleteCB withParams:(@[result?@"true":@"false"])];
    }
}

/**
* This public method is used to cancel a transaction.
*
* @param txId          - The transaction ID to cancel.
* @param message       - The message to be sent with the cancellation. //optional
* @param reason        - The reason for cancellation (e.g., "cancel", "suspicious").
* @param cancelCallback - The callback function to execute after cancellation.
*/
-(void)transactionCancel:(NSString *)txId withMessage:(NSString *)message withReason:(NSString *)reason withCallback:(JSValue *)cancelCallback {
    __block NSString *messageToSend = message;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* deviceError;
        NSError* error;
        HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
        id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
        
        if(deviceError != nil){
            int errorCodeDevice = (int)[deviceError code];
            if(errorCodeDevice == 0){
                NSLog(@"ApproveSDKWrapper ----> HID:transactionCancel Internal Exception %@",[deviceError localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Internal Exception"]];
                return;
            }else if (errorCodeDevice == 3){
                NSLog(@"ApproveSDKWrapper ----> HID:transactionCancel Invalid Argument Exception %@",[deviceError localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Invalid Argument Exception"]];
                return;
            }else if (errorCodeDevice == 7){
                NSLog(@"ApproveSDKWrapper ----> HID:transactionCancel Unsupported Version Exception %@",[deviceError localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Unsupported Version Exception"]];
                return;
            }else if (errorCodeDevice == 106){
                NSLog(@"ApproveSDKWrapper ----> HID:transactionCancel Lost Credentials Exception %@",[deviceError localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Lost Credentials Exception"]];
                return;
            }else{
                NSLog(@"ApproveSDKWrapper ----> HID:transactionCancel DeviceError While Deleting Container %@",[deviceError localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Device Error"]];
                return;
            }
        }
        
        id<HIDServerActionInfo> transactionInfo = [pDevice retrieveActionInfo:txId error:&error];
        
        
        id<HIDTransaction> pTransaction = (id<HIDTransaction>)[transactionInfo getAction:nil withParams:nil error:&error];
        
        NSString *transactionString = pTransaction.toString;
        
        id<HIDContainer> pContainer = [transactionInfo getContainer:&error];
        
        if(transactionString == nil){
            NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Transaction is Empty %@", [error localizedDescription]);
            [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Transaction is Empty"]];
            return;
        }
        
        if(pContainer == nil){
            NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Error while retrieving container info %@", [error localizedDescription]);
            [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Container is Empty"]];
            return;
        }
        
        if(reason == nil || [reason isEqualToString:@""]){
            NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Reason is null or empty");
            [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Reason is null or empty"]];
            return;
        }
        
        if(messageToSend == nil || [messageToSend isEqualToString:@""]){
            NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Message is null or empty");
            messageToSend = @"";
        }
        
        if([reason  isEqual: @"cancel"]){
            HIDCancelationReasonCode reasonCancel = CANCELATION_REASON_CANCEL;
            [pTransaction cancel:messageToSend withCancelationReason:reasonCancel withSessionPassword:@"" error:&error];
            NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Transaction cancelled successfully with reason: %@", reason);
            [self executeGenericCallback:cancelCallback withParams:@[@"success", @"Transaction cancelled successfully"]];
        }else if ([reason isEqual:@"suspicious"]){
            HIDCancelationReasonCode reasonSuspicious = CANCELATION_REASON_SUSPICIOUS;
            [pTransaction cancel:messageToSend withCancelationReason:reasonSuspicious withSessionPassword:@"" error:&error];
            NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Transaction marked as suspicious with reason: %@", reason);
            [self executeGenericCallback:cancelCallback withParams:@[@"success", @"Transaction marked as suspicious"]];
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Invalid reason provided");
            [self executeGenericCallback:cancelCallback withParams:@[@"error", @"Invalid reason provided"]];
            return;
        }
        
        if(error != nil){
            int errorCode = (int)[error code];
            if(errorCode == 0){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Internal Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[INTERNAL_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 8){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Invalid Container Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[HID_INVALID_CONTAINER_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 3){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Invalid Argument Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[HID_INVALID_ARGUMENT_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 9){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Inexplicit Container Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[HID_INEXPLICIT_CONTAINER_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 100){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Authentication Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[AUTHENTICATION_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 1000){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Transaction Expired Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[TRANSACTION_EXPIRED_EXCEPTION_NAME, [error localizedDescription]]];
            }else if (errorCode == 102){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Credentials Expired Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 103){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Password Expired Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[PASSWORD_EXPIRED_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 300){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Server Authentication Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[SERVER_AUTH_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 105){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Password Required Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[PASSWORD_REQUIRED_EXCEPTION_NAME, [error localizedDescription]]];
            }else if(errorCode == 305){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Server Operation Failed Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[HID_SERVER_OPERATION_FAILED_EXCEPTION_NAME, [error localizedDescription]]];
            }else if (errorCode == 304){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Server Unsupported Operation Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[HID_SERVER_UNSUPPORTED_OPERATION_NAME, [error localizedDescription]]];
            }else if(errorCode == 1002){
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Transaction Canceled Exception %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[HID_TRANSACTION_CANCELED_EXCEPTION_NAME, [error localizedDescription]]];
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:transactionCancel Error: %@", [error localizedDescription]);
                [self executeGenericCallback:cancelCallback withParams:@[@"error", [error localizedDescription]]];
            }
        }
    }
    );
}

/**
* This method is used to set the Username.
*
* @param username - Username to be set.
*/
-(void)setUsername:(NSString *)username {
    if(username != nil){
        _username = username;
        NSLog(@"ApproveSDKWrapper ---> HID:setUsername Username is %@", _username);
    }
}

/**
 *This method is used to convert a hex string to NSData.
 *
 * @param string - The hex string to convert.
 * @return NSData - The converted data from the hex string.
 */
-(NSData *)dataFromHexString:(NSString *)string {
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

/**
 * This method checks if a string is empty or contains only whitespace characters.
 *
 * @param str - The string to check.
 * @return BOOL - Returns YES if the string is empty or contains only whitespace characters, NO otherwise.
 */
-(bool) isEmptyString : (NSString* )str{
    return str == nil || [str length] == 0  || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0;
}

/**
* This method is used to check the multi user bio status.
*
* @return bool indicating whether the device is multi user or not.
*/
-(bool) checkMultiuserBioStatus{
    NSError* deviceError;
    NSError* containerError;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    if(deviceError != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:checkMultiuserBioStatus device Error: %@",[deviceError localizedDescription]);
        return FALSE;
    }
    NSMutableArray* filterContainers = [[NSMutableArray alloc]init];
    NSArray* pContainers = [pDevice findContainers:(filterContainers) error:(&containerError)];
    for(id<HIDContainer> pConatiner in pContainers){
        id<HIDBioPasswordPolicy> bioPasswordPolicy = (id<HIDBioPasswordPolicy>)[pConatiner getProtectionPolicy:(&containerError)];
        if([bioPasswordPolicy getBioAuthenticationState] == HIDBioAuthenticationStateEnabled){
            return FALSE;
        }
    }
    if(containerError != nil){
        NSLog(@"ApproveSDKWrapper ---> HID:checkMultiuserBioStatus container Error: %@",[deviceError localizedDescription]);
        return FALSE;
    }
    return TRUE;
}

/**
* This method deletes the container with authentication.
*
* @param pwd - The password for authentication, if any.
* @param callback - The callback function to execute after deletion.
*/
-(void) deleteContainerWithAuth:(NSString *)pwd withCallback:(JSValue *)callback{
    NSError *error;
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    id<HIDPasswordPolicy> policy = (id<HIDPasswordPolicy>) [pContainer getProtectionPolicy:&error];
    if(error!=nil){
        int errorCode = (int)[error code];
        if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuth Internal Exception While Deleting %@",[error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[INTERNAL_EXCEPTION_NAME]];
        }else if (errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuth Invalid Argument Exception While Deleting Container %@",[error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[HID_INVALID_ARGUMENT_EXCEPTION_NAME]];
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuth container Error: %@",[error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[HID_GENERIC_EXCEPTION]];
        }
        return;
    }
    if([self isEmptyString:pwd] && [self checkBioAvailability]){
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuth No Password Provided, Using BioAuth");
        [policy verifyPassword:nil error:&error];
    }else if([self isEmptyString:pwd]){
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuth No Password Provided, BioAuth not enabled");
        [self executeGenericCallback:callback withParams:@[BIO_NOT_ENABLED]];
        return;
    }else{
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuth Password Provided, Using Password Auth");
        [policy verifyPassword:pwd error:&error];
    }
    if(error != nil){
        int errorCode = (int)[error code];
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuth Error While Deleting user: %@",[error localizedDescription]);
        if(errorCode == 100){
            [self executeGenericCallback:callback withParams:@[AUTHENTICATION_EXCEPTION_NAME]];
            return;
        }
        if(errorCode == 105 || errorCode == 203){
            [self executeGenericCallback:callback withParams:@[HID_FINGERPRINT_EXCEPTION]];
            return;
        }
        [self executeGenericCallback:callback withParams:@[HID_GENERIC_EXCEPTION]];
        return;
    }
    NSString* status =  [self deleteContainer] ? @"success" : @"failure";
    NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuth Deletion status is %@", status);
    [self executeGenericCallback:callback withParams:@[status]];
}

/**
* This method deletes the container with authentication.
*
* @param pwd - The password for authentication, if any.
* @param callback - The callback function to execute after deletion.
*/
-(void) deleteContainerWithAuthWithReason:(NSString *)pwd withReason :(NSString *)reason withCallback:(JSValue *)callback{
    NSError *error;
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    id<HIDPasswordPolicy> policy = (id<HIDPasswordPolicy>) [pContainer getProtectionPolicy:&error];
    if(error!=nil){
        int errorCode = (int)[error code];
        if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason Internal Exception While Deleting %@",[error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[INTERNAL_EXCEPTION_NAME]];
        }else if (errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason Invalid Argument Exception While Deleting Container %@",[error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[HID_INVALID_ARGUMENT_EXCEPTION_NAME]];
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason container Error: %@",[error localizedDescription]);
            [self executeGenericCallback:callback withParams:@[HID_GENERIC_EXCEPTION]];
        }
        return;
    }
    
    NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason Deleting Container with reason %@", reason);
    if(reason == nil || [reason isEqualToString: @""]){
        reason = nil;  // If reason is empty, set it to nil
    }
    
    if([self isEmptyString:pwd] && [self checkBioAvailability]){
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason No Password Provided, Using BioAuth");
        [policy verifyPassword:nil error:&error];
    }else if([self isEmptyString:pwd]){
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason No Password Provided, BioAuth not enabled");
        [self executeGenericCallback:callback withParams:@[BIO_NOT_ENABLED]];
        return;
    }else{
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason Password Provided, Using Password Auth");
        [policy verifyPassword:pwd error:&error];
    }
    if(error != nil){
        int errorCode = (int)[error code];
        NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason Error While Deleting user: %@",[error localizedDescription]);
        if(errorCode == 100){
            [self executeGenericCallback:callback withParams:@[AUTHENTICATION_EXCEPTION_NAME]];
            return;
        }
        if(errorCode == 105 || errorCode == 203){
            [self executeGenericCallback:callback withParams:@[HID_FINGERPRINT_EXCEPTION]];
            return;
        }
        [self executeGenericCallback:callback withParams:@[HID_GENERIC_EXCEPTION]];
        return;
    }
    NSString* status =  [self deleteContainerWithReason:reason] ? @"success" : @"failure";
    NSLog(@"ApproveSDKWrapper ---> HID:deleteContainerWithAuthWithReason Deletion status is %@", status);
    [self executeGenericCallback:callback withParams:@[status]];
}

/**
* This method retrieves the device property, specifically the device ID.
*
* @return NSString - representing the device ID.
*/
- (NSString *)getDeviceProperty {
    NSError *error;
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    // Assuming this method returns a valid container
    NSString *deviceId = @"";
    NSLog(@"ApproveSDKWrapper ---> HID:getDeviceProperty inside get device property");
    @try {
        // Assuming `getProperty:` returns an object or string that can be cast to an NSString
        deviceId = [pContainer getProperty:DEVICE_ID
                                     error:&error];
        NSLog(@"ApproveSDKWrapper ---> HID:getDeviceProperty Device ID is %@", deviceId);
    }
    @catch (NSException *exception) {
        // Handle exception
        NSLog(@"ApproveSDKWrapper ---> HID:getDeviceProperty Exception %@", exception);
    }
    NSLog(@"ApproveSDKWrapper ---> HID:getDeviceProperty Device ID is %@", deviceId);
    return deviceId;
}

/**
* This method retrieves the friendly name of the container for a single user.
*
* @return string - representing the friendly name of the container.
*/
- (NSString *)getContainerFriendlyName {
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    NSLog(@"ApproveSDKWrapper ---> HID:getContainerFriendlyName HID In getContainerFriendlyName");
    
    NSString *getName = @"";
    @try {
        getName = pContainer.getName;
        NSLog(@"ApproveSDKWrapper ---> HID:getContainerFriendlyName Container Name is %@", getName);
    }
    @catch (NSException *exception) {
        // Handle exception
        NSLog(@"ApproveSDKWrapper ---> HID:getContainerFriendlyName getContainerFriendlyName Exception %@", exception);
    }
    return getName;
}

/**
* This method retrieves the friendly name of the container for a single or multiple users.
*
* @return string - representing the friendly name of the container(s).
*/
-(NSString *)getMultiContainerFriendlyName {
    
    NSError* deviceError;
    NSError* containerError;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    
    if (deviceError != nil) {
        int errorCodeDevice = (int)[deviceError code];
        
        if(errorCodeDevice == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName Internal Exception while creating container %@", [deviceError localizedDescription]);
        }else if(errorCodeDevice == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName Invalid Argument Exception while creating container %@", [deviceError localizedDescription]);
        }else if(errorCodeDevice == 7){
            NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName Unsupported Version Exception while creating container %@", [deviceError localizedDescription]);
        }else if (errorCodeDevice == 106){
            NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName Lost Credentials Exception while creating container %@", [deviceError localizedDescription]);
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName error while creating container %@", [deviceError localizedDescription]);
        }
        return @"error";
    }
    
    NSMutableArray *filterContainers = [[NSMutableArray alloc] init];
    NSArray *pContainers = [pDevice findContainers:filterContainers error:&containerError];
    if (containerError != nil) {
        int errorCodeContainer = (int)[containerError code];
        
        if(errorCodeContainer == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName Internal Exception while creating container %@", [containerError localizedDescription]);
        }else if(errorCodeContainer == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName Invalid Argument Exception while creating container %@", [containerError localizedDescription]);
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName error while creating container %@", [containerError localizedDescription]);
        }
        return @"error";
    }
    
    if ([pContainers count] == 0) {
        NSLog(@"ApproveSDKWrapper ---> HID:getMultiContainerFriendlyName getMultiContainerFriendlyName No Containers Found, prompting for register");
        return @"Register";
    }
    
    if ([pContainers count] == 1) {
        
        NSString *loginType = @"SingleLogin:";
        NSString *username = [pContainers[0] getUserId];
        NSString *getName = [pContainers[0] getName];
        NSLog(@"ApproveSDK ---> HID:getMultiContainerFriendlyName getMultiContainerFriendlyName: %@", [loginType stringByAppendingFormat:@"%@,%@", username, getName]);
        return [loginType stringByAppendingFormat:@"%@,%@", username, getName];
    } else {
        NSMutableString *multiflowString = [[NSMutableString alloc] initWithString:@"MultiLogin:"];
        
        for (id<HIDContainer> pContainerLoop in pContainers) {
            [multiflowString appendString:[pContainerLoop getUserId]];
            [multiflowString appendString:@","];
            [multiflowString appendString:[pContainerLoop getName]];
            [multiflowString appendString:@"|"];
        }
        
        NSLog(@"ApproveSDK ---> HID:getMultiContainerFriendlyName getMultiContainerFriendlyName: %@", multiflowString);
        
        return [multiflowString substringToIndex:([multiflowString length] - 1)];
    }
}

/**
* This method sets the friendly name of the container for a given username.
*
* @param username - The username associated with the container.
* @param friendlyName - The new friendly name to set for the container.
* @param setNameCallback - The callback function to execute after setting the name for success and failure response.
*/
- (void)setContainerFriendlyName:(NSString *)username withFriendlyName: (NSString *)friendlyName withSetNameCallback : (JSValue *)setNameCallback{
    NSError* deviceError;
    NSError* containerError;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    
    if (deviceError != nil) {
        NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName error while creating container %@", [deviceError localizedDescription]);
        [self executeGenericCallback:setNameCallback withParams:(@[@"Device Error",@"error"])];
    }
    
    NSMutableArray *filterContainers = [[NSMutableArray alloc] init];
    NSArray *pContainers = [pDevice findContainers:filterContainers error:&containerError];
    if (containerError != nil) {
        NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName error while creating container %@", [containerError localizedDescription]);
        [self executeGenericCallback:setNameCallback withParams:(@[@"Container Error",@"error"])];
    }
    
    NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName HID In setContainerFriendlyName");
    
    NSError *error = nil;
    
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _username = username;
    
    NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Wrapper Username --> %@", _username);
    NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Username --> %@", username);
    
    for (id<HIDContainer> c in pContainers) {
        NSString *userId = [[c getUserId] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Container UserId--> %@", userId);
        
        if ([username isEqualToString:userId]) {
            NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Container Name matched with userId--> %@ %@", username, userId);
            NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Friendly Name --> %@", friendlyName);
            [c setName:friendlyName error:&error];
            NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName New Friendly Name --> %@", friendlyName);
            [self executeGenericCallback:setNameCallback withParams:(@[@"Container Friendly Name Set Successfully", @"success"])];
        }
    }
    
    if(error != nil){
        int errorCode = (int)[error code];
        if(errorCode == 200){
            NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Error While setContainerFriendlyName %@", @"UnsupportedDeviceException");
            [self executeGenericCallback:setNameCallback withParams:(@[UNSUPPORTED_DEVICE_EXCEPTION_NAME,UNSUPPORTED_DEVICE_CODE])];
        }else if(errorCode == 106){
            NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Error While setContainerFriendlyName %@", @"LostCredentialsException");
            [self executeGenericCallback:setNameCallback withParams:(@[LOST_CREDENTIALS_EXCEPTION_NAME,LOST_CREDENTIALS_CODE])];
        }else if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Error While setContainerFriendlyName %@", @"InternalException");
            [self executeGenericCallback:setNameCallback withParams:(@[INTERNAL_EXCEPTION_NAME,INTERNAL_EXCEPTION_CODE])];
        }else if(errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Error While setContainerFriendlyName %@", @"InvalidParameterException");
            [self executeGenericCallback:setNameCallback withParams:(@[INVALID_PARAMETER_EXCEPTION,INVALID_PARAMETER_CODE])];
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:setContainerFriendlyName Error While Updating the notification status %@", [error localizedDescription] );
        }
    }
}


/**
* This method retrieves the lock policy of the OTP key in the container.
*
* @param otp_Key - The label of the OTP key (e.g., "hotp", "totp").
* @param code - The code indicating the type of operation (e.g., "secure", "sign").
* @return string - The lock policy type as a string, or null if not found.
*/
-(NSString *)getLockPolicy:(NSString *) otp_Key withCode:(NSString *)code {
    
    __block NSString *lockTypeString = @"Unknown";
    __block NSString *otp_key = otp_Key;
    
    NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy - otp_Key: %@", otp_Key);
    NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy - code: %@", code);
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError* error;
        
        if(otp_Key == nil || otp_Key.length == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy otp_Key is empty");
            return;
        }
        
        if([otp_key  isEqual: @"hotp"] || [otp_key  isEqual: @"totp"]){
            if([code isEqual: CODE_SECURE]){
                otp_key = HOTP_OTP_KEY;
                if([otp_key isEqualToString: TOTP_LABEL_NAME]){
                    otp_key = TOTP_OTP_KEY;
                    NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy - otp_key: %@",otp_key);
                }
            }
            if([code isEqual: CODE_SIGN]){
                otp_key = HOTP_SIGN_KEY;
                if([otp_key isEqualToString: TOTP_LABEL_NAME]){
                    otp_key = TOTP_SIGN_KEY;
                    NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy - otp_key: %@",otp_key);
                }
            }
        }
        
        id<HIDContainer> pContainer = [self getSingleUserContainer];
        if(pContainer == nil){
            NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy No Containers Found");\
            return;
        }
        NSMutableArray* filter = [[NSMutableArray alloc] init];
        [filter addObject:[HIDParameter parameterWithString:HID_KEY_PROPERTY_USAGE_OTP forKey:HID_KEY_PROPERTY_USAGE]];
        NSArray* keys = [pContainer findKeys:filter error:&error];
        if(error != nil){
            int errorCode = (int)[error code];
            if (errorCode == 0){
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy Internal Exception while finding keys %@", [error localizedDescription]);
            }else if(errorCode == 3){
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy Invalid Argument Exception while finding keys %@", [error localizedDescription]);
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy Error while finding keys %@", [error localizedDescription]);
            }
            return;
        }
        NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy Found Keys %@",keys);
        
        id<HIDKey> pKey = [keys objectAtIndex:0];
        
        if (!pKey) {
            NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy No OTP key found");
            return;
        }else{
            if (keys.count > 1) {
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy More than one OTP key found");
                for (id<HIDKey> key in keys) {
                    NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy - Key: %@", key);
                    NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy Checking key: %@", [key getProperty:HID_KEY_PROPERTY_LABEL error:nil]);
                    NSString *keyLabel = [key getProperty:HID_KEY_PROPERTY_LABEL error:nil];
                    if ([keyLabel isEqualToString:otp_key] && keyLabel != nil) {
                        pKey = key;
                        NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy - Selected Key: %@", pKey);
                        break;
                    }
                }
            }
        }
        
        NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy OTP Key Policy Type is %u", [[pKey getProtectionPolicy:nil] policyType]);
        NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy OTP Key Algorithm is %@", [pKey getAlgorithm:(&error)]);
        NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy OTP Key Label is %@", [pKey getProperty:HID_KEY_PROPERTY_LABEL error:nil]);
        

        id<HIDProtectionPolicy> policy = [pKey getProtectionPolicy:nil];
        id<HIDLockPolicy> lockPolicy = [policy lockPolicy];
        HIDLockType lockType = [lockPolicy lockType];
        NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy lockType is %u", lockType);

        switch (lockType) {
            case HIDLockTypeNone:
                lockTypeString = @"NONE";
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy HIDLockType is None (never locks)");
                break;
            case HIDLockTypeLock:
                lockTypeString = @"LOCK";
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy HIDLockType is Lock (locks after number of attempts)");
                break;
            case HIDLockTypeDelay:
                lockTypeString = @"DELAY";
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy HIDLockType is Delay (adds exponential delay)");
                break;
            case HIDLockTypeSilent:
                lockTypeString = @"SILENT";
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy HIDLockType is Silent (delegated server-side control)");
                break;
            default:
                lockTypeString = @"Unknown";
                NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy HIDLockType is unknown");
                break;
        }
    });
    NSLog(@"ApproveSDKWrapper ---> HID:getLockPolicy HIDLockType Lock Type is %@", lockTypeString);
    return lockTypeString;
}

/**
* This method retrieves information about the device and its containers.
*
* @return NSString - A JSON string containing device and container information.
*/
-(NSString *)getInfo{
    NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *containerInfo = [NSMutableDictionary dictionary];
    NSMutableArray *containerInfoArray = [NSMutableArray array];
    NSMutableDictionary *getInfo = [NSMutableDictionary dictionary];
    
    NSError* deviceError;
    NSError* containerError;
    HIDConnectionConfiguration* connectionConfig = [[HIDConnectionConfiguration alloc] init];
    id<HIDDevice> pDevice = [[HIDDeviceFactory alloc] getDevice:connectionConfig error:&deviceError];
    
    if (deviceError != nil) {
        NSLog(@"ApproveSDKWrapper ---> HID:getInfo Device Error User Info: %@", [deviceError userInfo]);
        NSLog(@"ApproveSDKWrapper ---> HID:getInfo Device Error: %@", [deviceError localizedDescription]);
        int errorCode = (int)[deviceError code];
        if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:getInfo HID Internal Exception %@", [deviceError localizedDescription]);
            return @"HID Internal Exception";
        }else if(errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:getInfo HID Invalid Argument Exception %@", [deviceError localizedDescription]);
            return @"HID Invalid Argument Exception";
        }else if(errorCode == 7){
            NSLog(@"ApproveSDKWrapper ---> HID:getInfo HID Unsupported Version Exception %@", [deviceError localizedDescription]);
            return @"HID Unsupported Version Exception";
        }else if (errorCode == 106){
            NSLog(@"ApproveSDKWrapper ---> HID:getInfo Lost Credentials Exception %@", [deviceError localizedDescription]);
            return @"Lost Credentials Exception";
        }else{
            return @"Device Error";
        }
    }
    
    deviceInfo[@"deviceBrand"] = [pDevice getDeviceInfo:HID_DEVICE_INFO_BRAND error:&deviceError];
    deviceInfo[@"deviceModel"] = [pDevice getDeviceInfo:HID_DEVICE_INFO_MODEL error:&deviceError];
    deviceInfo[@"deviceFriendlyName"] = [pDevice getDeviceInfo:HID_DEVICE_INFO_NAME error:&deviceError];
    deviceInfo[@"deviceOS"] = [pDevice getDeviceInfo:HID_DEVICE_INFO_OS error:&deviceError];
    deviceInfo[@"deviceOSName"] = [pDevice getDeviceInfo:HID_DEVICE_INFO_OS_NAME error:&deviceError];
    deviceInfo[@"deviceOSVersion"] = [pDevice getDeviceInfo:HID_DEVICE_INFO_OS_VERSION error:&deviceError];
    deviceInfo[@"deviceKeyStore"] = [pDevice getDeviceInfo:HID_DEVICE_INFO_KEYSTORE error:&deviceError];
    deviceInfo[@"deviceIsRooted"] = [pDevice getDeviceInfo:HID_DEVICE_INFO_ISROOTED error:&deviceError];
    deviceInfo[@"deviceHIDSDKVersion"] = [pDevice getVersion:&deviceError];
    
    NSMutableArray *filterContainers = [[NSMutableArray alloc] init];
    NSArray *pContainers = [pDevice findContainers:filterContainers error:&containerError];
    if (containerError != nil) {
        NSLog(@"ApproveSDKWrapper ---> HID:getInfo error while findContainers %@", [containerError localizedDescription]);
        int errorCode = (int)[deviceError code];
        if(errorCode == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:getInfo HID Internal Exception while findContainers %@", [containerError localizedDescription]);
            return @"HID Internal Exception";
        }else if(errorCode == 3){
            NSLog(@"ApproveSDKWrapper ---> HID:getInfo HID Invalid Argument Exception while findContainers %@", [containerError localizedDescription]);
            return @"HID Invalid Argument Exception";
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:getInfo error while findContainers %@", [containerError localizedDescription]);
            return @"Container Error";
        }
    }
    
    if ([pContainers count] == 0) {
        NSLog(@"ApproveSDKWrapper ---> HID:getInfo No Containers Found, prompting for register");
        return @"No Container found";
    }
     
    
    for(id<HIDContainer> container in pContainers){
        containerInfo[@"serverURL"] = [container getServerURL];
        containerInfo[@"serverDomain"] = [container getProperty:HID_PROPERTY_DOMAIN error:&containerError];
        containerInfo[@"serverVersion"] = [container getProperty:HID_PROPERTY_PROTOCOL_VERSION error:&containerError];
        containerInfo[@"deviceId"] = [self getDeviceProperty];
        containerInfo[@"containerId"] = [NSString stringWithFormat:@"%ld", (long)[container getId]];
        containerInfo[@"containerUserId"] = [container getUserId];
        containerInfo[@"containerFriendlyName"] = [self getContainerFriendlyName];
        NSDate *creationDate = [container getCreationDate:&containerError];
        NSDate *expiryDate = [container getExpiryDate:&containerError];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM dd HH:mm:ss z yyyy";
        containerInfo[@"containerCreationDate"] = [formatter stringFromDate:creationDate];
        containerInfo[@"containerExpirationDate"] = [formatter stringFromDate:expiryDate];
        containerInfo[@"isContainerRenewable"] = [container isRenewable:@"" error:&containerError] ? @"true" : @"false";
        
        [containerInfoArray addObject:containerInfo];
    }
    
    getInfo[@"deviceInfo"] = deviceInfo;
    getInfo[@"containerInfo"] = containerInfoArray;
    
    NSError *error;
    NSData *infoD = [NSJSONSerialization dataWithJSONObject:getInfo options:NSJSONWritingPrettyPrinted error:&error];
    if (!infoD){
        NSLog(@"ApproveSDKWrapper ---> HID:getInfo: JSON Error: %@", error.localizedDescription);
        return nil;
    }

    NSString *info = [[NSString alloc] initWithData:infoD encoding:NSUTF8StringEncoding];
    NSLog(@"ApproveSDKWrapper ---> HID:getInfo Get Info: %@", info);
    
    return info;
}

/**
* This method retrieves the list of keys in the container.
*
* @return NSString - A JSON string containing key information.
*/
-(NSString *)getKeyList{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableDictionary *keyInfo = [NSMutableDictionary dictionary];
    
    NSError *error;
    
    id<HIDContainer> pContainer = [self getSingleUserContainer];
    if (pContainer != nil) {
        NSMutableArray* filter = [[NSMutableArray alloc] init];
        [filter addObject:[HIDParameter parameterWithString:HID_KEY_PROPERTY_USAGE_OTP forKey:HID_KEY_PROPERTY_USAGE]];
        NSArray* keys = [pContainer findKeys:nil error:&error];
        if(error != nil){
            int errorCode = (int)[error code];
            if (errorCode == 0){
                NSLog(@"ApproveSDKWrapper ---> HID:getKeyList Internal Exception while finding keys %@", [error localizedDescription]);
            }else if(errorCode == 3){
                NSLog(@"ApproveSDKWrapper ---> HID:getKeyList Invalid Argument Exception while finding keys %@", [error localizedDescription]);
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:getKeyList Error while finding keys %@", [error localizedDescription]);
            }
        }
        for(id<HIDKey> key in keys){
            NSString *keyIdString;
            if ([[key getId] ID] && [[[key getId] ID] isKindOfClass:[NSString class]]) {
                keyIdString = [[key getId] ID];  // Directly use if it's NSString
            } else {
                keyIdString = [NSString stringWithFormat:@"%@", [[key getId] ID]];  // Force conversion to NSString
            }
            keyInfo[@"keyId"] = keyIdString;
            keyInfo[@"keyLabel"] = [key getProperty:HID_KEY_PROPERTY_LABEL error:&error];
            keyInfo[@"keyUsage"] = [key getProperty:HID_KEY_PROPERTY_USAGE error:&error];
            keyInfo[@"keyCreationDate"] = [key getProperty:HID_KEY_PROPERTY_CREATE error:&error];
            keyInfo[@"keyExpiryDate"] = [key getProperty:HID_KEY_PROPERTY_EXPIRY error:&error];
            
            id<HIDProtectionPolicy> policy = [key getProtectionPolicy:&error];
            id<HIDPasswordPolicy> pwdPolicy = (id<HIDPasswordPolicy>)policy;
            if(policy != nil){
                keyInfo[@"keyPolicyType"] = [NSString stringWithFormat:@"%u", [policy policyType]];
                NSString *policyIdString;
                if ([policy.policyId ID] && [[policy.policyId ID] isKindOfClass:[NSString class]]) {
                    policyIdString = [policy.policyId ID];  // Directly use if it's NSString
                } else {
                    policyIdString = [NSString stringWithFormat:@"%@", [policy.policyId ID]];  // Force conversion to NSString
                }
                keyInfo[@"keyProtectionPolicyId"] = policyIdString;
                keyInfo[@"keyLockPolicyType"] = [NSString stringWithFormat:@"%u", [[policy lockPolicy] lockType]];
                if([policy policyType] == HIDPolicyTypePassword || [policy policyType] == HIDPolicyTypeBioPassword){
                    keyInfo[@"keyCurrentAgent"] = [NSString stringWithFormat:@"%u", [pwdPolicy currentAge]];
                }
            }else {
                keyInfo[@"keyPolicyType"] = [NSNull null];
                keyInfo[@"keyProtectionPolicyId"] = [NSNull null];
                keyInfo[@"keyLockPolicyType"] = [NSNull null];
                keyInfo[@"keyCurrentAgent"] = [NSNull null];
            }
            
            [keyList addObject:keyInfo];
        }
    }
    
    result[@"containerId"] = [NSString stringWithFormat:@"%ld", (long)[pContainer getId]];
    result[@"containerUserId"] = [pContainer getUserId];
    result[@"totalKeys"] = @(keyList.count);
    result[@"keys"] = keyList;
    NSLog(@"Contents of keyInfo: %@", result);
    
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (!jsonData){
        NSLog(@"ApproveSDKWrapper ---> HID:getKeyList: JSON Error: %@", jsonError.localizedDescription);
        return nil;
    }

    NSString *resultInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"ApproveSDKWrapper ---> HID:getKeyList Key List: %@", resultInfo);
    
    return resultInfo;
}

/**
* This public method performs a direct client signature operation using the
* specified transaction message and key mode.
*
* @param txMessage   - The transaction message to sign.
* @param keyMode     - The key mode to use (e.g., "pkp", "pkip", "skp").
* @param generateCallback - The callback function to execute after signing.
*/
-(void)directClientSignature: (NSString *)txMessage withKeyMode:(NSString *)keyMode withGenerateCallback:(JSValue *)generateCallback {
    
    self.transactionMonitor = [[TransactionMonitor alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature HID In directClientSignature");
        NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Transaction Message: %@", txMessage);
        NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Key Mode: %@", keyMode); //keyMode can be "pkp","pkip","skp".
        
        NSString *keyLabel = @"";
        NSError *error;
        
        if (keyMode == nil || [keyMode length] == 0) {
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Key Mode is empty");
            [self executeGenericCallback:generateCallback withParams:@[@"Key Mode is null or empty"]];
            return;
        }else{
            if([keyMode.lowercaseString isEqualToString:PUSH_KEY_PUBLIC_LABEL_NAME]){
                keyLabel = PUSH_KEY_PUBLIC_LABEL;
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Key Label set to %@", keyLabel);
            }else if([keyMode.lowercaseString isEqualToString:PUSH_KEY_IDP_PUBLIC_LABEL_NAME]){
                keyLabel = PUSH_KEY_IDP_PUBLIC_LABEL;
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Key Label set to %@", keyLabel);
            }else if([keyMode.lowercaseString isEqualToString:SIGN_KEY_PUBLIC_LABEL_NAME]){
                keyLabel = SIGN_KEY_PUBLIC_LABEL;
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Key Label set to %@", keyLabel);
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Invalid Key Mode: %@", keyMode);
                [self executeGenericCallback:generateCallback withParams:@[@"Invalid Key Mode"]];
                return;
            }
        }
        
        id<HIDContainer> pContainer = [self getSingleUserContainer];
        
        NSArray* keys = [pContainer findKeys:nil error:&error];
        
        if (pContainer == nil) {
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature No Containers Found");
            [self executeGenericCallback:generateCallback withParams:@[@"No Container found"]];
            return;
        }
        
        
        if(keys.count == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature No Keys Found");
            [self executeGenericCallback:generateCallback withParams:@[@"No Keys found in the container"]];
            return;
        }
        
        id<HIDKey> pKey = keys[0];
        
        if(keys.count > 1){
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature More than one key found, checking for label match");
            for (id<HIDKey> key in keys) {
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature - Key: %@", key);
                
                NSString *keyCheck = [key getProperty:HID_KEY_PROPERTY_LABEL error:nil];
                
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature - Key Label: %@", keyCheck);
                
                if(keyCheck != nil && [keyCheck caseInsensitiveCompare:keyLabel] == NSOrderedSame){
                    pKey = key;
                    NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature - Found Matched Key: %@", pKey);
                    break;
                }
            }
        }
        
        NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Key Found: %@", pKey);
        
        NSString *keyId = [NSString stringWithFormat:@"%@",[pKey getId]];
        
        NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Key ID: %@", keyId);
        
        if(txMessage == nil || [txMessage length] == 0){
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Transaction Message is empty");
            [self executeGenericCallback:generateCallback withParams:@[@"Transaction Message is empty"]];
            return;
        }else{
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Transaction Message: %@", txMessage);
            
            id<HIDTransaction> transaction = [pContainer generateAuthenticationRequest:txMessage withKey:[pKey getId] error:&error];
            
            [self.transactionMonitor setTransaction:transaction];
            
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Generated Transaction");
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Transaction ID: %@", [transaction getPayload:&error]);
            
            NSMutableDictionary *transactionInfo = [NSMutableDictionary dictionary];
            transactionInfo[@"transaction"] = [NSString stringWithFormat:@"%@", transaction];
            transactionInfo[@"transactionPayload"] = [transaction getPayload:&error];
            transactionInfo[@"keyLabel"] = [pKey getProperty:HID_KEY_PROPERTY_LABEL error:&error];
            transactionInfo[@"keyId"] = keyId;
            
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Transaction generated successfully for key: %@ with Id: %@", keyMode, keyId);
            NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Transaction Info: %@", transactionInfo);
            
            [self executeGenericCallback:generateCallback withParams:@[@"success", transactionInfo]];
            
            
        }
        
        
        if(error != nil){
            int errorCode = (int)[error code];
            if (errorCode == 0){
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Internal Exception while finding keys %@", [error localizedDescription]);
                [self executeGenericCallback:(generateCallback) withParams:(@[INTERNAL_EXCEPTION_NAME,[error localizedDescription]])];
            }else if(errorCode == 3){
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Invalid Argument Exception while finding keys %@", [error localizedDescription]);
                [self executeGenericCallback:(generateCallback) withParams:(@[HID_INVALID_ARGUMENT_EXCEPTION_NAME,[error localizedDescription]])];
            }else if(errorCode == 304){
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Server Unsupported Operation Exception while finding keys %@", [error localizedDescription]);
                [self executeGenericCallback:(generateCallback) withParams:(@[HID_SERVER_UNSUPPORTED_OPERATION_NAME,[error localizedDescription]])];
            }else{
                NSLog(@"ApproveSDKWrapper ---> HID:directClientSignature Error while finding keys %@", [error localizedDescription]);
                [self executeGenericCallback:generateCallback withParams:(@[@"error", [error localizedDescription]])];
            }
        }
    });
}

/**
* This public method is used to sign the request for the request generated in directClientSignature method.
*
* @param consensus - status for the transaction (e.g., "approve").
* @param password - password for the transaction, if required.
* @param isBiometricEnabled - boolean indicating if biometric authentication is enabled.
* @param dcsCallback - The callback function to execute after signing with status.
*/
- (void)directClientSignatureWithStatus:(NSString *)consensus
                           withPassword:(NSString *)password
                  withBiometricEnabled:(BOOL)isBiometricEnabled
                       withDCSCallback:(JSValue *)dcsCallback {

    if (self.transactionMonitor == nil) {
        [self executeGenericCallback:dcsCallback withParams:@[@"MonitorNotInitialized", @"Transaction monitor not available"]];
        return;
    }

    // Set user input
    [self.transactionMonitor setUserInputWithConsensus:consensus
                                               password:password
                                      biometricEnabled:isBiometricEnabled];

    NSLog(@"ApproveSDKWrapper ---> HID:directClientSignatureWithStatus Consensus: %@, Password: %@, Biometric Enabled: %d",
          consensus, password, isBiometricEnabled);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<HIDTransaction> transaction = [self.transactionMonitor getTransaction];
        id<HIDContainer> container = [self getSingleUserContainer];

        if (!transaction) {
            [self executeGenericCallback:dcsCallback withParams:@[@"TransactionNotFound", @"No transaction available"]];
            return;
        }

        NSError *error = nil;
        BOOL result = NO;

        if (isBiometricEnabled) {
            result = [transaction setStatus:consensus
                       withSigningPassword:nil
                       withSessionPassword:nil
                               withParams:nil
                                    error:&error];
        } else {
            result = [transaction setStatus:consensus
                       withSigningPassword:password
                       withSessionPassword:nil
                               withParams:nil
                                    error:&error];
        }

        if (error) {
            [self handleSetStatusError:error callback:dcsCallback];
        } else {
            [self sendTransactionStatusResult:transaction result:result dcsCallback:dcsCallback];
        }
    });
}

/**
* This private method sends the transaction status result to the callback.
*
* @param transaction - The transaction object containing the transaction.
* @param result      - The result of the transaction status update.
* @param dcsCallback - The callback function to execute with the result.
*/
- (void)sendTransactionStatusResult:(id<HIDTransaction>)transaction
                              result:(BOOL)result
                        dcsCallback:(JSValue *)dcsCallback {

    NSError *error = nil;
    NSMutableDictionary *resultJson = [NSMutableDictionary dictionary];
    resultJson[@"status"] = result ? @"success" : @"failure";
    resultJson[@"requestId"] = [transaction getRequestId:&error] ?: @"";
    resultJson[@"idToken"] = [transaction getIdToken:&error] ?: @"";

    if (error) {
        [self handleSetStatusError:error callback:dcsCallback];
        return;
    }

    [self executeGenericCallback:dcsCallback withParams:@[@"TransactionStatus", resultJson]];
}

/**
* This private method handles exceptions that may occur during the direct client signature set status operation.
*
* @param e - The error that occurred.
* @param callback - The callback function to execute with the error details.
*/
- (void)handleSetStatusError:(NSError *)error callback:(JSValue *)callback {
    int errorCode = (int)[error code];
    NSString *errorMessage = [error localizedDescription];

    NSLog(@"ApproveSDKWrapper ---> HID:invokePasswordAuthNotification Error While Updating the notification status %@", errorMessage);

    switch (errorCode) {
        case 100:
            [self executeGenericCallback:(callback) withParams:@[AUTHENTICATION_EXCEPTION_NAME, errorMessage]];
            break;
        case 1000:
            [self executeGenericCallback:(callback) withParams:@[TRANSACTION_EXPIRED_EXCEPTION_NAME, errorMessage]];
            break;
        case 1002:
            [self executeGenericCallback:(callback) withParams:@[HID_TRANSACTION_CANCELED_EXCEPTION_NAME, errorMessage]];
            break;
        case 1003:
            [self executeGenericCallback:(callback) withParams:@[HID_TRANSACTION_SIGNED_EXCEPTION_NAME, errorMessage]];
            break;
        case 102:
            [self executeGenericCallback:(callback) withParams:@[HID_CREDENTIALS_EXPIRED_EXCEPTION_NAME, errorMessage]];
            break;
        case 0:
            [self executeGenericCallback:(callback) withParams:@[INTERNAL_EXCEPTION_NAME, errorMessage]];
            break;
        case 103:
            [self executeGenericCallback:(callback) withParams:@[PASSWORD_EXPIRED_EXCEPTION_NAME, errorMessage]];
            break;
        case 3:
            [self executeGenericCallback:(callback) withParams:@[HID_INVALID_ARGUMENT_EXCEPTION_NAME, errorMessage]];
            break;
        case 300:
            [self executeGenericCallback:(callback) withParams:@[SERVER_AUTH_EXCEPTION_NAME, errorMessage]];
            break;
        case 305:
            [self executeGenericCallback:(callback) withParams:@[SERVER_OPERATION_FAILED_EXCEPTION_NAME, errorMessage]];
            break;
        case 304:
            [self executeGenericCallback:(callback) withParams:@[HID_SERVER_UNSUPPORTED_OPERATION_NAME, errorMessage]];
            break;
        case 105:
            [self executeGenericCallback:(callback) withParams:@[PASSWORD_REQUIRED_EXCEPTION_NAME, errorMessage]];
            break;
        default:
            [self executeGenericCallback:(callback) withParams:@[@"Exception", errorMessage]];
            break;
    }
}



@end

