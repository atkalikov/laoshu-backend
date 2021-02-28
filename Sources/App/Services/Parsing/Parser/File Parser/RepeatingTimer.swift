//
//  RepeatingTimer.swift
//  Common
//
//  Created by Anton Tkalikov on 31.05.2020.
//  Copyright © 2020 Anton Tkalikov. All rights reserved.
//

import Foundation

public class RepeatingTimer {
    private let timeInterval: TimeInterval
    private var eventHandler: (() -> Void)?
    private var state: State = .suspended
    
    private enum State {
        case suspended
        case resumed
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        timer.setEventHandler(handler: { [weak self] in self?.eventHandler?() })
        return timer
    }()
    
    public init(timeInterval: TimeInterval, action: (() -> Void)?) {
        self.timeInterval = timeInterval
        self.eventHandler = action
    }
    
    public func resume() {
        if state == .resumed { return }
        state = .resumed
        timer.resume()
    }
    
    public func suspend() {
        if state == .suspended { return }
        state = .suspended
        timer.suspend()
    }
}
