//
//  PackageView.swift
//  Kobra
//
//  Created by Spencer SLiffe on 3/7/23.
//

import SwiftUI
struct PackageView: View {
    @ObservedObject var viewModel = PackageViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                VStack {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        }
    }
}

struct PackageView_Previews: PreviewProvider {
    static var previews: some View {
        PackageView()
    }
}




