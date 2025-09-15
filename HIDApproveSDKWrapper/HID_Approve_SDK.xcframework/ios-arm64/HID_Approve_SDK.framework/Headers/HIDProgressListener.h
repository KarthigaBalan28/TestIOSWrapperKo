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
#import "HIDProtectionPolicy.h"

/**
 * \file HIDProgressListener.h
 * \brief Listener delegate to report status information or receive password request events.
 *
 */

/**
 * \brief Enumeration indicating the outcome of the processing
 * Represents the HIDEventResult result possibilities of the client-side HIDProgressListener event processing.
 */
enum HIDEventResultCode {Continue = 0, Cancel = 1, Abort = 2};

/**
 * \brief Represents the result of HIDProgressListener client-side event processing
 */
@interface HIDEventResult : NSObject
/**
 * \brief Event Result Code
 */
@property enum HIDEventResultCode code;
/**
 * \brief Initialize instance with HIDEventResultCode value
 * \param code HIDEventResultCode value
 * \return HIDEventResult instance.
 */
- (instancetype)initWithCode:(enum HIDEventResultCode)code;
@end

/**
 * \brief Represents the requested password information for a HIDPasswordPromptEvent.
 * \see HIDProgressListener
 */
@interface HIDPasswordPromptResult : HIDEventResult
/**
 * \brief Password corresponding to HIDPasswordPromptEvent
 */
@property(strong) NSString* password;
/**
 * \brief Initialize instance with HIDEventResultCode value
 * \param code HIDEventResultCode value
 * \param pwd Password value
 * \return HIDPasswordPromptResult instance.
 */
- (instancetype)initWithCode:(enum HIDEventResultCode)code andPassword:(NSString*) pwd;
@end

/**
 * \brief Base class for a synchronization event sent from the server.
 * <p>The event identifier may be used to determine the expected event data.</p>
 */
@protocol HIDEvent
/**
 * \brief Returns the type identifier of this event.
 * \return The type identifier of this event.
 */
@property(readonly) NSString *ID;
/**
 * \brief Returns the metadata parameters.
 * \return The event metadata parameters.
 * <p>
 * A HIDProgressEvent may contain the following HIDParameter ids:
 * <ul>
 * <li>#HID_PARAM_PROGRESSEVENT_MESSAGE: server synchronization progress event message</li>
 * <li>#HID_PARAM_PROGRESSEVENT_PERCENT: server synchronization progress percentage</li>
 * <li>#HID_PARAM_PROGRESSEVENT_LEVEL: server event importance (INFO, ERROR)</li>
 * </ul>
 * <p>
 * A HIDPasswordPromptEvent may contain the following HIDParameter ids:
 * <ul>
 * <li>#HID_PARAM_PASSWORD_PROGRESS_EVENT_KEY_LABEL: Provides a key label hint concerning the requested password</li>
 * <li>#HID_PARAM_PASSWORD_PROGRESS_EVENT_KEY_USAGE: Provides a key usage hint concerning the requested password</li>
 * <li>#HID_PARAM_PASSWORD_PROGRESS_EVENT_TYPE: Provides key protection policy type hint concerning the requested password (#HID_PARAM_PASSWORD_PROGRESS_EVENT_TYPE_CONTAINER or #HID_PARAM_PASSWORD_PROGRESS_EVENT_TYPE_KEY)</li>
 * </ul>
 * </p>
 */
@property(readonly) NSArray *parameters;

@end


/**
 * \brief A synchronization progress event sent from the server.
 * <p>The event identifier may be used to determine the expected event data.</p>
 */
@interface HIDProgressEvent:NSObject<HIDEvent>
@end

/**
 * \brief A synchronization password request event sent from the server.
 * <p>The event identifier may be used to determine the expected event data.</p>
 */
@interface HIDPasswordPromptEvent:NSObject<HIDEvent>

/**
 * \brief The password policy instance
 */
@property(readonly) id<HIDPasswordPolicy> passwordPolicy;

/**
 * \brief Indicates whether the password is required for initialization or for verification
 */
@property(readonly) Boolean passwordInitialization;

/**
 * \brief Contains the date/time at which the operation expires
 */
@property(readonly) NSDate* expiryDate;
@end


/**
 * \brief This interface provides an integration point for receiving status information
 * sent from the server during the synchronization.
 * <p>This interface should be implemented by the integration layer
 * to process synchronization events in an implementation-specific manner.</p>
 */
@protocol HIDProgressListener

/**
 * \brief Invoked when events are dispatched from the server.
 * \param event A synchronization event received.
 * <p>If a listener implementation is passed to a synchronization, this
 * method is invoked when events are dispatched from the
 * server.</p>
 *\return it returns an event results object
 */
- (HIDEventResult*)onEventReceived:(id<HIDEvent>)event;

@end
