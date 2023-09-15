//
//  SectionHeader.swift
//  talos
//
//  Created by Tyler Torres on 9/14/23.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(title: "Title")
    }
}
