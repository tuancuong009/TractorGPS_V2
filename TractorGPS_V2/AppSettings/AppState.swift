//
//  AppState.swift
//  dummytractor
//
//  Created by MacBook on 19/12/2024.
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var hasAccess: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Lắng nghe thay đổi từ PremiumManager.shared.isPremium
        Task {
            await PremiumManager.shared.$isPremium
                .receive(on: DispatchQueue.main)
                .assign(to: \.hasAccess, on: self)
                .store(in: &cancellables)
        }
        
        Task {
            await PremiumManager.shared.checkPremiumStatus()
        }
       
        
        // Check lại trạng thái khi app khởi động
       
    }
}
