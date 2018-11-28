//
//  Constants.swift
//  ToDoList
//
//  Created by Apple on 11/27/18.
//  Copyright © 2018 Faris. All rights reserved.
//

import Foundation
struct Constants {
    static let  appName = "To Do"
    static let toDoTitleTag = 100
    static let toDoFinishButtonTag = 200
    static let googleClientID = "442169983096-lc2u9afhl64s57aic1r3vlsff1sfi2c0.apps.googleusercontent.com"
    struct ColorConstants {
        
    }
    struct GoogleSingInStatus {
        static let success = "success"
        static let failure = "failed"
        static let disconnected = "disconnected"
    }
    struct NSNotificationName {
        static let GoogleAuthNotification = "ToggleAuthUINotification"
    }
    struct userDefaultsKey {
        static let isLoginSkipped = "isLoginSkipped"
    }
    struct ErrorMessageConstants {
        static let emptyToDoList = "To do list is empty. Add a new to do task by tapping '+' button below..."
        static let error = "Some error occured..."
        static let taskDetailsEmpty = "Pleaase enter any To Do task..."
    }
}
