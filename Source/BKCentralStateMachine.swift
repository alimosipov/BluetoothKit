//
//  BluetoothKit
//
//  Copyright (c) 2015 Rasmus Taulborg Hummelmose - https://github.com/rasmusth
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

internal class BKCentralStateMachine {

    // MARK: Enums

    internal enum Error: ErrorType {
        case Transitioning(currentState: State, validStates: [State])
    }

    internal enum State {
        case Initialized, Starting, Unavailable(cause: BKUnavailabilityCause), Available, Scanning
    }

    internal enum Event {
        case Start, SetUnavailable(cause: BKUnavailabilityCause), SetAvailable, Scan, Connect, Stop
    }

    // MARK: Properties

    internal var state: State

    // MARK: Initialization

    internal init() {
        self.state = .Initialized
    }

    // MARK: Functions

    internal func handleEvent(event: Event) throws {
        switch event {
        case .Start:
            try handleStartEvent(event)
        case .SetAvailable:
            try handleSetAvailableEvent(event)
        case let .SetUnavailable(newCause):
            try handleSetUnavailableEvent(event, cause: newCause)
        case .Scan:
            try handleScanEvent(event)
        case .Connect:
            try handleConnectEvent(event)
        case .Stop:
            try handleStopEvent(event)
        }
    }

    private func handleStartEvent(event: Event) throws {
        switch state {
        case .Initialized:
            state = .Starting
        default:
            throw Error.Transitioning(currentState: state, validStates: [ .Initialized ])
        }
    }

    private func handleSetAvailableEvent(event: Event) throws {
        switch state {
        case .Initialized:
            throw Error.Transitioning(currentState: state, validStates: [ .Starting, .Available, .Unavailable(cause: nil) ])
        default:
            state = .Available
        }
    }

    private func handleSetUnavailableEvent(event: Event, cause: BKUnavailabilityCause) throws {
        switch state {
        case .Initialized:
            throw Error.Transitioning(currentState: state, validStates: [ .Starting, .Available, .Unavailable(cause: nil) ])
        default:
            state = .Unavailable(cause: cause)
        }
    }

    private func handleScanEvent(event: Event) throws {
        switch state {
        case .Available:
            state = .Scanning
        default:
            throw Error.Transitioning(currentState: state, validStates: [ .Available ])
        }
    }

    private func handleConnectEvent(event: Event) throws {
        switch state {
        case .Available, .Scanning:
            break
        default:
            throw Error.Transitioning(currentState: state, validStates: [ .Available, .Scanning ])
        }
    }

    private func handleStopEvent(event: Event) throws {
        switch state {
        case .Initialized:
            throw Error.Transitioning(currentState: state, validStates: [ .Starting, .Unavailable(cause: nil), .Available, .Scanning ])
        default:
            state = .Initialized
        }
    }

}
