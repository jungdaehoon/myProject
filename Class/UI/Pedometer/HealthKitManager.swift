//
//  HealthKitManager.swift
//  cereal
//
//  Created by 아프로 on 2021/11/09.
//  Copyright © 2021 srkang. All rights reserved.
//

import UIKit
import HealthKit

class HealthKitManager {
    
    //    static let shared = HealthKitManager()
    
    static let healthStore = HKHealthStore()
    static var isAuthorized: Bool = false
    var mPeometerCount: Int = 0
    
    private init()
    {}
    
    
    static func authStatus() -> String
    {
        let authorizationStatus = healthStore.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!)
        if authorizationStatus == HKAuthorizationStatus.sharingAuthorized {
            return "authorized"
        } else if authorizationStatus == HKAuthorizationStatus.sharingDenied {
            return "denied"
        } else {
            return "unknown"
        }
    }
    
    
    static func healthCheck(completion: @escaping (Bool) -> Void)
    {
        let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)! ]
        
        HealthKitManager.healthStore.requestAuthorization(toShare: nil, read: healthKitTypes, completion: { (userWasShownPermissionView, error) in
            
            // Determine if the user saw the permission view
            if (userWasShownPermissionView) {
                Slog("User was shown permission view")
                
                // ** IMPORTANT
                // Check for access to your HealthKit Type(s). This is an example of using BodyMass.
//                if (HealthKitManager.healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!) == .sharingAuthorized) {
//                    Slog("Permission Granted to Access BodyMass")
//                    HealthKitManager.isAuthorized = true
//
//                    completion(true)
//
//                } else {
//                    Slog("Permission Denied to Access BodyMass")
//                    HealthKitManager.isAuthorized = false
//                    completion(false)
//                }
                
                HealthKitManager.isAuthorized = true
                completion(true)
                
            } else {
                Slog("User was not shown permission view")
                
                // An error occurred
                if let e = error {
                    Slog(e)
                    completion(false)
                }
            }
        })
    }
    
    
    
    
    static func getTodaysSteps(completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        HealthKitManager.healthStore.execute(query)
    }
    
    
    static func getSpecificDaysStepsCount(forSpecificDate:Date, completion: @escaping (Double) -> Void) {
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let (start, end) = self.getWholeDate(date: forSpecificDate)

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }

        HealthKitManager.healthStore.execute(query)
    
    }
    
    static func getWholeDate(date : Date) -> (startDate:Date, endDate: Date) {
        var startDate = date
        var length = TimeInterval()
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate,endDate)
    }
 
    
    
}
