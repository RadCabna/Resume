//
//  OBBG.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

struct OBBG: View {
    @AppStorage("backgroundNumber") var backgroundNumber = 1
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let isLandscape = width > height
            if isLandscape {
                Image(whatBG())
                    .resizable()
                    .frame(width: height*1.2, height: width*1.2)
                    .rotationEffect(Angle(degrees: 90))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            } else {
                Image(whatBG())
                    .resizable()
                    .ignoresSafeArea()
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
            }
        }
    }
    
    func whatBG() -> String{
        switch backgroundNumber {
        case 1:
            return "background1"
        case 2:
            return "background2"
        case 3:
            return "background3"
        case 4:
            return "background4"
        case 5:
            return "background5"
        case 6:
            return "background6"
        default:
            return "background1"
        }
    }
}

#Preview {
    OBBG()
}
