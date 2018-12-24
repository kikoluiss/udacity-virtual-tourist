//
//  GCDBlackBox.swift
//  Virtual Tourist
//
//  Created by Kiko Santos on 17/12/18.
//  Copyright © 2018 Kiko Santos. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
