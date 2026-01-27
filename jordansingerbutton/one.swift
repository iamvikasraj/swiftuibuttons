//
//  bug.swift
//  jordansingerbutton
//
//  Created by Vikas Raj on 17/11/25.
//

import SwiftUI

struct one: View {
    var body: some View {
        Button {
            
            }
         label: {
            ArrowButton(rotation: .degrees(0), imageName: "jd")
                
        }
         .buttonStyle(.plain)
         
    }
}

#Preview {
    ZStack{
        Color.gray.opacity(0.2)
        one()
    }
    .ignoresSafeArea()
    

}
