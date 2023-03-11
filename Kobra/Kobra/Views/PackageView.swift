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
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    List(viewModel.packages, id: \.id) { package in
                        PackageCell(package: package)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .navigationBarTitle("")
        }
    }
}



struct PackageView_Previews: PreviewProvider {
    static var previews: some View {
        PackageView()
    }
}
